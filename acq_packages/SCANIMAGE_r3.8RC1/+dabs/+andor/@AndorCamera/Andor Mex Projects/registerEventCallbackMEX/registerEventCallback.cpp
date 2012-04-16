// registerEventCallbackMEX.cpp : Defines the exported functions for the DLL application.
//

//#include "AsyncMex.h"
#include "stdafx.h"


//Matlab signature
//status = registerEventCallbackMEX(cameraObj,callbackFunc)
//	cameraObj: Handle to Devices.Andor.AndorCamera object for which event is being registered/unregistered
//	callbackFunc: A function handle to callback to register, or an empty array, indicating that event should be unregistered.


//DEFINES
#define MAXNUMOBJS 100
#define MAXFIELDNAMELENGTH 64
#define MAXCALLBACKNAMELENGTH 256

//#define REGISTERANDOREVENT_DEBUG

#define AsyncMex_errorMsg(...) printf(__VA_ARGS__)
#ifdef REGISTERANDOREVENT_DEBUG
   #pragma message("REGISTERANDOREVENT_DEBUG - Compiling in debug mode.")
   #define RegAndorEvent_DebugMsg(...) printf(__VA_ARGS__)
#else
   #define RegAndorEvent_DebugMsg(...)
#endif




//Structure array, one element per camera with registered event
typedef struct{
	long	cameraHandle;
	mxArray *cameraObjHandle;
	mxArray *callbackFuncHandle;

	HANDLE	cameraThread;
	DWORD	cameraThreadID;

	HANDLE	cameraEvent;
	HANDLE	cameraApplicationEvent;

	AsyncMex *hAsyncMex;

	bool	active;

} CallbackData; 

AsyncMex *hAsyncMexArray[MAXNUMOBJS];
int numRegisteredObjects;
CallbackData *callbackDataRecords[MAXNUMOBJS];
mxArray *eventArray; //Placeholder for empty array to pass as event argument to callback

char AsyncMexInfo[1024];


//Helper Functions

//Clears registered callback -- first the associated thread, and then the callback data record
void clearRegisteredCallback(CallbackData *cbdata)
{
	//Flag that event trapping is disabled
	cbdata->active = false;

	if (cbdata->cameraApplicationEvent != NULL)
	{
		//Signal to async (event-trapping) thread to shut down
		SetEvent(cbdata->cameraApplicationEvent); //Sends event 
		switch (WaitForSingleObject(cbdata->cameraThread, 2000))
		{
			case WAIT_ABANDONED:
			case WAIT_TIMEOUT:
				MessageBox(NULL,"Failed to process shutdown an asynhchronous event handling thread.",NULL,MB_OK);
			break;
		}
	}

	RegAndorEvent_DebugMsg("Completed shutdown of async event-handling thread function\n");

	////Unbind the event handle from the Andor SDK
	SetCurrentCamera(cbdata->cameraHandle);
	SetDriverEvent(NULL);

	//Clear the mxArray holding the Matlab function handle for this callback record
	if (cbdata->callbackFuncHandle != NULL)
		mxFree(cbdata->callbackFuncHandle);

	//For good measure, clear pointers to no-longer valid callback record data (probably not strictly necessary, but nice to do)
	cbdata->callbackFuncHandle = NULL; 
	cbdata->cameraThread = NULL;
	cbdata->cameraThreadID = NULL;
	cbdata->cameraEvent = NULL;
	cbdata->cameraApplicationEvent = NULL;
	cbdata->active = false;

	return;
}

//MEX Exit function
void cleanUp(void)
{
	for (int i=0; i<numRegisteredObjects; i++)
	{
		clearRegisteredCallback(callbackDataRecords[i]);
		mxFree((void*)callbackDataRecords[i]);

		AsyncMex_destroy(&(hAsyncMexArray[i]));
	}

}

//Matlab callback wrapper function
void callbackWrapper(LPARAM cameraHandle, void *callbackData)
{
	mxArray *mException;
	mxArray *rhs[3];
	CallbackData *cbData = (CallbackData*)callbackData;

	RegAndorEvent_DebugMsg("Reached callback wrapper\n");

	if (cbData->active)
	{		
		//Initialize src/event arguments that will be passed to callback
		rhs[1] = cbData->cameraObjHandle;
		rhs[2] = eventArray;

		rhs[0] = cbData->callbackFuncHandle;
		mException = mexCallMATLABWithTrap(0,NULL,3,rhs,"feval"); //TODO -- pass arguments!
		if (mException)
		{
			char *errorString = (char*)mxCalloc(256,sizeof(char));
			mxGetString(mxGetProperty(mException, 0, "message"),errorString, MAXCALLBACKNAMELENGTH);
			mexPrintf("ERROR in event callback of AndorCamera object: %s\n", errorString);
			mxFree(errorString);
		}

		return;
	}
}



DWORD WINAPI asyncThreadFcn(LPVOID userData)
{
	HANDLE eventArray[2];
	DWORD response; 
	CallbackData *cbData = (CallbackData*)userData;

	eventArray[0] = cbData->cameraApplicationEvent;
	eventArray[1] = cbData->cameraEvent;

	RegAndorEvent_DebugMsg("Entering async event-handling thread function\n");

	while (cbData->active)
	{
		response = WaitForMultipleObjects(2, eventArray, FALSE, INFINITE);

		RegAndorEvent_DebugMsg("Async thread detected event\n");
		switch (response)
		{
			case WAIT_OBJECT_0:	//The application event signals intention to shutdown	
				cbData->active = false;
			break;

			case WAIT_OBJECT_0 + 1: //The camera event has signalled
				RegAndorEvent_DebugMsg("Posting event message pertaining to camera with handle: %d\n", cbData->cameraHandle);
				AsyncMex_postEventMessage(cbData->hAsyncMex, cbData->cameraHandle);
			break;

			//Handle cases where signal object(s) is invalid
			case WAIT_ABANDONED_0:
			case WAIT_ABANDONED_0 + 1:
				MessageBox(NULL,"Asynchronous event handling thread detected an abnormal state and is being terminated.",NULL,MB_OK);
				cbData->active = false;
			break;
		}
	}

	//Clean up the event objects
	SetCurrentCamera(cbData->cameraHandle);
	SetDriverEvent(NULL);
	CloseHandle(cbData->cameraEvent);
	CloseHandle(cbData->cameraApplicationEvent);

	RegAndorEvent_DebugMsg("Exiting async thread function\n");


	return 0;
}




//Gateway routine
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	//Shared vars
	bool registerTF;
	bool newCamera = true;


	//Initialize empty eventArray, if not done so already
	if (eventArray==NULL)
	{
		//mexLock();
		mexAtExit(cleanUp);

		eventArray = mxCreateStructMatrix(0, 0, 0, 0);
		mexMakeArrayPersistent(eventArray);
	}

	//Parse input arguments
	const mxArray *hCamera = prhs[0];
	int cameraHandle = (int) mxGetScalar(mxGetProperty(prhs[0],0,"cameraHandle"));
	
	if ((nrhs < 2) || mxIsEmpty(prhs[1]))
		registerTF = false;
	else
	{
		if ((mxGetClassID(prhs[1]) == mxFUNCTION_CLASS) && mxGetNumberOfElements(prhs[1])==1)
			registerTF = true;
	}
	RegAndorEvent_DebugMsg("Determined registerTF: %d\n",registerTF);


	CallbackData *currCBData;

	//Determine if camera has already been added
	for (int i=0;i<numRegisteredObjects;i++)
	{
		if (callbackDataRecords[i]->cameraHandle == cameraHandle)
		{
			newCamera=false;
			currCBData = callbackDataRecords[i];
			break;
		}			
	}
	RegAndorEvent_DebugMsg("Determined newCamera: %d\n",newCamera);

	if (registerTF)
	{
		//Add new callbackData record if none has been added for this Camera
		if (newCamera)
		{
			currCBData = (CallbackData*)mxCalloc(1,sizeof(CallbackData));	
			mexMakeMemoryPersistent((void*)currCBData); //Need to store the callbackData beyond the MEX call. (Would malloc() accomplish this? might it allow the data to then get deleted with Task? or might this happen anyway?)

			currCBData->cameraHandle = cameraHandle; 

			currCBData->cameraObjHandle = mxDuplicateArray(hCamera); //Store handle to AndorCamera object
			mexMakeArrayPersistent(currCBData->cameraObjHandle);		

			//Create a single hAsynMex 'object' for each registered object (camera)
			RegAndorEvent_DebugMsg("Creating AsyncMEX object for camera with handle: %d\n",cameraHandle);
			hAsyncMexArray[numRegisteredObjects] = AsyncMex_create((AsyncMex_Callback *) &callbackWrapper, (void *)currCBData);
			RegAndorEvent_DebugMsg("Created AsyncMEX object:%d\n",hAsyncMexArray[numRegisteredObjects]);

			currCBData->hAsyncMex = hAsyncMexArray[numRegisteredObjects];

		}
		else if (currCBData->callbackFuncHandle != NULL) //Clear the currently loaded callback (if any)
			clearRegisteredCallback(currCBData);


		//if (hAsyncMex == NULL)
		//{
		//	RegAndorEvent_DebugMsg("Creating AsyncMEX object...\n",registerTF);
		//	hAsyncMex = AsyncMex_create((AsyncMex_Callback *) &callbackWrapper, (void *)currCBData);

		//	RegAndorEvent_DebugMsg("Created AsyncMEX object:%d\n",hAsyncMex);
		//}


		//Pack callbackData structure
		currCBData->active = true;
		currCBData->callbackFuncHandle = mxDuplicateArray(prhs[1]); //Store Matlab function handle
		mexMakeArrayPersistent(currCBData->callbackFuncHandle);


		//TODO: Create signal objects and thread
		currCBData->cameraApplicationEvent = CreateEvent(NULL, FALSE, FALSE, NULL);
		currCBData->cameraEvent = CreateEvent(NULL, FALSE, FALSE, NULL); 

		currCBData->cameraThread = CreateThread(NULL,0, asyncThreadFcn, (LPVOID) currCBData, 0, &(currCBData->cameraThreadID));				
	
		RegAndorEvent_DebugMsg("Created camera application event object: %d\n",currCBData->cameraApplicationEvent);		
		RegAndorEvent_DebugMsg("Created camera event object: %d\n",currCBData->cameraEvent);		
		RegAndorEvent_DebugMsg("Created thread: %d\n",currCBData->cameraThread );		

		//Bind event to Andor API
		SetCurrentCamera(cameraHandle);
		SetDriverEvent(currCBData->cameraEvent);

		//Update count and callbackData record if successful; free allocated memory if not
		if (newCamera)
		{
			//mexPrintf("Calling SetDriverEvent with event: %d\n",currCBData->cameraEvent);
			callbackDataRecords[numRegisteredObjects] = currCBData;
			numRegisteredObjects++;
			RegAndorEvent_DebugMsg("Incremented object count: %d\n",numRegisteredObjects);

		}

	}
	else
	{
		//Unregister callback bound to the current camera
		if (!newCamera)
		{
			RegAndorEvent_DebugMsg("About to unregister callback bound to camera with handle: %d\n",currCBData->cameraHandle);
			clearRegisteredCallback(currCBData);
			RegAndorEvent_DebugMsg("Finished unregistering callback.\n");
		}
	}

}



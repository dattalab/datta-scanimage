// QCamMEX.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"

//Matlab signature
//status = queueFrame(cameraObj,callbackFunc, numBufferedFrames);
//	cameraObj: Handle to Devices.QImaging.QCam object
//  callType: One of {'grabFrame' 'registerFrameAcquiredCallback' 'configureBufferedAcquisition' 'grabFrameBuffered'}
//	callbackFunc: A function handle to callback to register (overrides any previously supplied callback)
//  numBufferedFrames: Number of frames to buffers

//DEFINES
#define MAXNUMOBJS 100
#define MAXFIELDNAMELENGTH 64
#define MAXCALLBACKNAMELENGTH 256

//Structure array, one element per camera with registered event
typedef struct{
	QCam_Handle	cameraHandle;
	mxArray *cameraObjHandle;
	mxArray *callbackFuncHandle; //At moment, only supporting a scalar function handle array

	//mxArray *eventArray; //structure of data to pass to Matlab callback

	int numBufferedFrames; //Number of buffered frames associated with this callback
	mxArray *frameCellArray; //Cell array of frames allocated for this object (camera)
	QCam_Frame **frameArray;

	//HANDLE	cameraThread;
	//DWORD	cameraThreadID;

	//HANDLE	cameraEvent;
	//HANDLE	cameraApplicationEvent;

	//bool	active;

} CallbackData; 



FILE *file;
char timeString[256];

AsyncMex *hAsyncMex;
int numRegisteredObjects;
CallbackData *callbackDataRecords[MAXNUMOBJS];
mxArray *eventArray; 

const char *eventStructFields[] = {"frameData"};
int eventStructNumFields = 1;

//mxArray *eventArray; //Placeholder for array to pass as event argument to callback

//Helper to clear allocated memory associated with callbackDataRecord
void clearRegisteredCallback(CallbackData *cbdata)
{
	
	//Clear the mxArrays holding the Matlab function handle for this callback record
	if (cbdata->callbackFuncHandle != NULL)
		mxFree(cbdata->callbackFuncHandle);

	if (cbdata->cameraObjHandle != NULL) //Do we need to do this?!
		mxFree(cbdata->cameraObjHandle);

	for (int i = 0; i < cbdata->numBufferedFrames; i++)
	{
		mxDestroyArray(mxGetCell(cbdata->frameCellArray, i));
		mxFree(cbdata->frameArray[i]);
	}

	if (cbdata->frameArray != NULL) //Do we need to do this?!
		mxFree(cbdata->frameArray);

	//For good measure, clear pointers to no-longer valid callback record data (probably not strictly necessary, but nice to do)
	//cbdata->callbackFuncHandle = NULL; 
	//cbdata->cameraObjHandle = NULL;
	//cbdata->frameArray = NULL;	
}

//MEX Exit function
void cleanUp(void)
{
	for (int i=0; i<numRegisteredObjects; i++)
	{
		clearRegisteredCallback(callbackDataRecords[i]);
		mxFree((void*)callbackDataRecords[i]);
	}

	AsyncMex_destroy(&hAsyncMex);

	mxDestroyArray(eventArray);
}

//QCam API callback wrapper function
void QCAMAPI qcamCallbackWrapper(void *hAsyncMex, unsigned long frameIndex, QCam_Err errCode, unsigned long flags)
{	
	FILE *file;
	char timeString[256];

	fprintf(1,"Reached Callback wrapper\n");
	file = fopen("C:\\QCamLog.txt","a+");

	//mexPrintf("Reached qcamCallback Wrapper\n");
	//MessageBox(NULL, "Reached callback wrapper", NULL, MB_OK);
	_strtime_s(timeString);
	fprintf(file,"Entered QCam callback at time: %s\n",timeString);
	fclose(file);
	//CallbackData *cbData = (CallbackData *)userPtr;
	AsyncMex_postEventMessage((AsyncMex *)hAsyncMex, frameIndex);
}

//Matlab callback wrapper function
void callbackWrapper(LPARAM frameIndex, void *callbackData)
{
	mxArray *mException;
	mxArray *rhs[3];
	CallbackData *cbData = (CallbackData*)callbackData;

	//RegAndorEvent_DebugMsg("Reached callback wrapper\n");
	mexPrintf("Reached Matlab Callback Wrapper\n");

	//Initialize src/event arguments that will be passed to callback
	mxSetField(eventArray,0,"frameData",mxGetCell(cbData->frameCellArray,frameIndex));

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


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	//double cameraHandle = mxGetScalar(mxGetProperty(prhs[0], 0, "cameraHandle"));

	//mexPrintf("cameraHandle: %f\n", cameraHandle);

	const mxArray *hCamera = prhs[0];
	QCam_Handle *cameraHandlePtr;
	QCam_Handle cameraHandle;

	char serialString[256];
	
	cameraHandlePtr = (QCam_Handle *) mxGetData(mxGetProperty(hCamera,0,"cameraHandle"));
	cameraHandle = *cameraHandlePtr;
	
	QCam_GetSerialString(cameraHandle, serialString,256);
	mexPrintf("Serial String: %s\n", serialString);

	//QCam_AsyncCallback funcPtr = qcamCallbackWrapper;

	int numBufferedFrames;
	//int32 (*funcPtr)(TaskHandle, int32, uInt32, void*) = callbackWrapper;


	//Verify/parse input arguments
	if (nrhs < 3)
		mexErrMsgTxt("All arguments must be supplied");

	if (!((mxGetClassID(prhs[1]) == mxFUNCTION_CLASS) && mxGetNumberOfElements(prhs[1])==1))
		mexErrMsgTxt("The 'callbackFunc' argument must be a function handle");

	if (!mxIsNumeric(prhs[2]))
		mexErrMsgTxt("The 'numBufferedFrames' argument must be a number specifying number of frames to queue.");


	numBufferedFrames = mxGetScalar(prhs[2]);
	
	mexPrintf("Number of Buffered Frames: %d\n",numBufferedFrames);


	//Initialize empty eventArray, if not done so already
	if (eventArray==NULL)
	{
		//mexLock();
		mexAtExit(cleanUp);

		eventArray = mxCreateStructMatrix(1, 1, eventStructNumFields, eventStructFields);
		mexMakeArrayPersistent(eventArray);

	}

	bool newCamera = true; 
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
	
	//Add new callbackData record if none has been added for this Camera
	if (newCamera)
	{
		mexPrintf("Detected new camera! Handle: %d\n",cameraHandle);
		currCBData = (CallbackData*)mxCalloc(1,sizeof(CallbackData));	
		mexMakeMemoryPersistent((void*)currCBData); //Need to store the callbackData beyond the MEX call. (Would malloc() accomplish this? might it allow the data to then get deleted with Task? or might this happen anyway?)

		currCBData->cameraHandle = cameraHandle; 

		currCBData->cameraObjHandle = mxDuplicateArray(hCamera); //Store handle to AndorCamera object
		mexMakeArrayPersistent(currCBData->cameraObjHandle);		
	}
	else if (currCBData->callbackFuncHandle != NULL) //Clear the currently loaded callback (if any)
	{
		mexPrintf("Clearing previous callback record...\n");
		clearRegisteredCallback(currCBData);
	}


	//TODO: Create an hAsyncMex object for /each/ camera object
	if (hAsyncMex == NULL)
	{
		//RegAndorEvent_DebugMsg("Creating AsyncMEX object...\n",registerTF);
		hAsyncMex = AsyncMex_create((AsyncMex_Callback *) &callbackWrapper, (void *)currCBData);

		//RegAndorEvent_DebugMsg("Created AsyncMEX object:%d\n",hAsyncMex);
	}


	//Pack callbackData structure
	currCBData->callbackFuncHandle = mxDuplicateArray(prhs[2]); //Store Matlab function handle
	mexMakeArrayPersistent(currCBData->callbackFuncHandle);

	//currCBData->eventArray = mxCreateStructMatrix(1, 1, eventStructNumFields, eventStructFields);
	//mexMakeArrayPersistent(currCBData->eventArray);

	currCBData->frameCellArray = mxCreateCellMatrix(numBufferedFrames,1);
	mexMakeArrayPersistent(currCBData->frameCellArray);

	//Determine size of frame to allocate
	unsigned long height, width, bitDepth, size;
	unsigned long sizeInBytes; 
	mxArray *newArray;
	QCam_GetInfo(cameraHandle,qinfImageHeight, &height);
	QCam_GetInfo(cameraHandle,qinfImageWidth, &width);
	QCam_GetInfo(cameraHandle,qinfBitDepth, &bitDepth);
	QCam_GetInfo(cameraHandle,qinfImageSize, &sizeInBytes);
	size = height * width * bitDepth;

	mexPrintf("Frame Size -- Height: %d\t Width: %d\t BitDepth: %d\t SizeInBytes: %d\n",height, width,bitDepth,sizeInBytes);

	// allocate the memory for each frame
	currCBData->frameArray = (QCam_Frame **)mxCalloc(numBufferedFrames,sizeof(QCam_Frame *));
	for (int i = 0; i < numBufferedFrames; i++)
	{
		currCBData->frameArray[i] = (QCam_Frame *)mxCalloc(1,sizeof(QCam_Frame));
		mexMakeMemoryPersistent(currCBData->frameArray[i]);

		newArray = mxCreateNumericMatrix(height, width, mxUINT16_CLASS, mxREAL);
		mxSetCell(currCBData->frameCellArray, i, newArray);
		mexMakeArrayPersistent(newArray);

		currCBData->frameArray[i]->pBuffer = mxGetData(newArray);
		currCBData->frameArray[i]->size = sizeInBytes;
	}
	mexMakeMemoryPersistent(currCBData->frameArray);		

	mexPrintf("CallbackData -- frameCellArray: %d\t frameArray: %d\n",&(currCBData->frameCellArray), &(currCBData->frameArray));
	
	//Call through to API
	//QCam_Abort(cameraHandle); //Clears previously queued frames/callbacks
	for (int i = 0; i < numBufferedFrames; i++)
	{	
		QCam_QueueFrame(cameraHandle, currCBData->frameArray[i], qcamCallbackWrapper, qcCallbackDone, NULL, i);
		mexPrintf("Queued a frame (address: %d) to camera (handle: %d)!\n",&(currCBData->frameArray[i]),cameraHandle);
		//MessageBox(NULL, "Queued a frame!", NULL, MB_OK);

		file = fopen("C:\\QCamLog.txt","a+");
		_strtime_s(timeString);
		fprintf(file,"Queued a frame at time: %s\n",timeString);
		fclose(file);	
	}

	//Update count and callbackData record if successful; free allocated memory if not
	if (newCamera)
	{
		//mexPrintf("Calling SetDriverEvent with event: %d\n",currCBData->cameraEvent);
		callbackDataRecords[numRegisteredObjects] = currCBData;
		numRegisteredObjects++;
		//RegAndorEvent_DebugMsg("Incremented object count: %d\n",numRegisteredObjects);
	}


	//else if (strcmpi[1], "configureBufferedAcquisition")
	//{


	//}

	//else if (strcmpi[1], "grabFrameBuffered")
	//{


	//}

	//else if (strcmpi[1], "grabFrame")
	//{


	//}


}
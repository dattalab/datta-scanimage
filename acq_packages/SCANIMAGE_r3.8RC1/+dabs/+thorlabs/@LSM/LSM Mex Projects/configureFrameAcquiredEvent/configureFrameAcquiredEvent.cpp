// configureFrameAcquiredEvent.cpp : Defines the exported functions for the DLL application.

#include "stdafx.h"
#include <windows.h>
#include <process.h>    /* _beginthread, _endthread */
#include "TifWriter.h"
#include <string>



// TODO: Review if logDataToDisk scanner data var is actually needed
// TODO: Review logFileParameterChangeLock usage -- is it optimally narrow etc? Right now, bulk of configLogFile() and loggingThreadFcn() must run atomically between context switches. 
// TODO: Review use/non-use of Sleep() and/or thread priorities -- at moment relying on Windows scheduling. Ideally we might have some way to prioiritize from highest-to-lowest: 1) Async frame copy thread (which cannot miss a frame) 2) Matlab MEX thread (which sometimes signals logging thread) 3) Logging thread


// TODO: Add multiple scanner support
// TODO: Ensure SelectCamera() gets called, when it's needed (need some static variable for last device ID selected to avoid unneeded calls)


#define MAXNUMOBJS 4
#define MAXFIELDNAMELENGTH 64
#define MAXCALLBACKNAMELENGTH 256
#define RETURNED_IMAGE_DATATYPE mxUINT16_CLASS
#define LOCK_TYPE HANDLE
#define MAXSCANNERID 4096
#define MAXFILENAMESIZE 256

//#define DEBUG_CONSOLE

#ifdef DEBUG_CONSOLE
	#define DebugMsg(...) _cprintf(__VA_ARGS__)
#else
	#define DebugMsg(...) 
#endif

/*
#define REGISTERLSMEVENT_DEBUG
#define REGISTERLSMEVENT_DEBUG_L2
#define AsyncMex_errorMsg(...) // printf(__VA_ARGS__)

#ifdef REGISTERLSMEVENT_DEBUG
   #pragma message("REGISTERANDOREVENT_DEBUG - Compiling in debug mode.")
// standard debug messages
// NOTE: DO NOT USE printf() here - it is redefined as mexPrintf and will cause crashes! (if used from the async thread)
#define RegLSMEvent_DebugMsg(...) if(debugMessagesFlag && errorFile != NULL)  { fprintf(errorFile, __VA_ARGS__); fflush(errorFile); }
#else
   #define RegLSMEvent_DebugMsg(...)
#endif

#ifdef REGISTERLSMEVENT_DEBUG_L2
// higher level debug messages (for CopyAcquistion/getdata events)
	#define RegLSMEvent_L2_DebugMsg(...) if(debugMessagesFlag && errorFile != NULL)  { fprintf(errorFile, __VA_ARGS__); fflush(errorFile); }
#else
	#define RegLSMEvent_L2_DebugMsg(...)
#endif
*/

const long DEFAULT_BYTES_PER_PIXEL = 2;
const long DEFAULT_NUM_CHANNELS = 3;
const long DEFAULT_IMAGE_HEIGHT = 512;
const long DEFAULT_IMAGE_WIDTH = 512;
const char *DEFAULT_LSM_FILENAME = "lsm_data";
//const char *ERROR_FILE_NAME = "c:\\lsm_mex_errors";


//Structure array, one element per scanner with registered event
typedef struct{
	int	scannerID;
	mxArray *scannerObjHandle;
	mxArray *callbackFuncHandle;

	HANDLE	scannerThread;
	unsigned int scannerThreadID;

	HANDLE	loggerThread;
	unsigned int loggerThreadID;

	HANDLE	scannerFrameEvent; //Frame acquired event
	HANDLE	scannerStartEvent; //External trigger
	HANDLE	scannerKillEvent;

	AsyncMex *hAsyncMex;

	int imageHeight;
	int imageWidth;
	int bytesPerPixel;
	int numChannels;
	int numChannelsActive;
	int frameSize;

	// dimensions of the data in the following format:
	// image y, image x, channel, frame
	mwSize arrayDims[4];
	
	// the circular data queue that holds incoming frames that are copied from the single frame bufffer 
	// to be written to disk or acquired from a MATLAB getdata call
	int circDataQueueSize; //applies to both getdata and logging queues
	int qBegin;
	int qSize;

	int qLogBegin; //for logging thread queue
	int qLogSize;  //for logging thread queue

	LOCK_TYPE qVarLock;
	int queueFullFlag;
	LOCK_TYPE qLogVarLock; //for logging thread queue
	int queueLogFullFlag; //for logging thread queue

	// state for disk-logging
	TifWriter *tifWriter;
	char *fileModeStr;
	char *fileName;
	char *headerString;
	bool logDataToDisk;
	bool diskLogOverFlowFlag;

	// this is necessary to prevent race condition when configLogFile is called while 
	// the asynch thread is opening or closing the old log file
	LOCK_TYPE logFileParameterChangeLock;
	
	int frameCount; // the frame count since the start of the acquisition

	int droppedFramesSinceLastAcquired; 
	int droppedFramesTotal;
	int droppedLogFramesSinceLastAcquired;
	int droppedLogFramesTotal;

	// if true, then data is acquired from device and saved to disk or added to queue to be grabbed by MATLAB 
	bool acquireData; //flag which enables/disables acquisition thread (thread remains active on being disabled)
	bool loggingData; //flag which enables/disables logging thread (thread exits after being disabled)	 
	
	int newLogFileSignal; // Value > 0 signals to start new log file; value signifies the frame count at which new file should start
	int loggingFrameCount;  //number of frames logged since start of acquisition
	bool loggingFrameSignalError; //Flag indicating if ever a frame was logged ahead of when a new file was to be started
	int loggingAverageFactor; //number of frames to average in logging stream -- data size reduced by this factor

	char *circDataQueue;
	char *loggingDataQueue;
	
	char *singleFrameBuffer; // a single frame buffer used to hold the currently aquiring frame from the LSM
	double *averagingBuffer; // buffer used for frame averaging computation
	void *averagingResultBuffer; // buffer used for result of frame averaging computation

} ScannerData; 

// int numRegisteredObjects;  
//AsyncMex *hAsyncMexArray[MAXNUMOBJS];

bool debugMessagesFlag = true;
bool firstCall = true;  // this remains true until MEX function has been called

#define CALLBACK_EVENT_ARRAY_NUM_STRUCTS 1
#define CALLBACK_EVENT_ARRAY_NUM_FIELDS 6
const mwSize CALLBACK_EVENT_ARRAY_DIM[2] = {1, CALLBACK_EVENT_ARRAY_NUM_STRUCTS };
const char *CALLBACK_EVENT_ARRAY_FIELD_NAMES[] = {"framesAvailable", "droppedFramesLast", "droppedFramesTotal", "droppedLogFramesTotal", "droppedLogFramesLast", "frameCount"};

// these must be 'top level' because they must be set in callback and we cannot create arrays asynchronously with MATLAB thread
mxArray *callbackEventArray;
mxArray *framesAvailableArray;
mxArray *droppedFramesLastArray;
mxArray *droppedFramesTotalArray;
mxArray *droppedLogFramesLastArray;
mxArray *droppedLogFramesTotalArray;
mxArray *frameCountArray;

ScannerData* ScannerDataRecords[MAXNUMOBJS];
int scannerIDtoDataRecordsMap[MAXSCANNERID+1];
int AsyncThreadWaitTimeoutInMilliseconds = 3;

//Type/enum declarations

enum LSMCommandType { INITIALIZE, 
	CONFIG_BUFFERS, 
	CONFIG_FILE,
	CONFIG_CALLBACK, 
	DEBUG_MESSAGES, 
	PREFLIGHT, 
	POSTFLIGHT, 
	SETUP, 
	NEWACQ,
	START, 
	START_DIRECT, 
	PAUSE,
	FINISH,
	STOP, 
	IS_ACQUIRING,
	GETDATA, 
	GET,
	FINISH_LOG,
	FLUSH,
	DESTROY,
	TEST,
	DEBUG_SHOW_STATUS,
	UNKNOWN_CMD } ;


//Function prototype declarations
void initMEX();
void initQueues(ScannerData*);
void clearQueues(ScannerData*);
void requestLock(LOCK_TYPE lockVar); // request lock on lockVar - blocks currently executing thread, until lock is released
void releaseLock(LOCK_TYPE lockVar); // release lock on lockVar for all threads

// gets the ID for  given Scanner object handle
int getScannerID(const mxArray*); 

// gets the index in ScannerDataRecords for a given Scanner object handle
int getScannerIndex(const mxArray*); 

 // returns the scanner given the scanner object handle, or NULL if no scanner with matching ID found in scannerIDtoDataRecordsMap
ScannerData* getScannerData(const mxArray*);

// initializes a new scanner data nad inserts it into the ScannerDataRecords and scannerIDtoDataRecordsMap arrays
void initializeScannerData(const mxArray*); 

// frees resources for scanner data at a given index in ScannerDataRecords, and sets pointer to NULL
void clearScannerData(int);

// configures the buffers (single frame and circular queue) for ScannerData record
void configureBuffers(ScannerData*, const mxArray*);

// configures the data log file for ScannerData record
void configureLogFile(ScannerData*, const mxArray*, int frameToStart);

// configures the callback for ScannerData record
void configureCallback(ScannerData*, const mxArray* );

// stops the acquisiiton from acquiring data, but keep it alive and looping 
// closes the data file for the if disk logging enabled
void stopAcquisition(ScannerData*, const mxArray*);

//Waits for logging queue to finish emptying, blocking until this occurs
void finishLogging(ScannerData*, bool);

void initializeLSM(const mxArray*);  

LSMCommandType getLSMCommand(char*);

mxArray* getData(ScannerData*, int);
void flushData(ScannerData*);
mxArray* getAttrib(ScannerData*, const mxArray*);

void destroy();


unsigned int WINAPI asyncThreadFcn(LPVOID);
unsigned int WINAPI loggingThreadFcn(LPVOID);

void callbackWrapper(LPARAM, void*);


#define VALID_COMMANDS "'initialize' 'configBuffers' 'configureFiles' 'debugmessages' 'preflight' 'postflight', 'isAcquiring','setup', 'start', 'startDirect', 'newacq', 'getdata', 'get', 'flush'  or 'destroy'"

// plhs[0] should be the object handle of the LSM that is calling 
// plhs[1] should always be the mode command string ('initialize', 'getdata', 'flush', etc..)
// other arguments and return values are mode dependent

FILE *errorFile = NULL;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	long status = 1;
	char cmdStr[32], errMsg[256];
	int numFrames = 0;
	mxArray *data;
	
	ScannerData *scannerData = NULL;
	LSMCommandType lsmCmd;

	if(firstCall)
		initMEX();

	if(nrhs < 2) {
		sprintf_s(errMsg, 256, "\nconfigureFrameAcquiredEvent: No command indicated: Command must be one of %s", VALID_COMMANDS);
		mexErrMsgTxt(errMsg);
	}
	mxGetString(prhs[1], cmdStr, 32);

	lsmCmd = getLSMCommand(cmdStr);
	if(lsmCmd == UNKNOWN_CMD) {
		sprintf_s(errMsg, 256, "\nconfigureFrameAcquiredEvent: Unrecognized command: Valid commands are %s:", VALID_COMMANDS);
		mexErrMsgTxt(errMsg);
	}

	const mxArray* scObjHnd = prhs[0];

	// most commands require that scanner data has been initialized, so perform this check first
	switch(lsmCmd) {
		// these commands DO NOT require a scanner has been initialized
		case INITIALIZE : case DEBUG_MESSAGES : case DESTROY : case TEST : break;


		// all other commands DO require an initialized scanner in ScannerDataRecords
		default : 
			scannerData = getScannerData(scObjHnd);
			if(scannerData == NULL) 
				mexErrMsgTxt("\nconfigureFrameAcquiredEvent: scanner not found or not initialized - call 'initialize' first");
			break;
	}

	// these commands require that 'configBuffers' has been called 
	switch(lsmCmd) {
		case PREFLIGHT : 
			if(scannerData->singleFrameBuffer == NULL)
				mexErrMsgTxt("\nconfigureFrameAcquiredEvent: buffers not initialized - call 'configBuffers' first.");
			break;
		case POSTFLIGHT : case SETUP : case START : case START_DIRECT : case GETDATA : case NEWACQ : 
			if(scannerData->singleFrameBuffer == NULL)
				mexErrMsgTxt("\ncLSM: An expected frame buffer was found not initialized. Most likely, preflightAcquisition() call is required.");
			break;
	}

	switch (lsmCmd) {
		case INITIALIZE : initializeLSM(scObjHnd); break;
		case CONFIG_CALLBACK : configureCallback(scannerData, scObjHnd); break;
		case CONFIG_BUFFERS : configureBuffers(scannerData, scObjHnd); break; 
		case CONFIG_FILE : 
			if (nrhs < 3)
				configureLogFile(scannerData, scObjHnd,1); 
			else
				configureLogFile(scannerData, scObjHnd,(int)mxGetScalar(prhs[2])); 
			break; 
		case DEBUG_MESSAGES : debugMessagesFlag = mxGetLogicals(prhs[2])[0]; break;  
		case GET : plhs[0] = getAttrib(scannerData, prhs[2]); break;
		case PREFLIGHT : 
			status = PreflightAcquisition(scannerData->singleFrameBuffer); break;
		case POSTFLIGHT :
			status = PostflightAcquisition(scannerData->singleFrameBuffer); break; 
		case SETUP :
			status = SetupAcquisition(scannerData->singleFrameBuffer); break;
		case NEWACQ : 

			scannerData->acquireData = false;  // if called during acquistion, stop acquiring data temporarily
			flushData(scannerData);

			//Start logging thread, if needed
			if (scannerData->logDataToDisk) {
				scannerData->newLogFileSignal = 0;

				scannerData->loggingData = true;

				scannerData->loggingAverageFactor = (int)mxGetScalar(mxGetProperty(scObjHnd, 0, "loggingAveragingFactor"));

				if (scannerData->loggingAverageFactor > 1)
				{
					if (scannerData->averagingBuffer != NULL)
						mxFree(scannerData->averagingBuffer);

					if (scannerData->averagingResultBuffer != NULL)
						mxFree(scannerData->averagingResultBuffer);
					
					scannerData->averagingBuffer = (double *) mxCalloc(scannerData->frameSize / scannerData->bytesPerPixel,sizeof(double));
					mexMakeMemoryPersistent(scannerData->averagingBuffer);

					scannerData->averagingResultBuffer = mxCalloc(scannerData->frameSize / scannerData->bytesPerPixel,scannerData->bytesPerPixel);
					mexMakeMemoryPersistent(scannerData->averagingResultBuffer);
				}		

				scannerData->loggerThread = (HANDLE)_beginthreadex(NULL,0,loggingThreadFcn,(LPVOID) scannerData,0,&(scannerData->loggerThreadID));
			}

			//Reset counters and start acquiring
			scannerData->frameCount = 0;
			scannerData->droppedFramesSinceLastAcquired = 0;
			scannerData->droppedFramesTotal = 0;
			scannerData->droppedLogFramesSinceLastAcquired = 0;
			scannerData->droppedLogFramesTotal = 0;
			scannerData->loggingFrameCount = 0;
			scannerData->loggingFrameSignalError = false;
			
			scannerData->acquireData = true; // re-enable acquireData
			break;

		case PAUSE : 
			scannerData->acquireData = false; break;
		case START : 			
			scannerData->acquireData = true; 
			SetEvent(scannerData->scannerStartEvent); //Sends event 
			break; 
		case START_DIRECT :
			//Directly call API StartAcquisition() function (which can block for long time in case of external triggering)
			scannerData->acquireData = true; 
			status = StartAcquisition(scannerData->singleFrameBuffer);
			break;
		case STOP :
			stopAcquisition(scannerData, scObjHnd);
			if (scannerData->loggerThreadID!=0) {
				scannerData->loggingData = false;
				scannerData->loggerThread = 0;
				scannerData->loggerThreadID = 0;
			}
			break;
		case FINISH :
			stopAcquisition(scannerData, scObjHnd);
			if (scannerData->loggerThreadID!=0) {
				finishLogging(scannerData,false); //Wait for logging to clear queue before killing thread

				scannerData->loggingData = false;
				scannerData->loggerThread = 0;
				scannerData->loggerThreadID = 0;

				finishLogging(scannerData,true); //Wait for logging to finish closing file
			}
			break;
		case IS_ACQUIRING : 
			status = (long) scannerData->acquireData;
			break;
		case GETDATA : 
			numFrames = 0;
			if(nrhs > 0)
				numFrames = (int)mxGetScalar(prhs[2]);
			data = getData(scannerData, numFrames);
			if(data == NULL)
				data = mxCreateNumericMatrix(1, 0, RETURNED_IMAGE_DATATYPE, mxREAL);
			plhs[0] = data;
			break; 
		case FLUSH : flushData(scannerData); break;
		case FINISH_LOG :
			finishLogging(scannerData,false); break; //VI031011A: For now, only use-case of calling finishLogging action directly is during pause/resume, so we don't wait for file to close. Should make this conditional on an argument probably.
		case DESTROY : destroy(); break;
		case TEST : mexPrintf("\nLSM test successful!\n"); break;
		case DEBUG_SHOW_STATUS :
			
			mexPrintf("acquireData: %d\nframeSize: %d\ncircDataQueueSize: %d\nframeCount: %d\n\n",scannerData->acquireData,scannerData->frameSize, scannerData->circDataQueueSize, scannerData->frameCount);


			mexPrintf("loggingData: %d\nlogDataToDisk: %d\ntifFileOpen: %d\n",scannerData->loggingData,scannerData->logDataToDisk,scannerData->tifWriter->isTifFileOpen());

			requestLock(scannerData->qLogVarLock);
			mexPrintf("qLogSize: %d\nqLogBegin: %d\nqueueLogFullFlag: %d\n\n",scannerData->qLogSize,scannerData->qLogBegin,scannerData->queueLogFullFlag);
			releaseLock(scannerData->qLogVarLock);

			requestLock(scannerData->qVarLock);
			mexPrintf("qSize: %d\nqBegin: %d\nqueueFullFlag: %d\n\n",scannerData->qSize,scannerData->qBegin,scannerData->queueFullFlag);
			releaseLock(scannerData->qVarLock);

			mexPrintf("asyncThreadHandle: %d\nasyncThreadID: %d\neventHandle: %d\ncallbackFcnHandle: %d\n",scannerData->scannerThread, scannerData->scannerThreadID, scannerData->scannerFrameEvent, scannerData->callbackFuncHandle);

		default: break;
	}

	// return status unless the command is getdata or get, which return different values
	if(nlhs > 0 && lsmCmd != GETDATA  && lsmCmd != GET) {
		plhs[0] = mxCreateNumericMatrix(1, 1, mxINT64_CLASS, mxREAL);
		long *dataptr = (long*)mxGetData(plhs[0]);
		dataptr[0] = status;
	}	
}

LSMCommandType getLSMCommand(char* str) {
	if(strcmp(str, "getdata") == 0) {
		return GETDATA;
	} else if(strcmp(str, "flush") == 0) {
		return FLUSH;
	} else if(strcmp(str, "finishLogging") == 0) {
		return FINISH_LOG;
	} else if(strcmp(str, "setup") == 0) {
		return SETUP;
	} else if(strcmp(str, "isAcquiring") == 0) {
		return IS_ACQUIRING;
	} else if(strcmp(str, "start") == 0) {
		return START;
	} else if(strcmp(str, "startDirect") == 0) {
		return START_DIRECT;
	} else if(strcmp(str, "get") == 0) {
		return GET;
	} else if(strcmp(str, "newacq") == 0) {
		return NEWACQ;
	} else if(strcmp(str, "pause") == 0) {
		return PAUSE;
	} else if(strcmp(str, "debugmessages") == 0) {
		return DEBUG_MESSAGES;
	} else if(strcmp(str, "configBuffers") == 0) {
		return CONFIG_BUFFERS;
	} else if(strcmp(str, "configLogFile") == 0) {
		return CONFIG_FILE;
	} else if(strcmp(str, "configCallback") == 0) {
		return CONFIG_CALLBACK;
	} else if(strcmp(str, "preflight") == 0) {
		return PREFLIGHT;
	} else if(strcmp(str, "postflight") == 0) {
		return POSTFLIGHT;	
	} else if(strcmp(str, "stop") == 0) {
		return STOP;
	} else if(strcmp(str, "finish") == 0) {
		return FINISH;
	} else if(strcmp(str, "initialize") == 0) {
		return INITIALIZE;
	} else if(strcmp(str, "destroy") == 0) {
		return DESTROY;
	} else if(strcmp(str, "test") == 0) {
		return TEST;
	} else if(strcmp(str, "debugShowStatus") == 0) {
		return DEBUG_SHOW_STATUS;
	}

	// fall through case
	return UNKNOWN_CMD;
}


int getScannerID(const mxArray* scannerObjHandle) {
	mxArray *devProp = mxGetProperty(scannerObjHandle, 0, "deviceID");
	if(devProp == NULL || mxIsEmpty(devProp))
		return -1;
	else
		return (int)mxGetScalar(devProp);
}

int getScannerIndex(const mxArray* scannerObjHandle) {
	int scannerID;

	scannerID = getScannerID(scannerObjHandle);
	if(scannerID < 0 || scannerID > MAXSCANNERID) 
		return -1;
	else
		return scannerIDtoDataRecordsMap[scannerID];
}

ScannerData* getScannerData(const mxArray* scannerObjHandle) {
	int scannerIdx = getScannerIndex(scannerObjHandle);

	if(scannerIdx == -1)
		return NULL;
	else 
		return ScannerDataRecords[scannerIdx];
}


mxArray* getAttrib(ScannerData* scannerData, const mxArray* attribName) {
	char attribStr[64];

	mxGetString(attribName, attribStr, 64);

	mxArray* val = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
	int *data = (int*)(mxGetData(val));

	data[0] = -1;

	if (!strcmp(attribStr, "framesAvailable")) {
		data[0] = scannerData->qSize;
	} else if (!strcmp(attribStr, "droppedFramesTotal")) {
		data[0] = scannerData->droppedFramesTotal;
	} else if (!strcmp(attribStr, "droppedFramesLast")) {
		data[0] = scannerData->droppedFramesSinceLastAcquired;
	} else if (!strcmp(attribStr, "droppedLogFramesTotal")) {
		data[0] = scannerData->droppedLogFramesTotal;
	} else if (!strcmp(attribStr, "droppedLogFramesLast")) {
		data[0] = scannerData->droppedLogFramesSinceLastAcquired;
	} else if (!strcmp(attribStr, "frameCount")) {
		data[0] = scannerData->frameCount;
	}

	return val;

	
}

// only called in one place
void stopAcquisition(ScannerData* scannerData, const mxArray* scannerObjHandle) {	

	double verbose = mxGetScalar(mxGetProperty(scannerObjHandle, 0, "verbose"));
	if (verbose == 1)
		mexPrintf("droppedFramesTotal: %d droppedLogFramesTotal: %d\n",scannerData->droppedFramesTotal,scannerData->droppedLogFramesTotal);
	else
	{
		if (scannerData->droppedFramesTotal > 0)
			mexPrintf("WARNING: Frames were dropped during acquisition. # of dropped frames: %d.\n", scannerData->droppedFramesTotal);
		
		if (scannerData->droppedLogFramesTotal > 0)
			mexPrintf("WARNING: Frames failed to be logged during acquisition. # of unlogged frames: %d.\n", scannerData->droppedLogFramesTotal);
	}

	scannerData->acquireData = false;
}

mxArray* dummyArray; // xxx doesn't appear to be used anywhere after creation
void initMEX() {
	int n;

#ifdef DEBUG_CONSOLE
	if (!AllocConsole())
		mexPrintf("WARNING: Failed to launch debug console!\n");
#endif


	firstCall = false;
	mexLock();
	mexAtExit(destroy);

	for(n=0; n<MAXNUMOBJS; n++)
		ScannerDataRecords[n] = NULL;
	for(n=0; n<MAXSCANNERID; n++)
		scannerIDtoDataRecordsMap[n] = -1;

	 dummyArray = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
	 callbackEventArray = mxCreateStructMatrix(0, 0, 0, 0);

	callbackEventArray = mxCreateStructMatrix(1, 1, CALLBACK_EVENT_ARRAY_NUM_FIELDS, CALLBACK_EVENT_ARRAY_FIELD_NAMES);
	framesAvailableArray = mxCreateDoubleMatrix(1, 1, mxREAL);
	droppedFramesLastArray = mxCreateDoubleMatrix(1, 1, mxREAL);
	droppedFramesTotalArray = mxCreateDoubleMatrix(1, 1, mxREAL);
	droppedLogFramesLastArray = mxCreateDoubleMatrix(1, 1, mxREAL);
	droppedLogFramesTotalArray = mxCreateDoubleMatrix(1, 1, mxREAL);
	frameCountArray = mxCreateDoubleMatrix(1, 1, mxREAL);

	mexMakeArrayPersistent(callbackEventArray);
	mexMakeArrayPersistent(framesAvailableArray);
	mexMakeArrayPersistent(droppedFramesLastArray);
	mexMakeArrayPersistent(droppedFramesTotalArray);
	mexMakeArrayPersistent(droppedLogFramesLastArray);
	mexMakeArrayPersistent(droppedLogFramesTotalArray);
	mexMakeArrayPersistent(frameCountArray);

	mxSetField(callbackEventArray, 0, "framesAvailable", framesAvailableArray);
	mxSetField(callbackEventArray, 0, "droppedFramesLast", droppedFramesLastArray);
	mxSetField(callbackEventArray, 0, "droppedFramesTotal", droppedFramesTotalArray);
	mxSetField(callbackEventArray, 0, "droppedLogFramesLast", droppedLogFramesLastArray);
	mxSetField(callbackEventArray, 0, "droppedLogFramesTotal", droppedLogFramesTotalArray);
	mxSetField(callbackEventArray, 0, "frameCount", frameCountArray);
}

void clearScannerData(int scannerIndex) {
	ScannerData* scannerData = ScannerDataRecords[scannerIndex];

	mxAssert(scannerIndex >= 0 && scannerIndex < MAXNUMOBJECTS, "clearScannerData: failed assertion scannerIndex out of range");
	if(scannerData == NULL)
		return;

	// do not close thread handle because it should already be closed...
	// CloseHandle(scannerData->scannerThread);
	scannerData->scannerThread = INVALID_HANDLE_VALUE;
	
	CloseHandle(scannerData->scannerKillEvent);
	CloseHandle(scannerData->scannerFrameEvent);
	CloseHandle(scannerData->scannerStartEvent);
	scannerData->scannerKillEvent = INVALID_HANDLE_VALUE;
	scannerData->scannerFrameEvent = INVALID_HANDLE_VALUE;
	scannerData->scannerStartEvent = INVALID_HANDLE_VALUE;
	
	CloseHandle(scannerData->qVarLock);
	CloseHandle(scannerData->qLogVarLock);
	CloseHandle(scannerData->logFileParameterChangeLock);
	
	mxDestroyArray(scannerData->scannerObjHandle);
	if(scannerData->callbackFuncHandle != NULL)
		mxDestroyArray(scannerData->callbackFuncHandle);

	mxFree(scannerData->circDataQueue);
	mxFree(scannerData->loggingDataQueue);
	mxFree(scannerData->singleFrameBuffer);
	
	if (scannerData->loggingData) {
		scannerData->loggingData = false;
	}

	if(scannerData->tifWriter != NULL) {
		delete scannerData->tifWriter;
		scannerData->tifWriter = NULL;
	}

	if(scannerData->fileName != NULL)
		mxFree(scannerData->fileName);
	mxFree(scannerData->fileModeStr);

	if (scannerData->headerString != NULL)
		mxFree(scannerData->headerString);

	AsyncMex_destroy(&(scannerData->hAsyncMex));

	if (scannerData->averagingBuffer != NULL)
		mxFree(scannerData->averagingBuffer);

	if (scannerData->averagingResultBuffer != NULL)
		mxFree(scannerData->averagingResultBuffer);

	mxFree(ScannerDataRecords[scannerIndex]);
	
	ScannerDataRecords[scannerIndex] = NULL;
}



void initializeScannerData(int scannerIndex, const mxArray* scannerObjHandle) {
	ScannerData* scannerData;
	char semName[64];
	long LSMerr;

	mxAssert(scannerIndex >= 0 && scannerIndex < MAXNUMOBJECTS, "initializeScannerData: failed assertion scannerIndex out of range"); 
	scannerData = ScannerDataRecords[scannerIndex];
	if (scannerData == NULL) {
		scannerData = (ScannerData*)mxCalloc(1,sizeof(ScannerData));	
		ScannerDataRecords[scannerIndex] = scannerData;

		//Need to store the ScannerData beyond the MEX call. (Would malloc() accomplish this? might it allow the data to then get deleted with Task? or might this happen anyway?)
		mexMakeMemoryPersistent((void*)scannerData);
	}
	

	scannerData->scannerObjHandle = mxDuplicateArray(scannerObjHandle);
	mexMakeArrayPersistent(scannerData->scannerObjHandle);
	scannerData->callbackFuncHandle = NULL;
	scannerData->scannerID = (int)mxGetScalar(mxGetProperty(scannerObjHandle, 0, "deviceID"));
	scannerData->circDataQueue = NULL;
	scannerData->circDataQueueSize = 0;
	scannerData->singleFrameBuffer = NULL;
	scannerData->imageHeight = 0;
	scannerData->imageWidth = 0;
	scannerData->numChannels = (int)mxGetScalar(mxGetProperty(scannerObjHandle, 0, "numChannels"));
	scannerData->numChannelsActive = 0;
	scannerData->bytesPerPixel = DEFAULT_BYTES_PER_PIXEL;
	scannerData->frameSize = 0;
	scannerData->droppedFramesSinceLastAcquired = -1;
	scannerData->droppedFramesTotal = -1;
	scannerData->droppedLogFramesSinceLastAcquired = -1;
	scannerData->droppedLogFramesTotal = -1;
	scannerData->fileName = (char*)mxCalloc(MAXFILENAMESIZE, 1);
	mexMakeMemoryPersistent(scannerData->fileName);
	scannerData->fileModeStr = (char*)mxCalloc(8, 1);
	mexMakeMemoryPersistent(scannerData->fileModeStr);
	strcpy_s(scannerData->fileModeStr, 8, "wbn");
	scannerData->frameCount = 0;
	scannerData->tifWriter = new TifWriter();
	
	scannerData->acquireData = false;
	scannerData->newLogFileSignal = 0;

	sprintf_s(semName, 64, "MEX LSM %d getdata queue", scannerData->scannerID);
	scannerData->qVarLock = CreateSemaphore(NULL, 1, 1, semName);

	sprintf_s(semName, 64, "MEX LSM %d logging  queue", scannerData->scannerID);
	scannerData->qLogVarLock = CreateSemaphore(NULL, 1, 1, semName);


	sprintf_s(semName, 64, "MEX LSM %d log file param change", scannerData->scannerID);
	scannerData->logFileParameterChangeLock = CreateSemaphore(NULL, 1, 1, semName);	


	scannerData->hAsyncMex = AsyncMex_create((AsyncMex_Callback *) &callbackWrapper, (void *)scannerData);
	
	scannerData->scannerKillEvent = CreateEvent(NULL, FALSE, FALSE, NULL);
	scannerData->scannerFrameEvent = CreateEvent(NULL, FALSE, FALSE, NULL);
	scannerData->scannerStartEvent = CreateEvent(NULL, FALSE, FALSE, NULL);


	// create a new high-priority thread that starts executing immediately upon creation (will enter wait state)
	scannerData->scannerThread = (HANDLE)_beginthreadex(NULL,0,asyncThreadFcn,(LPVOID) scannerData,0,&(scannerData->scannerThreadID));
	//SetThreadPriority(scannerData->scannerThread, THREAD_PRIORITY_TIME_CRITICAL);
	//scannerData->scannerThread = CreateThread(NULL,0, asyncThreadFcn, (LPVOID) scannerData, 0, &(scannerData->scannerThreadID));

	scannerData->loggingData = false;
	scannerData->loggerThread = 0;
	scannerData->loggerThreadID = 0;

	LSMerr = SetStatusEvent(scannerData->scannerFrameEvent);
}		

void configureLogFile(ScannerData *scData, const mxArray* scannerObjHandle, int frameToStart) {

	requestLock(scData->logFileParameterChangeLock);

	if (!scData->loggingData)
		scData->logDataToDisk = (bool)((mxGetLogicals(mxGetProperty(scannerObjHandle, 0, "loggingEnableMEX")))[0]);
	
	if (scData->logDataToDisk) {
		// used as a failsafe if mxGetString fails
		sprintf_s(scData->fileName, 32, "%s_%d", DEFAULT_LSM_FILENAME, scData->scannerID);

		//update loggingModeString in scanner record
		mxArray* val;
		val = mxGetProperty(scannerObjHandle, 0, "loggingOpenModeString");
		if(val != NULL)
			mxGetString(val, scData->fileModeStr, 8);
		else
			DebugMsg("WARNING! configureLogFile: mxGetProperty 'loggingOpenModeString' returned NULL!");

		// update loggingFullFileName in scanner record. 
		//File will be created when entering the AsyncThread (which will own the file handle)
		val = mxGetProperty(scannerObjHandle, 0, "loggingFullFileName");
		if(val != NULL)
			mxGetString(val, scData->fileName, MAXFILENAMESIZE);
		else
			DebugMsg("WARNING! configureLogFile: mxGetProperty 'loggingFullFileName' returned NULL!");

		//update headerString in scanner record
		val = mxGetProperty(scannerObjHandle,0,"loggingHeaderString");
		if (val != NULL)
		{
			size_t strSize = mxGetNumberOfElements(val) + 1;
			if (scData->headerString != NULL)			
				mxFree(scData->headerString);

			scData->headerString = (char*)mxCalloc(1, strSize);
			mxGetString(val, scData->headerString, strSize);
			mexMakeMemoryPersistent(scData->headerString);
		}
		else
			DebugMsg("WARNING! configureLogFile: mxGetProperty 'loggingHeaderString' returned NULL!");

		//Update TIF file configuration (to reflect new headerString value, if any -- other values should /not/ change in the middle of an acquisition!)
		scData->tifWriter->configureImage(scData->imageWidth,scData->imageHeight,DEFAULT_BYTES_PER_PIXEL,scData->numChannelsActive,scData->headerString);

	}

	if (scData->logDataToDisk)
		scData->newLogFileSignal = frameToStart;
	else
		scData->newLogFileSignal = 0;

	releaseLock(scData->logFileParameterChangeLock);
}

void configureCallback(ScannerData *scData, const mxArray* scannerObjHandle) {
	mxArray *callbackFcn;

	/* UNCOMMENT FOR FRAME LOCKING - allows ability to change callback while running

	bool resumeAcquisition = false;
	
	if(scData->acquireData) 
		resumeAcquisition = true;

	// temporarily pause acquisition
	scData->acquireData = false;
	requestLock(scData->acquireFrameLock);
	*/


	if(scData->callbackFuncHandle != NULL) {
		mxDestroyArray(scData->callbackFuncHandle);
	}

	callbackFcn = mxGetProperty(scannerObjHandle, 0, "frameAcquiredEventFcn");
	
	scData->callbackFuncHandle = NULL;
	if(callbackFcn == NULL) {
		DebugMsg("WARNING! configureCallback: 'frameAcquiredEventFcn' is NULL\n");
	} else if(mxGetClassID(callbackFcn) != mxFUNCTION_CLASS) {
		DebugMsg("WARNING! configureCallback: 'frameAcquiredEventFcn' is not a function handle\n");
	} else if(!mxIsEmpty(callbackFcn)) {
		//mexCallMATLABWithTrap(0, NULL, 1, &callbackFcn, "disp");
		scData->callbackFuncHandle = mxDuplicateArray(callbackFcn); //Store Matlab function handle
		mexMakeArrayPersistent(scData->callbackFuncHandle);		
	} 

	/* UNCOMMENT FOR FRAME LOCKING - allows ability to change callback while running
	// resume acquisition
	if(resumeAcquisition)
		scData->acquireData = true;

	releaseLock(scData->acquireFrameLock);
	*/
}

void configureBuffers(ScannerData *scData, const mxArray* scannerObjHandle) {
	int oldFrameSize, oldQueueSize;
	bool resumeAcquisition = false;
	
	/* UNCOMMENT FOR FRAME LOCKING 
	// temporarily pause acquisition
	if(scData->acquireData) 
		resumeAcquisition = true;

	scData->acquireData = false;
//	requestLock(scData->acquireFrameLock);
	*/

	oldFrameSize = scData->frameSize;
	oldQueueSize = scData->circDataQueueSize;

	scData->imageHeight = (int)mxGetScalar(mxGetProperty(scannerObjHandle, 0, "pixelsPerDim"));
	scData->imageWidth = (int)mxGetScalar(mxGetProperty(scannerObjHandle, 0, "pixelsPerDim"));
	scData->bytesPerPixel = DEFAULT_BYTES_PER_PIXEL; //TODO: Use mxGetProperty()
	scData->numChannelsActive = (int)mxGetScalar(mxGetProperty(scannerObjHandle, 0, "numChannelsActive"));

	//If more than one frame is active, frame data is returned for ALL the available channels
	int frameNumChannels;
	if (scData->numChannelsActive == 1)
		frameNumChannels = scData->numChannelsActive;
	else
		frameNumChannels = scData->numChannels;

	scData->frameSize = scData->imageHeight*scData->imageWidth*scData->bytesPerPixel*frameNumChannels;
	scData->tifWriter->configureImage(scData->imageWidth,scData->imageHeight,DEFAULT_BYTES_PER_PIXEL,scData->numChannelsActive,scData->headerString);

	scData->circDataQueueSize = (int)mxGetScalar(mxGetProperty(scannerObjHandle, 0, "circBufferSize"));
	
	scData->diskLogOverFlowFlag = false;
	initQueues(scData);

	scData->arrayDims[0] = scData->imageHeight;
	scData->arrayDims[1] = scData->imageWidth;
	scData->arrayDims[2] = frameNumChannels;
	scData->arrayDims[3] = 1;

	// setup single frame buffer for CopyAcquisition, if frameSize has changed
//	if((scData->singleFrameBuffer == NULL)) { // || (oldFrameSize != scData->frameSize)) {
		if(scData->singleFrameBuffer != NULL)
			mxFree(scData->singleFrameBuffer);
//			free(scData->singleFrameBuffer);

//		scData->singleFrameBuffer = (char*)calloc(scData->frameSize, 1);
		scData->singleFrameBuffer = (char*)mxCalloc(1, scData->frameSize);
		
		mexMakeMemoryPersistent(scData->singleFrameBuffer);
	

	// set up circular data queue for grabbing data and disk writing
//	if((scData->circDataQueue == NULL) || (oldQueueSize*oldFrameSize != (scData->frameSize*scData->circDataQueueSize))) {
		if(scData->circDataQueue != NULL)
			mxFree(scData->circDataQueue);

		scData->circDataQueue = (char*)mxCalloc(1, scData->frameSize * scData->circDataQueueSize);
		mexMakeMemoryPersistent(scData->circDataQueue);

	// set up disk logging queue
		if(scData->loggingDataQueue != NULL)
			mxFree(scData->loggingDataQueue);

		scData->loggingDataQueue = (char*)mxCalloc(1, scData->frameSize * scData->circDataQueueSize);
		mexMakeMemoryPersistent(scData->loggingDataQueue);


	/* UNCOMMENT FOR FRAME LOCKING 
	
	// resume acquisition
	if(resumeAcquisition) 
		scData->acquireData = true;

	releaseLock(scData->acquireFrameLock);
	*/
}


void initQueues(ScannerData* scannerData) {
	scannerData->qBegin = 0;
	scannerData->qSize = 0;
	scannerData->qLogBegin = 0;
	scannerData->qLogSize = 0;
	
	scannerData->queueFullFlag = 0;
	scannerData->queueLogFullFlag = 0;
}

void clearQueues(ScannerData* scannerData) {
	requestLock(scannerData->qVarLock);
	requestLock(scannerData->qLogVarLock);

	initQueues(scannerData);

	releaseLock(scannerData->qVarLock);
	releaseLock(scannerData->qLogVarLock);
}

void requestLock(LOCK_TYPE lockVar) {
	DWORD err;
	
	err = WaitForSingleObject(lockVar, INFINITE);
	
	mxAssert(err == WAIT_OBJECT_0, "requestLock: failed assertion: invalid return condition from WaitForSingleObject, aborting...");
}

void releaseLock(LOCK_TYPE lockVar) {
	ReleaseSemaphore(lockVar, 1, NULL);
}

void initializeLSM(const mxArray* scannerObjHandle) {
	int scannerID, scannerIdx, n;
	long LSMerr;

	scannerID = (int)mxGetScalar(mxGetProperty(scannerObjHandle, 0, "deviceID"));
	if(scannerID < 0 || scannerID > MAXSCANNERID)
		mexErrMsgTxt("initializeLSM: deviceID out of range"); //, must be between %d and %d", 0, MAXSCANNERID);

	// TODO: change for multiple camera support

	// check to see if scanner has already been registered - if so, clear it
	scannerIdx = getScannerIndex(scannerObjHandle);

	// object has already been initialized, simply copy object handle and recreate status event
	if(scannerIdx >= 0) {
		mxDestroyArray(ScannerDataRecords[scannerIdx]->scannerObjHandle);
		ScannerDataRecords[scannerIdx]->scannerObjHandle = mxDuplicateArray(scannerObjHandle);
		mexMakeArrayPersistent(ScannerDataRecords[scannerIdx]->scannerObjHandle);

		AsyncMex_destroy(&ScannerDataRecords[scannerIdx]->hAsyncMex);

		ScannerDataRecords[scannerIdx]->hAsyncMex = AsyncMex_create((AsyncMex_Callback *) &callbackWrapper, (void *)ScannerDataRecords[scannerIdx]);

		CloseHandle(ScannerDataRecords[scannerIdx]->scannerFrameEvent);

		ScannerDataRecords[scannerIdx]->scannerFrameEvent = CreateEvent(NULL, FALSE, FALSE, NULL);

		LSMerr = SetStatusEvent(ScannerDataRecords[scannerIdx]->scannerFrameEvent);
	}

	// if not, find new 
	else {
		
		// scanner index = -1
			n = 0;
			while(n < MAXNUMOBJS && ScannerDataRecords[n] != NULL)
				n++;

			if(n == MAXNUMOBJS)
				mexErrMsgTxt("initializeLSM: maximum number of scanners reached"); 
			else scannerIdx = n;
			scannerIDtoDataRecordsMap[scannerID] = scannerIdx;
		
		// if new scanner, initialize new record
		initializeScannerData(scannerIdx, scannerObjHandle);
	}
	
}


// xxx currently it looks like this gets the oldest data. however the newest might make more sense. however however, as-is, 
// there are issues with this code when the buffer overflows
mxArray* getData(ScannerData* scData, int numFrames) {
	mxArray *data = NULL; 
	int startCopyIdx, endCopyIdx, wrapAroundIdx, bytesToCopy;
	void *dataPtr;

	//scData->arrayDims[3] = 1;
	//data = mxCreateNumericArray(4, scData->arrayDims, RETURNED_IMAGE_DATATYPE, mxREAL);
	//dataPtr = mxGetData(data);

	//// copy buffer from startCopyIdx to endCopyIdx to data
	////RegLSMEvent_DebugMsg("Copying queue data to mxArray\n");
	//memcpy(dataPtr, scData->singleFrameBuffer, scData->frameSize);

	//return data;
	
	requestLock(scData->qVarLock);
	
	mxAssert(scData->qSize >=0, "getdata: qSize is less than zero");

	if (scData->qSize == 0) { //no data to copy
		releaseLock(scData->qVarLock); // nothing to do, so release the lock 
	} else {
		// if numFrames is 0, or if request more frames then available, simply return all frames
		if(numFrames > scData->qSize || numFrames <= 0)
			numFrames = scData->qSize;

		//DebugMsg("getdata: qBegin=%d qSize=%d ", scData->qBegin, scData->qSize);
		
		startCopyIdx = scData->qBegin;
		endCopyIdx = scData->qBegin + numFrames;
		

		wrapAroundIdx = -1;
		if(endCopyIdx > scData->circDataQueueSize) {
			endCopyIdx = scData->circDataQueueSize;
			wrapAroundIdx =  (scData->qBegin + numFrames) % scData->circDataQueueSize;
		}
		releaseLock(scData->qVarLock);

		mxAssert(startCopyIdx != endCopyIdx, "getdata: startCopyIdx is the same as endCopyIdx");
		scData->arrayDims[3] = (mwSize) numFrames;
		data = mxCreateNumericArray(4, scData->arrayDims, RETURNED_IMAGE_DATATYPE, mxREAL);

		dataPtr = mxGetData(data);

		// copy buffer from startCopyIdx to endCopyIdx to data
		
		bytesToCopy = (endCopyIdx - startCopyIdx)*scData->frameSize;
		//DebugMsg("getdata: Copying queue data to mxArray numFrames=%d startCopyIdx=%d endCopyIdx=%d wrapAroundIdx=%d bytesToCopy=%d\n", numFrames, startCopyIdx, endCopyIdx, wrapAroundIdx, bytesToCopy);
		
		memcpy(dataPtr, (scData->circDataQueue + startCopyIdx*scData->frameSize), bytesToCopy);
		if(wrapAroundIdx >= 0)
			memcpy(dataPtr, scData->circDataQueue, (wrapAroundIdx + 1)*scData->frameSize);

		requestLock(scData->qVarLock);
			scData->qBegin = (scData->qBegin + numFrames) % scData->circDataQueueSize;
			scData->qSize = scData->qSize - numFrames;
		releaseLock(scData->qVarLock);
	}

	return data;
}


void flushData(ScannerData* scData) {
	clearQueues(scData);
}

//Waits for logging queue to finish emptying, blocking until this occurs
void finishLogging(ScannerData* scData,bool waitForClose) {

	int framesToLog;

	if (scData->loggerThreadID!=0) {
		while (true)
		{
			requestLock(scData->qLogVarLock);
			framesToLog = scData->qLogSize;
			releaseLock(scData->qLogVarLock);

			if (framesToLog == 0 ) //Wait for queue to be cleared
			{
				if (waitForClose)
				{
					if (scData->tifWriter->isTifFileOpen())
						Sleep(1);
					else
						break;
				}
				else
					break;
			}
			else
				Sleep(1);			

			//if (framesToLog == 0)
			//{
			//	if (!scData->acquiringData && scData->tifWriter->isTifFileOpen()) //we can force the file close operation here
			//		scData->tifWriter->closeTifFile();

			//	break;
			//}
			//else
			//	Sleep(0);			

			//if (framesToLog == 0) {
			//	if (scData->tifWriter->isTifFileOpen()) {
			//		scData->tifWriter->closeTifFile();
			//	}
			//	break;
			//}
			//else
			//	Sleep(0); 				
		}
	}
}


void destroy() {

	int n;

	
	for(n=0; n<MAXNUMOBJS; n++) {
		if(ScannerDataRecords[n] != NULL) {
			
			if (ScannerDataRecords[n]->scannerThread != INVALID_HANDLE_VALUE) {
				//Signal to async (event-trapping) thread to shut down
				SetEvent(ScannerDataRecords[n]->scannerKillEvent); //Sends event 
				switch (WaitForSingleObject(ScannerDataRecords[n]->scannerThread, 10000)) 	{
					case WAIT_ABANDONED : case WAIT_TIMEOUT:
						MessageBoxA(NULL, "stopAsyncThread: Failed to process shutdown an asynhchronous event handling thread.",NULL,MB_OK);
					break;
				}
			}
		
			flushData(ScannerDataRecords[n]);

			clearScannerData(n);
		}
	}
	
	if(callbackEventArray != NULL) {		

		mxDestroyArray(callbackEventArray);
		callbackEventArray = NULL;
		framesAvailableArray = NULL;
		droppedFramesTotalArray = NULL;
		droppedFramesLastArray = NULL;
		droppedLogFramesTotalArray = NULL;
		droppedLogFramesLastArray = NULL;
		frameCountArray = NULL; 
	}

	firstCall = true;

	if(errorFile != NULL) {
		fclose(errorFile);
		errorFile = NULL;
	}

	mexUnlock();
}

///Helper Functions



//Matlab callback wrapper function
void callbackWrapper(LPARAM scannerID, void *scData)
{
	mxArray *mException;
	mxArray *rhs[3];
	double *ptr;

	ScannerData *scannerData = (ScannerData*)scData;

	if (scannerData->acquireData)
	{		
		//Initialize src/event arguments that will be passed to callback
		rhs[0] = scannerData->callbackFuncHandle;
		
		
		//vvv: Although these are 'array' variables, /all/ scanners' events would update arrays' first element
		ptr = mxGetPr(framesAvailableArray);
		ptr[0] = scannerData->qSize;
		
		ptr = mxGetPr(droppedFramesLastArray);
		ptr[0] = scannerData->droppedFramesSinceLastAcquired;
		
		ptr = mxGetPr(droppedFramesTotalArray);
		ptr[0] = scannerData->droppedFramesTotal;

		ptr = mxGetPr(droppedLogFramesLastArray);
		ptr[0] = scannerData->droppedLogFramesSinceLastAcquired;

		ptr = mxGetPr(droppedLogFramesTotalArray);
		ptr[0] = scannerData->droppedLogFramesTotal;

		ptr = mxGetPr(frameCountArray);
		ptr[0] = scannerData->frameCount;

		
		rhs[1] = scannerData->scannerObjHandle; //the 'source'

		
		int* pdata = (int*)(mxGetData(rhs[1])); 
		pdata[0] = scannerData->scannerID;
		

		rhs[2] = callbackEventArray;
		// rhs[2] = dummyArray;
		
		
		mException = mexCallMATLABWithTrap(0,NULL,3,rhs,"feval"); //TODO -- pass arguments!
//		mException = mexCallMATLABWithTrap(0,NULL,2,rhs,"frameAcquiredCallback"); //TODO -- pass arguments!
		if (mException)
		{
			char *errorString = (char*)mxCalloc(256,sizeof(char));
			mxGetString(mxGetProperty(mException, 0, "message"),errorString, MAXCALLBACKNAMELENGTH);
			DebugMsg("WARNING! callbackWrapper: error executing callback: \n\t%s\n", errorString);
			mxFree(errorString);
		}

		return;
	}
}

/* Logging data acquistion thread  */
unsigned int WINAPI loggingThreadFcn(LPVOID userData)
{
	ScannerData *scData = (ScannerData*)userData;

	while (scData->loggingData){
		//_cprintf("Logging data\n");

		requestLock(scData->logFileParameterChangeLock);

		//Start new log file as needed (including in middle of acquisition)
		if (scData->newLogFileSignal > 0) {

			if (scData->loggingFrameCount >= (scData->newLogFileSignal - 1)) //only start new file before logging signalled frame index
			{	
				if (scData->loggingFrameCount > (scData->newLogFileSignal - 1)) //signal if signalled frame was logged prior to opening new file
					scData->loggingFrameSignalError = true;

				scData->newLogFileSignal = 0;
				assert(scData->tifWriter!=NULL);
				scData->tifWriter->closeTifFile();
					
				// open new log file
				if (scData->logDataToDisk) {
					std::string fname = scData->fileName;
					//fname += ".tif";
					if (!scData->tifWriter->openTifFile(fname.c_str(),scData->fileModeStr)) {
					  DebugMsg("WARNING! LoggingThreadFcn: could not open tiff log file %s... disabling logging\n", fname.c_str());
					  scData->logDataToDisk = false; 
					}
				}

			}
		}

		// write tif file to disk
		if(scData->logDataToDisk && scData->tifWriter->isTifFileOpen()) {

			requestLock(scData->qLogVarLock);
			if (scData->qLogSize < 0) {
				releaseLock(scData->qLogVarLock);
			} else if (scData->qLogSize == 0) {
				// no data to copy
				releaseLock(scData->qLogVarLock);

			} else {
				// There is at least one frame queued up to write
				
				//DebugMsg("LoggingThreadFcn: Writing frame to disk. Current log queue state: qLogBegin=%d qLogSize=%d\n", 
				//	scData->qLogBegin, scData->qLogSize);

				char *ptr = scData->loggingDataQueue + (scData->qLogBegin)*(scData->frameSize);
				releaseLock(scData->qLogVarLock);

				if (scData->loggingAverageFactor == 1)
				{
					scData->tifWriter->writeFramesForAllChannels(ptr,scData->frameSize);
					scData->loggingFrameCount++; //increment count of logged frames
				}
				else
				{

					int modVal = scData->loggingFrameCount % scData->loggingAverageFactor;
			
					//Reset averaging buffer
					if (modVal == 0)
						memset(scData->averagingBuffer,0,scData->frameSize / scData->bytesPerPixel * sizeof(double));

					//Add to averaging buffer
					for (int i=0;i < (scData->frameSize / scData->bytesPerPixel); i++)
					{

						switch (scData->bytesPerPixel){
							case 1:
								scData->averagingBuffer[i] = scData->averagingBuffer[i] + (double) (*((char*)ptr + i)) ;
								break;
							case 2:
								scData->averagingBuffer[i] = scData->averagingBuffer[i] + (double) (*((short*)ptr + i));
								break;
							case 4:
								scData->averagingBuffer[i] = scData->averagingBuffer[i] + (double) (*((long*)ptr + i));
								break;								
							default:
								assert(false);							
						}
					}				

					if (modVal + 1 == scData->loggingAverageFactor){


						//Compute average result 
						for (int i=0; i < (scData->frameSize / scData->bytesPerPixel); i++)
						{

							switch (scData->bytesPerPixel){
								case 1:
									((char *)scData->averagingResultBuffer)[i] = (char) (*(scData->averagingBuffer + i) / (double) scData->loggingAverageFactor) ;
									break;
								case 2:				
									((short *)scData->averagingResultBuffer)[i] = (short) (*(scData->averagingBuffer + i) / (double) scData->loggingAverageFactor) ;
									break;
								case 4:
									((long *)scData->averagingResultBuffer)[i] = (long) (*(scData->averagingBuffer + i) / (double) scData->loggingAverageFactor) ;
									break;
								default:
									assert(false);
							}
						}

						//Log averaged frame to disk
						scData->tifWriter->writeFramesForAllChannels((char *)scData->averagingResultBuffer,scData->frameSize);
					}										
				
					scData->loggingFrameCount++;
				}			

				//Signal that frame has been removed from logging queue (processed or logged)
				requestLock(scData->qLogVarLock);
				scData->qLogBegin = (scData->qLogBegin + 1) % scData->circDataQueueSize;
				scData->qLogSize--;
				releaseLock(scData->qLogVarLock);
			}
		}

		releaseLock(scData->logFileParameterChangeLock);

		Sleep(0);  //relinquish thread

		//BOOL didSwitch = SwitchToThread();
		//if (didSwitch!=0) {
		//	RegLSMEvent_L2_DebugMsg("LoggingThreadFcn: Switched to next thread.\n");
		//}
	}

	//Turning off loggingData flag signals to close any open TIF stream
	if (scData->tifWriter->isTifFileOpen())
		scData->tifWriter->closeTifFile();


	return 0;
}


/* Asynchrous data acquistion thread  */
//This thread is started each time a new scanner object is initialized, and continues until destroy()
unsigned int WINAPI asyncThreadFcn(LPVOID userData)
{
	HANDLE eventArray[3];
	DWORD response; 
	ScannerData *scData = (ScannerData*)userData;
	long status, indexOfLastCompletedFrame;
	bool keepLooping = true;

	eventArray[0] = scData->scannerKillEvent;
	eventArray[1] = scData->scannerStartEvent;
	eventArray[2] = scData->scannerFrameEvent;

	while (keepLooping)
	{
		
		// if acquiring data wait for scanner, stop acquire event or shutdown event
		response = WaitForMultipleObjects(3, eventArray, FALSE, 200); 

		// response = WaitForMultipleObjects(2, eventArray, FALSE, AsyncThreadWaitTimeoutInMilliseconds); 		
		
		switch (response) {
			case WAIT_OBJECT_0:	//The scanner kill event signals intention to shutdown	
				keepLooping = false;
			break;

			case WAIT_OBJECT_0 + 1: //The start acquisition event has signalled

				status = StartAcquisition(scData->singleFrameBuffer); //This will block until acquisition starts, or timeout occurs waiting for external trigger

				if (!status) //error occurred, e.g. timeout				
					scData->acquireData = false;	
			break;

			case WAIT_OBJECT_0 + 2: //The frame acquired event has signalled
			{
				// do nothing if acquireData is false
				
				if(!scData->acquireData)
					break;				

				//TODO: Likely remove this...should be able to assume status is ready when Event is posted
				// update 8/18 ( P. Raphael):  above may not be true if averaging is enabled
				
				/*
				do {
					if(false == StatusAcquisition(status)) {
						
					}
				} while(status == STATUS_BUSY && keepLooping);
				*/

				if(!keepLooping) break;

				//Copy single frame onto buffers

				CopyAcquisition(scData->singleFrameBuffer);


				// Copy into getdata buffer
				requestLock(scData->qVarLock);
				int qIdxToCopy = (scData->qBegin + scData->qSize) % scData->circDataQueueSize;
				releaseLock(scData->qVarLock);

				//DebugMsg("asyncThreadFcn: Copying data to circular queue qBegin=%d qSize =%d\n", scData->qBegin, scData->qSize);
				
				memcpy((void*)(scData->circDataQueue + qIdxToCopy*scData->frameSize), (void*)scData->singleFrameBuffer, scData->frameSize);

				requestLock(scData->qVarLock);
				scData->qSize++;
				if(scData->qSize > scData->circDataQueueSize) {
					scData->qSize = scData->circDataQueueSize;
					scData->queueFullFlag = 1; // xxx currently has no effect
				}
				releaseLock(scData->qVarLock);


				// Copy into logging buffer
				if (scData->loggingData) {
					requestLock(scData->qLogVarLock);
					qIdxToCopy = (scData->qLogBegin + scData->qLogSize) % scData->circDataQueueSize;
					releaseLock(scData->qLogVarLock);

					//DebugMsg("asyncThreadFcn: Copying data to logging queue qBegin=%d qSize =%d\n", scData->qLogBegin, scData->qLogSize);
					memcpy((void*)(scData->loggingDataQueue + qIdxToCopy*scData->frameSize), (void*)scData->singleFrameBuffer, scData->frameSize);

					requestLock(scData->qLogVarLock);
					scData->qLogSize++;
					if(scData->qLogSize > scData->circDataQueueSize) {
						//Overflow!
						scData->qLogSize = scData->circDataQueueSize;
						scData->qLogBegin = (scData->qLogBegin + 1) % scData->circDataQueueSize;

						scData->droppedLogFramesSinceLastAcquired++;
						scData->droppedLogFramesTotal++;
						DebugMsg("WARNING! asyncThreadFcn: Overwrote an unlogged frame in the logging data buffer!!\n");
					}
					releaseLock(scData->qLogVarLock);
				}

				//Update frame counters
				//vvv: Maybe lock this pair?
				scData->frameCount++;
				StatusAcquisitionEx(status, indexOfLastCompletedFrame);

				scData->droppedFramesSinceLastAcquired = 0;
				if(indexOfLastCompletedFrame >= 0) {
					scData->droppedFramesSinceLastAcquired = indexOfLastCompletedFrame+1 - scData->frameCount; 
					if (scData->droppedFramesSinceLastAcquired > 0) {
						DebugMsg("WARNING! asyncThreadFcn: Dropped frame on frame count %d, Thorlabs idx %d.\n",
							scData->frameCount,indexOfLastCompletedFrame);
					}

					scData->frameCount += scData->droppedFramesSinceLastAcquired;
					scData->droppedFramesTotal += scData->droppedFramesSinceLastAcquired; //xxx not sure about this

				}

				//Post frame-acquired event to Matlab thread
				if(scData->callbackFuncHandle != NULL) {
					AsyncMex_postEventMessage(scData->hAsyncMex, scData->scannerID);
				}
	
			}
			break;

			//Handle cases where signal object(s) is invalid
			case WAIT_ABANDONED_0:
			case WAIT_ABANDONED_0 + 1:
				MessageBoxA(NULL,"asyncThreadFcn: Asynchronous event handling thread detected an abnormal state and is being terminated.",NULL,MB_OK);
				keepLooping = false;

			case WAIT_TIMEOUT: 
				break;

			default:  // unknown event
				MessageBoxA(NULL,"asyncThreadFcn: Asynchronous event handling thread received an abnormal event and is being terminated.",NULL,MB_OK);
				keepLooping = false;
				break;
		}
	 } // end while(keepLooping) 

	 //Cleanup operations on shutdown of acquisition thread

	//SetCurrentscanner(scData->cameraHandle);
	//SetDriverEvent(NULL);
		
	// if(scData->dataFilePtr != NULL) {
	// 	RegLSMEvent_DebugMsg("asyncThreadFcn: closing log file %s \n", scData->fileName);
	// 	fclose(scData->dataFilePtr);
	// }


	 //VI031011: Remove this section -- let the logging thread always handle the closing!
	//assert(scData->tifWriter!=NULL);	
	//RegLSMEvent_DebugMsg("asyncThreadFcn: closing tiff log file %s \n", scData->fileName);
	//scData->tifWriter->closeTifFile();

	//SelectCamera(scData->scannerID);
	//PostflightAcquistion(scData->singleFrameBuffer);

	//CloseHandle(ScannerDataRecords[0]->qVarLock);
	//CloseHandle(scData->scannerFrameEvent);
	//CloseHandle(scData->scannerApplicationEvent);


	return 0;
}




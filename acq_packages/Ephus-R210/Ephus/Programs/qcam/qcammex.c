/*
 * qcammex.c
 *
 * Direct Matlab interface to the QImaging QCapture API.
 *
 * CHANGES
 *  JL02062008A - add variable zero and one -- Jinyang Liu 2/6/08
 *  JL02062008B - Change the input arguments of FrameDoneCallback -- Jinyang Liu 2/6/08
 *  JL02062008C - change the order of doubleBUffer should be resource and framebBuffer should be destination -- Jinyang Liu 2/6/08
 *  JL02062008D - Change the arguments of the callback QCam_QueueFrame. -- Jinyang Liu 2/6/08
 *  JL02072008A - change FrameDoneCallback from void to void QCAMAPI -- Jinyang Liu 2/6/08
 *  JL02072008B - delete (QCam_AsyncCallback) for FrameDoneCallback -- Jinyang Liu 2/7/08
 *  TO021908A - Removed JL02062008A, JL02062008B, JL02062008D because they contradicted the goal of the doubleBuffer. -- Tim O'Connor 2/19/08
 *  TO082008A - Implemented native file logging. -- Tim O'Connor 2/20/08
 *  TO082208B - Implemented threadsafe queues and full multithreading (including synchronous acquisition). -- Tim O'Connor 2/22/08
 *  JL02272008A - set pointer to NULL -- Jinyang Liu 2/27/08
 *  JL02272008B - add default case -- Jinyang Liu 2/27/08
 *  JL02272008C - change the order of src and dest -- Jinyang Liu 2/27/08
 *  JL02292008A - correct typo = to == -- Jinyang Liu 2/29/08
 *  JL03032008A - Move the setstreaming before create the synchronousgrab thread -- Jinyang Liu 2/29/08
 *  JL03062008A - Change the mxUINT16_CLASS to mxUINT8_CLASS because the image format mono8 -- Jinyang Liu 3/6/08
 *  JL03062008B - should change pBufferSize to bufferSize, use QMX_DEFAULT_BUFFER_SIZE for the time being -- Jinyang Liu 2/6/08
 *  TO032408A - Store filename, for Matlab to check file rollover events. -- Tim O'Connor 3/24/08
 *  TO032508A - Add built in logging for debugging, instead of relying on the Matlab command line. -- Tim O'Connor 3/25/08
 *  JL03272008A - remove function qmx_cBuff_resetPreprocessorStream() -- Jinyang Liu 3/27/08
 *  JL03262008B - Debug cBuff to *cBuff -- Jinyang Liu 3/26/08
 *  JL03262008C - change type from short to unsigned short -- Jinyang Liu 3/26/08
 *  JL03262008D - add qmx_frameCounter and  qmx_totalFrameCounter increasement in the first run -- Jinyang Liu 3/26/08
 *  JL03262008E - Change qmx_averageFramesTogether from callback function to a new thread -- Jinyang Liu 3/26/08
 *  JL03262008E - close the thread frameAverageThread -- Jinyang Liu 3/26/08
 *  JL03262008F - add command setImageFormatToMono16 -- Jinyang Liu 3/26/08
 *  JL03272008G - add qmx_framecounter value to the qcam GUI -- Jinyang Liu
 *  TO032708A - In the various thread `while` loops, retry the queue interactions when a timeout occurs. External triggers may result in long waits. -- Tim O'Connor 3/27/08
 *  TO032708B - Religiously yield the CPU during busy-wait loops. This results in suprisingly good responsiveness during intense disk logging. -- Tim O'Connor 3/27/08
 *  TO032708C - Improved timeout handling for blocking queue put/get calls. -- Tim O'Connor 3/27/08
 *  TO032708D - 64-bit file access, for files over 2GB. -- Tim O'Connor 3/27/08
 *  TO032708E - Do preprocessor calculations in a 64-bit buffer, to lower the possibility of rollover. -- Tim O'Connor 3/27/08
 *  TO032708F - Replace qmx_averagedFrameCounter, which has been co-opted for the preprocessor's thread, with qmx_totalAveragedFrameCounter to report back to Matlab. -- Tim O'Connor 3/27/08
 *  TO032708G - Added raw 12-bit disk logging. -- Tim O'Connor 3/27/08
 *  TO032708H - Added qmx_framesToAcquire, to automatically shut down after a specified number of frames have been logged. -- Tim O'Connor 3/27/08
 *  TO032708J - Added qmx_getSnapshot, to grab and return a frame immediately. If an acquisition is running, the current display buffer is returned. -- Tim O'Connor 3/27/08
 *  TO032708M - Implemented qmx_triggerType, for informational purposes (ie. the header). -- Tim O'Connor 3/27/08
 *  TO032808A - Apply TO032708A and TO032708B to qmx_frameDoneCallback's requeueing mechanism. -- Tim O'Connor 3/28/08
 *  JL04032008A - change true to null or the threadID always true
 *  JL04082008A - Add a new variable qmx_totalFramesWrittenCounter, this one doesn't be reset in qmx_initfile.
 *  JL04082008B - Add the realtime viewing mode for future micropublisher RTV model 
 *  JL04082008C - Add set camera mode to the standard mode 
 *  JL04082008D - Add terminatethread to kill the threads
 *  JL04082008E - replace mxIsInf with mxIsFinite because mxIsInf didn't work
 *  JL04082008F - Add vairable qmx_pixelCount
 *  JL04112008A - unlock the cBuff so the putter has a chance to get the mutex
 *  JL04112008B - unlock the cBuff so the getter has a chance to get the mutex
 *  JL04112008C - Stop queue more frames when the required qmx_framesToAcquire reaches
 *  JL04112008D - comment qerrDriverFault warning out to avoid confusing users
 *  JL04112008E - Change if statement to while statement to avoid of missing frames

 *
 * Created
 *  Timothy O'Connor 1/26/08
 *
 * Copyright
 *  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
 *
 */

//Prepare for header imports.
#ifndef __cplusplus
    typedef enum { false=0, true=1, _bool_force32=0xFFFFFFFF } bool;
    //Matlab's headers will try to define these as 8-bit without this flag.
    //QImaging likes them to be 32-bit.
    #define __bool_true_false_are_defined
#endif
//Deprecations.
#define _CRT_SECURE_NO_DEPRECATE //Who needs security?
#define _WIN32_WINNT 0x0400 //For CriticalSection use.

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <windows.h>
//Matlab
#ifdef MATLAB_MEX_FILE
    #define QMX_MATLAB_BINDING
#endif
#ifdef QMX_MATLAB_BINDING
    #include "mex.h"
#endif
//Data compression.
 //None, yet.
//QImaging - Camera Control
#include "QCamApi.h"
#include "QCaptureAPI.h"
#include "QCamImgfnc.h"
//Integrated graphical display.
 //Not yet implemented.
//WxWidgets - Graphics (Window Implementation + OpenGL Interface)
//#include "wx/wx.h" 
//#include "wx/glcanvas.h"

/*
 * Platform macros.
 *
 */
#if defined(MSDOS) || defined(OS2) || defined(WIN32) || defined(__CYGWIN__)
    //Zlib recommended procedure for preventing line-ending corruption from MS.
    #include <fcntl.h>
    #include <io.h>
    #define SET_BINARY_MODE(file) _setmode(_fileno(file), O_BINARY)
    #define SET_TEXT_MODE(file) _setmode(_fileno(file), O_TEXT)
    #define stringcompare(...) _strcmpi(__VA_ARGS__)
#else
    #define SET_BINARY_MODE(file)
    #define stringcompare(...) strcmpi(__VA_ARGS__)
#endif
#define QMX_PRINTF_LOCK if (qmx_printfLock == NULL) {qmx_printfLock = (CRITICAL_SECTION*)calloc(1, sizeof(CRITICAL_SECTION)); InitializeCriticalSection(qmx_printfLock);} EnterCriticalSection(qmx_printfLock);
//#define QMX_PRINTF_LOCK
#define QMX_PRINTF_UNLOCK if (qmx_printfLock != NULL) LeaveCriticalSection(qmx_printfLock);
//#define QMX_PRINTF_UNLOCK
//#define QMX_LOGFILE "C:\\Users\\Tim\\QCamSDK\\qcammex-log.txt"
#ifdef QMX_LOGFILE
    //TO032508A
    FILE* qmx_logFile;
    #define QMX_OPEN_LOG qmx_logFile = fopen(QMX_LOGFILE, "a");
    #define QMX_CLOSE_LOG fclose(qmx_logFile);
    #define QMX_PRINTF_MACRO(...) { QMX_PRINTF_LOCK QMX_OPEN_LOG fprintf(qmx_logFile, __VA_ARGS__); QMX_CLOSE_LOG QMX_PRINTF_UNLOCK }
    #define QMX_PRINTF_UNSYNCHRONIZED(...) QMX_PRINTF_MACRO(__VA_ARGS__)
#else
  #ifdef MATLAB_MEX_FILE
    #define QMX_PRINTF_MACRO(...) { QMX_PRINTF_LOCK mexPrintf(__VA_ARGS__); QMX_PRINTF_UNLOCK }
    #define QMX_PRINTF_UNSYNCHRONIZED(...) { QMX_PRINTF_LOCK printf(__VA_ARGS__); QMX_PRINTF_UNLOCK } // mexPrintf(__VA_ARGS__);
  #else
    //#define QMX_PRINTF_MACRO(...) { QMX_PRINTF_LOCK printf(__VA_ARGS__); QMX_PRINTF_UNLOCK }
    #define QMX_PRINTF_MACRO(...) { printf(__VA_ARGS__); }
    #define QMX_PRINTF_UNSYNCHRONIZED(...) printf(__VA_ARGS__);
    #endif
  #endif

#define QMX_WAIT_YIELD_IMPLEMENTATION SwitchToThread();
//#define QMX_WAIT_YIELD_IMPLEMENTATION Sleep(40); //Don't recheck too rapidly. Meant for testing thread interactions.

/*
 * Constants and header values.
 *
 */
//Numeric constants.
#define QCAMMEX_VERSION 0.1
#define QMX_OUTPUT_FILE_VERSION 0.1
#define QMX_OUTPUT_FILE_HEADER_SIZE 512 //Bytes. What is sufficient/excessive?
#define QMX_OUTPUT_FILE_FORMAT_RAW16 1 //No compression, 16-bit pixels (LSB aligned), flat frame layout.
#define QMX_OUTPUT_FILE_FORMAT_BZ2 2
#define QMX_OUTPUT_FILE_FORMAT_ZIP 3
#define QMX_OUTPUT_FILE_FORMAT_DEFLATE 4
#define QMX_OUTPUT_FILE_BYTES_PER_PIXEL 2
#define QMX_CIRCULAR_BUFFER_INVALID_POSITION 0xFFFFFFFF
#define QMX_CIRCULAR_BUFFER_OK 0
#define QMX_CIRCULAR_BUFFER_FULL 1
#define QMX_CIRCULAR_BUFFER_EMPTY 2
#define QMX_CIRCULAR_BUFFER_TIMEOUT 3
#define QMX_CIRCULAR_BUFFER_INTERRUPT 4
#define QMX_CIRCULAR_BUFFER_STATE_CHANGE 5
#define QMX_CIRCULAR_BUFFER_ERROR -1
#define QMX_CIRCULAR_BUFFER_SERIOUS_ERROR -2
#define QMX_CIRCULAR_BUFFER_CLOSED 0xFFFFFFEE
#define QMX_MAX_QUEUED_FRAME_BUFFERS 50//Maximum across all queues, including QImaging's internal asynchronous queue. This hard limits things to ~100MB.
#define QMX_STREAMING_MODE_ASYNC 0
#define QMX_STREAMING_MODE_SYNC 1
#define QMX_DEFAULT_BUFFER_SIZE 5
#define QMX_DEFAULT_QUEUE_TIMEOUT 75 //Milliseconds.
#define QMX_WORKER_THREAD_TIMEOUT 75 //Milliseconds.
#define QMX_OUTFILENAME_BUFFERSIZE 256
//Strings for header encoding/decoding.
#define QMX_HEADER_DELIMITER ": "
#define QMX_HEADER_SUFFIX "\r\n"
#define QMX_HEADER_SUFFIX_BYTES " [bytes]" QMX_HEADER_SUFFIX
#define QMX_HEADER_NAME_VERSION "Encoding-Version"
#define QMX_HEADER_NAME_SIZE "Fixed-Header-Size"
#define QMX_HEADER_NAME_ROI "ROI"
#define QMX_HEADER_SUFFIX_ROI " [x, y, width, height]" QMX_HEADER_SUFFIX
#define QMX_HEADER_NAME_QMX_HEADER_SIZE "Fixed-Header-Size"
#define QMX_HEADER_NAME_FRAME_SIZE "Frame-Size"
#define QMX_HEADER_NAME_QMX_IMAGEENCODING "Image-Encoding"
#define QMX_HEADER_NAME_QMX_IMAGEFORMAT "Image-Format"
#define QMX_HEADER_NAME_QMX_BYTESPERPIXEL "Bytes-Per-Pixel"
#define QMX_HEADER_NAME_TRIGGER_TYPE "Trigger-Type"
#define QMX_IMAGEENCODING_STR_RAW16 "raw16"
#define QMX_IMAGEENCODING_STR_BZ2 "bz2"
#define QMX_IMAGEENCODING_STR_ZIP "zip"
#define QMX_IMAGEENCODING_STR_DEFLATE "DEFLATE"
#define QMX_IMAGEFORMAT_MONO16 "Mono16"
#define QMX_IMAGEFORMAT_MONO8 "Mono8"

/*
 * Callback function declarations (only those needed for compiling).
 *
 */
void QCAMAPI qmx_FrameDoneCallback(QCam_Frame* frame, unsigned long sizeInBytes, QCam_Err errCode, unsigned long flags);
/*
 * Types.
 *
 */
//Only the fields that are needed to parse the rest of the file will get loaded here.
typedef struct
{
    double version;//Make sure the version is supported.
    long int headerSize;//The total header size is fixed. Check against QMX_OUTPUT_FILE_HEADER_SIZE.
    //ROI fields...
    unsigned long int roiX;
    unsigned long int roiY;
    unsigned long int roiWidth;
    unsigned long int roiHeight;
    unsigned long int frameSizeInBytes;//To allow jumping from frame to frame. May be invalidated by encodings with compression.
    int imageEncoding;//Compression and archive layout.
    QCam_ImageFormat imageFormat;//Implies bit depth and color.
    FILE* stream;
    unsigned long int fileSizeInBytes;//For sanity checking.
    unsigned long int bytesPerPixel;//More sanity checking.
    int bitsPerPixel;//Even more sanity checking.
} qmx_QCamFile;

typedef void (*qmx_QueueFullCallback) (void* ptr);

//Implement our own circular buffer with queueing semantics for multithreading.
typedef struct
{
    unsigned int readPos;
    unsigned int writePos;
    unsigned int dropOnFull;//When this is 0, it overwrites on full.
    unsigned int bufferSize;
    QCam_Frame** buffer;
    unsigned int pixelBufferSize;
    HANDLE lock[3];//Mutex, reader/writer event, state change event. The event is to allow cross-thread interruption.
    volatile long int refCount;//Atomically keep track of waiting threads.
    volatile DWORD threadID;//Don't recurse mutex ownership, because Microsoft sucks.
    qmx_QueueFullCallback cBuffFullCallback;
    void* cBuffFullCallbackPtr;
} qmx_CircularBuffer;

/*
 * Global variables.
 *
 */
//File I/O.
char*           qmx_baseFilename = NULL;
FILE*           qmx_outputFile = NULL;
int             qmx_fileFormat = QMX_OUTPUT_FILE_FORMAT_RAW16;
unsigned int    qmx_framesPerFile = 1;
char*           qmx_headerData = NULL;
char*           qmx_userTimingData = NULL;
unsigned int    qmx_framesWrittenCounter = 0;
unsigned int    qmx_totalFramesWrittenCounter = 0; //JL04082008 Add a new variable qmx_totalFramesWrittenCounter, this one doesn't be reset in qmx_initfile.
char            qmx_fileInitTimestamp[20] = {'\0'};
int             qmx_fileCounter = 0;
char            qmx_outputFileName[QMX_OUTFILENAME_BUFFERSIZE];//TO032408A
CRITICAL_SECTION* qmx_fileLock;
unsigned int    qmx_framesToAcquire = 0;//TO032708H
//Driver and camera handles.
int             qmx_driverResident = 0;
QCam_Handle     qmx_cameraHandle;
QCam_Settings   qmx_camSettings;
//Threads
HANDLE          qmx_synchronousThread = NULL;
DWORD           qmx_synchronousThreadID;
HANDLE          qmx_diskLoggingThread = NULL;
DWORD           qmx_diskLoggingThreadID;
HANDLE          qmx_frameAverageThread = NULL;
DWORD           qmx_frameAverageThreadID;
//Buffers.
QCam_Frame*     qmx_frameCache[QMX_MAX_QUEUED_FRAME_BUFFERS];
QCam_Frame*     qmx_displayFrameBuffer;//Store the "latest" frame here, for Matlab access.
bool            qmx_displayFrameBufferStale = true;
CRITICAL_SECTION* qmx_displayBufferLock;
unsigned long int qmx_lastDisplayFrameBufferUpdate;
unsigned long int qmx_maxDisplayUpdateInterval = 40;//No more than once every 40ms (ie. 25Hz).
unsigned long int qmx_lastDisplayFrameBufferUpdate = 0;
qmx_CircularBuffer* qmx_preprocessorStream = NULL;//Frames retrieved from the camera go here (ie. for averaging).
unsigned long long int* qmx_preprocessorResult;//Temporary, non-pipelined buffer for computing. //TO032708E
qmx_CircularBuffer* qmx_inputBufferStream = NULL;//Frames retrieved from the camera go here if preprocessing is not enabled.
qmx_CircularBuffer* qmx_outputBufferStream = NULL;//Frames waiting disk logging go here.
int             qmx_inputStreamBufferSize = QMX_DEFAULT_BUFFER_SIZE;
int             qmx_outputStreamBufferSize = QMX_DEFAULT_BUFFER_SIZE;
int             qmx_preprocessorTimeout = QMX_DEFAULT_QUEUE_TIMEOUT;//Milliseconds.
int             qmx_outputBufferTimeout = QMX_DEFAULT_QUEUE_TIMEOUT;//Milliseconds.
//State.
int             qmx_streamingMode = QMX_STREAMING_MODE_SYNC;//Default to synchronous, which gives us more control.
bool            qmx_runningAsync = false;
bool            qmx_runningSync = false;//Implement queued asynchronous acquisition internally.
bool            qmx_stopThreadsFlag = true;//Flag for the thread to stop.
bool            qmx_diskLoggingOn;
bool            qmx_diskLoggingRunning;
bool            qmx_frameAverageRunning;
int             qmx_averagedFrameCounter = 0;
int             qmx_totalAveragedFrameCounter = 0;//TO032708F
int             qmx_averageFrames = 1;//This is used as the preprocessing flag and preprocessor buffer size, if it's greater than 1.
int             qmx_triggerType = -1;//TO032708M
//Statistics.
unsigned int    qmx_frameCounter = 0;
unsigned int    qmx_totalFrameCounter = 0;//This one doesn't get reset.
unsigned long int qmx_totalFrameGrabLatency = 0xFFFFFFFF;
unsigned long int qmx_lastFrameTime = 0xFFFFFFFF;
//Debugging.
int             qmx_debugOn = false;
int             qmx_cBuffDebugOn = false;
int             qmx_printEveryFrame = true;//Depends on qmx_debugOn.
int             qmx_printPixelRangeInFrame = true;//Depends on qmx_printEveryFrame.
unsigned long int qmx_pixelCount; //JL04082008F add vairable qmx_pixelCount
int             qmx_queueAsncFrameCounter = 5;
CRITICAL_SECTION* qmx_printfLock;//Keep the output readable.

/*
 * To-String conversions.
 *
 */
char* qmx_imageFormat2String(int format)
{
    switch (format)
    {
        case qfmtMono16:
            return QMX_IMAGEFORMAT_MONO16;
        case qfmtMono8:
            return QMX_IMAGEFORMAT_MONO8;
        default:
            return "UNSUPPORTED_FORMAT";
    }
}

char* qmx_imageEncoding2String(int imageEncoding)
{
    switch (imageEncoding)
    {
        case QMX_OUTPUT_FILE_FORMAT_RAW16:
            return QMX_IMAGEENCODING_STR_RAW16;
        case QMX_OUTPUT_FILE_FORMAT_BZ2:
            return QMX_IMAGEENCODING_STR_BZ2;
        case QMX_OUTPUT_FILE_FORMAT_ZIP:
            return QMX_IMAGEENCODING_STR_ZIP;
        case QMX_OUTPUT_FILE_FORMAT_DEFLATE:
            return QMX_IMAGEENCODING_STR_DEFLATE;
        default:
            return "UNKOWN_ENCODING";
    }
}

char* qmx_circularBufferReturnCode2String(int code)
{
    switch (code)
    {
        case QMX_CIRCULAR_BUFFER_OK:
            return "QMX_CIRCULAR_BUFFER_OK";
        case QMX_CIRCULAR_BUFFER_FULL:
            return "QMX_CIRCULAR_BUFFER_FULL";
        case QMX_CIRCULAR_BUFFER_EMPTY:
            return "QMX_CIRCULAR_BUFFER_EMPTY";
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            return "QMX_CIRCULAR_BUFFER_TIMEOUT";
        case QMX_CIRCULAR_BUFFER_INTERRUPT:
            return "QMX_CIRCULAR_BUFFER_INTERRUPT";
        case QMX_CIRCULAR_BUFFER_STATE_CHANGE:
            return "QMX_CIRCULAR_BUFFER_STATE_CHANGE";
        case QMX_CIRCULAR_BUFFER_ERROR:
            return "QMX_CIRCULAR_BUFFER_ERROR";
        case QMX_CIRCULAR_BUFFER_SERIOUS_ERROR:
            return "QMX_CIRCULAR_BUFFER_SERIOUS_ERROR";
        case QMX_CIRCULAR_BUFFER_CLOSED:
            return "QMX_CIRCULAR_BUFFER_CLOSED";
        default:
            return "Unknown-circular-buffer-return-code";
    }
}

//TO032708M
char* qmx_triggerType2String(int triggerType)
{
    switch (triggerType)
    {
    	case qcTriggerEdgeHi:
        	return "External (rising edge)";
    	case qcTriggerEdgeLow:
        	return "External (falling edge)";
    	case qcTriggerFreerun:
        	return "Freerun (None)";
    	case qcTriggerPulseHi:
        	return "PulseHi (integrate over pulse, with masking)";
    	case qcTriggerPulseLow:
        	return "PulseLow (integrate over pulse, with masking)";
    	case qcTriggerSoftware:
        	return "Software";
    	case qcTriggerStrobeHi:
        	return "StrobeHi (integrate over pulse, without masking)";
    	case qcTriggerStrobeLow:
        	return "StrobeLow (integrate over pulse, without masking)";
        default:
            return "Indeterminate (not yet explicitly set)";
    }
}

/*
 * Statistics.
 *
 */
double qmx_getEstimatedFrameRate()
{
    //100 * NumberOfFrames / MsBetweenFrames
    return 1000.0 * (double)qmx_frameCounter / (double)qmx_totalFrameGrabLatency;
}

/*
 * Informational displays.
 *
 */
void qmx_printCameraListItem(QCam_CamListItem cam)
{
    QMX_PRINTF_UNSYNCHRONIZED(" cameraId: %d\n cameraType: %d\n uniqueId: %d\n isOpen: %d\n\n", cam.cameraId, cam.cameraType, cam.uniqueId, cam.isOpen);
    return;
}

int qmx_errorMsg(QCam_Err result, char* msg)
{
    int failure = 1;

    switch (result)
    {
        case qerrSuccess:
            failure = 0;
            break;
        case qerrNotSupported:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrNotSupported\n", msg);
            break;
        case qerrInvalidValue:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrInvalidValue\n", msg);
            break;
        case qerrBadSettings:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrBadSettings\n", msg);
            break;
        case qerrNoUserDriver:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrNoUserDriver\n", msg);
            break;
        case qerrNoFirewireDriver:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrNoFirewireDriver\n", msg);
            break;
        case qerrDriverConnection:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrDriverConnection\n", msg);
            break;
        case qerrDriverAlreadyLoaded:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrDriverAlreadyLoaded\n", msg);
            break;
        case qerrDriverNotLoaded:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrDriverNotLoaded\n", msg);
            break;
        case qerrInvalidCameraId:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrInvalidCameraId\n", msg);
            break;
        case qerrNoMoreConnections:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrNoMoreConnections\n", msg);
            break;
        case qerrHardwareFault:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrHardwareFault\n", msg);
            break;
        case qerrFirewireFault:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrFirewireFault\n", msg);
            break;
        case qerrCameraFault:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrCameraFault\n", msg);
            break;
        case qerrDriverFault:
            //JL04112008D comment qerrDriverFault warning out to avoid confusing users
            //QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrDriverFault\n", msg);
            break;
        case qerrInvalidFrameIndex:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrInvalidFrameIndex\n", msg);
            break;
        case qerrBufferTooSmall:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrBufferTooSmall\n", msg);
            break;
        case qerrOutOfMemory:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrOutOfMemory\n", msg);
            break;
        case qerrOutOfSharedMemory:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrOutOfSharedMemory\n", msg);
            break;
        case qerrBusy:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrBusy\n", msg);
            break;
        case qerrQueueFull:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrQueueFull\n", msg);
            break;
        case qerrCancelled:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrCancelled\n", msg);
            break;
        case qerrNotStreaming:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrNotStreaming\n", msg);
            break;
        case qerrLostSync:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrLostSync\n", msg);
            break;
        case qerrBlackFill:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrBlackFill\n", msg);
            break;
        case qerrFirewireOverflow:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrFirewireOverflow\n", msg);
            break;
        case qerrUnplugged:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrUnplugged\n", msg);
            break;
        case qerrAccessDenied:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrAccessDenied\n", msg);
            break;
        case qerrStreamFault:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrStreamFault\n", msg);
            break;
        case qerrQCamUpdateNeeded:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrQCamUpdateNeeded\n", msg);
            break;
        case qerrRoiTooSmall:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: qerrRoiTooSmall\n", msg);
            break;
        default:
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: %s - QCam_Err: Unrecognized QCam_Err value - %d\n", msg, result);
            break;
    }

    return failure;
}

void qmx_printFrame(QCam_Frame* frame)
{
    unsigned int min = 0xFFFFFFFF;
    unsigned int max = 0;
    int i = 0;
    int bytesPerPixel = 2;
    
    QMX_PRINTF_LOCK

    QMX_PRINTF_UNSYNCHRONIZED(" QCam_Frame: @%p\n", frame);
    if (frame == NULL)
    {
        QMX_PRINTF_UNSYNCHRONIZED("\tNULL\n");
        QMX_PRINTF_UNLOCK
        return;
    }
    QMX_PRINTF_UNSYNCHRONIZED("\tpBuffer: @%p\n", frame->pBuffer);
    QMX_PRINTF_UNSYNCHRONIZED("\tbufferSize: %lu\n", frame->bufferSize);
    QMX_PRINTF_UNSYNCHRONIZED("\tformat: %s\n", qmx_imageFormat2String(frame->format));
    QMX_PRINTF_UNSYNCHRONIZED("\twidth: %lu [pixels]\n", frame->width);
    QMX_PRINTF_UNSYNCHRONIZED("\theight: %lu [pixels]\n", frame->height);
    QMX_PRINTF_UNSYNCHRONIZED("\tsize: %lu [bytes]\n", frame->size);
    QMX_PRINTF_UNSYNCHRONIZED("\tbits (bit depth): %hu\n", frame->bits);
    QMX_PRINTF_UNSYNCHRONIZED("\tframeNumber: %hu\n", frame->frameNumber);
    QMX_PRINTF_UNSYNCHRONIZED("\tbayerPattern: %p\n", frame->bayerPattern);
    QMX_PRINTF_UNSYNCHRONIZED("\terrorCode: %lu\n", frame->errorCode);
    QMX_PRINTF_UNSYNCHRONIZED("\ttimeStamp: %lu\n", frame->timeStamp);

    if ((frame->pBuffer != NULL) && qmx_printPixelRangeInFrame)
    {
        QMX_PRINTF_UNSYNCHRONIZED("\t Checking pixel range...\n");
        bytesPerPixel = (frame->format == qfmtMono8) ? 1 : 2;
        QMX_PRINTF_UNSYNCHRONIZED("\t  Bytes Per Pixel: %ld\n", bytesPerPixel);
        switch (frame->format)
        {
            case qfmtMono8:
                for (i = 0; i < frame->width * frame->height; i = i++ * bytesPerPixel)
                {
                    if (((char*)frame->pBuffer)[i] > max)
                        max = ((char*)frame->pBuffer)[i];
                    if (((char*)frame->pBuffer)[i] < min)
                        min = ((char*)frame->pBuffer)[i];
                }
                break;

           case qfmtMono16:
                for (i = 0; i < frame->width * frame->height; i = i++ * bytesPerPixel)
                {
                    if (((unsigned short*)frame->pBuffer)[i] > max)
                        max = ((unsigned short*)frame->pBuffer)[i];
                    if (((unsigned short*)frame->pBuffer)[i] < min)
                        min = ((unsigned short*)frame->pBuffer)[i];
                }
                break;

           default:
               QMX_PRINTF_UNSYNCHRONIZED("\t  Unsupported pixel buffer format value for analysis.\n");
               QMX_PRINTF_UNLOCK
               return;
        }
        QMX_PRINTF_UNSYNCHRONIZED("\t  Actual Pixel Range: %hu (0x%04.4hX) - %hu (0x%04.4hX)\n", min, min, max, max);
    }

    QMX_PRINTF_UNLOCK

    return;
}


void qmx_printCamera(QCam_Handle cameraHandle)
{
    QCam_Info camInfo;
    unsigned long hardwareVersion, firmwareVersion, firmwareBuild, uniqueID, exposureRes, triggerDelayRes, streamVersion;
    QCam_Settings currentSettings;
    char serialString[128] = {'\0'};
    unsigned long x, y, width, height, binFactor, imageFormat, highSensitivityMode, normalizedGain, sizeInBytes, triggerType;
    long int absoluteOffset;
    unsigned long long int exposureTimeInNS;

    QMX_PRINTF_LOCK

    QMX_PRINTF_UNSYNCHRONIZED("Camera info - \n");
    if (cameraHandle == NULL)
    {
        QMX_PRINTF_UNSYNCHRONIZED("\tNULL\n");
        QMX_PRINTF_UNLOCK
        return;
    }
    QCam_GetSerialString(cameraHandle, serialString, 128);
    QMX_PRINTF_UNSYNCHRONIZED(" Serial Number: %s\n", serialString);
    QCam_GetInfo(cameraHandle, qinfHardwareVersion, &hardwareVersion);
    QMX_PRINTF_UNSYNCHRONIZED(" Hardware Version: %lu\n", hardwareVersion);
    QCam_GetInfo(cameraHandle, qinfFirmwareVersion, &firmwareVersion);
    QMX_PRINTF_UNSYNCHRONIZED(" Firmware Version: %lu\n", firmwareVersion);
    QCam_GetInfo(cameraHandle, qinfFirmwareBuild, &firmwareBuild);
    QMX_PRINTF_UNSYNCHRONIZED(" Firmware Version: %lu\n", firmwareBuild);
    QCam_GetInfo(cameraHandle, qinfUniqueId, &uniqueID);
    QMX_PRINTF_UNSYNCHRONIZED(" Unique ID: %lu\n", uniqueID);
    QCam_GetInfo(cameraHandle, qinfExposureRes, &exposureRes);
    QMX_PRINTF_UNSYNCHRONIZED(" Exposure Time Resolution: %lu [ns]\n", exposureRes);
    QCam_GetInfo(cameraHandle, qinfTriggerDelayRes, &triggerDelayRes);
    QMX_PRINTF_UNSYNCHRONIZED(" Trigger Delay Time Resolution: %lu [ns]\n", triggerDelayRes);
    QCam_GetInfo(cameraHandle, qinfStreamVersion, &streamVersion);
    QMX_PRINTF_UNSYNCHRONIZED(" Stream Version: %lu\n", streamVersion);
    QCam_GetInfo(cameraHandle, qinfImageSize, &sizeInBytes);
    QMX_PRINTF_UNSYNCHRONIZED(" Frame Size: %lu [bytes]\n", sizeInBytes);
    if (qmx_errorMsg(QCam_ReadSettingsFromCam(qmx_cameraHandle, &currentSettings), "qmx_PrintCamera"))
    {
        QMX_PRINTF_MACRO("qcammex.c: Error retrieving settings from camera.\n");
        QMX_PRINTF_UNLOCK
        return;
    }
    QMX_PRINTF_UNSYNCHRONIZED(" Current Camera Settings -\n");
    QCam_GetParam(&qmx_camSettings, qprmRoiX, &x);
	QCam_GetParam(&qmx_camSettings, qprmRoiY, &y);
	QCam_GetParam(&qmx_camSettings, qprmRoiWidth, &width);
	QCam_GetParam(&qmx_camSettings, qprmRoiHeight, &height);
    QMX_PRINTF_UNSYNCHRONIZED("  ROI: %lu, %lu, %lu, %lu [x, y, width, height]\n", x, y, width, height);
    QCam_GetParam64(&qmx_camSettings, qprm64Exposure, &exposureTimeInNS);
    QMX_PRINTF_UNSYNCHRONIZED("  Exposure: %llu [ns]\n", exposureTimeInNS);
    QCam_GetParam(&qmx_camSettings, qprmBinning, &binFactor);
    QMX_PRINTF_UNSYNCHRONIZED("  Binning: %dx%d [pixels]\n", binFactor, binFactor);
    QCam_GetParam(&qmx_camSettings, qprmHighSensitivityMode, &highSensitivityMode);
    if (highSensitivityMode)
        QMX_PRINTF_UNSYNCHRONIZED("  High-Sensitivity-Mode: On\n")
    else
        QMX_PRINTF_UNSYNCHRONIZED("  High-Sensitivity-Mode: Off\n")
    QCam_GetParam(&qmx_camSettings, qprmNormalizedGain, &normalizedGain);
    QMX_PRINTF_UNSYNCHRONIZED("  NormalizedGain: %d\n", normalizedGain);
    QCam_GetParamS32(&qmx_camSettings, qprmS32AbsoluteOffset, &absoluteOffset);
    QMX_PRINTF_UNSYNCHRONIZED("  AbsoluteOffset: %d\n", absoluteOffset);
    QCam_GetParam(&qmx_camSettings, qprmImageFormat, &imageFormat);
    QMX_PRINTF_UNSYNCHRONIZED("  ImageFormat: %s\n", qmx_imageFormat2String(imageFormat));
    QCam_GetParam(&qmx_camSettings, qprmTriggerType, &triggerType);
    QMX_PRINTF_UNSYNCHRONIZED("  TriggerType: %s\n", triggerType);

    QMX_PRINTF_UNLOCK

    return;
}

void qmx_printQCamFileStruct(qmx_QCamFile* qcf)
{
    QMX_PRINTF_LOCK

    QMX_PRINTF_UNSYNCHRONIZED("qmx_QCamFile structure -\n");
    QMX_PRINTF_UNSYNCHRONIZED("\tversion: %1.2f\n", qcf->version);
    QMX_PRINTF_UNSYNCHRONIZED("\troiX: %lu\n", qcf->roiX);
    QMX_PRINTF_UNSYNCHRONIZED("\troiY: %lu\n", qcf->roiY);
    QMX_PRINTF_UNSYNCHRONIZED("\troiWidth: %lu\n", qcf->roiWidth);
    QMX_PRINTF_UNSYNCHRONIZED("\troiHeight: %lu\n", qcf->roiHeight);
    QMX_PRINTF_UNSYNCHRONIZED("\tframeSizeInBytes: %ld\n", qcf->frameSizeInBytes);
    QMX_PRINTF_UNSYNCHRONIZED("\timageEncoding: %lu\n", qmx_imageEncoding2String(qcf->imageEncoding));
    QMX_PRINTF_UNSYNCHRONIZED("\timageFormat: %lu\n", qmx_imageFormat2String(qcf->imageFormat));
    QMX_PRINTF_UNSYNCHRONIZED("\tfileSizeInBytes: %lu\n", qcf->fileSizeInBytes);
    QMX_PRINTF_UNSYNCHRONIZED("\theaderSize: %lu\n", qcf->headerSize);
    QMX_PRINTF_UNSYNCHRONIZED("\tbytesPerPixel: %lu\n", qcf->bytesPerPixel);
    QMX_PRINTF_UNSYNCHRONIZED("\tbitsPerPixel: %d\n", qcf->bitsPerPixel);

    QMX_PRINTF_UNLOCK

    return;
}

void qmx_printBufferPosition(unsigned int pos)
{
    if (pos == QMX_CIRCULAR_BUFFER_INVALID_POSITION)
        QMX_PRINTF_UNSYNCHRONIZED("QMX_CIRCULAR_BUFFER_INVALID_POSITION")
    else if (pos == QMX_CIRCULAR_BUFFER_CLOSED)
        QMX_PRINTF_UNSYNCHRONIZED("QMX_CIRCULAR_BUFFER_CLOSED")
    else
        QMX_PRINTF_UNSYNCHRONIZED("%lu", pos)
    
    return;
}

void qmx_printQueue(qmx_CircularBuffer* cBuff)
{
    int i = 0;
    
    QMX_PRINTF_LOCK
    
    QMX_PRINTF_UNSYNCHRONIZED("qmx_CircularBuffer -\n");
    if (cBuff == NULL)
    {
        QMX_PRINTF_UNSYNCHRONIZED(" NULL\n");
        QMX_PRINTF_UNLOCK
        return;
    }
    
    QMX_PRINTF_UNSYNCHRONIZED(" readPos: ");
    qmx_printBufferPosition(cBuff->readPos);
    QMX_PRINTF_UNSYNCHRONIZED("\n");
    QMX_PRINTF_UNSYNCHRONIZED(" writePos: ");
    qmx_printBufferPosition(cBuff->writePos);
    QMX_PRINTF_UNSYNCHRONIZED("\n");
    QMX_PRINTF_UNSYNCHRONIZED(" dropOnFull: %lu\n", cBuff->dropOnFull);
    QMX_PRINTF_UNSYNCHRONIZED(" bufferSize: %lu\n", cBuff->bufferSize);
    QMX_PRINTF_UNSYNCHRONIZED(" pixelBufferSize: %lu\n", cBuff->pixelBufferSize);
    QMX_PRINTF_UNSYNCHRONIZED(" mutex: @%p\n", cBuff->lock[0]);
    QMX_PRINTF_UNSYNCHRONIZED(" reader/writer event: @%p\n", cBuff->lock[1]);
    QMX_PRINTF_UNSYNCHRONIZED(" state change event: @%p\n", cBuff->lock[2]);
    QMX_PRINTF_UNSYNCHRONIZED(" cBuffFullCallback: @%p\n", cBuff->cBuffFullCallback);
    QMX_PRINTF_UNSYNCHRONIZED(" cBuffFullCallbackPtr: @%p\n", cBuff->cBuffFullCallbackPtr);
    QMX_PRINTF_UNSYNCHRONIZED(" refCount: %d\n", cBuff->refCount);
    QMX_PRINTF_UNSYNCHRONIZED(" threadID: %d\n", cBuff->threadID);
    QMX_PRINTF_UNSYNCHRONIZED(" buffer:\n");
    for (i = 0; i < cBuff->bufferSize; i++)
        qmx_printFrame((QCam_Frame *)cBuff->buffer[i]);
    
    QMX_PRINTF_UNLOCK
    
    return;
}

void qmx_printState(void)
{
    int i = 0;

    QMX_PRINTF_LOCK
    QMX_PRINTF_UNSYNCHRONIZED("qcammex.c - Full State -\n");
    QMX_PRINTF_UNSYNCHRONIZED(" File I/O.\n");
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_baseFilename: %s\n", qmx_baseFilename);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_outputFile: @%p\n", qmx_outputFile);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_fileFormat: %s\n", qmx_imageEncoding2String(qmx_fileFormat));
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_framesPerFile: %u\n", qmx_framesPerFile);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_headerData: %s\n", qmx_headerData);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_userTimingData: %s\n", qmx_userTimingData);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_framesWrittenCounter: %u\n", qmx_framesWrittenCounter);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_totalFramesWrittenCounter: %u\n", qmx_totalFramesWrittenCounter);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_fileInitTimestamp: %s\n", qmx_fileInitTimestamp);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_fileCounter: %d\n", qmx_fileCounter);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_fileLock: @%p\n", qmx_fileLock);

    QMX_PRINTF_UNSYNCHRONIZED(" Driver and camera handles.\n");
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_driverResident: %d\n", qmx_driverResident);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_cameraHandle: @%p\n", qmx_cameraHandle);
    qmx_printCamera(qmx_cameraHandle);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_camSettings: @%p\n", qmx_camSettings);

    QMX_PRINTF_UNSYNCHRONIZED(" Threads.\n");
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_synchronousThread: @%p\n", qmx_synchronousThread);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_synchronousThreadID: %p\n", qmx_synchronousThreadID);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_diskLoggingThread: @%p\n", qmx_diskLoggingThread);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_diskLoggingThreadID: %p\n", qmx_diskLoggingThreadID);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_frameAverageThread: @%p\n", qmx_frameAverageThread);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_frameAverageThreadID: %p\n", qmx_frameAverageThreadID);

    QMX_PRINTF_MACRO(" Buffers.\n");
    QMX_PRINTF_MACRO("  qmx_frameCache[%d]: @%p\n", QMX_MAX_QUEUED_FRAME_BUFFERS, qmx_frameCache);
    for (i = 0; i < QMX_MAX_QUEUED_FRAME_BUFFERS; i++)
        qmx_printFrame(qmx_frameCache[i]);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_displayFrameBuffer: %d\n", qmx_displayFrameBuffer);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_displayFrameBufferStale: %d\n", qmx_displayFrameBufferStale);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_lastDisplayFrameBufferUpdate: %lu\n", qmx_lastDisplayFrameBufferUpdate);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_maxDisplayUpdateInterval: %lu\n", qmx_maxDisplayUpdateInterval);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_preprocessorStream -\n");
    qmx_printQueue(qmx_preprocessorStream);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_inputBufferStream -\n");
    qmx_printQueue(qmx_inputBufferStream);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_outputBufferStream -\n");
    qmx_printQueue(qmx_outputBufferStream);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_inputStreamBufferSize: %d\n", qmx_inputStreamBufferSize);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_outputStreamBufferSize: %d\n", qmx_outputStreamBufferSize);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_preprocessorTimeout: %d\n", qmx_preprocessorTimeout);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_outputBufferTimeout: %d\n", qmx_outputBufferTimeout);

    QMX_PRINTF_UNSYNCHRONIZED(" State.\n");
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_averageFrames: %d\n", qmx_averageFrames);
    if (qmx_streamingMode == QMX_STREAMING_MODE_SYNC)
        QMX_PRINTF_UNSYNCHRONIZED("  qmx_streamingMode: QMX_STREAMING_MODE_SYNC\n")
    else
        QMX_PRINTF_UNSYNCHRONIZED("  qmx_streamingMode: QMX_STREAMING_MODE_ASYNC\n")
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_runningAsync: %d\n", qmx_runningAsync);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_runningSync: %d\n", qmx_runningSync);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_stopThreadsFlag: %d\n", qmx_stopThreadsFlag);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_diskLoggingOn: %d\n", qmx_diskLoggingOn);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_diskLoggingRunning: %d\n", qmx_diskLoggingRunning);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_frameAverageRunning: %d\n", qmx_frameAverageRunning);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_averagedFrameCounter: %d\n", qmx_averagedFrameCounter);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_totalAveragedFrameCounter: %d\n", qmx_totalAveragedFrameCounter);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_triggerType: %s\n", qmx_triggerType2String(qmx_triggerType));//TO032708M
    QMX_PRINTF_UNSYNCHRONIZED(" Statistics.\n");
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_totalFrameCounter: %lu\n", qmx_totalFrameCounter);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_frameCounter: %lu\n", qmx_frameCounter);
    if ((qmx_totalFrameGrabLatency == 0xFFFFFFFF) || (qmx_lastFrameTime = 0xFFFFFFFF))
    {
        QMX_PRINTF_UNSYNCHRONIZED("  qmx_totalFrameGrabLatency: UNINITIALIZED [ms]\n");
        QMX_PRINTF_UNSYNCHRONIZED("  qmx_lastFrameTime: UNINITIALIZED [ms since last restart]\n");
        QMX_PRINTF_UNSYNCHRONIZED("   Estimated frame rate: ??? [Hz]\n", qmx_getEstimatedFrameRate());
    }
    else
    {
        QMX_PRINTF_UNSYNCHRONIZED("  qmx_totalFrameGrabLatency: %lu [ms]\n", qmx_totalFrameGrabLatency);
        QMX_PRINTF_UNSYNCHRONIZED("  qmx_lastFrameTime: %lu [ms since last restart]\n", qmx_lastFrameTime);
        QMX_PRINTF_UNSYNCHRONIZED("   Estimated frame rate: %6.2lf [Hz]\n", qmx_getEstimatedFrameRate());
    }

    QMX_PRINTF_UNSYNCHRONIZED(" Debugging.\n");
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_debugOn: %d\n", qmx_debugOn);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_cBuffDebugOn: %d\n", qmx_cBuffDebugOn);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_printEveryFrame: %d\n", qmx_printEveryFrame);
    QMX_PRINTF_UNSYNCHRONIZED("  qmx_printPixelRangeInFrame: %d\n", qmx_printPixelRangeInFrame);

    QMX_PRINTF_UNSYNCHRONIZED("\n\n");
    QMX_PRINTF_LOCK

    return;
}

/*
 * QCam_Frame constructors/destructors
 * for queued frames (not globals, such as qmx_displayFrameBuffer).
 *
 */
QCam_Frame* qmx_allocateFrame()
{
    int i;
    
    //Not dynamically allocated...
    //if (qmx_frameCache == NULL)
      //  qmx_frameCache = (QCam_Frame**)calloc(QMX_MAX_QUEUED_FRAME_BUFFERS, sizeof(QCam_Frame*));

    for (i = 0; i < QMX_MAX_QUEUED_FRAME_BUFFERS; i++)
    {
        if (qmx_frameCache[i] == NULL)
        {
            qmx_frameCache[i] = (QCam_Frame*)calloc(1, sizeof(QCam_Frame));
            return qmx_frameCache[i];
        }
    }

    //No more room.
    QMX_PRINTF_MACRO("qcammex.c: qmx_allocateFrame: This is no more room to allocate a frame!.\n");
    return NULL;
}


void qmx_freeFrame(QCam_Frame** frame)
{
    int i;

    if (*frame == NULL)
        return;
    
    if ((*frame)->pBuffer != NULL)
    {
        free((*frame)->pBuffer);
        (*frame)->pBuffer = NULL;
    }
    
    if (qmx_frameCache != NULL)
    {
        for (i = 0; i < QMX_MAX_QUEUED_FRAME_BUFFERS; i++)
        {
            if (qmx_frameCache[i] == *frame)
            {
                qmx_frameCache[i] = NULL;
                break;
            }
         }
    }
    *frame = NULL;

    return;
}


/*
 * Threadsafe circular buffer (of QCam_Frame pointers) implementation.
 *
 */
void qmx_cBuff_unlock(qmx_CircularBuffer* cBuff)
{
    if (cBuff == NULL)
        return;
    InterlockedCompareExchange(&cBuff->threadID, (DWORD)NULL, cBuff->threadID);
    ReleaseMutex(cBuff->lock[0]);
    return;
}

int qmx_cBuff_doubleLock(qmx_CircularBuffer* cBuff1, qmx_CircularBuffer* cBuff2, unsigned int timeout)
{
    int result1, result2;
    volatile DWORD threadID;
    
    if ((cBuff1 == NULL) || (cBuff2 == NULL))
        return QMX_CIRCULAR_BUFFER_CLOSED;

    //First, check if this thread already owns the buffer, since Microsoft's mutexes can't handle recursive locking.
    threadID = GetCurrentThreadId();
    InterlockedCompareExchange(&threadID, true, cBuff2->threadID);
    if (!threadID)
    {
        InterlockedIncrement(&cBuff1->refCount);
        switch(WaitForMultipleObjects(3, cBuff1->lock, false, timeout))
        {
            case WAIT_OBJECT_0:
                InterlockedCompareExchange(&cBuff1->threadID, GetCurrentThreadId(), cBuff1->threadID);
                InterlockedDecrement(&cBuff1->refCount);
                result1 = QMX_CIRCULAR_BUFFER_OK;
                break;
            case WAIT_OBJECT_0 + 1:
                InterlockedDecrement(&cBuff1->refCount);
                ResetEvent(cBuff1->lock[1]);
                result1 = QMX_CIRCULAR_BUFFER_INTERRUPT;//Reader/writer event.
                break;
            case WAIT_OBJECT_0 + 2:
                InterlockedDecrement(&cBuff1->refCount);
                ResetEvent(cBuff1->lock[2]);
                result1 = QMX_CIRCULAR_BUFFER_STATE_CHANGE;//State change event.
                break;
            case WAIT_TIMEOUT:
                InterlockedDecrement(&cBuff1->refCount);
                result1 = QMX_CIRCULAR_BUFFER_TIMEOUT;
                break;
            default:
                InterlockedDecrement(&cBuff1->refCount);
                result1 = QMX_CIRCULAR_BUFFER_SERIOUS_ERROR;
                break;
        }
    }
    else
        result1 = QMX_CIRCULAR_BUFFER_OK;
    
    //Let's look for a close-out, again.
    if ((cBuff1 == NULL) || (cBuff2 == NULL))
        return QMX_CIRCULAR_BUFFER_CLOSED;

    //First, check if this thread already owns the buffer, since Microsoft's mutexes can't handle recursive locking.
    threadID = GetCurrentThreadId();
    InterlockedCompareExchange(&threadID, true, cBuff2->threadID);
    if (!threadID)
    {
        InterlockedIncrement(&cBuff2->refCount);
        switch(WaitForMultipleObjects(3, cBuff2->lock, false, timeout))
        {
            case WAIT_OBJECT_0:
                InterlockedCompareExchange(&cBuff2->threadID, GetCurrentThreadId(), cBuff2->threadID);
                InterlockedDecrement(&cBuff2->refCount);
                result2 = QMX_CIRCULAR_BUFFER_OK;
                break;
            case WAIT_OBJECT_0 + 1:
                InterlockedDecrement(&cBuff1->refCount);
                InterlockedDecrement(&cBuff2->refCount);
                ResetEvent(cBuff1->lock[1]);
                qmx_cBuff_unlock(cBuff1);
                result2 =  QMX_CIRCULAR_BUFFER_INTERRUPT;//Reader/writer event.
                break;
            case WAIT_OBJECT_0 + 2:
                InterlockedDecrement(&cBuff1->refCount);
                InterlockedDecrement(&cBuff2->refCount);
                ResetEvent(cBuff1->lock[2]);
                qmx_cBuff_unlock(cBuff1);
                result2 =  QMX_CIRCULAR_BUFFER_STATE_CHANGE;//State change event.
                break;
            case WAIT_TIMEOUT:
                InterlockedDecrement(&cBuff1->refCount);
                InterlockedDecrement(&cBuff2->refCount);
                qmx_cBuff_unlock(cBuff1);
                result2 =  QMX_CIRCULAR_BUFFER_TIMEOUT;
                break;
            default:
                InterlockedDecrement(&cBuff1->refCount);
                InterlockedDecrement(&cBuff2->refCount);
                qmx_cBuff_unlock(cBuff1);
                result2 =  QMX_CIRCULAR_BUFFER_SERIOUS_ERROR;
                break;
        }
    }
    else
        result2 = QMX_CIRCULAR_BUFFER_OK;
    
    if ((result1 != QMX_CIRCULAR_BUFFER_OK) || (result2 != QMX_CIRCULAR_BUFFER_OK))
    {
        if (result1 != QMX_CIRCULAR_BUFFER_OK)
            qmx_cBuff_unlock(cBuff1);
        if (result2 != QMX_CIRCULAR_BUFFER_OK)
            qmx_cBuff_unlock(cBuff2);
        
        return QMX_CIRCULAR_BUFFER_ERROR;
    }
    else
        return QMX_CIRCULAR_BUFFER_OK;
}

int qmx_cBuff_lock(qmx_CircularBuffer* cBuff, unsigned int timeout)
{
    volatile DWORD threadID;
    
    if (cBuff == NULL)
        return QMX_CIRCULAR_BUFFER_CLOSED;

    //First, check if this thread already owns the buffer, since Microsoft's mutexes can't handle recursive locking.
    threadID = GetCurrentThreadId();
    
    //JL04032008A change true to null or the threadID always true
    InterlockedCompareExchange(&threadID, (DWORD)NULL, cBuff->threadID);
    if (!threadID)
        return QMX_CIRCULAR_BUFFER_OK;
    
    InterlockedIncrement(&cBuff->refCount);
    switch(WaitForMultipleObjects(3, cBuff->lock, false, timeout))
    {
        case WAIT_OBJECT_0:
            InterlockedDecrement(&cBuff->refCount);
            //Mark thread ownership of this object.
            InterlockedCompareExchange(&cBuff->threadID, GetCurrentThreadId(), cBuff->threadID);
            return QMX_CIRCULAR_BUFFER_OK;
        case WAIT_OBJECT_0 + 1:
            InterlockedDecrement(&cBuff->refCount);
            ResetEvent(cBuff->lock[1]);
            return QMX_CIRCULAR_BUFFER_INTERRUPT;//Reader/writer event.
        case WAIT_OBJECT_0 + 2:
            InterlockedDecrement(&cBuff->refCount);
            ResetEvent(cBuff->lock[2]);
            return QMX_CIRCULAR_BUFFER_STATE_CHANGE;//State change event.
        case WAIT_TIMEOUT:
            InterlockedDecrement(&cBuff->refCount);
            return QMX_CIRCULAR_BUFFER_TIMEOUT;
        default:
            InterlockedDecrement(&cBuff->refCount);
            return QMX_CIRCULAR_BUFFER_SERIOUS_ERROR;
    }

    return QMX_CIRCULAR_BUFFER_SERIOUS_ERROR;//This wil never execute.
}

void qmx_cBuff_notify(qmx_CircularBuffer* cBuff)
{
    SetEvent(cBuff->lock[1]);
    SwitchToThread();
    return;
}

void qmx_cBuff_closeStream(qmx_CircularBuffer* cBuff)
{
    if (cBuff == NULL)
        return;//Already closed/destroyed.

    //Close stream.
    cBuff->readPos = QMX_CIRCULAR_BUFFER_CLOSED;
    cBuff->writePos = QMX_CIRCULAR_BUFFER_CLOSED;

    //Signal state change.
    SetEvent(cBuff->lock[2]);

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_closeStream while waiting for lock.\n");
            return;
    }

    qmx_cBuff_unlock(cBuff);

    return;
}

bool qmx_cBuff_isClosed(qmx_CircularBuffer* cBuff)
{
    bool result;

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
         case QMX_CIRCULAR_BUFFER_TIMEOUT:
             QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_isClosed while waiting for lock.\n");
            return false;//???
    }

    if ((cBuff->readPos == QMX_CIRCULAR_BUFFER_CLOSED) ||
        (cBuff->writePos == QMX_CIRCULAR_BUFFER_CLOSED))
        result = true;
    else
        result = false;

    qmx_cBuff_unlock(cBuff);
    
    return result;
}

bool qmx_cBuff_isEmpty(qmx_CircularBuffer* cBuff)
{
    bool result = false;

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_isEmpty while waiting for lock.\n");
            return false;//???
    }

    if (cBuff->readPos == QMX_CIRCULAR_BUFFER_INVALID_POSITION)
        result = true;
    
    qmx_cBuff_unlock(cBuff);
    
    return result;
}

bool qmx_cBuff_isFull(qmx_CircularBuffer* cBuff)
{
    bool result = false;

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_isFull while waiting for lock.\n");
            return false;//???
    }

    if (cBuff->writePos == QMX_CIRCULAR_BUFFER_INVALID_POSITION)
        result = true;
    
    qmx_cBuff_unlock(cBuff);
    
    return result;
}

bool qmx_cBuff_hasFrame(qmx_CircularBuffer* cBuff, QCam_Frame* frame)
{
    int i = 0;

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_hasFrame while waiting for lock.\n");
            return false;//???
    }

    for (i = 0; i < cBuff->bufferSize; i++)
        if (cBuff->buffer[i] == frame)
            return true;

    qmx_cBuff_unlock(cBuff);

    return false;
}

void qmx_cBuff_resetMarkers(qmx_CircularBuffer* cBuff)//preprocessorStream)
{
    int i = 0;

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_resetMarkers while waiting for lock.\n");
            return;
    }

    //Find the first NULL position that is either at 0 or immediately following a non-NULL value.
    cBuff->writePos = QMX_CIRCULAR_BUFFER_INVALID_POSITION;
    for(i = cBuff->bufferSize - 2; i >= 0; i--)
    {
        if ((cBuff->buffer[i] != NULL) && (cBuff->buffer[i + 1] == NULL))
        {
            cBuff->writePos = i;
            break;
        }
        else if ((cBuff->buffer[i] == NULL) && (i == 0))
        {
            cBuff->writePos = i;
            break;
        }
    }

    //Find the first non-NULL position that is either the last or immediately following a NULL value.
    cBuff->readPos = QMX_CIRCULAR_BUFFER_INVALID_POSITION;
    for(i = 0; i < cBuff->bufferSize; i++)
    {
        if (cBuff->buffer[i] != NULL)
            cBuff->readPos = i;
        if (i > 0)
            if (cBuff->buffer[i - 1] == NULL)
                break;
    }
    if ((cBuff->readPos == QMX_CIRCULAR_BUFFER_INVALID_POSITION) && (cBuff->buffer[0] != NULL))
        cBuff->readPos = 0;

    qmx_cBuff_unlock(cBuff);

    return;
}

//JL03272008A remove function qmx_cBuff_resetPreprocessorStream()

void qmx_cBuff_setQueueFullCallback(qmx_CircularBuffer* cBuff, qmx_QueueFullCallback fullCallback, void* ptr)
{
    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_setQueueFullCallback while waiting for lock.\n");
            return;
            
        default:
            break;
    }

    cBuff->cBuffFullCallback = fullCallback;
    cBuff->cBuffFullCallbackPtr = ptr;
    
    qmx_cBuff_unlock(cBuff);

    return;
}

qmx_CircularBuffer* qmx_cBuff_createCircularBuffer(unsigned int bufferSize)
{
    qmx_CircularBuffer* cBuff;

    cBuff = (qmx_CircularBuffer*)calloc(1, sizeof(qmx_CircularBuffer));

    cBuff->readPos = QMX_CIRCULAR_BUFFER_INVALID_POSITION;
    cBuff->writePos = 0;
    cBuff->dropOnFull = 1;
    cBuff->bufferSize = bufferSize;
    cBuff->refCount = 0;

    cBuff->buffer = (QCam_Frame**)calloc(bufferSize, sizeof(QCam_Frame*));

    cBuff->pixelBufferSize = 0;
    cBuff->cBuffFullCallback = NULL;
    cBuff->cBuffFullCallbackPtr = NULL;

    cBuff->lock[0] = CreateMutex(NULL, false, NULL);//Barrier to buffer access.
    cBuff->lock[1] = CreateEvent(NULL, false, true, NULL);//Reader/writer moved.
    cBuff->lock[2] = CreateEvent(NULL, false, true, NULL);//Buffer state change.
    
    cBuff->threadID = (DWORD)NULL;

    return cBuff;
}

void qmx_setPixelBufferSize(QCam_Frame* frame, unsigned int pBufferSize)
{
    //Adjust the pixel buffer size.
    if ((frame->bufferSize != pBufferSize) || (frame->pBuffer == NULL))
    {
        //Clear the old pixel buffer.
        if (frame->pBuffer != NULL)
        {
            free(frame->pBuffer);
            frame->pBuffer = NULL;
        }
        
        //Create a new pixel buffer.
        frame->pBuffer = calloc(pBufferSize, sizeof(char)); 
        frame->bufferSize = pBufferSize;
    }
    
    return;
}

void qmx_cBuff_setPixelBufferSize(qmx_CircularBuffer* cBuff, int pBufferSize)
{
    int i;

    qmx_cBuff_closeStream(cBuff);

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_setPixelBufferSize while waiting for lock.\n");
            return;
        //JL02272008B add default case
        default:
            break;
    }
   
    if (cBuff->buffer == NULL)
        cBuff->buffer = (QCam_Frame**)calloc(QMX_DEFAULT_BUFFER_SIZE, sizeof(QCam_Frame*)); //JL03062008B ??? should change pBufferSize to bufferSize, use QMX_DEFAULT_BUFFER_SIZE for the time being

    
    for (i = 0; i < cBuff->bufferSize; i++)
    {
        //Create a frame.
        if (cBuff->buffer[i] == NULL)
        {
            cBuff->buffer[i] = qmx_allocateFrame();
            if (cBuff->readPos == QMX_CIRCULAR_BUFFER_INVALID_POSITION)
                cBuff->readPos = i;
            if (cBuff->writePos == i)
            {
                if (i == cBuff->readPos)
                    cBuff->writePos = QMX_CIRCULAR_BUFFER_INVALID_POSITION;
                else if ( (i == cBuff->bufferSize - 1) && (cBuff->readPos != 0) )
                    cBuff->writePos = 0;
                else
                    cBuff->writePos = i + 1;
            }
        }

        qmx_setPixelBufferSize((QCam_Frame *)cBuff->buffer[i], pBufferSize);
       
    }

    cBuff->pixelBufferSize = pBufferSize;

    qmx_cBuff_unlock(cBuff);
   
    return;
}

void qmx_cBuff_setBuffer(qmx_CircularBuffer* cBuff, QCam_Frame** arr, int len)
{
    int i;

    qmx_cBuff_closeStream(cBuff);

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_setBuffer while waiting for lock.\n");
            return;
    }
    
    if (cBuff->bufferSize != len)
        QMX_PRINTF_MACRO("qcammex.c: Error - Attempt to set circular buffer's contents with mismatched array size.\n\tExpected: %lu\n\tFound: %d\n", cBuff->bufferSize, len);

    for (i = 0; i < cBuff->bufferSize; i++)
        cBuff->buffer[i] = arr[i];
    
    qmx_cBuff_unlock(cBuff);
}

void qmx_cBuff_emptyCircularBuffer(qmx_CircularBuffer* cBuff)
{
    int i;

    qmx_cBuff_closeStream(cBuff);

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_emptyCircularBuffer while waiting for lock.\n");
            return;
    }
    
    for (i = 0; i < cBuff->bufferSize; i++)
        cBuff->buffer[i] = NULL;
    
    qmx_cBuff_unlock(cBuff);
    
    return;
}

void qmx_cBuff_purgeCircularBuffer(qmx_CircularBuffer* cBuff)
{
    int i;

    qmx_cBuff_closeStream(cBuff);

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_purgeCircularBuffer while waiting for lock.\n");
            return;
    }

    for (i = 0; i < cBuff->bufferSize; i++)
        if (cBuff->buffer[i] != NULL)
            qmx_freeFrame((QCam_Frame **)&cBuff->buffer[i]);
    if ((QCam_Frame *)cBuff->buffer != NULL)
    {
        free((QCam_Frame *)cBuff->buffer);
        (QCam_Frame *)cBuff->buffer = NULL;
    }

    cBuff->readPos = QMX_CIRCULAR_BUFFER_INVALID_POSITION;
    cBuff->writePos = QMX_CIRCULAR_BUFFER_INVALID_POSITION;

    qmx_cBuff_unlock(cBuff);

    return;
}

void qmx_cBuff_setBufferSize(qmx_CircularBuffer* cBuff, int size, bool updatePixelBuffers)
{
    qmx_cBuff_closeStream(cBuff);

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_setBufferSize while waiting for lock.\n");
            return;
        
        //JL02272008B add default case
        default:
            break;
    }

    if (cBuff->bufferSize == size)
        return;
    
    qmx_cBuff_purgeCircularBuffer(cBuff);
    cBuff->bufferSize = size;
    cBuff->readPos = 0;
    cBuff->writePos = QMX_CIRCULAR_BUFFER_INVALID_POSITION;
    if (updatePixelBuffers)
        qmx_cBuff_setPixelBufferSize(cBuff, cBuff->pixelBufferSize);
    
    qmx_cBuff_unlock(cBuff);

    return;
}

void qmx_cBuff_destroyCircularBuffer(qmx_CircularBuffer** cBuff)
{
    int i;

    if (*cBuff == NULL)
        return;

    qmx_cBuff_closeStream(*cBuff);

    qmx_cBuff_purgeCircularBuffer(*cBuff);
    
    if ((QCam_Frame *)(*cBuff)->buffer != NULL )
    {
        free((QCam_Frame *)(*cBuff)->buffer);
        (QCam_Frame *)(*cBuff)->buffer = NULL;
    }
    
    CloseHandle((*cBuff)->lock[0]);
    CloseHandle((*cBuff)->lock[1]);
    CloseHandle((*cBuff)->lock[2]);
    
    
    //JL03262008B Debug cBuff to *cBuff
    free(*cBuff);
    *cBuff = NULL;

        
    return;
}

//Make sure there are no references left in the buffer. Print errors if there are. Reset pointers.
void qmx_cBuff_confirmEmpty(qmx_CircularBuffer* cBuff)
{
    int i = 0;

    qmx_cBuff_closeStream(cBuff);

    switch (qmx_cBuff_lock(cBuff, QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out in qmx_cBuff_confirmEmpty while waiting for lock.\n");
            return;
    }

    
    for (i = 0; i < cBuff->bufferSize; i++)
    {
        if (cBuff->buffer[i] != NULL)
        {
           // QMX_PRINTF_MACRO("qcammex.c: Active reference found in supposedly empty circular buffer.\n");
            cBuff->buffer[i] = NULL;
        }
        
    }
    
    cBuff->writePos = 0;
    cBuff->readPos = QMX_CIRCULAR_BUFFER_INVALID_POSITION;
    
    qmx_cBuff_resetMarkers(cBuff);

    qmx_cBuff_unlock(cBuff);
    
    return;
}

int qmx_cBuff_Get(qmx_CircularBuffer* cBuff, QCam_Frame** frame)
{
    if (cBuff == NULL)
        return QMX_CIRCULAR_BUFFER_CLOSED;
    if (cBuff->readPos == QMX_CIRCULAR_BUFFER_CLOSED)
    {
        return QMX_CIRCULAR_BUFFER_CLOSED;
    }
    if (cBuff->readPos == QMX_CIRCULAR_BUFFER_INVALID_POSITION)
    {
        return QMX_CIRCULAR_BUFFER_EMPTY;
    }
    if (cBuff->buffer[cBuff->readPos] == NULL)
    {
        QMX_PRINTF_MACRO("qcammex.c: qmx_cBuff_Get read a NULL pointer.\n");
        return QMX_CIRCULAR_BUFFER_SERIOUS_ERROR;
    }
    
    //Kick out the frame.
    *frame = (QCam_Frame *)cBuff->buffer[cBuff->readPos];
    cBuff->buffer[cBuff->readPos] = NULL;
    
    //Clear the full flag.
    if (cBuff->writePos == QMX_CIRCULAR_BUFFER_INVALID_POSITION)
        cBuff->writePos = cBuff->readPos;
    
    //Move the read pointer.
    cBuff->readPos++;
    if (cBuff->readPos >= cBuff->bufferSize)
    {
        if (cBuff->writePos > 0)
            cBuff->readPos = 0;//Wrap.
        else
            cBuff->readPos = QMX_CIRCULAR_BUFFER_INVALID_POSITION;//Empty.
    }
    if (cBuff->buffer[cBuff->readPos] == NULL)
        cBuff->readPos = QMX_CIRCULAR_BUFFER_INVALID_POSITION;//Empty.
    
    return QMX_CIRCULAR_BUFFER_OK;
}

int qmx_cBuff_Put(qmx_CircularBuffer* cBuff, QCam_Frame** frame)
{
    int i;

    if (cBuff == NULL)
        return QMX_CIRCULAR_BUFFER_CLOSED;

    //Sanity Check: See if the frame is already in the buffer, which should be illegal.
    for (i = 0; i < cBuff->bufferSize; i++)
    {
        if (cBuff->buffer[i] == *frame)
        {
            //It's already here. Reject it.
            frame = NULL;
            QMX_PRINTF_MACRO("qcammex.c: Detected attempt to put a duplicate entry into a ring buffer.\n");
            qmx_cBuff_notify(cBuff);//Wake up readers, which might help shake things loose.
            qmx_cBuff_unlock(cBuff);
            return QMX_CIRCULAR_BUFFER_SERIOUS_ERROR;
        }
    }

    if (cBuff->writePos == QMX_CIRCULAR_BUFFER_CLOSED)
    {
        qmx_cBuff_unlock(cBuff);
        return QMX_CIRCULAR_BUFFER_CLOSED;
    }

    if (cBuff->writePos == QMX_CIRCULAR_BUFFER_INVALID_POSITION)
    {
        if (cBuff->dropOnFull)
        {
            if (qmx_debugOn)
                QMX_PRINTF_MACRO("qcammex.c: Ring buffer full. Dropping frame.\n");

            qmx_cBuff_unlock(cBuff);
            return QMX_CIRCULAR_BUFFER_FULL;//Full.
        }
        else
        {
            if (qmx_debugOn)
                QMX_PRINTF_MACRO("qcammex.c: Ring buffer full. Silently overwriting buffer slot.\n");

            //Move pointer to the oldest (immediately prior to cBuff->readPos) and overwrite.
            if (cBuff->readPos != 0)
                cBuff->writePos = cBuff->readPos - 1;
            else
                cBuff->writePos = cBuff->bufferSize - 1;
        }
    }

    if (cBuff->buffer[cBuff->writePos] != NULL)
    {
        QMX_PRINTF_MACRO("qcammex.c: qmx_cBuff_Put attempted to overwrite a pointer.\n");
        return QMX_CIRCULAR_BUFFER_SERIOUS_ERROR;
    }

    cBuff->buffer[cBuff->writePos] = *frame;//Store the frame.
    *frame = NULL;//Take the frame back.

    //Clear the empty flag.
    if (cBuff->readPos == QMX_CIRCULAR_BUFFER_INVALID_POSITION)
        cBuff->readPos = cBuff->writePos;

    //Move the write pointer.
    cBuff->writePos++;
    if (cBuff->writePos >= cBuff->bufferSize)
    {
        if (cBuff->readPos > 0)
            cBuff->writePos = 0;//Wrap.
        else
        {
            cBuff->writePos = QMX_CIRCULAR_BUFFER_INVALID_POSITION;//Full.
            if (cBuff->cBuffFullCallback != NULL)
            {
                if (qmx_debugOn)
                    QMX_PRINTF_MACRO("qcammex.c: Executing queue full callback @%p->@%p(@%p).\n", cBuff, cBuff->cBuffFullCallback, cBuff->cBuffFullCallbackPtr);
                cBuff->cBuffFullCallback(cBuff->cBuffFullCallbackPtr);//Notify the listener that the buffer is full.
            }
        }
    }

    return QMX_CIRCULAR_BUFFER_OK;
}

//Once you take a frame out, you should never destroy it, just pass it back in to qmx_cBuff_blockingPut.
int qmx_cBuff_blockingGet(qmx_CircularBuffer* cBuff, QCam_Frame** frame, unsigned long int timeoutMilliseconds)
{
    int result;
    
    if (cBuff == NULL)
        return QMX_CIRCULAR_BUFFER_CLOSED;

    result = qmx_cBuff_lock(cBuff, timeoutMilliseconds);
    switch (result)
    {
        case QMX_CIRCULAR_BUFFER_STATE_CHANGE:
            qmx_cBuff_unlock(cBuff);
            return QMX_CIRCULAR_BUFFER_CLOSED;
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out after %lu [ms] in qmx_cBuff_blockingGet while waiting for lock.\n", timeoutMilliseconds);
            return QMX_CIRCULAR_BUFFER_TIMEOUT;
        //The other cases should be self-handling for now...
    }
    
    if (qmx_cBuffDebugOn)
    {
        QMX_PRINTF_MACRO("qcammex.c: qmx_cBuff_blockingGet for @%p...\n", cBuff);
      //  qmx_printQueue(cBuff);
    }
    
    if (qmx_cBuff_isClosed(cBuff))
    {
        qmx_cBuff_unlock(cBuff);
        return QMX_CIRCULAR_BUFFER_CLOSED;
    }

    while (cBuff->readPos == QMX_CIRCULAR_BUFFER_INVALID_POSITION)
    {
        qmx_cBuff_unlock(cBuff); //JL04112008A unlock the cBuff so the putter has a chance to get the mutex
        SwitchToThread();//TO032708B - Yield the CPU during the polling.
        result = qmx_cBuff_lock(cBuff, timeoutMilliseconds);
    }

    if (qmx_cBuffDebugOn)
        QMX_PRINTF_MACRO("qcammex.c: qmx_cBuff_blockingGet finished waiting. Retrieving frame...\n", cBuff);

    result = qmx_cBuff_Get(cBuff, frame);

    if (qmx_cBuffDebugOn)
    {
        QMX_PRINTF_MACRO("qcammex.c: qmx_cBuff_blockingGet retrieved frame: @%p\n", cBuff, *frame);
        qmx_printQueue(cBuff);
    }

    qmx_cBuff_unlock(cBuff);
    qmx_cBuff_notify(cBuff);

    return result;
}

//Once you put a frame in, you can no longer access it, you must call qmx_cBuff_blockingGet to grab another.
int qmx_cBuff_blockingPut(qmx_CircularBuffer* cBuff, QCam_Frame** frame, unsigned long int timeoutMilliseconds)
{
    int result;

    if (cBuff == NULL)
        return QMX_CIRCULAR_BUFFER_CLOSED;

    result = qmx_cBuff_lock(cBuff, timeoutMilliseconds);
    switch (result)
    {
        case QMX_CIRCULAR_BUFFER_STATE_CHANGE:
            qmx_cBuff_unlock(cBuff);
            return QMX_CIRCULAR_BUFFER_CLOSED;
        case QMX_CIRCULAR_BUFFER_TIMEOUT:
            QMX_PRINTF_MACRO("qcammex.c: Timed out after %lu [ms] in qmx_cBuff_blockingput while waiting for lock.\n", timeoutMilliseconds);
            return QMX_CIRCULAR_BUFFER_TIMEOUT;
        //The other cases should be self-handling for now...
    }


    if (qmx_cBuff_isClosed(cBuff))
    {
        qmx_cBuff_unlock(cBuff);
        return QMX_CIRCULAR_BUFFER_CLOSED;
    }

    while (cBuff->writePos == QMX_CIRCULAR_BUFFER_INVALID_POSITION)
    {
           qmx_cBuff_unlock(cBuff);  //JL04112008B - unlock the cBuff so the getter has a chance to get the mutex  
           SwitchToThread();//TO032708B - Yield the CPU during the polling.
           qmx_cBuff_lock(cBuff, timeoutMilliseconds);
    }

    result = qmx_cBuff_Put(cBuff, frame);
    
    if (qmx_cBuffDebugOn)
    {
        QMX_PRINTF_MACRO("qcammex.c: qmx_cBuff_blockingPut for @%p...\n", cBuff);
        qmx_printQueue(cBuff);
    }


    qmx_cBuff_unlock(cBuff);
    qmx_cBuff_notify(cBuff);

    return result;
}

void qmx_cBuff_flush(qmx_CircularBuffer* src, qmx_CircularBuffer* dest)
{
    QCam_Frame* frame;

    switch (qmx_cBuff_doubleLock(src, dest, 2 * QMX_DEFAULT_QUEUE_TIMEOUT))
    {
        case QMX_CIRCULAR_BUFFER_OK:
            break;
        default:
            QMX_PRINTF_MACRO("qcammex.c: Failed to acquire both streams' locks in qmx_cBuff_doubleLock. Aborting...\n");
            break;
    }

    while (!qmx_cBuff_isEmpty(src) && !qmx_cBuff_isFull(dest))
    {
        qmx_cBuff_Get(src, &frame);
        qmx_cBuff_Put(dest, &frame);
    }
    
    qmx_cBuff_unlock(src);
    qmx_cBuff_unlock(dest);
    
    return;
}

/*
 * Driver and camera resource loading/unloading functions.
 *
 */
void qmx_loadQCamDriver(void)
{
    if (qmx_driverResident)
        return;
    
    // load the driver
    if (qmx_errorMsg(QCam_LoadDriver(), "qmx_loadDriver"))
    {
        QMX_PRINTF_MACRO("qcammex.c: Failed to load camera driver.\n");
        return;
    }
    qmx_driverResident = 1;
}

void qmx_releaseQCamDriver(void)
{
    QCam_CamListItem list[1];
    unsigned long listLen = 1;

    if (qmx_cameraHandle != NULL)
    {
        // Close the camera. We are done.
        if (qmx_errorMsg(QCam_CloseCamera(qmx_cameraHandle), "qmx_releaseQCamDriver - QCam_CloseCamera"))
        {
            QMX_PRINTF_MACRO("qcammex.c: Failed to close camera.\n");
        }
        qmx_cameraHandle = NULL;
    }
    
    QCam_ReleaseDriver();
    
    //Test if the driver's still hanging around.
    if (QCam_ListCameras(list, &listLen))
        qmx_driverResident = 0;
    else
    {
        qmx_driverResident = 1;
        QMX_PRINTF_MACRO("qcammex.c: It appears that the QCam driver is still resident, despite a call to release it...\n");
    }
}

void qmx_acquireCamera(void)
{
    QCam_CamListItem list[10];
    unsigned long listLen = 10 * sizeof(QCam_CamListItem);
    int i = 0;
    
    //Camera already acquired.
    if (qmx_cameraHandle != NULL)
        return;

    qmx_loadQCamDriver();
    
    // get a list of the cameras
    if (qmx_errorMsg(QCam_ListCameras(list, &listLen), "qmx_acquireCamera - QCam_ListCameras"))
    {
        QMX_PRINTF_MACRO("qcammex.c: Failed to list available cameras.\n");
        return;
    }

    if (listLen == 1)
        QMX_PRINTF_MACRO("qcammex.c: Found 1 camera.\n")
    else
        QMX_PRINTF_MACRO("qcammex.c: Found %d cameras.\n", listLen)

    for (i = 0; i < listLen; i++)
    {
        QMX_PRINTF_MACRO("qcammex.c: Found camera (%d) -\n", i);
        qmx_printCameraListItem(list[i]);
    }
    
    if ((listLen > 0) && (list[0].isOpen == false))
    {
        // Open the first camera in the list.
        QMX_PRINTF_MACRO("qcammex.c: Opening camera %d...\n", list[0].uniqueId);
        if (qmx_errorMsg(QCam_OpenCamera(list[0].cameraId, &qmx_cameraHandle), "qmx_acquireCamera - QCam_OpenCamera"))
        {
            QMX_PRINTF_MACRO("qcammex.c: Failed to open camera.\n");
            return;
        }

        //Why this is required, I have no idea, but it's important.
    	qmx_camSettings.size = sizeof(qmx_camSettings);

        //Get the default settings.
        QCam_ReadSettingsFromCam(qmx_cameraHandle, &qmx_camSettings);
    }
    else if (listLen > 0)
        QMX_PRINTF_MACRO("qcammex: Camera %d seems to be in use.", list[0].uniqueId);
}

void qmx_init(void)
{
    int i = 0;

    qmx_loadQCamDriver();
    qmx_acquireCamera();
}

/*
 * File Input.
 *
 */
void qmx_closeQCamFile(qmx_QCamFile** qcf)
{
    if ((*qcf) == NULL)
        return;
    
    if ((*qcf)->stream != NULL)
        fclose((*qcf)->stream);
    if (*qcf != NULL )
    {
        free(*qcf);
        *qcf = NULL;
    }
    
    return;
}

int qmx_seekFrame(qmx_QCamFile* qcf, unsigned int frameNumber)
{     
    unsigned long int address = 0;

    address = qcf->headerSize + qcf->frameSizeInBytes * (frameNumber - 1);
    if (address > qcf->fileSizeInBytes)
    {
        QMX_PRINTF_MACRO("qcammex.c: Attempt to seek beyond EOF while accessing frame #%lu. Requested byte %lu in file of %lu bytes.\n", frameNumber, address, qcf->fileSizeInBytes);
        return -1;
    }
    else if (address + qcf->frameSizeInBytes > qcf->fileSizeInBytes)
    {
        QMX_PRINTF_MACRO("qcammex.c: Attempt to seek beyond EOF while accessing frame #%lu. Requested byte %lu in file of %lu bytes.\n", frameNumber, address + qcf->frameSizeInBytes, qcf->fileSizeInBytes);
        return -1;
    }

    SET_BINARY_MODE(qcf->stream);
    fseek(qcf->stream, address, SEEK_SET);

    return 0;
}

int qmx_seekPixelByIndex(qmx_QCamFile* qcf, unsigned int frameNumber, unsigned int pixelNumber)
{
    unsigned int address = 0;

    address = qcf->headerSize + qcf->frameSizeInBytes * frameNumber + qcf->bytesPerPixel * pixelNumber;

    if (address > qcf->fileSizeInBytes - qcf->bytesPerPixel)
    {
        QMX_PRINTF_MACRO("qcammex.c: Attempt to seek beyond EOF while accessing pixel #%lu in frame #%lu. Requested byte %lu in file of %llu bytes.\n", 
               pixelNumber, frameNumber, address, qcf->fileSizeInBytes);
        return -1;
    }

    SET_BINARY_MODE(qcf->stream);
    fseek(qcf->stream, address, SEEK_SET);

    return 0;
}

int qmx_seekPixelByCoordinate(qmx_QCamFile* qcf, unsigned int frameNumber, unsigned int x, unsigned int y)
{
    unsigned int address = 0;

    address = qcf->headerSize + qcf->frameSizeInBytes * frameNumber + qcf->bytesPerPixel * (x + y);

    if (address > qcf->fileSizeInBytes - qcf->bytesPerPixel)
    {
        QMX_PRINTF_MACRO("qcammex.c: Attempt to seek beyond EOF while accessing pixel (%lu, %lu) in frame #%lu. Requested byte %llu in file of %lu bytes.\n", 
               x, y, frameNumber, address, qcf->fileSizeInBytes);
        return -1;
    }

    SET_BINARY_MODE(qcf->stream);
    fseek(qcf->stream, address, SEEK_SET);

    return 0;
}

int qmx_readFrame(qmx_QCamFile* qcf, void* buf, unsigned int frameNumber)
{
    long result;
    if (qmx_seekFrame(qcf, frameNumber))
    {
        QMX_PRINTF_MACRO("qcammex.c: Failed to access frame #%lu before loading into buffer.\n", frameNumber);
        return -1;
    }

    if (qmx_debugOn)
        QMX_PRINTF_MACRO("Reading frame (%lu bytes) from offset %lu [bytes]...\n", qcf->frameSizeInBytes, ftell(qcf->stream));

    result = fread(buf, 1, qcf->frameSizeInBytes, qcf->stream);
    QMX_PRINTF_MACRO("qcammex.c:fread buf @%p, elements %d, stream @%p\n", buf, qcf->frameSizeInBytes, qcf->stream);
    //if (fread(buf, sizeof(char), qcf->frameSizeInBytes, qcf->stream) != qcf->frameSizeInBytes)
    if (result != qcf->frameSizeInBytes)
    {
        //QMX_PRINTF_MACRO("qcammex.c: loaded %lu Failed to load frame #%lu into buffer.\n",aa, frameNumber);
        return -2;
    }

    return 0;
}

int qmx_getNextHeader(FILE* stream, char* expectedHeaderName, char* format, void* receptacle, int suffixExists)
{
    char headerName[35];
    int fscanfResult;
    int len;
    
    fscanfResult = fscanf(stream, "%s" QMX_HEADER_DELIMITER, headerName);
    if (fscanfResult != 1)
    {
        QMX_PRINTF_MACRO("qcammex.c: Error reading next header name. fscanf returned %d instead of 1.\n", fscanfResult);
        return -1;
    }

    //If requested, check the header name.
    if (expectedHeaderName != NULL)
    {
        //Trim the delimiter
        len = strlen(headerName);
        headerName[len - 1] = (char)NULL;
        if (stringcompare(headerName, expectedHeaderName) != 0)
        {
            QMX_PRINTF_MACRO("qcammex.c: Error parsing header name.\n"
                   "           Expected '%s'\n"
                   "           Found: '%s'\n", expectedHeaderName, headerName);
            return -2;
        }
    }
    
    //If requested, load a single variable.
    if (format != NULL)
    {
        fscanfResult = fscanf(stream, format, receptacle);
        if (fscanfResult != 1)
        {
            QMX_PRINTF_MACRO("qcammex.c: Error reading header value for '%s'. fscanf returned %d instead of 1.\n", headerName, fscanfResult);
            return -1;
        }
    }
    
    //Advance stream pointer to after the next end-of-line.
    if (suffixExists)
        fscanf(stream, "%s", headerName);
    
    return 0;
}

//Parse the header of files that are compatible with the 0.1 file format.
//The stream MUST be positioned immediately after the file format specifier in the header.
int qmx_openQCamFile_v0_1(qmx_QCamFile* qcf)
{
    char str[30];

    SET_BINARY_MODE(qcf->stream);
    
    //Header Size
    if (qmx_getNextHeader(qcf->stream, QMX_HEADER_NAME_QMX_HEADER_SIZE, "%i", &(qcf->headerSize), true))
        QMX_PRINTF_MACRO("qcammex.c: Warning - Failed to read header size from header.\n");
    if (qcf->headerSize != QMX_OUTPUT_FILE_HEADER_SIZE)
    {
        //Should we check which one is correct (by seeking around and looking for the transition from ' ' to NULL)?
        QMX_PRINTF_MACRO("qcammex.c: Warning - Header size does not match expected (fixed) header size.\n"
               "                     Expected: %lu.\n"
               "                     Found: %lu.\n"
               "                     Image data should still be recoverable. Assuming %lu is correct.\n", 
               QMX_OUTPUT_FILE_HEADER_SIZE, qcf->headerSize, qcf->headerSize);
    }

    //ROI
    if (qmx_getNextHeader(qcf->stream, QMX_HEADER_NAME_ROI, NULL, NULL, false))
    {
        QMX_PRINTF_MACRO("qcammex.c: Warning - Failed to read ROI from header.\n");
    }
    else
    {
        if (fscanf(qcf->stream, "%u, %u, %u, %u", &(qcf->roiX), &(qcf->roiY), &(qcf->roiWidth), &(qcf->roiHeight)) != 4)
            QMX_PRINTF_MACRO("qcammex.c: Warning - Failed to read ROI from header.\n");
    }

    //Frame Size
    if (qmx_getNextHeader(qcf->stream, QMX_HEADER_NAME_FRAME_SIZE, "%u", &(qcf->frameSizeInBytes), true))
        QMX_PRINTF_MACRO("qcammex.c: Warning - Failed to read frame size from header.\n");

    //Image Encoding
    if (qmx_getNextHeader(qcf->stream, QMX_HEADER_NAME_QMX_IMAGEENCODING, "%s", str, false))
        QMX_PRINTF_MACRO("qcammex.c: Warning - Failed to read image encoding from header.\n");
    if (stringcompare(str, QMX_IMAGEENCODING_STR_RAW16) == 0)
        qcf->imageEncoding = QMX_OUTPUT_FILE_FORMAT_RAW16;
    else if (stringcompare(str, QMX_IMAGEENCODING_STR_BZ2) == 0)
        qcf->imageEncoding = QMX_OUTPUT_FILE_FORMAT_BZ2;
    else if (stringcompare(str, QMX_IMAGEENCODING_STR_ZIP) == 0)
        qcf->imageEncoding = QMX_OUTPUT_FILE_FORMAT_ZIP;
    else if (stringcompare(str, QMX_IMAGEENCODING_STR_DEFLATE) == 0)
        qcf->imageEncoding = QMX_OUTPUT_FILE_FORMAT_DEFLATE;
    else
    {
        QMX_PRINTF_MACRO("qcammex.c: Error - Unrecognized file encoding string '%s', aborting file loading.");
        return -1;
    }

    //Image Format
    if (qmx_getNextHeader(qcf->stream, QMX_HEADER_NAME_QMX_IMAGEFORMAT, "%s", str, false))
        QMX_PRINTF_MACRO("qcammex.c: Warning - Failed to read imager format from header.\n");
    if (stringcompare(str, QMX_IMAGEFORMAT_MONO16) == 0)
        qcf->imageFormat = qfmtMono16;
    else if (stringcompare(str, QMX_IMAGEFORMAT_MONO8) == 0)
        qcf->imageFormat = qfmtMono8;
    else
    {
        QMX_PRINTF_MACRO("qcammex.c: Error - Unrecognized image format string '%s', aborting file loading.");
        return -1;
    }

    return 0;
}

qmx_QCamFile* qmx_openQCamFile(char* filename)
{
    qmx_QCamFile* qcf;
    FILE* f;
    double qmx_fileFormat = -1;

    f = fopen(filename, "r");
    if (!f)
    {
        QMX_PRINTF_MACRO("qcammex.c - Failed to open QCam file '%s'.\n", filename);
        return NULL;
    }

    qcf = calloc(1, sizeof(qmx_QCamFile));
    qcf->stream = f;
    qcf->version = -1;
    
    SET_BINARY_MODE(qcf->stream);
    fseek(qcf->stream, 0, SEEK_END);
    qcf->fileSizeInBytes = ftell(qcf->stream);
    QMX_PRINTF_MACRO("qcammex.c - qmx_openQCamFile: fileSizeInBytes = %lu \n", qcf->fileSizeInBytes);
    rewind(qcf->stream);
    qcf->bytesPerPixel = QMX_OUTPUT_FILE_BYTES_PER_PIXEL;

    SET_BINARY_MODE(qcf->stream);
    
    //Get the file format and invoke the correct handler.
    if (qmx_getNextHeader(qcf->stream, QMX_HEADER_NAME_VERSION, "%4lf", &(qcf->version), false))
        QMX_PRINTF_MACRO("qcammex.c: Error reading file format version from header of '%s', further loaded data may be corrupted.\n", filename);
    
    switch ((int)(qcf->version * 100))
    {
        case -1:
            QMX_PRINTF_MACRO("qcammex.c: Unable to determine qcam file format. Can not open file '%s'.\n"
                   "           The first of the file MUST be the file format version. For example:\n"
                   "Encoding-Version: 0.10\r\n");
            qmx_closeQCamFile(&qcf);
            return NULL;

        case 10:
            if (qmx_openQCamFile_v0_1(qcf))
            {
                QMX_PRINTF_MACRO("qcammex.c: Failed to open file using file format version %1.2f handler."
                       "           Header data may be corrupted. Can not continue processing file."
                       "           Try checking the headers manually (they are clear text). Frames may still be recoverable.", qcf->version);
                qmx_closeQCamFile(&qcf);
            }
            break;

        default:
            QMX_PRINTF_MACRO("qcammex.c: Unsupported/unrecognized qcam file format (%1.2f). Can not open file '%s'.\n", qcf->version);
            qmx_closeQCamFile(&qcf);
            return NULL;
    }

    return qcf;
}

/*
 * File Output.
 *
 */
char* qmx_getFileEncodingString(void)
{
    return qmx_imageEncoding2String(qmx_fileFormat);
}

void qmx_getTimestamp(char* timestamp)
{   
    time_t  currentTime = (time_t)NULL;

    if (time(&currentTime) < currentTime)
    {
        QMX_PRINTF_MACRO("Failed to retrieve wall clock time.\n");
        return;
    }
    strftime(timestamp, 20, "%m-%d-%Y_%H:%M:%S", localtime(&currentTime));
    
    return;
}
void qmx_printHeader(FILE* stream)
{
    char    timestamp[20] = {'\0'};
    QCam_Settings currentSettings;
    unsigned long x, y, width, height, binFactor, imageFormat, highSensitivityMode, normalizedGain, sizeInBytes;
    long int absoluteOffset;
    unsigned long long int exposureTimeInNS;

    EnterCriticalSection(qmx_fileLock);

    SET_BINARY_MODE(stream);
    
    qmx_getTimestamp(timestamp);
    if (qmx_errorMsg(QCam_ReadSettingsFromCam(qmx_cameraHandle, &currentSettings), "qmx_printHeader"))
    {
        QMX_PRINTF_MACRO("qcammex.c: Error retrieving settings from camera. Header data may be corrupted/incomplete.\n");
        LeaveCriticalSection(qmx_fileLock);
        return;
    }
    //These are the most important headers, in terms of data retrieval. They MUST always follow this order:
    //      version, header size, roi, frame size, image encoding
    fprintf(stream, QMX_HEADER_NAME_VERSION QMX_HEADER_DELIMITER "%1.2f" QMX_HEADER_SUFFIX, QMX_OUTPUT_FILE_VERSION);
    fprintf(stream, QMX_HEADER_NAME_QMX_HEADER_SIZE QMX_HEADER_DELIMITER "%ld" QMX_HEADER_SUFFIX_BYTES, QMX_OUTPUT_FILE_HEADER_SIZE);
    QCam_GetParam(&qmx_camSettings, qprmRoiX, &x);
	QCam_GetParam(&qmx_camSettings, qprmRoiY, &y);
	QCam_GetParam(&qmx_camSettings, qprmRoiWidth, &width);
	QCam_GetParam(&qmx_camSettings, qprmRoiHeight, &height);
    fprintf(stream, QMX_HEADER_NAME_ROI QMX_HEADER_DELIMITER"%lu, %lu, %lu, %lu" QMX_HEADER_SUFFIX, x, y, width, height);
    QCam_GetInfo(qmx_cameraHandle, qinfImageSize, &sizeInBytes);
    fprintf(stream, QMX_HEADER_NAME_FRAME_SIZE QMX_HEADER_DELIMITER "%lu" QMX_HEADER_SUFFIX_BYTES, sizeInBytes);
    QCam_GetParam(&qmx_camSettings, qprmImageFormat, &imageFormat);
    fprintf(stream, QMX_HEADER_NAME_QMX_IMAGEENCODING QMX_HEADER_DELIMITER "%s" QMX_HEADER_SUFFIX, qmx_getFileEncodingString());
    fprintf(stream, QMX_HEADER_NAME_QMX_IMAGEFORMAT QMX_HEADER_DELIMITER "%s" QMX_HEADER_SUFFIX, qmx_imageFormat2String(imageFormat));
    fprintf(stream, QMX_HEADER_NAME_QMX_BYTESPERPIXEL QMX_HEADER_DELIMITER "%lu" QMX_HEADER_SUFFIX, QMX_OUTPUT_FILE_BYTES_PER_PIXEL);
    //These are the more informational headers. Their order is optional.
    fprintf(stream, "Temporal-Averaging" QMX_HEADER_DELIMITER "%d [frames]" QMX_HEADER_SUFFIX, qmx_averageFrames);
    QCam_GetParam64(&qmx_camSettings, qprm64Exposure, &exposureTimeInNS);
    fprintf(stream, "Exposure" QMX_HEADER_DELIMITER "%llu [ns]" QMX_HEADER_SUFFIX, exposureTimeInNS);
    QCam_GetParam(&qmx_camSettings, qprmBinning, &binFactor);
    fprintf(stream, "Spatial-Binning" QMX_HEADER_DELIMITER "%dx%d [pixels]" QMX_HEADER_SUFFIX, binFactor, binFactor);
    QCam_GetParam(&qmx_camSettings, qprmHighSensitivityMode, &highSensitivityMode);
    if (highSensitivityMode)
        fprintf(stream, "High-Sensitivity-Mode" QMX_HEADER_DELIMITER "On" QMX_HEADER_SUFFIX);
    else
        fprintf(stream, "High-Sensitivity-Mode" QMX_HEADER_DELIMITER "Off" QMX_HEADER_SUFFIX);
    QCam_GetParam(&qmx_camSettings, qprmNormalizedGain, &normalizedGain);
    fprintf(stream, "Normalized-Gain" QMX_HEADER_DELIMITER "%d" QMX_HEADER_SUFFIX, normalizedGain);
    QCam_GetParamS32(&qmx_camSettings, qprmS32AbsoluteOffset, &absoluteOffset);
    fprintf(stream, "Absolute-Offset" QMX_HEADER_DELIMITER "%d" QMX_HEADER_SUFFIX, absoluteOffset);
    fprintf(stream, "File-Init-Timestamp" QMX_HEADER_DELIMITER "%s" QMX_HEADER_SUFFIX, qmx_fileInitTimestamp);
    fprintf(stream, "Header-Creation-Timestamp" QMX_HEADER_DELIMITER "%s" QMX_HEADER_SUFFIX, timestamp);

    //User-definable headers.
    fprintf(stream, "User-Timing-Data" QMX_HEADER_DELIMITER "%s" QMX_HEADER_SUFFIX, qmx_userTimingData);
    fprintf(stream, "User-Defined-Header" QMX_HEADER_DELIMITER "%s" QMX_HEADER_SUFFIX, qmx_headerData);

    LeaveCriticalSection(qmx_fileLock);
    
    return;
}

void qmx_saveHeader(void)
{
    int i = 0;
    int pos = 0;
    
    EnterCriticalSection(qmx_fileLock);
    
    fseek(qmx_outputFile, 0, SEEK_SET);
    qmx_printHeader(qmx_outputFile);
    fprintf(qmx_outputFile, "\r\n");

    pos = ftell(qmx_outputFile);
    //Watch out for header over-runs.
    if (pos > QMX_OUTPUT_FILE_HEADER_SIZE)
        QMX_PRINTF_MACRO("qcammex.c: Header over-run error. Header size should be fixed at %ld or less bytes, %ld bytes of data may have been lost.\n", 
               ftell(qmx_outputFile) - QMX_OUTPUT_FILE_HEADER_SIZE, QMX_OUTPUT_FILE_HEADER_SIZE)
    else
    {
        //Fill the rest of the header with nice whitespace.
        for (i = pos; i < QMX_OUTPUT_FILE_HEADER_SIZE - 3; i++)
            putc(' ', qmx_outputFile);
        putc('\r', qmx_outputFile);
        putc('\n', qmx_outputFile);
        putc((char)NULL, qmx_outputFile);
    }
    fflush(qmx_outputFile);
    
    if (qmx_debugOn)
        qmx_printHeader(stdout);
    
    LeaveCriticalSection(qmx_fileLock);
    
    return;
}

void qmx_finalizeFile(void)
{
    if (qmx_fileLock == NULL)
        return;

    EnterCriticalSection(qmx_fileLock);

    if (qmx_outputFile != NULL)
    {
        qmx_saveHeader();
        fclose(qmx_outputFile);
        qmx_outputFile = NULL;
        memset(qmx_outputFileName, 0x0000, QMX_OUTFILENAME_BUFFERSIZE);//TO032408A - Clear the string.
    }

    LeaveCriticalSection(qmx_fileLock);
    
    return;
}

void qmx_initFile(char* filename)
{
    int i;

    if (qmx_fileLock == NULL)
    {
        qmx_fileLock = (CRITICAL_SECTION*)calloc(1, sizeof(CRITICAL_SECTION));
        InitializeCriticalSection(qmx_fileLock);
    }
    
    EnterCriticalSection(qmx_fileLock);

    if (qmx_outputFile != NULL)
    {
        QMX_PRINTF_MACRO("qcammex.c: Warning - Request to initialize new output file before previous file is finalized."
               "                     Forcing finalization.\n");
        qmx_finalizeFile();
    }
    
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qcammex.c: Initalizing output file: '%s'\n", filename);

    qmx_outputFile = fopen(filename, "w");
    if (!qmx_outputFile)
        QMX_PRINTF_MACRO("qcammex.c: Failed to open output file '%s' for writing.\n", filename);

    memcpy(qmx_outputFileName, filename, strlen(filename));//TO032408A
    SET_BINARY_MODE(qmx_outputFile);
    qmx_framesWrittenCounter = 0;
    
    qmx_getTimestamp(qmx_fileInitTimestamp);
    
    //Fill in dummy header data, for now. The real header gets filled in upon finalization.
    for (i = 0; i < QMX_OUTPUT_FILE_HEADER_SIZE - 3; i++)
            putc(' ', qmx_outputFile);
    putc('\r', qmx_outputFile);
    putc('\n', qmx_outputFile);
    putc((char)NULL, qmx_outputFile);

    LeaveCriticalSection(qmx_fileLock);

    return;
}

void qmx_writeFrameToFile(QCam_Frame* frame)
{
    EnterCriticalSection(qmx_fileLock);
    
    SET_BINARY_MODE(qmx_outputFile);
    
    fseek(qmx_outputFile, 0, SEEK_END);

    if (qmx_debugOn)
        QMX_PRINTF_MACRO("Writing frame (%lu bytes) to %lu...\n", frame->bufferSize, ftell(qmx_outputFile));
    
    if (fwrite(frame->pBuffer, sizeof(char), frame->bufferSize, qmx_outputFile) != frame->bufferSize)
        QMX_PRINTF_MACRO("qcammex.c: fwrite I/O error. Failed to write (some) pixels for frame %lu.\n", frame->frameNumber);
    qmx_framesWrittenCounter++;
    qmx_totalFramesWrittenCounter++;
    
    LeaveCriticalSection(qmx_fileLock);

    return;
}

void qmx_initFileFromBaseFilename()
{
    char* fname;

    if (qmx_baseFilename == NULL)
        return;

    if (qmx_fileLock == NULL)
    {
        qmx_fileLock = (CRITICAL_SECTION*)calloc(1, sizeof(CRITICAL_SECTION));
        InitializeCriticalSection(qmx_fileLock);
    }

    EnterCriticalSection(qmx_fileLock);

    //Append an extension to the filename, and an optional number for handling automatic rollover.
    if (qmx_fileCounter)
    {
        if (qmx_fileCounter < 1000)
        {
            fname = calloc(strlen(qmx_baseFilename) + 12, sizeof(char));//qmx_baseFilename + "XXX.qcamraw" + NULL
            sprintf(fname, "%s%03.3d.qcamraw", qmx_baseFilename, qmx_fileCounter);
            if (qmx_debugOn)
                QMX_PRINTF_MACRO("qcammex.c: File '%s' has been auto-generated from '%s' while rolling over files.\n", fname, qmx_baseFilename);
        }
        else
        {
            QMX_PRINTF_MACRO("qcammex.c: Automatic filename rollover exceeded limit (1000 files), disabling disk logging.\n");
            //free(qmx_baseFilename);
            //qmx_baseFilename = NULL;
            qmx_diskLoggingOn = false;
            LeaveCriticalSection(qmx_fileLock);
            return;
        }
    }
    else
    {
        fname = calloc(strlen(qmx_baseFilename) + 9, sizeof(char));//qmx_baseFilename + ".qcamraw" + NULL
        sprintf(fname, "%s.qcamraw", qmx_baseFilename);
        if (qmx_debugOn)
                QMX_PRINTF_MACRO("qcammex.c: File '%s' has been auto-generated from '%s'.\n", fname, qmx_baseFilename);
    }

    qmx_initFile(fname);
    
    if (fname != NULL)
    {
        free(fname);
        fname = NULL;
    }
    
    LeaveCriticalSection(qmx_fileLock);

    return;
}

/*
 * Buffer management.
 *
 */
void qmx_clearBuffers(void)
{
    int i;

    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_clearBuffers --> qmx_cBuff_destroyCircularBuffer(&qmx_preprocessorStream)\n");
    qmx_cBuff_destroyCircularBuffer(&qmx_preprocessorStream);

    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_clearBuffers --> qmx_cBuff_destroyCircularBuffer(&qmx_inputBufferStream)\n");
    qmx_cBuff_destroyCircularBuffer(&qmx_inputBufferStream);

    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_clearBuffers --> qmx_cBuff_destroyCircularBuffer(&qmx_outputBufferStream)\n");
    qmx_cBuff_destroyCircularBuffer(&qmx_outputBufferStream);

    //Destroy orphaned frames. These are frames that were in the QImaging queue during an abort.
    for (i = 0; i < QMX_MAX_QUEUED_FRAME_BUFFERS; i++)
    {
        if (qmx_frameCache[i] != NULL)
        {
            if (qmx_frameCache[i]->pBuffer != NULL)
            {
                free(qmx_frameCache[i]->pBuffer);
                qmx_frameCache[i]->pBuffer = NULL;
            }
            
            free(qmx_frameCache[i]);
            qmx_frameCache[i] = NULL;
        }
    }

    return;
}

void qmx_configureBuffers(void)
{
    int i = 0;
    unsigned long sizeInBytes = 0;
    QCam_Frame* frame;

    // Image size depends on the current region & image format.
    if (qmx_errorMsg(QCam_GetInfo(qmx_cameraHandle, qinfImageSize, &sizeInBytes), "qmx_configureBuffers"))
    {
        QMX_PRINTF_MACRO("qcammex.c: Failed to get frame size in bytes from camera info.\n");
        return;
    }

    //reset preprocessor stream.
    if (qmx_preprocessorStream != NULL)
            qmx_cBuff_destroyCircularBuffer(&qmx_preprocessorStream);
   
    if (qmx_averageFrames > 1)
    {
        qmx_preprocessorStream = qmx_cBuff_createCircularBuffer(QMX_DEFAULT_BUFFER_SIZE);
        
            //Initialize preprocessor calculation buffer.
  
        if (qmx_preprocessorStream->pixelBufferSize != sizeInBytes)
        {
            if (qmx_preprocessorResult != NULL)
            {
                free(qmx_preprocessorResult);
            }
            qmx_preprocessorResult = (unsigned long long int *)calloc(qmx_pixelCount, sizeof(unsigned long long int)); //JL03262008C change type from short to unsigned short
        }
        
         qmx_cBuff_confirmEmpty(qmx_preprocessorStream);
    
        //Set up pumping of averaged frames to the disk.
        // qmx_cBuff_setQueueFullCallback(qmx_preprocessorStream, qmx_averageFramesTogether, qmx_outputBufferStream);  
    }

    //reset input stream.
    if (qmx_inputBufferStream != NULL)
           qmx_cBuff_destroyCircularBuffer(&qmx_inputBufferStream);
    qmx_inputBufferStream = qmx_cBuff_createCircularBuffer(qmx_inputStreamBufferSize);


    //reset output stream.
    if (qmx_outputBufferStream != NULL)
           qmx_cBuff_destroyCircularBuffer(&qmx_outputBufferStream);
    qmx_outputBufferStream = qmx_cBuff_createCircularBuffer(qmx_outputStreamBufferSize);


    // Initialize displaybufferlock
    if (qmx_displayBufferLock == NULL)
    {
        qmx_displayBufferLock = (CRITICAL_SECTION*)calloc(1, sizeof(CRITICAL_SECTION));
        InitializeCriticalSection(qmx_displayBufferLock);
    }

//Move all buffer frames, including orphans, back into the input stream.
    for (i = 0; i < QMX_MAX_QUEUED_FRAME_BUFFERS; i++)
    {
        if (qmx_frameCache[i] != NULL)
            if (!qmx_cBuff_hasFrame(qmx_inputBufferStream, qmx_frameCache[i]))
                qmx_cBuff_Put(qmx_inputBufferStream, &qmx_frameCache[i]);//This should have no reason to be synchronized.
    }
    

    //Update pixel buffer sizes, and create/destroy frames, if necessary.
    qmx_cBuff_setPixelBufferSize(qmx_inputBufferStream, sizeInBytes);
    
    qmx_cBuff_resetMarkers(qmx_inputBufferStream);
    
    //Make sure there are no oddball straglers.
    qmx_cBuff_confirmEmpty(qmx_outputBufferStream);
   
    //Initialize the display frame buffer.
    if (qmx_displayFrameBuffer == NULL)
        qmx_displayFrameBuffer = (QCam_Frame*)calloc(1, sizeof(QCam_Frame));
    qmx_displayFrameBufferStale = true;

    //Adjust the display frame buffer's pixel buffer size.
    qmx_setPixelBufferSize(qmx_displayFrameBuffer, sizeInBytes);

    return;
}

/*
 * Mutators for acquisition parameters.
 *
 */
void qmx_setROI(int x, int y, int width, int height)
{
    unsigned int binFactor;
    
    QCam_GetParam(&qmx_camSettings, qprmBinning, &binFactor);
    if (binFactor > 1)
    {
        if ( (width > (1600 / binFactor)) || (height > (1200 / binFactor)) )
            QMX_PRINTF_UNSYNCHRONIZED("qcammex: ROI size exceeds number of available pixels. With binning set to %lu, maximum size is %dx%d pixels.\n", 
            binFactor, (int)(1600 / binFactor), (int)(1200 / binFactor));
    }
    QCam_SetParam(&qmx_camSettings, qprmRoiX, x);
	QCam_SetParam(&qmx_camSettings, qprmRoiY, y);
	QCam_SetParam(&qmx_camSettings, qprmRoiWidth, width);
	QCam_SetParam(&qmx_camSettings, qprmRoiHeight, height);
    return;
}

void qmx_setTriggerToFreeRun(void)
{
    qmx_triggerType = qcTriggerFreerun;//TO032708M
    QCam_SetParam(&qmx_camSettings, qprmTriggerType, qcTriggerFreerun);
    return;
}

void qmx_setTriggerToEdgeHi(void)
{
    qmx_triggerType = qcTriggerEdgeHi;//TO032708M
    QCam_SetParam(&qmx_camSettings, qprmTriggerType, qcTriggerEdgeHi);
    return;
}

void qmx_setTriggerToEdgeLow(void)
{
    qmx_triggerType = qcTriggerEdgeLow;//TO032708M
    QCam_SetParam(&qmx_camSettings, qprmTriggerType, qcTriggerEdgeLow);
    return;
}

void qmx_setBinning(unsigned int binFactor)
{
    int width, height;
    
    if (binFactor > 1)
    {
    	QCam_GetParam(&qmx_camSettings, qprmRoiWidth, &width);
    	QCam_GetParam(&qmx_camSettings, qprmRoiHeight, &height);
        if ( (width > (1600 / binFactor)) || (height > (1200 / binFactor)) )
            QMX_PRINTF_UNSYNCHRONIZED("qcammex: ROI size exceeds number of available pixels. With binning set to %lu, maximum size is %dx%d pixels.\n", 
            binFactor, (int)(1600 / binFactor), (int)(1200 / binFactor));
    }
    
    QCam_SetParam(&qmx_camSettings, qprmBinning, binFactor);
    return;
}

void qmx_setExposure(unsigned long long int exposureTimeInNS)
{
    QCam_SetParam64(&qmx_camSettings, qprm64Exposure, exposureTimeInNS);
    return;
}

void qmx_setImageFormatToMono8(void)
{
    unsigned long sizeInBytes = 0;
    QCam_SetParam(&qmx_camSettings, qprmImageFormat, qfmtMono8);
    QCam_GetInfo(qmx_cameraHandle, qinfImageSize, &sizeInBytes);
    qmx_pixelCount = sizeInBytes;
    return;
}

void qmx_setImageFormatToMono16(void)
{
    unsigned long sizeInBytes = 0;
    QCam_SetParam(&qmx_camSettings, qprmImageFormat, qfmtMono16);
    QCam_GetInfo(qmx_cameraHandle, qinfImageSize, &sizeInBytes);
    qmx_pixelCount = sizeInBytes/2;
    return;
}

//JL04082008B - Add the realtime viewing mode for future micropublisher RTV model 
void qmx_setCameraModeToRTV(void)
{
    QCam_SetParam(&qmx_camSettings, qprmCameraMode, qmdRealTimeViewing);
    return;
}

//JL04082008C add set camera mode to the standard mode 
void qmx_setCameraModeToSTD(void)
{
    QCam_SetParam(&qmx_camSettings, qprmCameraMode, qmdStandard);
    return;
}

void qmx_setHighSensitivityOn(void)
{
    QCam_SetParam(&qmx_camSettings, qprmHighSensitivityMode, 1);
    return;
}

void qmx_setHighSensitivityOff(void)
{
    QCam_SetParam(&qmx_camSettings, qprmHighSensitivityMode, 0);
    return;
}

void qmx_setNormalizedGain(unsigned int gain)
{
    QCam_SetParam(&qmx_camSettings, qprmNormalizedGain, gain);
    return;
}

void qmx_setAbsoluteOffset(int offset)
{
    QCam_SetParamS32(&qmx_camSettings, qprmS32AbsoluteOffset, offset);
    return;
}

void qmx_setTriggerDelayInNS(unsigned int delay)
{
    QCam_SetParam(&qmx_camSettings, qprmTriggerDelay, delay);
    return;
}

void qmx_setTriggerMask(void)
{
    QCam_SetParam(&qmx_camSettings, qprmSyncb, qcSyncbTrigmask);
   
}

/*
 * Callbacks and online analysis/buffering/data reduction.
 *
 */
void qmx_copyFrame(QCam_Frame* src, QCam_Frame* dest)
{
    if ((src == NULL) || (dest == NULL))
    {
        QMX_PRINTF_MACRO("qcammex.c: qmx_copyFrame encountered NULL frame. src=@%p, dest=@%p\n", src, dest);
        return;
    }
        
    if (src->bufferSize != dest->bufferSize)
    {
        QMX_PRINTF_MACRO("qcammex.c: pBufferSize mismatch.\n\tExpected: %ld [bytes]\n\tFound: %ld [bytes]\n Not copying frame...",
        dest->bufferSize, src->bufferSize);
        return;
    }
    if ( (src->pBuffer == NULL) || (dest->pBuffer == NULL) )
    {
        QMX_PRINTF_MACRO("qcammex.c: qmx_copyFrame encountered NULL buffer...\n");
        qmx_printFrame(src);
        qmx_printFrame(dest);
        return;
    }
    
   //JL02272008C change the order of src and dest
    memcpy(dest->pBuffer, src->pBuffer, src->bufferSize);
    dest->bufferSize = src->bufferSize;
    dest->format = src->format;
    dest->width = src->width;
    dest->height = src->height;
    dest->size = src->size;
    dest->bits = src->bits;
    dest->frameNumber = src->frameNumber;
    dest->bayerPattern = src->bayerPattern;
    dest->errorCode = src->errorCode;
    dest->timeStamp = src->timeStamp;

    return;
}

void qmx_updateFrameGrabStatistics()
{
    unsigned long int currentTime;

    currentTime = GetTickCount();
    if ( (qmx_totalFrameGrabLatency == 0xFFFFFFFF) || (qmx_lastFrameTime == 0xFFFFFFFF) )
    {
        if (qmx_debugOn)
            QMX_PRINTF_UNSYNCHRONIZED("qmx_updateFrameGrabStatistics() - Initializing on first pass...\n");
        qmx_totalFrameGrabLatency = 0;
        qmx_lastFrameTime = currentTime;
        //JL03262008D add qmx_frameCounter and  qmx_totalFrameCounter increasement in the first run    
        qmx_frameCounter++;
        qmx_totalFrameCounter++;
        return;
    }
    
    qmx_totalFrameGrabLatency += currentTime - qmx_lastFrameTime;
    qmx_frameCounter++;
    qmx_totalFrameCounter++;

    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("qmx_updateFrameGrabStatistics()\n"
                         "  qmx_totalFrameCounter: %lu\n"
                         "  qmx_frameCounter: %lu\n"
                         "  qmx_totalFrameGrabLatency: %lu [ms]\n"
                         "  qmx_lastFrameTime: %lu\n"
                         "  currentTime: %lu\n"
                         "   Estimated frame rate: %6.2f [Hz]\n",
        qmx_totalFrameCounter, qmx_frameCounter, qmx_totalFrameGrabLatency, qmx_lastFrameTime, currentTime, qmx_getEstimatedFrameRate());

    qmx_lastFrameTime = currentTime;
    //QMX_PRINTF_MACRO("qcammex.c: qmx_updateFrameGrabStatistics  qmx_frameCounter = %d\n", qmx_frameCounter);
    return;
}

void qmx_updateDisplayBuffer(QCam_Frame* frame)
{
    if ((GetTickCount() - qmx_lastDisplayFrameBufferUpdate) < qmx_maxDisplayUpdateInterval)
        return;//The update rate's too fast, drop this one.

//QMX_PRINTF_MACRO("qmx_updateDisplayBuffer --> qmx_copyFrame(@%p, @%p)\n", frame, qmx_displayFrameBuffer);
//qmx_printFrame(frame);
//qmx_printFrame(qmx_displayFrameBuffer);
    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Updating display buffer...\n");

    //Hang onto this one, for Matlab retrieval.
    EnterCriticalSection(qmx_displayBufferLock);
    qmx_copyFrame(frame, qmx_displayFrameBuffer);
    LeaveCriticalSection(qmx_displayBufferLock);
    qmx_displayFrameBufferStale = false;
    qmx_lastDisplayFrameBufferUpdate = GetTickCount();
    
    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Display buffer updated.\n");
    
    return;
}

//JL03262008E Change qmx_averageFramesTogether from callback function to a new thread
DWORD WINAPI qmx_averageFramesTogether(void* cBuff)
{
    QCam_Frame* frame;
    int i = 0;
    int j = 0;
    int numberOfFrames = 0;
    int result;
    unsigned long sizeInBytes =0;
    
    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Starting output average frame thread...\n");

    qmx_frameAverageRunning = true;
    
    while (!qmx_stopThreadsFlag)
    {
  
        result = qmx_cBuff_blockingGet(qmx_preprocessorStream, &frame, QMX_WORKER_THREAD_TIMEOUT);
        
        switch (result)
        {
            case QMX_CIRCULAR_BUFFER_OK:
                break;
            case QMX_CIRCULAR_BUFFER_TIMEOUT:
                SwitchToThread();
                continue;//TO032708A - Try again on timeout, we just don't want to wait infinitely, in case of a shutdown signal.
            case QMX_CIRCULAR_BUFFER_CLOSED:
                return 0;
            default:
                    QMX_PRINTF_MACRO("qcammex.c: Failed to get buffer frame from preprocessor stream, to pipe into output stream.");
                    break;
        }
        
        if (qmx_stopThreadsFlag)
            break;
        
        qmx_averagedFrameCounter++;
        qmx_totalAveragedFrameCounter++;
        
        //JL03262008E
        //This is crude, but for now it's the only iteration that's necessary, and the stream is guaranteed to be locked and full during this stage.
        //numberOfFrames = qmx_preprocessorStream->bufferSize;
        //for (i = 0; i < qmx_preprocessorStream->pixelBufferSize; i++)
        //TO032708E - Do the calculation in a 64-bit buffer, to prevent rollover, handle both 8 and 16 bit pixel data.
        if (frame->format == qfmtMono8)
        {
            for (i = 0; i < qmx_pixelCount; i++)
                qmx_preprocessorResult[i] = qmx_preprocessorResult[i] + ((unsigned char *)frame->pBuffer)[i];
        }
        else
        {
            for (i = 0; i < qmx_pixelCount; i++)
                qmx_preprocessorResult[i] = qmx_preprocessorResult[i] + ((unsigned short *)frame->pBuffer)[i];
        }
 //QMX_PRINTF_MACRO("qmx_averageFramesTogether frame->pBuffer[1000] = %d, qmx_preprocessorResult[1000] = %d\n",((unsigned short *)frame->pBuffer)[1000], qmx_preprocessorResult[1000]);
        
        if (qmx_stopThreadsFlag)
            break;
        
        //Timeout fast here, since this shouldn't really block anyway.
        //QMX_PRINTF_MACRO("qmx_averageFramesTogether-->qmx_cBuff_blockingGet(qmx_preprocessorStream, &frame, 10)\n");
        
        if (qmx_averagedFrameCounter == qmx_averageFrames)
        {
            if (qmx_stopThreadsFlag)
                  break;
            
            //TO032708E
            if (frame->format == qfmtMono8)
            {
                for (i = 0; i < qmx_pixelCount; i++)
                    ((unsigned char *)frame->pBuffer)[i] = qmx_preprocessorResult[i] / qmx_averageFrames;
            }
            else
            {
                for (i = 0; i < qmx_pixelCount; i++)
                    ((unsigned short *)frame->pBuffer)[i] = qmx_preprocessorResult[i] / qmx_averageFrames;
            }
            
            qmx_averagedFrameCounter = 0;
            
            //TO032708E
            //memcpy(frame->pBuffer, qmx_preprocessorResult, frame->bufferSize);
            
                        
            if (qmx_stopThreadsFlag)
                  break;
            
            //reset qmx_preprocessorResult
            for (i = 0; i < qmx_pixelCount; i++)
                qmx_preprocessorResult[i] = 0; //Reset to zero. //TO032708E
            
            if (qmx_stopThreadsFlag)
                  break;            
            frame->frameNumber = qmx_totalAveragedFrameCounter;//TO032708F
            
            //qmx_printFrame(frame);
            //Pass the averaged frame down the pipeline.
            qmx_updateDisplayBuffer(frame);
            
            if (qmx_stopThreadsFlag)
                  break;            
            
            // qmx_updateDisplayBuffer (qmx_preprocessorStream->buffer[1]);
            
            if (qmx_debugOn && qmx_printEveryFrame)
            {
                QMX_PRINTF_MACRO("qcammex.c: Got frame for averaging from pipeline...\n");
                qmx_printFrame(frame);
            }
            
            //QMX_PRINTF_MACRO("qmx_averageFramesTogether-->qmx_cBuff_blockingPut(cBuff, &frame, QMX_WORKER_THREAD_TIMEOUT)\n");
            
            if (qmx_diskLoggingOn && qmx_diskLoggingRunning)
            {
                //result = qmx_cBuff_blockingPut((qmx_CircularBuffer*)cBuff, &frame, QMX_WORKER_THREAD_TIMEOUT);
                result = qmx_cBuff_blockingPut(qmx_outputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT);
                switch (result)
                {
                    case QMX_CIRCULAR_BUFFER_OK:
                        break;
                    case QMX_CIRCULAR_BUFFER_CLOSED:
                        return 0;
                    case QMX_CIRCULAR_BUFFER_TIMEOUT:
                        SwitchToThread();
                        continue;
                    default:
                            QMX_PRINTF_MACRO("qcammex.c: Failed to put buffer frame from preprocessor stream into next stream in chain.");
                            break;
                }
                
                if (qmx_stopThreadsFlag)
                  break;                
            }
            else
            {
                result = qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT);
                switch (result)
                {
                    case QMX_CIRCULAR_BUFFER_OK:
                        break;
                    case QMX_CIRCULAR_BUFFER_CLOSED:
                        return 0;
                    case QMX_CIRCULAR_BUFFER_TIMEOUT:
                        SwitchToThread();
                        continue;
                    default:
                            QMX_PRINTF_MACRO("qcammex.c: Failed to put buffer frame from preprocessor stream into next stream in chain.");
                            break;
                }
                
                if (qmx_stopThreadsFlag)
                     break;                
                
            }
        }
        else
        {
            result = qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT);
            switch (result)
                {
                    case QMX_CIRCULAR_BUFFER_OK:
                        break;
                    case QMX_CIRCULAR_BUFFER_CLOSED:
                        return 0;
                    case QMX_CIRCULAR_BUFFER_TIMEOUT:
                        SwitchToThread();
                        continue;                    
                    default:
                            QMX_PRINTF_MACRO("qcammex.c: Failed to put buffer frame from preprocessor stream into next stream in chain.");
                            break;
                }
                
            if (qmx_stopThreadsFlag)
                  break;
        }       
        SwitchToThread();//Be a nice neighbor.
    }
    
    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: qmx_averageFramesTogether: Shutting down disk logging thread...\n");
    
    qmx_frameAverageRunning = false;

    return 0;
}

void qmx_routeAcquiredFrame(QCam_Frame* frame)
{
    int result;

    //Quit if the flag was changed prior to the routing request.
    if (qmx_stopThreadsFlag)
            return;
    //Time average raw frames (if necessary).
     if (qmx_averageFrames > 1)
     {
//QMX_PRINTF_MACRO("qmx_routeAcquiredFrame-->qmx_cBuff_blockingPut(qmx_preprocessorStream, &frame, qmx_preprocessorTimeout) 0\n");
        result = qmx_cBuff_blockingPut(qmx_preprocessorStream, &frame, qmx_preprocessorTimeout);
        //Quit if the flag was changed during the blocking call to put a frame on the preprocessor stream.

        //If it fails, the stream's probably full and we timed out. Otherwise something really bad happened.
        if (result != QMX_CIRCULAR_BUFFER_OK)
        {
            if (result == QMX_CIRCULAR_BUFFER_CLOSED)
                return;
            else if (result == QMX_CIRCULAR_BUFFER_TIMEOUT)
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Timed out while trying to put preprocessed buffer frame onto output stream. Dropping frame...\n")
            else if (result == QMX_CIRCULAR_BUFFER_FULL)
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Failed to put preprocessed buffer frame onto output stream. The stream's underlying buffer is full. Dropping frame...\n")
            else
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Error - Failed to put preprocessed buffer frame onto output stream. Dropping frame...\n")
            //Drop/lose frames...?
            if (qmx_inputBufferStream == NULL)
                return;
//QMX_PRINTF_MACRO("qmx_routeAcquiredFrame-->qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT) 1\n");
            if (qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT))
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Failed to return dropped preprocessed buffer frame to input stream.\n")

       }
       if (qmx_stopThreadsFlag)
             return;
     }
    else if (qmx_diskLoggingOn && qmx_diskLoggingRunning)
    {
        qmx_updateDisplayBuffer(frame);
//QMX_PRINTF_MACRO("qmx_routeAcquiredFrame-->qmx_cBuff_blockingPut(qmx_outputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT) 2\n");
        
        result = qmx_cBuff_blockingPut(qmx_outputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT);
        //Quit if the flag was changed during the blocking call to put a frame on the output stream.

        if (result != QMX_CIRCULAR_BUFFER_OK)
        {
            if (result == QMX_CIRCULAR_BUFFER_CLOSED)
                return;
            else if (result == QMX_CIRCULAR_BUFFER_TIMEOUT)
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Timed out while trying to put buffer frame onto output stream. Dropping frame...\n")
            else if (result == QMX_CIRCULAR_BUFFER_FULL)
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Failed to put buffer frame onto output stream. The stream's underlying buffer is full. Dropping frame...\n")
            else
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Error - Failed to put buffer frame onto output stream. Dropping frame...\n")
            //Drop/lose frames...?
            if (qmx_inputBufferStream == NULL)
                return;
//QMX_PRINTF_MACRO("qmx_routeAcquiredFrame-->qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT) 3\n");
            if (qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT))
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Failed to return dropped buffer frame to input stream.\n")
        }
        
        if (qmx_stopThreadsFlag)
                return;
    }
    else
    {
        qmx_updateDisplayBuffer(frame);
        //Quit if the flag was changed during the blocking call to update the display buffer.
        if (qmx_stopThreadsFlag)
                return;
        //Drop/lose frames...?
        if (qmx_inputBufferStream == NULL)
                return;
//QMX_PRINTF_MACRO("qmx_routeAcquiredFrame-->qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT) 4\n");
//qmx_printQueue(qmx_inputBufferStream);
        result = qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT);
        //Quit if the flag was changed during the blocking call to return the frame to the input stream.

//QMX_PRINTF_MACRO("qmx_routeAcquiredFrame-->qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT) 4 COMPLETED\n");
        if (result != QMX_CIRCULAR_BUFFER_OK)
        {
            if (result == QMX_CIRCULAR_BUFFER_CLOSED)
                return;
            else if (result == QMX_CIRCULAR_BUFFER_TIMEOUT)
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Timed out while trying to put buffer frame back into input stream. Frame has been orphaned...\n")
            else if (result == QMX_CIRCULAR_BUFFER_FULL)
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Failed to put buffer frame back into input stream. The stream's underlying buffer is full. Frame has been orphaned...\n")
            else
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Error - Failed to put buffer frame back into input stream. Frame has been orphaned...\n")
        }
       if (qmx_stopThreadsFlag)
                return;
   }

    return;
}

DWORD WINAPI qmx_outputStreamPump(LPVOID lpParam)
{
    QCam_Frame* frame = (QCam_Frame*)NULL;
    int result;
    
    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Starting output stream pump thread...\n");

    qmx_diskLoggingRunning = true;
    
    while (!qmx_stopThreadsFlag)
    {        
        if (qmx_debugOn)
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Getting frame from output stream for disk logging...\n");

        if (qmx_stopThreadsFlag)
            break;
        
        //Get a frame buffer.
        //QMX_PRINTF_MACRO("qmx_outputStreamPump-->qmx_cBuff_blockingGet(qmx_outputBufferStream, &frame, 150)\n");
        
        result = qmx_cBuff_blockingGet(qmx_outputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT);//Don't use an infinite wait, since that won't shut down.
        switch (result)
        {   
            case QMX_CIRCULAR_BUFFER_OK:
                break;
            case QMX_CIRCULAR_BUFFER_CLOSED:
                if (qmx_debugOn)
                    QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Output stream closed.\n");
                qmx_diskLoggingRunning = false;
                break;
            case QMX_CIRCULAR_BUFFER_TIMEOUT:
                SwitchToThread();
                continue;//TO032708A - Try again on timeout, we just don't want to wait infinitely, in case of a shutdown signal.
            default:
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Failed to get buffer frame from output stream, to write to disk.");
                break;
        }

        //Check to see if disk logging was disabled while we were blocking.
        if (qmx_stopThreadsFlag)
            break;
        
        if ((frame == NULL))
        {
            //if (qmx_debugOn)
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Got NULL frame for disk logging, ignoring...\n");
            SwitchToThread();
            continue;//Oops?!?
        }

        if (qmx_stopThreadsFlag)
            break;
        
        if (qmx_debugOn)
        {
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Got frame for disk logging.\n");
            if (qmx_printEveryFrame)
                qmx_printFrame(frame);
        }
        
        if (qmx_framesWrittenCounter >= qmx_framesPerFile)
        {
            if (qmx_debugOn)
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Automatically rolling over file.\n\tqmx_framesWrittenCounter = %d\n\tqmx_framesPerFile = %d\n", qmx_framesWrittenCounter, qmx_framesPerFile);
            qmx_finalizeFile();
            
            if (qmx_stopThreadsFlag)
                break;            
            
            qmx_fileCounter++;
            qmx_initFileFromBaseFilename();
            
            if (qmx_stopThreadsFlag)
                break;
        }
        
        //Check to see if disk logging was disabled while we potentially rolling over a file.
        if (qmx_stopThreadsFlag)
            break;

        //Write the frame to the disk.
        if (qmx_diskLoggingOn)
        {
            if (qmx_debugOn)
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Writing frame to disk...\n");
            qmx_writeFrameToFile(frame);
        }
        //QMX_PRINTF_MACRO("qcammex.c:qmx_outputStreamPump qmx_framesWrittenCounter = %d\n", qmx_framesWrittenCounter);
        
        //TO032708H
        if ((qmx_framesToAcquire > 0) && (qmx_totalFramesWrittenCounter >= qmx_framesToAcquire))
        {
            qmx_stopThreadsFlag = true;
            if (qmx_debugOn)
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Acquired all %lu frames. Shutting down threads...\n", qmx_framesToAcquire);
        }
        //Check to see if disk logging was disabled while we writing to a file.
        if (qmx_stopThreadsFlag)
            break;
        
        if (qmx_debugOn)
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Finished writing frame to disk. Returning frame to input stream...\n");
        //Return the frame buffer to be re-used.
        //QMX_PRINTF_MACRO("qmx_outputStreamPump-->qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT)\n");

        result = qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT);
            
        switch (result)
           {
                case QMX_CIRCULAR_BUFFER_OK:
                    break;
                case QMX_CIRCULAR_BUFFER_CLOSED:
                    qmx_diskLoggingRunning = false;
                    if (qmx_debugOn)
                        QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Input stream closed. Shutting down disk logging thread.\n");
                    return 0;
                case QMX_CIRCULAR_BUFFER_TIMEOUT:
                    SwitchToThread();
                    continue;//TO032708A - Try again on timeout, we just don't want to wait infinitely, in case of a shutdown signal.
                default:
                        QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Failed to return buffer frame to input stream after logging frame's data to disk.\n");
                        break;
            }
            
        if (qmx_stopThreadsFlag)
            break;
            
        SwitchToThread();//Be a nice neighbor.
    }
    
    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: qmx_outputStreamPump Shutting down disk logging thread...\n");
    
    qmx_finalizeFile();
    qmx_diskLoggingRunning = false;

    return 0;
}

DWORD WINAPI qmx_synchronousGrab(LPVOID lpParam)
{
    QCam_Frame* frame = (QCam_Frame*)NULL;
    QCam_Err qcamResult;
    int result;
    
    
    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Starting synchronous streaming thread...\n");

    //Indicate that this thread is running.
    qmx_runningSync = 1;
   
    
    while (!qmx_stopThreadsFlag)
    {
        //Get a frame buffer.
//QMX_PRINTF_MACRO("qmx_synchronousGrab-->qmx_cBuff_blockingGet(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT)\n");
        result = qmx_cBuff_blockingGet(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT);
        switch (result)
        {
            case QMX_CIRCULAR_BUFFER_OK:
                break;
            case QMX_CIRCULAR_BUFFER_CLOSED:
                if (qmx_debugOn)
                    QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Input stream closed. Shutting down synchronous streaming thread.\n");
                qmx_runningSync = false;
                return 0;
            case QMX_CIRCULAR_BUFFER_TIMEOUT:
                     SwitchToThread();
                     continue;//TO032708A - Try again on timeout, we just don't want to wait infinitely, in case of a shutdown signal.
            default:
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Failed to get buffer frame from input stream to fill with camera data.\n");
                continue;
        }

        if (qmx_debugOn)
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Got frame from input stream, filling frame with camera data...\n");

        //Fill the frame with data.
        qcamResult = QCam_GrabFrame(qmx_cameraHandle, frame);
        
        if (!qmx_stopThreadsFlag)
            qmx_errorMsg(qcamResult, "qmx_synchronousGrab");
        else
            break;

        qmx_updateFrameGrabStatistics();

        if (qmx_debugOn)
        {
            QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Got frame synchronously from camera for pipeline...\n");
            if (qmx_printEveryFrame)
                qmx_printFrame(frame);
        }

        //Quit if the flag was changed during the blocking call to grab.
        if (qmx_stopThreadsFlag)
            break;
        
        if (qmx_debugOn)
            QMX_PRINTF_UNSYNCHRONIZED("qmx_synchronousGrab: Acquired frame...\n");

        //Check the frame's status.
        if (frame->errorCode)
            qmx_errorMsg(frame->errorCode, "qmx_synchronousGrab - frame->errorCode");

        //Route the frame down the pipeline.
        qmx_routeAcquiredFrame(frame);
        
        
        //Quit if the flag was changed during the pipelining of the frame.
        if (qmx_stopThreadsFlag)
            break;
               
        
        SwitchToThread();//Be a nice neighbor.
    }
    
    //Indicate that we're finished.
    qmx_runningSync = 0;
    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("qmx_synchronousGrab: Shutting down synchronous streaming thread...\n");
        
    return 0;
}

void qmx_queueAsyncFrame(QCam_Frame* frame)
{
     qmx_queueAsncFrameCounter++;
     //JL04112008C Stop queue more frames when the required qmx_framesToAcquire reaches
     if ((qmx_framesToAcquire > 0) && (qmx_queueAsncFrameCounter/qmx_averageFrames > qmx_framesToAcquire))
            return;
    
    //Pass a frame into
    if (qmx_errorMsg(QCam_QueueFrame(qmx_cameraHandle, frame, 
                                     qmx_FrameDoneCallback, qcCallbackDone, (void *)frame, 0), "qmx_queueAsyncFrame"))
    {
        QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Failed to queue frame for asynchronous acquisition...\n");
        //Put it back, for re-use.
        
        switch (qmx_cBuff_blockingPut(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT))
        {
            case QMX_CIRCULAR_BUFFER_OK:
                break;
            case QMX_CIRCULAR_BUFFER_CLOSED:
                return;
            default:
                QMX_PRINTF_MACRO("qcammex.c: Failed to return buffer frame to input stream for re-use.\n");
                break;
        }
    }
 

    return;
}

//calback function
//JL02062008B Change the input arguments of FrameDoneCallback
//JL02072008A change FrameDoneCallback from void to void QCAMAPI
void QCAMAPI qmx_FrameDoneCallback(QCam_Frame* frame, unsigned long sizeInBytes, QCam_Err errCode, unsigned long flags)
{
    int getAFrame = 0;
    
   if (!qmx_runningAsync || qmx_stopThreadsFlag)
            return;
   
   qmx_updateFrameGrabStatistics();

    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("qmx_FrameDoneCallback: Recieved frame...\n");
    
    if (errCode)
    {
        qmx_errorMsg(errCode, "qmx_FrameDoneCallback");
        return;
    }

    //Quit if the flag was changed lately...
    if (!qmx_runningAsync || qmx_stopThreadsFlag)
            return;
    
    if (qmx_debugOn && qmx_printEveryFrame)
    {
        QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Got frame from QImaging asynchronous queue...\n");
        qmx_printFrame(frame);
    }
      
    if (!qmx_runningAsync || qmx_stopThreadsFlag)
            return; 
   
    //Route the frame down the pipeline.
    qmx_routeAcquiredFrame(frame);

    //Quit if the flag was during pipelining.
    if (!qmx_runningAsync || qmx_stopThreadsFlag)
            return;

    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("Requeueing frame for asynchronous streaming...\n");

    //Get a frame buffer.
//QMX_PRINTF_MACRO("qmx_FrameDoneCallback-->qmx_cBuff_blockingGet(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT)\n");
    
    //JL04112008E Change if statement to while statement to avoid of missing frames
 while (!getAFrame)
    {

        if (!qmx_runningAsync || qmx_stopThreadsFlag)
            return; 
        
        switch (qmx_cBuff_blockingGet(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT))
    {
            case QMX_CIRCULAR_BUFFER_OK:
                getAFrame = 1;
                break;
            case QMX_CIRCULAR_BUFFER_CLOSED:
                return;
            case QMX_CIRCULAR_BUFFER_TIMEOUT:
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Timed out while trying to get buffer frame from input stream to be queued to the QImaging asynchronous streaming queue.\n");
                SwitchToThread();
                continue;
            default:
                QMX_PRINTF_UNSYNCHRONIZED("qcammex.c: Failed to get buffer frame from input stream to be queued to the QImaging asynchronous streaming queue.\n");
                return;
        }
    }

    //TO062108A - Allow quiting before attempting to queue a frame.
    if (!qmx_runningAsync || qmx_stopThreadsFlag)
            return;

    //Queue another frame.
    qmx_queueAsyncFrame(frame);
    
    //Quit if the flag was changed during requeueing of the buffer.
    if (!qmx_runningAsync || qmx_stopThreadsFlag)
            return;

    if (qmx_debugOn)
        QMX_PRINTF_UNSYNCHRONIZED("Frame %d complete.\n", qmx_frameCounter);

    return;
}


/*
 * State controls.
 *
 */
void qmx_stopThreads(void)
{
    qmx_stopThreadsFlag = true;
    SwitchToThread();
    if (qmx_synchronousThread != NULL)
    {
        if (qmx_debugOn)
            printf("qcammex.c: Stopping synchronous streaming thread...\n");
        SwitchToThread();
        WaitForSingleObject(qmx_synchronousThread, 500);
        if (qmx_runningSync)
        {
            if (qmx_debugOn)
                QMX_PRINTF_MACRO("qcammex.c: qmx_synchronousThread seems to be taking a long time to shut down (>500ms). Abandoning thread...\n");
            qmx_runningSync = false;
        }
        TerminateThread(qmx_synchronousThread, (DWORD)NULL); //JL04082008D - Add terminatethread to kill the threads
        CloseHandle(qmx_synchronousThread);
        qmx_synchronousThread = NULL;
        qmx_synchronousThreadID = (DWORD)NULL;
    }
    qmx_runningAsync = false;
    

    qmx_diskLoggingOn = false;
    if (qmx_diskLoggingThread != NULL)
    {
        if (qmx_debugOn)
            printf("qcammex.c: Stopping disk logging thread...\n");
        SwitchToThread();
        WaitForSingleObject(qmx_diskLoggingThread, 500);
        if (qmx_diskLoggingRunning)
        {
            if (qmx_debugOn)
                QMX_PRINTF_MACRO("qcammex.c: qmx_diskLoggingThread seems to be taking a long time to shut down (>500ms). Abandoning thread...\n");
            qmx_diskLoggingRunning = false;
        }
        TerminateThread(qmx_diskLoggingThread, (DWORD)NULL); //JL04082008D - Add terminatethread to kill the threads
        CloseHandle(qmx_diskLoggingThread);
        qmx_diskLoggingThread = NULL;
        qmx_diskLoggingThreadID = (DWORD)NULL;
    }
    
    //JL03262008E close the thread frameAverageThread
    if (qmx_frameAverageThread != NULL)
    {
        if (qmx_debugOn)
            printf("qcammex.c: Stopping frame average thread...\n");
        SwitchToThread();
        WaitForSingleObject(qmx_frameAverageThread, 500);
        if (qmx_frameAverageRunning)
        {
            if (qmx_debugOn)
                QMX_PRINTF_MACRO("qcammex.c: qmx_frameAverageThread seems to be taking a long time to shut down (>500ms). Abandoning thread...\n");
            qmx_frameAverageRunning = false;
        }
        TerminateThread(qmx_frameAverageThread, (DWORD)NULL);  //JL04082008D - Add terminatethread to kill the threads
        CloseHandle(qmx_frameAverageThread);
        qmx_frameAverageThread = NULL;
        qmx_frameAverageThreadID = (DWORD)NULL;
    }
    return;
}

void qmx_abort(void)
{
    if (qmx_errorMsg(QCam_Abort(qmx_cameraHandle), "qmx_abort - QCam_Abort"))
    {
        QMX_PRINTF_MACRO("qcammex.c: Failed to abort current camera operation(s).\n");
        return;
    }
    if (qmx_errorMsg(QCam_SetStreaming(qmx_cameraHandle, 0), "qmx_abort - QCam_SetStreaming"))
    {
        QMX_PRINTF_MACRO("qcammex.c: Failed to stop streaming.");
    }

    qmx_finalizeFile();
    qmx_stopThreads();

    return;
}

void qmx_reset()
{
    QMX_PRINTF_MACRO("Resetting qcammex...\n\tAborting current operations...\n");
    qmx_abort();
    QMX_PRINTF_MACRO("\tReleasing QCam drivers...\n");
    qmx_releaseQCamDriver();
    QMX_PRINTF_MACRO("\tLoading QCam drivers...\n");
    qmx_loadQCamDriver();
    QMX_PRINTF_MACRO("\tAcquiring camera...\n");
    qmx_acquireCamera();
    
    return;
}

void qmx_commitSettingsToCam(void)
{
    qmx_abort();
    QCam_SetParam(&qmx_camSettings, qprmDoPostProcessing, 0);//Hard-code no post processing.
    QCam_SetParam(&qmx_camSettings, qprmReadoutSpeed, qcReadout20M);//Always try for the highest possible readout speed?
    if (qmx_errorMsg(QCam_SendSettingsToCam(qmx_cameraHandle, &qmx_camSettings), "qmx_commitSettingsToCam"))
    {
        QMX_PRINTF_MACRO("qcammex.c: Failed to send settings to camera.\n");
        return;
    }

    return;
}

void qmx_start(void)
{
    unsigned long sizeInBytes = 0;
    int i = 0;
    QCam_Frame* frame;
    
    
    //qmx_debugOn = true;
    //qmx_printEveryFrame = true;
    //qmx_cBuffDebugOn = true;
    

    qmx_abort();
   
    qmx_configureBuffers();
  
    
    //Reset statistics.
    qmx_totalFrameGrabLatency = 0xFFFFFFFF;
    qmx_lastFrameTime = 0xFFFFFFFF;
    qmx_frameCounter = 0;
    qmx_averagedFrameCounter = 0;//TO032708F - This wasn't being reset already, and it should've been.
    qmx_totalAveragedFrameCounter = 0;//TO032708F

    if (qmx_errorMsg(QCam_SetStreaming(qmx_cameraHandle, 0), "qmx_start - QCam_SetStreaming(..., false)"))
    {
        QMX_PRINTF_MACRO("qcammex.c: Failed to stop streaming.");
        return;
    }

    // Image size depends on the current region & image format.
    if (qmx_errorMsg(QCam_GetInfo(qmx_cameraHandle, qinfImageSize, &sizeInBytes), "qmx_start - QCam_GetInfo"))
    {
        QMX_PRINTF_MACRO("qcammex.c: Failed to get frame size in bytes from camera info.\n");
        return;
    }
   
    
    //JL03032008A Move the setstreaming before create the synchronousgrab thread   
    //Start streaming data over Firewire.
    if (qmx_errorMsg(QCam_SetStreaming(qmx_cameraHandle, 1), "qmx_start - QCam_SetStreaming(..., true)"))
    {
        QMX_PRINTF_MACRO("qcammex.c: Failed to start streaming.");
        return;
    }
    
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qcammex.c: Starting threads...\n");
    //Start threads.
    qmx_stopThreadsFlag = false;
    if (qmx_streamingMode == QMX_STREAMING_MODE_SYNC)
    {
        qmx_synchronousThread = CreateThread(NULL, 0, qmx_synchronousGrab, NULL, 0, &qmx_synchronousThreadID);
    }
    else
        qmx_runningAsync = true;

    //Prepare disk logging.
    if (qmx_baseFilename != NULL)
    {
        qmx_diskLoggingOn = true;
        qmx_fileCounter = 0;
        qmx_framesWrittenCounter = 0;
        qmx_totalFramesWrittenCounter = 0;
    	qmx_initFileFromBaseFilename();
        qmx_diskLoggingThread = CreateThread(NULL, 0, qmx_outputStreamPump, NULL, 0, &qmx_diskLoggingThreadID);
    }
    
    //start frame average thread
    if (qmx_averageFrames > 1)
        qmx_frameAverageThread = CreateThread(NULL, 0, qmx_averageFramesTogether, NULL, 0, &qmx_frameAverageThreadID);
    
    //Push frames from the qcammex queue into the QImaging queue, for asynchronous streaming.
    //It appears, from the documentation, that this must be done after streaming is enabled, not before.
    if (qmx_streamingMode == QMX_STREAMING_MODE_ASYNC)
    {
        while (!qmx_cBuff_isEmpty(qmx_inputBufferStream))
        {
            if (qmx_cBuff_blockingGet(qmx_inputBufferStream, &frame, QMX_WORKER_THREAD_TIMEOUT))
                QMX_PRINTF_MACRO("qcammex.c: Failed to move buffer frame from input stream into QImaging's asynchronous queue. The buffer frame has been orphaned.\n")
            else
            {
                //if (qmx_debugOn)   
                QCam_QueueFrame(qmx_cameraHandle, frame, qmx_FrameDoneCallback, qcCallbackDone, frame, sizeInBytes);
                //QMX_PRINTF_MACRO("qcammex.c: QCam_QueueFrame(@%p, @%p, qmx_FrameDoneCallback, qcCallbackDone, @%p, %lu);\n", qmx_cameraHandle, frame, frame, sizeInBytes);
            }
        }
        qmx_queueAsncFrameCounter =4;
    }        


    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qcammex.c: Started threads -\n qmx_synchronousThread: @%p\n qmx_diskLoggingThread: @%p\n", qmx_synchronousThread, qmx_diskLoggingThread);

    SwitchToThread();//Yield to the new threads. Once they're started, they will wait on the queues and yield back.

    return;
}

/*
 * mexAtExit
 *
 */
void qmx_cleanUp(void)
{
    if (qmx_debugOn)
    {
        QMX_PRINTF_MACRO("qcammex.c: Releasing all resources and memory...\n");
    }
    qmx_abort();
    qmx_finalizeFile();
    qmx_releaseQCamDriver();
    qmx_clearBuffers();

    if (qmx_headerData != NULL)
    {
        free(qmx_headerData);
        qmx_headerData = NULL;
    }

    if (qmx_baseFilename != NULL)
    {
        free(qmx_baseFilename);
        qmx_baseFilename = NULL;
    }

    if (qmx_fileLock != NULL)
    {
        DeleteCriticalSection(qmx_fileLock);
        free(qmx_fileLock);
        qmx_fileLock = NULL;
    }

    if (qmx_printfLock != NULL)
    {
        DeleteCriticalSection(qmx_printfLock);
        free(qmx_printfLock);
        qmx_printfLock = NULL;
    }
    
    if (qmx_displayBufferLock != NULL)
    {
        DeleteCriticalSection(qmx_displayBufferLock);
        free(qmx_displayBufferLock);
        qmx_displayBufferLock = NULL;
    }

    if (qmx_debugOn)
    {
        QMX_PRINTF_MACRO("qcammex.c: Released all resources and memory. Have a nice day, sucker!\n");
    }
    
    return;
}

/*
 * Matlab interface.
 *
 */
#ifdef QMX_MATLAB_BINDING
char* qmx_strCopy(const mxArray* string)
{
    char* cString;

    cString = calloc(mxGetNumberOfElements(string) + 1, sizeof(char));
    mxGetString(string, cString, mxGetNumberOfElements(string) + 1);

    return cString;
}

mxArray* qmx_copyFramesIntoMatlab(QCam_Frame** src, int numberOfFrames)
{
    int i;
    mwSize dims[] = {0, 0, 0};
    uint16 *mxData;
    
    mxArray* dest;
    //JL02292008A correct typo = to ==
    if ((src == NULL) || (numberOfFrames == 0))
    {
        QMX_PRINTF_MACRO("qmx_copyFramesIntoMatlab: the scr == NULL");
        return mxCreateDoubleScalar(0);
    }
    
    dims[0] = src[0]->width;
    dims[1] = src[0]->height;
    dims[2] = numberOfFrames;
    
    //JL03062008A Change the mxUINT16_CLASS to mxUINT8_CLASS because the image format mono8 
    dest = mxCreateNumericArray(3, dims, mxUINT16_CLASS, mxREAL);
    mxData = mxGetData(dest);
    
    for (i = 0; i < numberOfFrames; i++)
        memcpy(mxData + (src[i]->size * i), src[i]->pBuffer, src[i]->size);

    
    return dest;
}

mxArray* qmx_loadFramesIntoMatlab(qmx_QCamFile* qcf, int numberOfFrames, int* indices)
{
    int i;
    mwSize dims[] = {0, 0, 0};
    uint16 *mxData;
    void *bb;
    
    mxArray* dest;

    dims[0] = qcf->roiWidth;
    dims[1] = qcf->roiHeight;
    dims[2] = numberOfFrames;
    //JL03062008A Change the mxUINT16_CLASS to mxUINT8_CLASS because the image format mono8 
    dest = mxCreateNumericArray(3, dims, mxUINT16_CLASS, mxREAL);
    mxData = mxGetData(dest);
    for (i = 0; i < numberOfFrames; i++){
        qmx_readFrame(qcf, (void *)(mxData + (qcf->frameSizeInBytes * i)), indices[i]);
        //qmx_readFrame(qcf, (void *)(mxData + (qcf->frameSizeInBytes * i)), indices[i]);
    }
        //qmx_readFrame(qcf, (void *)(mxData + qcf->frameSizeInBytes), indices[i]);
    return dest;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    char* command;
    char* header;
   qmx_QCamFile* qcf;
    int* indices;
    int numel;
    int i = 0;
    double* pr;
    unsigned long sizeInBytes = 0;

    //Don't leave a mess when the DLL is unloaded.
//    mexAtExit(qmx_cleanUp);
        
   
    command = mxArrayToString(prhs[0]);
    // QMX_PRINTF_MACRO("command = %s\n", command);
    if (qmx_debugOn)
    {
        if (nrhs > 1)
        {
            QMX_PRINTF_MACRO("qcammex.c(command='%s', {%d})\n", command, nrhs - 1);
        }
        else
        {
            QMX_PRINTF_MACRO("qcammex.c(command='%s')\n", command, nrhs - 1);
        }
    }
   
    //Check these commands first, since they don't depend on the drivers already being loaded.
    if (stringcompare(command, "releaseDriver") == 0)
    {
        qmx_releaseQCamDriver();
        return;
    }
    else if (stringcompare(command, "getOutputFileName") == 0)
    {
        plhs[0] = mxCreateString(qmx_outputFileName);//TO032408A
        return;
    }
    else if (stringcompare(command, "setFilename") == 0)
    {
//         if (qmx_baseFilename != NULL)
//            free(qmx_baseFilename);
        
        //Apparently mxIsEmpty doesn't work, it evaluates as true when a string is non-empty.
        

        qmx_baseFilename = qmx_strCopy(prhs[1]);
        

        
        if (strlen(qmx_baseFilename) > 0)
            qmx_diskLoggingOn = true;
        else
        {
            qmx_diskLoggingOn = false;
            if (qmx_baseFilename != NULL)
            {
                free(qmx_baseFilename);
                qmx_baseFilename = NULL;
            }
        }

        return;
    }
    else if (stringcompare(command, "setAverageFrames") == 0)
    {
        qmx_averageFrames = (unsigned int)*(mxGetPr(prhs[1]));
        return;
    }
    else if (stringcompare(command, "setFramesPerFile") == 0)
    {
        qmx_framesPerFile = (unsigned int)*(mxGetPr(prhs[1]));
        return;
    }
    else if (stringcompare(command, "setUserHeaderField") == 0)
    {
        if (qmx_headerData != NULL)
        {
            free(qmx_headerData);
            qmx_headerData = NULL;
        }
          //Comment this out because it always show prhs[1] is empty      
        //if (!mxIsEmpty(prhs[1]))
            qmx_headerData = qmx_strCopy(prhs[1]);
        return;
    }
    else if (stringcompare(command, "setUserTimingField") == 0)
    {
        if (qmx_userTimingData != NULL)
        {
            free(qmx_userTimingData);
            qmx_userTimingData = NULL;
        }
        
       //Comment this out because it always show prhs[1] is empty 
       //       if (!mxIsEmpty(prhs[1]))
            qmx_userTimingData = qmx_strCopy(prhs[1]);
        
        return;
    }
    else if (stringcompare(command, "setIntputQueueSize") == 0)
    {
        qmx_inputStreamBufferSize = (unsigned int)*(mxGetPr(prhs[1]));
        return;
    }
    else if (stringcompare(command, "setOutputQueueSize") == 0)
    {
        qmx_outputStreamBufferSize = (unsigned int)*(mxGetPr(prhs[1]));
        return;
    }
    else if (stringcompare(command, "setStreamingMode") == 0)
    {
        if (stringcompare(mxArrayToString(prhs[1]), "qcammex") == 0)
            qmx_streamingMode = QMX_STREAMING_MODE_SYNC;
        else if (stringcompare(mxArrayToString(prhs[1]), "API") == 0)
            qmx_streamingMode = QMX_STREAMING_MODE_ASYNC;
        else
        {
            mexErrMsgTxt("Invalid parameter for qcammex('setStreamingMode', ...)\n  Must be 'qcammex' or 'API'.");
        }
        
        return;
    }
    else if (stringcompare(command, "getFrames") == 0)
    {
        qcf = qmx_openQCamFile(mxArrayToString(prhs[1]));
        numel = mxGetNumberOfElements(prhs[2]);
        indices = (int*)mxCalloc(numel, sizeof(int));
        pr = mxGetPr(prhs[2]);
        for (i = 0; i < numel; i++)
        {
            indices[i] = pr[i];
        QMX_PRINTF_MACRO("qcammex.c: indices value is %d\n", indices[i]);
        }
        plhs[0] = qmx_loadFramesIntoMatlab(qcf, numel, indices);

        return;
    }
    else if (stringcompare(command, "getNumberOfFrames") == 0)
    {
        qcf = qmx_openQCamFile(mxArrayToString(prhs[1]));
        plhs[0] = mxCreateDoubleScalar(((double)qcf->fileSizeInBytes - (double)qcf->headerSize) / (double)qcf->frameSizeInBytes);
        QMX_PRINTF_MACRO("qcammex.c: filesizeinbyte = % lu, headersize = %d, framesizeInBytes = %d\n", qcf->fileSizeInBytes, qcf->headerSize, qcf->frameSizeInBytes);
        return;
    }
    else if (stringcompare(command, "getHeaderString") == 0)
    {
        qcf = qmx_openQCamFile(mxArrayToString(prhs[1]));
        header = mxCalloc(qcf->headerSize, sizeof(char));
        if (!qcf)
            mexErrMsgTxt("qcammex.c: Failed to open file for reading.");
        fseek(qcf->stream, 0, SEEK_SET);
        if (fread(header, sizeof(char), qcf->headerSize, qcf->stream) != qcf->headerSize)
            QMX_PRINTF_MACRO("qcammex.c: Error reading header data. Header may be corrupted.\n");
        plhs[0] = mxCreateString(header);
        qmx_closeQCamFile(&qcf);
        
        return;
    }
    else if (stringcompare(command, "getVersion") == 0)
    {
        plhs[0] = mxCreateDoubleScalar(QCAMMEX_VERSION);
        return;
    }
    else if (stringcompare(command, "getEstimatedFrameRate") == 0)
    {
        plhs[0] = mxCreateDoubleScalar(qmx_getEstimatedFrameRate());
        return;
    }
    else if (stringcompare(command, "debugOn") == 0)
    {
        if (*mxGetPr(prhs[1]))
        {
            qmx_debugOn = true;
            qmx_printEveryFrame = true;
            qmx_printPixelRangeInFrame = true;
            qmx_cBuffDebugOn = false;
        }
        else
        {
            qmx_debugOn = false;
            qmx_printEveryFrame = false;
            qmx_printPixelRangeInFrame = false;
            qmx_cBuffDebugOn = false;
        }
        return;
    }
    else if (stringcompare(command, "printState") == 0)
    {
        qmx_printState();
        return;
    }
    else if (stringcompare(command, "loadCamera") == 0)
    {
        if (qmx_cameraHandle == NULL)
        qmx_init();
        return;
    }
    else if (stringcompare(command, "setFramesToAcquire") == 0)
    {
        //TO032708H
        if (!mxIsFinite(*mxGetPr(prhs[1])))  //JL04082008E - replace mxIsInf with mxIsFinite because mxIsInf didn't work
            qmx_framesToAcquire = 0;
        else
            qmx_framesToAcquire = (unsigned int)*(mxGetPr(prhs[1]));
        
        return;
                    
    }

    //Initialize the drivers.
    if (qmx_cameraHandle == NULL)
        qmx_init();

    //Now process commands that require the drivers.
    if (stringcompare(command, "printCamera") == 0)
    {
        qmx_printCamera(qmx_cameraHandle);
        return;
    }
    else if (stringcompare(command, "start") == 0)
    {
        qmx_start();
        return;
    }
    else if (stringcompare(command, "stop") == 0)
    {
        //qmx_finalizeFile(); // qmx_abort calls qmx_finalizeFile
        qmx_abort();
        return;
    }
    else if (stringcompare(command, "commitSettingsToCam") == 0)
    {
        qmx_commitSettingsToCam();
        return;
    }
    else if (stringcompare(command, "finalizeFile") == 0)
    {
        qmx_finalizeFile();
        return;
    }
    else if (stringcompare(command, "setBinFactor") == 0)
    {
        qmx_setBinning((unsigned int)*(mxGetPr(prhs[1])));
        return;
    }
    else if (stringcompare(command, "setROI") == 0)
    {
        qmx_setROI((unsigned int)*(mxGetPr(prhs[1])), (unsigned int)*(mxGetPr(prhs[2])), 
                   (unsigned int)*(mxGetPr(prhs[3])), (unsigned int)*(mxGetPr(prhs[4])));//x, y, width, height
        
        return;
    }
    else if (stringcompare(command, "setExposureTime") == 0)
    {
        qmx_setExposure((unsigned int)*(mxGetPr(prhs[1])));
        return;
    }
    //JL03262008F add command setImageFormatToMono16
    else if (stringcompare(command, "setImageFormatToMono16") == 0)     
    {
        qmx_setImageFormatToMono16();
        return;
    }
    else if (stringcompare(command, "setTriggerType") == 0)
    {
        if (stringcompare(mxArrayToString(prhs[1]), "auto") == 0)
            qmx_setTriggerToFreeRun();
        else if (stringcompare(mxArrayToString(prhs[1]), "edgeLow") == 0)
            qmx_setTriggerToEdgeLow();
        else if (stringcompare(mxArrayToString(prhs[1]), "edgeHigh") == 0)
            qmx_setTriggerToEdgeHi();
        else
            QMX_PRINTF_MACRO("qcammex.c: Bad triggerType value: '%s'\n", mxArrayToString(prhs[1]));
        
        return;
    }
    else if (stringcompare(command, "setCameraMode") == 0)
    {
        if (stringcompare(mxArrayToString(prhs[1]), "rtv") == 0) 
            qmx_setCameraModeToRTV();
        else if (stringcompare(mxArrayToString(prhs[1]), "std") == 0)
            qmx_setCameraModeToSTD();
        else
            QMX_PRINTF_MACRO("qcammex.c: Bad triggerType value: '%s'\n", mxArrayToString(prhs[1]));
    }
    else if (stringcompare(command, "getCurrentFrame") == 0)
    {
        if (!qmx_displayFrameBufferStale && (qmx_runningAsync || qmx_runningSync))
        {

            if (qmx_displayBufferLock != NULL)
            {
                EnterCriticalSection(qmx_displayBufferLock);
                plhs[0] = qmx_copyFramesIntoMatlab(&qmx_displayFrameBuffer, 1);
                qmx_displayFrameBufferStale = true;
                LeaveCriticalSection(qmx_displayBufferLock);
            }
            else
                QMX_PRINTF_MACRO("qmx_copyFramesIntoMatlab:qmx_displayBufferLock = NULL\n");
        }
        else
        {   
            //QMX_PRINTF_MACRO("qmx_copyFramesIntoMatlab: qmx_displayFrameBufferStale=true\n");
            plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
            }
        //JL03272008G add qmx_framecounter value to the qcam GUI
        if (nlhs == 3)
            plhs[1] = mxCreateDoubleScalar(qmx_getEstimatedFrameRate());
            plhs[2] = mxCreateDoubleScalar(qmx_frameCounter);
            
        return;
    }
    else if (stringcompare(command, "getSnapshot") == 0)
    {
        //TO032708J
        if (qmx_runningAsync || qmx_runningSync)
        {        
            if (qmx_displayBufferLock != NULL)
            {
                EnterCriticalSection(qmx_displayBufferLock);                 
                plhs[0] = qmx_copyFramesIntoMatlab(&qmx_displayFrameBuffer, 1);                
                qmx_displayFrameBufferStale = true;                 
                LeaveCriticalSection(qmx_displayBufferLock);
            }
            else
                QMX_PRINTF_MACRO("qmx_copyFramesIntoMatlab:qmx_displayBufferLock = NULL\n");
        }
        else
        {               
            //Configure the camera.
            qmx_commitSettingsToCam(); 
            //Initialize the display frame buffer, if necessary.
            if (qmx_displayFrameBuffer == NULL)
                qmx_displayFrameBuffer = (QCam_Frame*)calloc(1, sizeof(QCam_Frame)); 
            qmx_displayFrameBufferStale = true;
            if (qmx_errorMsg(QCam_GetInfo(qmx_cameraHandle, qinfImageSize, &sizeInBytes), "getSnapshot"))
            {
                mexErrMsgTxt("qcammex.c: Failed to determine pixel buffer size in bytes.\n");
                return;
            }
            qmx_setPixelBufferSize(qmx_displayFrameBuffer, sizeInBytes);

            //Acquire and return frame.
            if (qmx_errorMsg(QCam_GrabFrame(qmx_cameraHandle, qmx_displayFrameBuffer), "getSnapshot"))
            {
                mexErrMsgTxt("qcammex.c: Failed to retrieve frame.\n");
                return;
            }
            plhs[0] = qmx_copyFramesIntoMatlab(&qmx_displayFrameBuffer, 1);
        }

        return;
    }
    else if (stringcompare(command, "clearBuffers") == 0)
    {
        qmx_clearBuffers();
        return;
    }
    else if (stringcompare(command, "reset") == 0)
    {
        qmx_reset();
        return;
    }
    else
        QMX_PRINTF_MACRO("qcammex.c: Error - Command '%s' not found/supported.\n", command);

    return;
}
#endif //#ifdef QMX_MATLAB_BINDING

/*
 * Testing and debugging.
 *
 */
void bufferTest(void)
{
    int i = 0;
    int sizeInBytes = 256;

    //Initialize/resize preprocessor stream.
    if ((qmx_preprocessorStream == NULL) && (qmx_averageFrames > 1))
    {
        qmx_preprocessorStream = qmx_cBuff_createCircularBuffer(qmx_averageFrames);
        
        //The input buffer needs to have enough frames to fill the preprocessor buffer.
        if (qmx_inputStreamBufferSize < qmx_averageFrames)
            qmx_inputStreamBufferSize = qmx_averageFrames + 1;
    }

    //Initialize preprocessor calculation buffer.
    if (qmx_averageFrames > 1)
    {
        if (qmx_preprocessorStream->pixelBufferSize != sizeInBytes)
        {
            if (qmx_preprocessorResult != NULL)
                free(qmx_preprocessorResult);
            qmx_preprocessorResult = (unsigned long long int *)calloc(qmx_pixelCount, sizeof(unsigned long long int));
        }
    }

    //Initialize/resize input stream.
    if (qmx_inputBufferStream == NULL)
        qmx_inputBufferStream = qmx_cBuff_createCircularBuffer(qmx_inputStreamBufferSize);

    //Initialize/resize output stream.
    if (qmx_outputBufferStream == NULL)
        qmx_outputBufferStream = qmx_cBuff_createCircularBuffer(qmx_outputStreamBufferSize);
    
    //Move all buffer frames, including orphans, back into the input stream.
    for (i = 0; i < QMX_MAX_QUEUED_FRAME_BUFFERS; i++)
    {
        if (qmx_frameCache[i] != NULL)
            if (!qmx_cBuff_hasFrame(qmx_inputBufferStream, qmx_frameCache[i]))
                qmx_cBuff_Put(qmx_inputBufferStream, &qmx_frameCache[i]);//This should have no reason to be synchronized.
    }
    //Update pixel buffer sizes, and create/destroy frames, if necessary.
    qmx_cBuff_setPixelBufferSize(qmx_inputBufferStream, sizeInBytes);
    qmx_cBuff_resetMarkers(qmx_inputBufferStream);
    //Make sure there are no oddball straglers.
    qmx_cBuff_confirmEmpty(qmx_outputBufferStream);
    
    qmx_printQueue(qmx_inputBufferStream);
    qmx_printQueue(qmx_outputBufferStream);
    printf("\nqmx_cBuff_flush(qmx_inputBufferStream, qmx_outputBufferStream);\n\n");
    qmx_cBuff_flush(qmx_inputBufferStream, qmx_outputBufferStream);
    printf("\nqmx_cBuff_flush(qmx_inputBufferStream, qmx_outputBufferStream); COMPLETE\n\n");
    qmx_printQueue(qmx_inputBufferStream);
    qmx_printQueue(qmx_outputBufferStream);

    return;
}

#define QMX_TEST_FILE_ENCODING
#ifdef QMX_TEST_FILE_ENCODING
void testFileEncoding(void)
{
    QCam_Frame* framesOut[10];
    QCam_Frame* frameIn;
    qmx_QCamFile* qcf;
    int i = 0;
    int j = 0;
    int pixelsPerFrame = 1200 * 1600;
    bool framesMatch = false;
    
    //printf("\n\tAll I ask of life is a constant and exaggerated sense of my own importance.\n\n");
    
    //Allocate frames and fill them with dummy data.
    for (i = 0; i < 10; i++)
    {
        framesOut[i]->pBuffer = calloc(pixelsPerFrame, 2 * sizeof(char));
        framesOut[i]->bufferSize = 2 * pixelsPerFrame;
        for (j = 0; j < pixelsPerFrame; j += 3)
            ((unsigned short*)framesOut[i]->pBuffer)[j] = i;
        for (j = 1; j < pixelsPerFrame; j += 3)
            ((unsigned short*)framesOut[i]->pBuffer)[j] = i + 1;
        for (j = 2; j < pixelsPerFrame; j += 3)
            ((unsigned short*)framesOut[i]->pBuffer)[j] = 0;
    }

    //Initialize file, write out a pile of frames, and close the file.
    qmx_initFile("C:\\Users\\Tim\\QCamSDK\\framedata.raw");
    for (i = 0; i < 1; i++)
    {
        for (j = 0; j < 10; j++)
            qmx_writeFrameToFile(framesOut[j]);
    }
    qmx_finalizeFile();

    //Open the file, parsing the header info.
    qcf = qmx_openQCamFile("C:\\Users\\Tim\\QCamSDK\\framedata.raw");
    qmx_printQCamFileStruct(qcf);

    frameIn = (QCam_Frame *)calloc(1, sizeof(QCam_Frame));
    frameIn->bufferSize = 2 * pixelsPerFrame;
    frameIn->pBuffer = calloc(pixelsPerFrame, 2 * sizeof(char));
    for (i = 0; i < 10; i++)
    {
        framesMatch = true;
        qmx_readFrame(qcf, frameIn->pBuffer, 0);
        for (j = 0; j < pixelsPerFrame; j++)
        {
            if (((unsigned short*)frameIn->pBuffer)[j] != ((unsigned short*)framesOut[i]->pBuffer)[j])
            {
                framesMatch = false;
                break;
            }
        }
        
        if (framesMatch)
            printf(" OK - Frame %d matches on disk and in memory.\n", i);
        else
            printf(" FAIL - Frame %d does not match on disk and in memory.\n", i);
    }
    qmx_closeQCamFile(&qcf);

    return;
}
#endif
#ifndef QMX_MATLAB_BINDING
void main(int argc, char** argv)
{
    QCam_Frame* frame = NULL;
    qmx_QCamFile* qcf;
    int i = 0;
/*bufferTest();
if (true)
return;*/
    QMX_PRINTF_MACRO("qmx_debugOn=1\nqmx_printEveryFrame = 1\n");
    qmx_debugOn = 1;
    qmx_printEveryFrame = 1;
    
    //Set up wrapper.
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_init()\n");

    qmx_init();

    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_averageFrames = 1\n");
    qmx_averageFrames = 1;

    //Configure.
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_setImageFormatToMono16()\n");
    qmx_setImageFormatToMono16();
//    if (qmx_debugOn)
//      QMX_PRINTF_MACRO("setImageFormatToMono8()\n");
//        setImageFormatToMono8();
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("setExposure(126200000)\n");
    qmx_setExposure(126200000);//30ms.
    if (qmx_debugOn)
      QMX_PRINTF_MACRO("qmx_setTriggerToFreeRun()\n");
    qmx_setTriggerToFreeRun();//Run asynchronously and continuously.
//    if (qmx_debugOn)
//        QMX_PRINTF_MACRO("qmx_setTriggerToEdgeHi()\n");
//    qmx_setTriggerToEdgeHi();
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_setROI(0, 0, 800, 600)\n");
    qmx_setROI(0, 0, 800, 600);//800x600 ROI.
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_setBinning(1)\n");
    qmx_setBinning(1);
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_configureBuffers()\n");
    qmx_configureBuffers();//Only need one frame in the buffer.
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_setTriggerMask()\n");
    qmx_setTriggerMask();
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_commitSettingsToCam()\n");
    qmx_commitSettingsToCam();

QMX_PRINTF_MACRO("configure for disk logging...\n");
qmx_framesPerFile = 3;
qmx_diskLoggingOn = true;
qmx_baseFilename = "C:\\Users\\Tim\\QCamSDK\\framedata";
qmx_averageFrames = 2;
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("qmx_streamingMode = QMX_STREAMING_MODE_SYNC\n");
    qmx_streamingMode = QMX_STREAMING_MODE_SYNC;
//    if (qmx_debugOn)
//        QMX_PRINTF_MACRO("qmx_streamingMode = QMX_STREAMING_MODE_ASYNC\n");
//    qmx_streamingMode = QMX_STREAMING_MODE_ASYNC;
QMX_PRINTF_MACRO("qmx_cBuffDebugOn = true\n");
qmx_cBuffDebugOn = false;
qmx_debugOn = false;
qmx_printEveryFrame = false;
qmx_printPixelRangeInFrame = true;
//qmx_printState();
    QMX_PRINTF_MACRO("start()\n");
    qmx_start();
//qmx_printState();
SwitchToThread();
    if (qmx_streamingMode == QMX_STREAMING_MODE_SYNC)
    {
        QMX_PRINTF_MACRO("\nWaitForMultipleObjects(1, &qmx_synchronousThread, TRUE, 3000)\n\n");
        WaitForMultipleObjects(1, &qmx_synchronousThread, TRUE, 3000);
    }
    else
    {
        QMX_PRINTF_MACRO("\nSleep(5000)\n\n");
        Sleep(5000);
    }

    //QMX_PRINTF_MACRO("\nAcquired frames - ");
    //for (i = 0; i < qmx_frameBufferSize; i++)
    //    qmx_printFrame(qmx_frameBuffer[i]);
    //QMX_PRINTF_MACRO("\n\n");
//qmx_printState();
    QMX_PRINTF_MACRO("abort()\n");
QMX_PRINTF_MACRO("\nSleep(5000)\n\n");
Sleep(5000);
    qmx_abort();//Stop acquisition.
//qmx_printState();
//    QMX_PRINTF_MACRO("\nGrabbing frame...\n");
//    qmx_errorMsg(QCam_GrabFrame(qmx_cameraHandle, frame), "main");
//    qmx_printFrame(frame);

//    if (qmx_debugOn)
//        for (i = 0; i < 100; i++)
//            //for (i = 0; i < qmx_frameBuffer[0]->bufferSize; i++)
//            QMX_PRINTF_MACRO("%02.2hX ", ((unsigned char*)frame->pBuffer)[i]);

    
/*
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("\n");
    qmx_start();
//qmx_printState();
SwitchToThread();
    if (qmx_streamingMode == QMX_STREAMING_MODE_SYNC)
    {
        QMX_PRINTF_MACRO("\nWaitForMultipleObjects(1, &qmx_synchronousThread, TRUE, 10500)\n\n");
        WaitForMultipleObjects(1, &qmx_synchronousThread, TRUE, 10500);
    }
    else
    {
        QMX_PRINTF_MACRO("\nSleep(5000)\n\n");
        Sleep(5000);
    }
    qmx_abort();
*/
    
    
//    if (qmx_debugOn)
  //  {
/*        qmx_outputFile = fopen("C:\\Users\\Tim\\QCamSDK\\header.txt", "w");
        qmx_printHeader(qmx_outputFile);
        fclose(qmx_outputFile);
        qmx_outputFile = NULL;
        qcf = qmx_openQCamFile("C:\\Users\\Tim\\QCamSDK\\header.txt");
        qmx_printQCamFileStruct(qcf);
        qmx_closeQCamFile(&qcf);
 */
    /*
qmx_initFile("C:\\Users\\Tim\\QCamSDK\\framedata.raw");
qmx_debugOn = true;
qmx_writeFrameToFile(qmx_frameBuffer[0]);
qmx_debugOn = false;
qmx_finalizeFile();
QMX_PRINTF_MACRO("\n");
qcf = qmx_openQCamFile("C:\\Users\\Tim\\QCamSDK\\framedata.raw");
qmx_printQCamFileStruct(qcf);
QMX_PRINTF_MACRO("\n");
qmx_debugOn = true;
qmx_readFrame(qcf, qmx_frameBuffer[0]->pBuffer, 0);
qmx_debugOn = false;
qmx_closeQCamFile(&qcf);
qmx_printFrame(qmx_frameBuffer[0]);
     **/
//    }
qmx_printState();
    if (qmx_debugOn)
        QMX_PRINTF_MACRO("cleanUp()\n");
    qmx_cleanUp();//Clean up.
    
    return;//Shutdown.
}
#endif //#ifdef QMX_MATLAB_BINDING

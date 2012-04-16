// grabFrame.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"

/** 
 * DEFINES
 */
#define MAXERRORMESSAGESIZE 128
#define MAXVARNAMESIZE 64

/**
 * FUNCTION PROTOTYPES
 */
void prepareOutputDataBuffer(int nrhs, const mxArray *prhs[]);
void returnOutputData(int nlhs,mxArray *plhs[]);

/**
 * STATIC VARIABLES
 */
static int status;
static const mxArray *hCamera;
static QCam_Handle *cameraHandlePtr;
static QCam_Handle cameraHandle;
static QCam_Frame frame;
static unsigned long m, n, sizeInBytes;
static mxArray *image;

/**
 * MISC VARIABLES
 */
char methodName[MAXVARNAMESIZE] = "grabFrame";


/**
 * Defines the entry point for the MEX function.  
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	static bool isInit = false;

	if (!isInit)
	{
		prepareOutputDataBuffer(nrhs, prhs);

		isInit = true;
	}

	status = QCam_GrabFrame(cameraHandle, &frame);

	returnOutputData(nlhs, plhs);
}


/**
 * Allocates the necessary memory for image acquisition.
 */
void prepareOutputDataBuffer(int nrhs, const mxArray *prhs[])
{
	hCamera = prhs[0];
	cameraHandlePtr = (QCam_Handle *) mxGetData(mxGetProperty(hCamera,0,"cameraHandle"));
	cameraHandle = *cameraHandlePtr;

	QCam_GetInfo(cameraHandle, qinfImageHeight, &m);
	QCam_GetInfo(cameraHandle, qinfImageWidth, &n);
	QCam_GetInfo(cameraHandle, qinfImageSize, &sizeInBytes);

	image = mxCreateNumericMatrix(m, n, mxUINT8_CLASS, mxREAL);
	mexMakeArrayPersistent(image);

	// Fill out fields in QCam_Frame structure.
	frame.pBuffer = mxGetData(image);
	frame.bufferSize = sizeInBytes;
}


/**
 * Verifies acquisition success and assigns the output data
 */
void returnOutputData(int nlhs, mxArray *plhs[])
{
	if (status == qerrSuccess)
	{
		if (nlhs >= 1)
			plhs[0] = image;
		else
			mxDestroyArray(image); //If you don't read out, all the reading was done for naught

	}
	else //Read failed
	{
		char errorMsgTxt[MAXERRORMESSAGESIZE];
		sprintf_s(errorMsgTxt,"ERROR in %s call. Status code %d was returned",methodName,status);
		mexErrMsgTxt(errorMsgTxt);
	}
	
}
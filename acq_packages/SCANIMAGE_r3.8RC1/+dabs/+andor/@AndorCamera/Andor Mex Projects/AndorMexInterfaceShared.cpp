
#include "stdafx.h"

//Variable definitions
unsigned int status;
bool outputData;
int outputClassNumBits;
char* outputVarName;
mxArray* outputDataBuf;
void* outputDataPtr;
mwSize outputVarSize;

bool reshape;
mwSize outputSizeM, outputSizeN = 1;
size_t outputSizeNumElements;
double *outputSizeArray;
mxClassID outputSizeClass;


void prepareOutputDataBuffer(int nrhs, const mxArray *prhs[])
{
	outputClassNumBits = (int) mxGetScalar(prhs[1]);

	if ((nrhs < 3) || mxIsEmpty(prhs[2]))
	{
		outputData = true;
		outputSizeM = (mwSize) mxGetScalar(mxGetProperty(prhs[0],0,"expectedM"));
		outputSizeN = (mwSize) mxGetScalar(mxGetProperty(prhs[0],0,"expectedN"));

		reshape = true;
	}
	else
	{
		outputData = mxIsNumeric(prhs[2]); 
		
		if (outputData)
		{
			outputSizeNumElements = mxGetNumberOfElements(prhs[2]); //Temporary -- have user specify either single number or 2-element array (indicating to reshape)

			if (outputSizeNumElements == 1) //scalar case
			{
				outputSizeM = (mwSize) mxGetScalar(prhs[2]);
				outputSizeN = 1;
			}
			else if (outputSizeNumElements == 2) //2 element array
			{	
				reshape = true;
				
				if (mxIsDouble(prhs[2]))
					outputSizeArray = mxGetPr(prhs[2]);
				else
					mexErrMsgTxt(" At this time, if an output size array is specified, it must be given as class 'double'.");
	
				outputSizeM = (mwSize) outputSizeArray[0];
				outputSizeN = (mwSize) outputSizeArray[1];


			}
			else		
				mexErrMsgTxt("Either a scalar valure or a 2 element array must be supplied as the outputSize");


		}
		else
			mxGetString(prhs[2], outputVarName, MAXVARNAMESIZE); //We tested this but found it to be slightly slower -- Vijay Iyer 4/27/10
	}


	if (outputData)	
	{
		outputVarSize = outputSizeM * outputSizeN; 

		switch (outputClassNumBits)
		{
			case 16:
				if (reshape)
					outputDataBuf = mxCreateNumericMatrix(outputSizeM,outputSizeN,mxINT16_CLASS,mxREAL);
				else
					outputDataBuf = mxCreateNumericMatrix(outputVarSize,1,mxINT16_CLASS,mxREAL);
			break;

			case 32:
				if (reshape)
					outputDataBuf = mxCreateNumericMatrix(outputSizeM,outputSizeN,mxINT32_CLASS,mxREAL);
				else
					outputDataBuf = mxCreateNumericMatrix(outputVarSize,1,mxINT16_CLASS,mxREAL);
			break;
		}
	}
	else
	{
		outputDataBuf = mexGetVariable("global", outputVarName);	
		if (!outputDataBuf)
		{
			mexPrintf("Failed to find variable '%s' in workspace. Aborting read.\n",outputVarName);
			return;
		}
		outputVarSize = mxGetNumberOfElements(outputDataBuf);
		//TODO: Add check to ensure WS variable is of correct class
	}
	outputDataPtr = mxGetData(outputDataBuf);

}


void returnOutputData(int nlhs,mxArray *plhs[])
{
	if (status == DRV_SUCCESS)
	{
		//TODO: RESHAPE transpose operation (if required)
		//if (reshape)
		//{
		//}


		if (outputData)
		{
			if (nlhs >= 1)
				plhs[0] = outputDataBuf;
			else
				mxDestroyArray(outputDataBuf); //If you don't read out, all the reading was done for naught
		}
		else
		{
			int putStatus;
			putStatus = mexPutVariable("global", outputVarName, outputDataBuf);

			if (putStatus)			
				mexPrintf("Error occurred in mexPutVariable()\n");

		}
	}
	else //Read failed
	{
		char errorMsgTxt[MAXERRORMESSAGESIZE];
		sprintf_s(errorMsgTxt,"ERROR in %s call. Status code %d was returned",methodName,status);
		mexErrMsgTxt(errorMsgTxt);
	}
	
}
// GetAcquiredData.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"

//Matlab signature
//outputData = GetAcquiredData(cameraObj,outputClassNumBits,outputVarOrSize)
//	cameraObj: Handle to Devices.Andor.AndorCamera object for which data is being retrieved
//	outputClassNumBits: One of {16 32}, indicating size, in bits, of integer class to return.
//	outputVarOrSize: (OPTIONAL) Either name of preallocated MATLAB variable into which to store read data, or the size in pixels of the output variable to create (to be returned as outputData argument).
//						If empty/omitted, array is allocated of size matching number of configured pixels
//	
//	outputData: Array of output data. This value is not output if outputVarOrSize is a string specifying a preallocated output variable.

//Variable definitions
char methodName[MAXVARNAMESIZE] = "getAcquiredData";

//Gateway routine
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	prepareOutputDataBuffer(nrhs, prhs);

	switch (outputClassNumBits)
	{
		case 16:
			status = GetAcquiredData16((WORD *)outputDataPtr,outputVarSize);
		break;

		case 32:
			status = GetAcquiredData((at_32 *)outputDataPtr,outputVarSize);
		break;
	}

	returnOutputData(nlhs,plhs);
}




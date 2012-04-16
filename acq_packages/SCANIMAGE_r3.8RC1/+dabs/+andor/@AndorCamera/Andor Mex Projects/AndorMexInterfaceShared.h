#pragma once

#include "stdafx.h"

//Constant definitions
#define MAXVARNAMESIZE 64
#define MAXERRORMESSAGESIZE 256

//Variable declarations
extern unsigned int status;
extern bool outputData;
extern mxArray* outputDataBuf;
extern char* outputVarName;
extern mwSize outputVarSize;
extern int outputClassNumBits;
extern void* outputDataPtr;


extern char	methodName[MAXVARNAMESIZE];

//Function declarations
void prepareOutputDataBuffer(int nrhs, const mxArray *prhs[]);
void returnOutputData(int nlhs,mxArray *plhs[]);




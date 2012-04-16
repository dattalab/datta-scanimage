%function outputData = getAcquiredData(obj,outputClassNumBits, varargin)
%   outputClassNumBits: One of {16 32}. Indicates size, in bits, of integer class to return.
%   outputVarOrSize: (OPTIONAL) Either name of preallocated MATLAB variable into which to store read data, or the size in pixels of the output variable to create (to be returned as outputData argument).
%                    If empty/omitted, array is allocated of size matching number of configured pixels
%
%   outputData: Array of output data. This value is not output if outputVarOrSize is a string specifying a preallocated output variable.
%
% NOTES
%   No 'status' information is returned. If underlying API call returns an unsuccessful 'status', an error is thrown.
%

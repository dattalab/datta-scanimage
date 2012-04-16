% @nimex/nimex_readAnalogF64 - Read 64-bit analog data.
% 
% SYNTAX
%  data = nimex_readAnalogF64(nimextask, numSamplesPerChannel)
%  data = nimex_readAnalogF64(nimextask, numSamplesPerChannel, timeout)
%  read = nimex_readAnalogF64(nimextask, numSamplesPerChannel, buff, offset)
%  read = nimex_readAnalogF64(nimextask, numSamplesPerChannel, timeout, buff, offset)
%   nimextask - An instance of the nimex class.
%   numSamplesPerChannel - The number of samples, per channel, to read.
%   timeout - A timeout, after which to give up, in seconds.
%   buff - An array of class 'double', with length greater than or equal to (numSamplesPerChannel * numChannels) + offset
%   offset - The C-array-style offset in the buffer at which to begin writing samples. 0 indicates the beginning of the buffer.
%   data - The samples which have been read.
%   read - The number of samples which have been read.
%  
% NOTES
%  Relies on NIMEX_readAnalogF64.mex32.
%  Is not guaranteed to return the number of samples that have been requested.
%  
% CHANGES
%  TO013007A: Updated to allow reading into a Matlab-supplied buffer (for memory re-use). -- Tim O'Connor 1/30/07
%
% Created
%  Aleksander Sobczyk & Timothy O'Connor 11/16/06
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function data = nimex_readAnalogF64(this, varargin)

data = NIMEX_readAnalogF64(this.NIMEX_TaskDefinition, varargin{:});

% fprintf(1, 'nimex_readAnalogF64: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
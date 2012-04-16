% @nimex/nimex_readDigitalU32 - Read 64-bit analog data.
% 
% SYNTAX
%  data = nimex_readDigitalU32(nimextask, numSamples)
%  data = nimex_readDigitalU32(nimextask, numSamples, timeout)
%   nimextask - An instance of the nimex class.
%   numSamples - The number of samples, per channel, to read.
%   timeout - A timeout, after which to give up, in seconds.
%   data - The samples which have been read.
%  
% NOTES
%  Relies on NIMEX_readDigitalU32.mex32.
%  Is not guaranteed to return the number of samples that have been requested.
%  
% Created
%  Timothy O'Connor 1/24/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function data = nimex_readDigitalU32(this, varargin)

data = NIMEX_readDigitalU32(this.NIMEX_TaskDefinition, varargin{:});

% fprintf(1, 'nimex_readDigitalU32: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
% @nimex/nimex_writeAnalogF64 - Write 64-bit analog data.
% 
% SYNTAX
%  written = nimex_writeAnalogF64(nimextask, channelName, data, numSamples)
%  written = nimex_writeAnalogF64(nimextask, channelName, data, numSamples, timeout)
%   nimextask - An instance of the nimex class.
%   channelName - The channel for which to write data.
%   data - The samples to be written.
%   numSamples - The number of samples, per channel, to write.
%   timeout - A timeout, after which to give up, in seconds.
%   written - The number of samples actually written.
%  
% NOTES
%  Relies on NIMEX_writeAnalogF64.mex32.
%  Is not guaranteed to write the number of samples that have been requested.
%
% CHANGES
%   TO012407E: Make sure the data is 64-bit float.
%
% Created
%  Timothy O'Connor 11/29/06
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function written = nimex_writeAnalogF64(this, channelName, data, numSamples, varargin)
% getStackTraceString
if ~strcmpi(class(data), 'double')
    fprintf(1, 'nimex_writeAnalogF64 - Warning: Converting data into float64 format.\n');
    data = double(data);
end
written = NIMEX_writeAnalogF64(this.NIMEX_TaskDefinition, channelName, data, numSamples, varargin{:});

% fprintf(1, 'nimex_writeAnalogF64: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
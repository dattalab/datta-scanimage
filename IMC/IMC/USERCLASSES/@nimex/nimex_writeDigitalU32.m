% @nimex/nimex_writeDigitalU32 - Write 32-bit unsigned digital data.
% 
% SYNTAX
%  written = nimex_writeDigitalU32(nimextask, channelName, data, numSamples)
%  written = nimex_writeDigitalU32(nimextask, channelName, data, numSamples, timeout)
%   nimextask - An instance of the nimex class.
%   channelName - The channel for which to write data.
%   data - The samples to be written.
%   numSamples - The number of samples, per channel, to write.
%   timeout - A timeout, after which to give up, in seconds.
%   written - The number of samples actually written.
%  
% NOTES
%  Relies on NIMEX_writeDigitalU32.mex32.
%  Is not guaranteed to write the number of samples that have been requested.
%  
% Created
%  Timothy O'Connor 1/24/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function written = nimex_writeDigitalU32(this, channelName, data, numSamples, varargin)

if ~strcmpi(class(data), 'uint32')
    fprintf(1, 'nimex_writeDigitalU32 - Warning: Converting data into uint32 format.\n');
    data = uint32(data);
end
written = NIMEX_writeDigitalU32(this.NIMEX_TaskDefinition, channelName, data, numSamples, varargin{:});

% fprintf(1, 'nimex_writeAnalogF64: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
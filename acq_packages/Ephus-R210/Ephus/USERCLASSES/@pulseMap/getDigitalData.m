%  @pulseMap/getDigitalData - Retrieve the digital data for a specified channel name.
%
% SYNTAX
%  data = getDigitalData(pm, channelName)
%  data = getDigitalData(pm, channelName, job)
%  data = getDigitalData(pm, channelName, time)
%  data = getDigitalData(pm, channelName, samples, 'Samples')
%   pm - @pulseMap instance.
%   channelName - The channel for which to retrieve data.
%   job - A @daqjob instance.
%         In this form, the amount of data to retrieve is determined by examining the @daqjob.
%   time - The amount of data to retrieve, in seconds.
%   samples - The amount of data to retrieve, in samples.
%             Only applies when an extra argument is supplied and that argument is the string 'Samples'.
%
% NOTES
%  Calls through to @pulseMap/getData.
%
% CHANGES
%
% Created
%  Timothy O'Connor 
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function data = getDigitalData(this, channelName, varargin)
% getStackTraceString

data = getData(this, channelName, varargin{:});
data(data ~= 0) = 1;
data = uint32(data);
% fprintf(1, '@pulseMap/getDigitalData(this, ''%s'', ...) - = %s samples\n', channelName, num2str(length(data)));
return;
% @pulseMap/getAggregatedDigitalData - Retrieve the data for a specified channel name.
%
% SYNTAX
%  data = stim_getAggregatedDigitalData(pm, channels, channelName)
%  data = stim_getAggregatedDigitalData(pm, channels, channelName, job)
%  data = stim_getAggregatedDigitalData(pm, channels, channelName, time)
%  data = stim_getAggregatedDigitalData(pm, channels, channelName, samples, 'Samples')
%   pm - An @pulseMap instance, from which to retrieve the per-channel pulses.
%   channels - The list of channels to be aggregated, in their order, from least-significant to most-significant bit correspondence.
%   channelName - The actual channel for which to retrieve data.
%   job - A @daqjob instance.
%         In this form, the amount of data to retrieve is determined by examining the @daqjob.
%   time - The amount of data to retrieve, in seconds.
%   samples - The amount of data to retrieve, in samples.
%             Only applies when an extra argument is supplied and that argument is the string 'Samples'.
%   actualChannelName - Another channel name, corresponding to the actual underlying channel, for times when the mnemonic name in a GUI doesn't match the hardware configuration.
%
% Created
%  Timothy O'Connor 7/22/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function data = getAggregatedDigitalData(this, channels, channelName, varargin)

daqjobForm = 0;
if ~isempty(varargin)
    if strcmpi(class(varargin{1}), 'daqjob')
        daqjobForm = 1;
    end
end

if daqjobForm
    data = getDigitalData(this, channels{1}, varargin{1}, channelName);
    for i = 2 : length(channels)
        data = bitor(data, 2^(i-1) * getDigitalData(this, channels{i}, varargin{1}, channelName));
    end
else
    data = getDigitalData(this, channels{1}, varargin{:});
    for i = 2 : length(channels)
        data = bitor(data, 2^(i-1) * getDigitalData(this, channels{i}, varargin{:}));
    end
end
% fprintf(1, '@pulseMap/getAggregatedDigitalData(this, ''%s'', ...) - = %s samples\n', channelName, num2str(length(data)));
return;
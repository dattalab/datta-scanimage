% @daqjob/bindDataPreprocessor - Set a NIMEX data preprocessor for the specified channel.
%
% SYNTAX
%  bindDataPreprocessor(dj, channelName, callback, callbackName)
%   dj - @daqjob instance.
%   channelName - The name of the channel for which to bind a listener (may be a pseudochannel).
%   callback - The callback to handle the data. Must take the data as an argument.
%   callbackName - A unique identifier for this callback.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%  TO073108B - Use getTaskByDeviceName for nimex_bindEveryNCallback, instead of getTaskByChannelName. -- Tim O'Connor 7/31/08
%
% Created 8/14/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function bindDataPreprocessor(this, channelName, callback, name)
global daqjobGlobalStructure;

channelName = channelNamesToRealChannels(this, channelName);%TO073008A

if channelName(1) ~= '/'
    channelName = getDeviceNameByChannelName(this, channelName);
end

nimex_bindEveryNCallback(getTaskByDeviceName(this, channelName), {@dispatchData, this, channelName}, ['daqjob_' daqjobGlobalStructure(this.ptr).name], 1);

if ~isEvent(daqjobGlobalStructure(this.ptr).preprocessors, channelName)
    addEvent(daqjobGlobalStructure(this.ptr).preprocessors, channelName);
end
addCallback(daqjobGlobalStructure(this.ptr).preprocessors, channelName, callback, name);

return;
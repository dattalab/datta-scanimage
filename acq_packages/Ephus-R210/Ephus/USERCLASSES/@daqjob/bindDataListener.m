% @daqjob/bindDataListener - Bind a callback to recieve data from dispatched EveryN samples events.
%
% SYNTAX
%  bindDataListener(dj, channelName, callback, callbackName)
%   dj - @daqjob instance.
%   channelName - The name of the channel for which to bind a listener (may be a pseudochannel).
%   callback - The callback to handle the data. Must take the data and the sample rate as arguments.
%   callbackName - A unique identifier for this callback.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%
% Created 8/14/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function bindDataListener(this, channelName, callback, name)
global daqjobGlobalStructure;
% fprintf(1, 'channelName = ''%s'' @ %s\n', channelName, getStackTraceString);
if channelName(1) ~= '/'
    channelName = getDeviceNameByChannelName(this, channelNamesToRealChannels(this, channelName));%TO073008A
end

nimex_bindEveryNCallback(getTaskByDeviceName(this, channelName), {@dispatchData, this, channelName}, ['daqjob_' daqjobGlobalStructure(this.ptr).name], 1);
if ~isEvent(daqjobGlobalStructure(this.ptr).callbackManager, channelName)
    addEvent(daqjobGlobalStructure(this.ptr).callbackManager, channelName);
end
addCallback(daqjobGlobalStructure(this.ptr).callbackManager, channelName, callback, name);

return;
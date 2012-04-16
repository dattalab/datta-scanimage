% @daqjob/getDeviceNameByChannelName - Look up a NIDAQmx device based on the name mnemonic channel name.
%
% SYNTAX
%  deviceName = getDeviceNameByChannelName(job, channelName)
%   channelName - The mnemonic name corresponding to deviceName. May be a cell array of names.
%   deviceName - A NIDAQmx style device name, such as '/dev1/ai0'. May be a cell array of names.
%
% NOTES
%
% CHANGES
%  VI060108A - Add capability to return boardID, chanID instead of deviceName -- Vijay Iyer 6/1/08
%  VI060108B - Pull out redundant output arg processing -- Vijay Iyer 6/1/08
%  VI061108A - Handle digital channel case -- Vijay Iyer 6/11/08
%  TO073008D - Pulled out VI060108A/VI060108B/VI061108A because it made no sense, didn't belong here, was implemented badly, was nearly unreadable, made the return arguments unmanageable, and screwed up the functionality quite a bit. -- Tim O'Connor 7/30/08
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%
% Created
%  Timothy O'Connor 7/30/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function deviceName = getDeviceNameByChannelName(this, channelName)
global daqjobGlobalStructure;

channelName = channelNamesToRealChannels(this, channelName);%TO073008A

if iscell(channelName)
    deviceName = cell(size(channelName));
    for i = 1 : length(channelName)
        deviceName{i} = getDeviceNameByChannelName(this, channelName{i});
    end
    return;
end

index = indexOf(daqjobGlobalStructure(this.ptr).channelMap, channelName);
if isempty(index)
    error('Failed to find mnemonic channel name ''%s''.', channelName);
end

deviceName = [daqjobGlobalStructure(this.ptr).channelMap{index, 2}, daqjobGlobalStructure(this.ptr).channelMap{index, 3}];

return;

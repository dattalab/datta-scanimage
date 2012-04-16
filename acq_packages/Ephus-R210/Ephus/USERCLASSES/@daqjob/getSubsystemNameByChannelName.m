% @daqjob/getSubsystemNameByChannelName - Returns the subsystem name that corresponds to the given channel name.
%
% SYNTAX
%  subsystemName = getSubsystemNameByChannelName(dj, channelName)
%   dj - @daqjob instance.
%   channelName - The name of the channel for which to look up the subsystem.
%   subsystemName - The name of the subsystem that corresponds to channelName.
%
% NOTES
%
% CHANGES
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%
% Created
%  Timothy O'Connor 7/30/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function subsystemName = getSubsystemNameByChannelName(this, channelName)
global daqjobGlobalStructure;
% getStackTraceString

channelName = channelNamesToRealChannels(this, channelName);%TO073008A

%Lookup the channel name to get the subsystem name.
index = indexOf(daqjobGlobalStructure(this.ptr).channelMap, channelName);
if isempty(index)
    error('Failed to find mnemonic channel name ''%s''.', channelName);
end
subsystemName = daqjobGlobalStructure(this.ptr).channelMap{index, 2};

return;
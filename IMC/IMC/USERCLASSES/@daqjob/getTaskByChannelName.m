% @daqjob/getTaskByChannelName - Returns the task that corresponds to the given channel name.
%
% SYNTAX
%  task = getTaskByChannelName(dj, channelName)
%   dj - @daqjob instance.
%   channelName - The name of the channel for which to look up the task.
%   task - The task that corresponds to channelName.
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
function task = getTaskByChannelName(this, channelName)

channelName = channelNamesToRealChannels(this, channelName);%TO073008A

subsystemName = getSubsystemNameByChannelName(this, channelName);

task = getTaskBySubsystemName(this, subsystemName);

return;
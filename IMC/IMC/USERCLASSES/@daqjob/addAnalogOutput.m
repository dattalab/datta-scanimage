% @daqjob/addAnalogOutput - Add analog output channel.
%
% SYNTAX
%  addAnalogOutput(job, channelName, subsystemName, channelID)
%   job - A @daqjob instance.
%   channelName - A mnemonic name for the channel.
%   subsystemName - The NIDAQmx subsystem, such as '/dev1/ai'.
%   channelID - The channel to be used. Such as 0, 1, '0', etc.
%
% NOTES
%
% CHANGES
%  TO032908A - Implement end-to-end digital channel support in Ephus. -- Tim O'Connor 3/29/08
%  TO050508F - Disable channels by default. They'll get enabled when starting. -- Tim O'Connor 5/5/08
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%
% Created
%  Timothy O'Connor 7/30/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function addAnalogOutput(this, channelName, subsystemName, channelID)
global daqjobGlobalStructure;
% fprintf(1, 'channelName = ''%s'' @ %s\n', channelName, getStackTraceString);
index = indexOf(daqjobGlobalStructure(this.ptr).channelMap, channelName);
if ~isempty(index)
    error('A channel with the name ''%s'' already exists.', channelName);
end
%TO073008A
if ismember(channelName, daqjobGlobalStructure(this.ptr).pseudoChannelMap)
    error('A pseudochannel with the name ''%s'' already exists.', channelName);
end
index = size(daqjobGlobalStructure(this.ptr).channelMap, 1) + 1;

if ~ischar(channelID)
    channelID = num2str(channelID);
end

task = getOrCreateTask(this, subsystemName);
daqjobGlobalStructure(this.ptr).channelMap{index, 1} = channelName;
daqjobGlobalStructure(this.ptr).channelMap{index, 2} = subsystemName;
daqjobGlobalStructure(this.ptr).channelMap{index, 3} = channelID;
daqjobGlobalStructure(this.ptr).channelMap{index, 4} = 'analogOut';
nimex_addAnalogOutput(task, [subsystemName channelID]);

nimex_setChannelProperty(task, [subsystemName channelID], 'mnemonicName', channelName, 'enable', 0);%TO050508F

return;
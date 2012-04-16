% @daqjob/addDigitalOutput - Add a digital output channel.
%
% SYNTAX
%  addDigitalOutput(job, channelName, subsystemName, lineID)
%   job - A @daqjob instance.
%   channelName - A mnemonic name for the channel.
%   subsystemName - The NIDAQmx subsystem, such as '/dev1/port0'.
%   lineID - The line(s) to be used. Such as 0, 1, 0:7, etc.
%            Only sequential sets of lines are supported.
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
function addDigitalOutput(this, channelName, subsystemName, lineID)
global daqjobGlobalStructure;

index = indexOf(daqjobGlobalStructure(this.ptr).channelMap, channelName);
if ~isempty(index)
    error('A channel with the name ''%s'' already exists.', channelName);
end
%TO073008A
if ismember(channelName, daqjobGlobalStructure(this.ptr).pseudoChannelMap)
    error('A pseudochannel with the name ''%s'' already exists.', channelName);
end
index = size(daqjobGlobalStructure(this.ptr).channelMap, 1) + 1;

if ~ischar(lineID)
    if length(lineID) > 1
        lineID = [num2str(lineID(1)) ':' num2str(lineID(end))];
    else
        lineID = num2str(lineID);
    end
end

task = getOrCreateTask(this, subsystemName);
daqjobGlobalStructure(this.ptr).channelMap{index, 1} = channelName;
daqjobGlobalStructure(this.ptr).channelMap{index, 2} = subsystemName;
daqjobGlobalStructure(this.ptr).channelMap{index, 3} = lineID;
daqjobGlobalStructure(this.ptr).channelMap{index, 4} = 'digitalOut';
nimex_addDigitalOutput(task, [subsystemName lineID]);
nimex_setChannelProperty(task, [subsystemName lineID], 'mnemonicName', channelName, 'enable', 0);%TO050508F

return;
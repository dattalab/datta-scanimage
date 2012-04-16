% @daqjob/getSubsystemNameByTask - Look up the subsystem corresponding to a given task
%
%% SYNTAX
%  subsystemName = getSubsystemNameByTask(dj, task)
%   dj - A @daqjob instance.
%   subsystemName - The name of the NI subsystem (or cell array of subsytems)
%                   ie. '/dev1/ao' or '/dev2/ai' or '/dev3/port0/line'
%   task - The task (or task array) whose subsystemName to query
%
%% NOTES
%   This function has been made because, at present, the @nimex 'subsystem' property belongs to channels, rather than tasks. 
%   The latter would make more sense, as tasks/subsystems have a one-to-one correspondence.
%   This function is not particularly efficient, as it must loop through the @daqjob taskMap and rely on the @nimex eq() method
%
%
%% CHANGES
%
%% CREDITS 
%  Created 8/20/08 by Vijay Iyer
%% **********************************************************

function subsystemName = getTaskBySubsystemName(this, task)
global daqjobGlobalStructure;

index = [];
for i=1:size(daqjobGlobalStructure(this.ptr).taskMap,1)
   if daqjobGlobalStructure(this.ptr).taskMap{i,2} == task
       index = i;
       break;
   end
end    
    
if isempty(index)
    error('Failed to find supplied task.');
else
    subsystemName = daqjobGlobalStructure(this.ptr).taskMap{index,1};
end

return;
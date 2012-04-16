% @daqjob/private/getOrCreateTask - Instantiates/retrieves a nimex task. Calls `updateTaskProperties` for the task.
% 
% SYNTAX
%  task - getOrCreateTask(job, subSystemName)
%   job - @daqjob instance.
%   subsystemName - The NIDAQmx subsystem for which a nimex task is required.
%                   Example: '/dev1/ai0'
%   task - The @nimex task that corresponds to the specified subsystem.
%  
% NOTES
%
% CHANGES
%  TO101507C - Created the triggerDestination field. -- Tim O'Connor 10/15/07
%  TO033008D - Created the clockDestination field. -- Tim O'Connor 3/30/08
%  TO033008E - Refactored `updateTaskProperties` out of `getOrCreateTask`. -- Tim O'Connor 3/30/08
%  TO073008C - Only update task properties on task creation. -- Tim O'Connor 7/30/08
%  
% Created
%  Timothy O'Connor 7/30/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function task = getOrCreateTask(this, subsystemName)
global daqjobGlobalStructure;

index = indexOf(daqjobGlobalStructure(this.ptr).taskMap, subsystemName);
if isempty(index)
    task = nimex;
    index = size(daqjobGlobalStructure(this.ptr).taskMap, 1) + 1;
    daqjobGlobalStructure(this.ptr).taskMap{index, 1} = subsystemName;
    daqjobGlobalStructure(this.ptr).taskMap{index, 2} = task;
    nimex_bindDoneCallback(task, {@doneCallback, this, task}, ['daqjob_' daqjobGlobalStructure(this.ptr).name '_doneListener'], 0);
    updateTaskProperties(this, subsystemName, task);%TO073008C
else
    task = daqjobGlobalStructure(this.ptr).taskMap{index, 2};
end

return;
% @daqjob/setTriggerDestination - Set the "relative" destination of the "global" trigger, for all tasks in this job.
% 
% SYNTAX
%  setTriggerDestination(job, triggerDestination)
%   job - A @dajob instance.
%   triggerDestination - The NIDAQmx terminal on which to accept the trigger.
%                        This value is relative to the device.
%                        For example: 'PFI0' would map to '/dev1/PFI0' on dev1.
%
% NOTES
%
% CHANGES
%  TO083007C - Forcibly update the underlying task property immediately. -- Tim O'Connor 7/30/08
%  
% Created
%  Timothy O'Connor 10/15/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function setTriggerDestination(this, triggerDestination)
global daqjobGlobalStructure;

daqjobGlobalStructure(this.ptr).triggerDestination = triggerDestination;

%TO083007C
for i = 1 : size(daqjobGlobalStructure(this.ptr).taskMap, 1)
    updateTaskProperties(this, daqjobGlobalStructure(this.ptr).taskMap{i, 1}, daqjobGlobalStructure(this.ptr).taskMap{i, 2}, 'triggerSource');
end

return;
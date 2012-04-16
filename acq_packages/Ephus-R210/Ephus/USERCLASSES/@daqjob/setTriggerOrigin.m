% @daqjob/setTriggerOrigin - Set the source of the "global" trigger, for all tasks in this job.
% 
% SYNTAX
%  setTriggerOrigin(job, triggerOrigin)
%   job - A @dajob instance.
%   triggerOrigin - The NIDAQmx terminal on which to send the trigger.
%                   For example: '/dev1/port0/line0'
%  
% NOTES
%
% CHANGES
%  
% Created
%  Timothy O'Connor 7/30/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function setTriggerOrigin(this, triggerOrigin)
global daqjobGlobalStructure;

daqjobGlobalStructure(this.ptr).triggerOrigin = triggerOrigin;

return;
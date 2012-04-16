% @daqjob/getTriggerOrigin - Get the source of the "global" trigger, for all tasks in this job.
% 
% SYNTAX
%  triggerOrigin = getTriggerOrigin(job)
%   job - A @dajob instance.
%   triggerOrigin - The NIDAQmx terminal on which to send the trigger.
%                   For example: '/dev1/port0/line0'
%  
% NOTES
%
% CHANGES
%  
% Created
%  Timothy O'Connor 3/31/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function triggerOrigin = getTriggerOrigin(this, triggerOrigin)
global daqjobGlobalStructure;

triggerOrigin = daqjobGlobalStructure(this.ptr).triggerOrigin;

return;
% @daqjob/getTriggerDestination - Get the "relative" destination of the "global" trigger, for all tasks in this job.
% 
% SYNTAX
%  triggerDestination = getTriggerDestination(job)
%   job - A @dajob instance.
%   triggerDestination - The NIDAQmx terminal on which to accept the trigger.
%                        This value is relative to the device.
%                        For example: 'PFI0' would map to '/dev1/PFI0' on dev1.
%
% NOTES
%  This file appeared to be missing as of 6/2/08, or never existed. Since SVN sucks, we're not sure.
%
% CHANGES
%  
% Created
%  Timothy O'Connor 6/2/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function triggerDestination = getTriggerDestination(this)
global daqjobGlobalStructure;

triggerDestination = daqjobGlobalStructure(this.ptr).triggerDestination;

return;
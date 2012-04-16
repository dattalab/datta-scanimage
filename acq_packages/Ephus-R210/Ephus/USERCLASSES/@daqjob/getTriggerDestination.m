% @daqjob/getTriggerDestination - Get the "relative" destination of the "global" trigger, for all tasks in this job.
% 
%% SYNTAX
%  triggerDestination = getTriggerDestination(job)
%   job - A @dajob instance.
%   triggerDestination - The NIDAQmx terminal on which to accept the trigger.
%                        This value is relative to the device.
%                        For example: 'PFI0' would map to '/dev1/PFI0' on dev1.
%
%% NOTES
%  This file appeared to be missing as of 6/2/08, or never existed. Since SVN sucks, we're not sure.
%
%% CHANGES
%   VI102208A: Deal with new possibility that triggerDestination is a cell array -- Vijay Iyer 10/22/08
%  
%% CREDITS
%  Timothy O'Connor 6/2/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function triggerDestination = getTriggerDestination(this)
global daqjobGlobalStructure;

triggerDestinations = daqjobGlobalStructure(this.ptr).triggerDestinations; %VI102208A: use triggerDestinations vs. triggerDestination

%%%VI102208A%%%%%%%%%
if isempty(triggerDestinations)
    triggerDestination = '';
else
    idx = daqjobGlobalStructure(this.ptr).triggerDestinationIndex;
    triggerDestination = triggerDestinations{idx};
end
%%%%%%%%%%%%%%%%%%%%%

return;
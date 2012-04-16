% @daqjob/setTriggerDestinations - Sets a list of valid triggerDestinations for this job 
% 
%% SYNTAX
%  triggerDestinations = setTriggerDestinations(job)
%   job - A @dajob instance.
%   triggerDestinations - A cell array of strings specifying valid triggerDestinations
%                        Each triggerDestination represents a NIDAQmx terminal on which to accept the trigger. This value is relative to the device.
%                        For example: 'PFI0' would map to '/dev1/PFI0' on dev1.
%
%% NOTES
%   See @daqjob/setTriggerDestinations
%   
%   If the current triggerDestination is not among the listed triggerDestinations, then the current triggerDestination will be updated to be the first in the specified list. 
%   
%% CHANGES
%  
%% CREDITS
%  Created by Vijay Iyer, 10/23/08
%  
%% ************************************************************************

function triggerDestinations = getTriggerDestinations(this)
global daqjobGlobalStructure;

triggerDestinations = daqjobGlobalStructure(this.ptr).triggerDestinations;

return;
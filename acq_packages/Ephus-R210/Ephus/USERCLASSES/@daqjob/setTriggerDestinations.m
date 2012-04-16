% @daqjob/setTriggerDestinations - Sets a list of valid triggerDestinations for this job 
% 
%% SYNTAX
%  setTriggerDestination(job, triggerDestinations)
%   job - A @dajob instance.
%   triggerDestination - A cell array of strings specifying valid triggerDestinations
%                        Each triggerDestination represents a NIDAQmx terminal on which to accept the trigger. This value is relative to the device.
%                        For example: 'PFI0' would map to '/dev1/PFI0' on dev1.
%
%% NOTES
%   See @daqjob/setTriggerDestination
%   
%   If the current triggerDestination is not among the listed triggerDestinations, then the current triggerDestination will be updated to be the first in the specified list. 
%   
%% CHANGES
%  
%% CREDITS
%  Created by Vijay Iyer, 10/23/08
%  
%% ************************************************************************

function setTriggerDestinations(this, triggerDestinations)
global daqjobGlobalStructure;

triggerDest = getTriggerDestination(this);

if ~ischar(triggerDestinations) && (~iscellstr(triggerDestinations) || ~isvector(triggerDestinations))
    error(['Trigger destination must be a string or a cell array of string, specifying name(s) of NI terminal on which the trigger for this ' mfilename('class') ' will be received.']);
end

if ischar(triggerDestinations)
    triggerDestinations = {triggerDestinations};
end

daqjobGlobalStructure(this.ptr).triggerDestinations = triggerDestinations; 

[ismem, idx] = ismember(triggerDest,triggerDestinations);
if ~ismem
    daqjobGlobalStructure(this.ptr).triggerDestinationIndex = 1;
else
    daqjobGlobalStructure(this.ptr).triggerDestinationIndex = idx;
end  

updateSharedTaskProperties(this, {'triggerDestinations' 'triggerDestinationIndex'});

return;
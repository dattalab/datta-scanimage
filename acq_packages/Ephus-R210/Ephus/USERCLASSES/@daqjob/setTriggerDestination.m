% @daqjob/setTriggerDestination - Set the "relative" destination of the "global" trigger, for all tasks in this job.
% 
%% SYNTAX
%  setTriggerDestination(job, triggerDestination)
%   job - A @dajob instance.
%   triggerDestination - The NIDAQmx terminal on which to accept the trigger. This value is relative to the device.
%                        For example: 'PFI0' would map to '/dev1/PFI0' on dev1.
%
%% NOTES
%   The specified triggerDestination value is appended to the daqJob's triggerDestinations cell array property, if it's not there already.
%   
%   
%% CHANGES
%  TO073008C - Forcibly update the underlying task property immediately. -- Tim O'Connor 7/30/08
%  VI082008A - Use updateSharedTaskProperties -- Vijay Iyer 8/20/08
%  VI102308A - Deal with new capability for multiple triggerDestination choices -- Vijay Iyer 10/23/08
%  TO021510C - Make VI102308A actually work by updating the 'triggerDestination' property. This whole change was way too complicated, it made a big mess. And, hooray for testing! ...or not. -- Tim O'Connor 2/15/10
%  
%% CREDITS
%  Timothy O'Connor 10/15/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
%% ************************************************************************

function setTriggerDestination(this, triggerDestination)
global daqjobGlobalStructure;

%daqjobGlobalStructure(this.ptr).triggerDestination = triggerDestination;

%%%VI102308A%%%%%%%%%%%%%%%%%
if ~ischar(triggerDestination)
    error(['Trigger destination must be a string, specifying the name of an NI terminal on which the trigger for this ' mfilename('class') ' will be received.']);
end

triggerDestinations = daqjobGlobalStructure(this.ptr).triggerDestinations;
[ismem, idx] = ismember(lower(triggerDestination), lower(triggerDestinations));
if ~ismem
    daqjobGlobalStructure(this.ptr).triggerDestinations = {triggerDestinations{:} triggerDestination};
    daqjobGlobalStructure(this.ptr).triggerDestinationIndex = 1;
else
    daqjobGlobalStructure(this.ptr).triggerDestinationIndex = idx;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

%TO073008C
% for i = 1 : size(daqjobGlobalStructure(this.ptr).taskMap, 1)
%     updateTaskProperties(this, daqjobGlobalStructure(this.ptr).taskMap{i, 1}, daqjobGlobalStructure(this.ptr).taskMap{i, 2}, 'triggerSource');
% end

updateSharedTaskProperties(this, {'triggerDestination', 'triggerDestinations' 'triggerDestinationIndex'}); %VI102308A %TO021510C

return;
% shared_initializeExternalTrigger - Initialize the list of external trigger choices for those available 
%
%% SYNTAX
%  shared_initializeExternalTrigger(hObject)
%
%% NOTES
%   This function is sharable by all programs which employ the 'acquisition' @daqjob.
%   It is assumed/required that all such programs have a GUI popup-menu control named 'pmExtTriggerSource' tied to a property named 'externalTriggerSource'
%   See VI102308A.
%
%% CHANGES
%
%% CREDITS
% Created 10/23/08 by Vijay Iyer
function shared_initializeExternalTrigger(hObject)

trigDests = getTriggerDestinations(daqjob('acquisition'));
setLocalGh(progmanager, hObject, 'pmExtTriggerSource', 'String', trigDests); 
if isempty(trigDests)
    setLocalGh(progmanager, hObject, 'pmExtTriggerSource', 'Value', 1); 
else 
    setLocal(progmanager, hObject, 'externalTriggerSource', getTriggerDestination(daqjob('acquisition')));
end

bindEventListener(daqjob('acquisition'), 'sharedPropertyUpdate', {@shared_daqjobPropUpdateListener, hObject}, [getProgramName(progmanager,hObject) ': shared_daqjobPropUpdate']);

return;
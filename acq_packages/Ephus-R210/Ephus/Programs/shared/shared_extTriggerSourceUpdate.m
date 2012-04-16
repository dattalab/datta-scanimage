% shared_extTriggerSourceUpdate - Shared callback for changes to external trigger source control
%
%% SYNTAX
%  shared_extTriggerSourceUpdate(hObject)
%
%% NOTES
%   This callback is used by programs which employ shared_initializeExtTrigger(). 
%   
%% CHANGES
%
%% CREDITS
% Created 10/23/08 by Vijay Iyer

function shared_extTriggerSourceUpdate(hObject)

setTriggerDestination(daqjob('acquisition'),getLocal(progmanager,hObject,'externalTriggerSource'));

return;
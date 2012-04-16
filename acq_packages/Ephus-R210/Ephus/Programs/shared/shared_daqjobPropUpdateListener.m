% shared_daqjobPropUpdateListener - Handler for event where @daqjob's shared task properties have been updated 
%
%% SYNTAX
%  shared_daqjobPropUpdateListener(hObject)
%
%% NOTES
%   This listener is used by programs which employ shared_initializeExtTrigger(). 
%   
%% CHANGES
%
%% CREDITS
% Created 10/23/08 by Vijay Iyer

function shared_daqjobPropUpdateListener(hObject)

%One might hypothetically test for the availability of this property, if this function were truly a handler for all/any of the shared task properties, rather than just the triggerDestination
setLocal(progmanager, hObject, 'externalTriggerSource', getTriggerDestination(daqjob('acquisition')));

return;
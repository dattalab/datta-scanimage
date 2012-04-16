% mapper_stopStimulationPoint - Recieves the signal that all components have completed an acquisition.
%
% SYNTAX
%  mapper_stopStimulationPoint(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO042806E: Only increment flash number when autosave is on. -- Tim O'Connor 4/28/06
%
% Created 2/8/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function mapper_stopStimulationPoint(hObject)

% mapper_restoreConfigs(hObject);

[flashing mapping mousing flashNumber] = getLocalBatch(progmanager, hObject, 'flashing', 'mousing', 'mapping', 'flashNumber');
%CHANGES
if xsg_getAutosave
    incrementBy = 1;
else
    incrementBy = 0;
end

if flashing
    mapper_restoreConfigs(hObject);
    setLocalBatch(progmanager, hObject, 'flashNumber', flashNumber + incrementBy, 'flashing', 0);
end

if mapping
end

if mousing
    setLocal(progmanager, hObject, 'flashNumber', flashNumber + incrementBy);
end

setLocalBatch(progmanager, hObject, 'flashing', 0, 'mousing', 0, 'mapping', 0);

return;
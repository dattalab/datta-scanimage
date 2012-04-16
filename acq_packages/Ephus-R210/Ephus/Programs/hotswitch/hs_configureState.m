% hs_configureState - Configure the specified hot state.
%
% SYNTAX
%  hs_configureState(hObject)
%  hs_configureState(hObject, stateNumber)
%    hObject - The program handle.
%    stateNumber - The number of the state to configure.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO031610A - Make sure the gui is visible. -- Tim O'Connor 3/16/10
%
% Created 9/7/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function hs_configureState(hObject, varargin)

hs_updateRunningProgramsList(hObject);%Update the list, just in case new programs have become available.

if ~isempty(varargin)
    setLocal(progmanager, hObject, 'stateNumber', varargin{1});
end

toggleGuiVisibility(progmanager, hObject, 'hs_config', 'On');%TO031610A

[stateNumber] = getLocalBatch(progmanager, hObject, 'stateNumber');
states = getMain(progmanager, hObject, 'states');

setLocalBatch(progmanager, hObject, 'name', states(stateNumber).name, 'directory', states(stateNumber).directory);
if exist(states(stateNumber).directory, 'dir') == 7
    setLocalGh(progmanager, hObject, 'directory', 'ForegroundColor', [0 0 0]);
    setDefaultCacheValue(progmanager, 'hotswitchDirectory', states(stateNumber).directory);
else
    setLocalGh(progmanager, hObject, 'directory', 'ForegroundColor', [1 .2 .2]);
end

return;
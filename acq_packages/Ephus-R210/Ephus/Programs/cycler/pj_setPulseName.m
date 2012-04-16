% pj_setPulseName - Select the pulse for the current channel.
%
% SYNTAX
%  pj_setPulseName(hObject)
%  pj_setPulseName(hObject, pulseName)
%    hObject - The program handle.
%    pulseName - The new pulse set.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/29/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_setPulseName(hObject, varargin)

[pulseName, pulsePath, positions, currentPosition, currentChannel] = getLocalBatch(progmanager, hObject, ...
    'pulseName', 'pulsePath', 'positions', 'currentPosition', 'currentChannel');

if ~isempty(varargin)
    pulseName = varargin{1};
    setLocal(progmanager, hObject, 'pulseName', pulseName);
end

index = pj_positionArray2positionIndex(positions{currentPosition}, currentChannel);
pos = positions{currentPosition};
pos(index).pulseName = pulseName;
positions{currentPosition} = pos;

setLocalBatch(progmanager, hObject, 'positions', positions);
pj_saveCycle(hObject);

return;
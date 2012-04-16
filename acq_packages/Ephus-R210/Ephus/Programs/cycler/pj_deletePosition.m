% pj_deletePosition - Delete a position structure from the list of positions.
%
% SYNTAX
%  pj_deletePosition(hObject)
%  pj_deletePosition(hObject, positionNumber)
%    hObject - The program handle.
%    positionNumber - The position to delete.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/29/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_deletePosition(hObject, varargin)

[positions, currentPosition] = getLocalBatch(progmanager, hObject, 'positions', 'currentPosition');
if ~isempty(varargin)
    currentPosition = varargin{1};
end
if length(positions) == 1
    positions = {};
else
    positions = cat(2, positions(1:currentPosition-1), positions(currentPosition+1:length(positions)));
end

setLocalBatch(progmanager, hObject, 'positions', positions, 'currentPosition', length(positions), 'totalPositionsLabel', length(positions));

pj_saveCycle(hObject);
pj_currentPosition(hObject);

return;
% pj_increment - Increment the position counter (reset to 1 if it's at the end).
%
% SYNTAX
%  pj_increment(hObject)
%    hObject - The program handle.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/30/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_increment(hObject)

[currentPosition positions] = getLocalBatch(progmanager, hObject, 'currentPosition', 'positions');
if isempty(positions)
    currentPosition = 0;
else
    currentPosition = currentPosition + 1;
    if currentPosition > length(positions)
        currentPosition = 1;
    end
end

setLocal(progmanager, hObject, 'currentPosition', currentPosition);
pj_currentPosition(hObject);

return;
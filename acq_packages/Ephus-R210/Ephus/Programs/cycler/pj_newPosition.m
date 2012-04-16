% pj_newPosition - Create a new position structure, add it to the list of positions, select it.
%
% SYNTAX
%  pj_newPosition(hObject)
%    hObject - The program handle.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO090506B - Default pulseSetName and pulseName to match the preceding position (if one exists). -- Tim O'Connor 9/5/06
%
% Created 8/28/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_newPosition(hObject)

[positions] = getLocalBatch(progmanager, hObject, 'positions');
channelNames = get(getLocalGh(progmanager, hObject, 'currentChannel'), 'String');
if strcmpi(class(channelNames), 'char')
    channelNames = {channelNames};
end

for i = 1 : length(channelNames)
    pos(i).channelIndex = i;
    if ~isempty(positions)
        posDefault = positions{end};
        pos(i).pulseName = posDefault(i).pulseName;
        pos(i).pulseSetName = posDefault(i).pulseSetName;
    else
        pos(i).pulseName = '';
        pos(i).pulseSetName = '';
    end
    pos(i).channelName = channelNames{i};
end

if isempty(positions)
    positions = {pos};
else
    positions{length(positions) + 1} = pos;
end
setLocalBatch(progmanager, hObject, 'positions', positions, 'currentPosition', length(positions), 'totalPositionsLabel', length(positions));
pj_saveCycle(hObject);
pj_currentPosition(hObject);

return;
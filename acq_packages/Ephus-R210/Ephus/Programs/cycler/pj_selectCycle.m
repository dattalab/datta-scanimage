% pj_new - Create a new pulseJacker cycle.
%
% SYNTAX
%  pj_selectCycle(hObject)
%    hObject - The program handle.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO040710D - Make sure that the positions' channel lists match the current channel list. -- Tim O'Connor 4/7/10
%
% Created 8/25/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_selectCycle(hObject)

[positions, currentPosition, cycleName, pulsePath] = getLocalBatch(progmanager, hObject, 'positions', 'currentPosition', 'cycleName', 'pulsePath');

if isempty(cycleName)
    setLocalGhBatch(progmanager, hObject, {'addPosition'}, 'Enable', 'Off');
else
    setLocalGhBatch(progmanager, hObject, {'addPosition'}, 'Enable', 'On');
end

if isempty(positions)
    setLocalBatch(progmanager, hObject, 'currentPosition', 0, 'pulseSetName', '', 'pulseName', '', 'totalPositionsLabel', length(positions));
    setLocalGhBatch(progmanager, hObject, {'currentPosition', 'positionIncrementSlider', 'positionDecrementSlider', ...
            'pulseSetName', 'pulseName', 'currentChannel', 'deletePosition'}, 'Enable', 'Off');
else
    setLocalBatch(progmanager, hObject, 'currentPosition', max(1, currentPosition), 'pulseSetName', '', 'pulseName', '', 'totalPositionsLabel', length(positions));
    setLocalGh(progmanager, hObject, 'pulseSetName', 'String', {''});
    setLocalGh(progmanager, hObject, 'pulseName', 'String', {''});
    setLocalGhBatch(progmanager, hObject, {'currentPosition', 'positionIncrementSlider', 'positionDecrementSlider', ...
            'pulseSetName', 'pulseName', 'currentChannel', 'deletePosition'}, 'Enable', 'Off');
    pj_setPulsePath(hObject, pulsePath);

    %TO040710D - Make sure that the positions' channel lists match the current channel list. -- Tim O'Connor 4/7/10
    channelNames = get(getLocalGh(progmanager, hObject, 'currentChannel'), 'String');
    invalidChannels = {};
    for i = 1 : length(positions)
        pos = positions{i};
        for j = 1 : length(pos)
            if ~ismember(pos(j).channelName, channelNames)
                invalidChannels{length(invalidChannels) + 1} = pos(j).channelName;
                pos(j).pulseName = '';
                pos(j).pulseSetName = '';
            end
        end
        positions{i} = pos;
    end
    invalidChannels = unique(invalidChannels);
    if ~isempty(invalidChannels)
        setLocal(progmanager, hObject, 'positions', positions);%Overwrite with the scrubbed cycle.
        fprintf(1, '%s - pulseJacker - Warning: The loaded cycle contained data for channels that do not exist: ', datestr(now));
        for i = 1 : length(invalidChannels)
            if i < length(invalidChannels)
                fprintf(1, '''%s'', ', invalidChannels{i});
            else
                fprintf(1, '''%s''', invalidChannels{i});
            end
        end
        fprintf(1, '\n\t\tNote: The currently loaded cycle (''%s'') has been "scrubbed" to work with the current configuration.\n', cycleName);
    end
end
setLocalGhBatch(progmanager, hObject, {'cycleName'}, 'Enable', 'On');

pj_currentPosition(hObject);

return;
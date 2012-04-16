% pj_precacheDefinitions - Precache the pulses for the acquisition (required fixed trace lengths across acquisitions).
%
% SYNTAX
%  pj_precacheDefinitions(hObject)
%    hObject - The program handle.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO090506E - Gracefully handle null pulses in cycles. -- Tim O'Connor 9/5/06
%
% Created 8/30/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_precacheDefinitions(hObject)

[positions, hObject, pulseDataMap] = getLocalBatch(progmanager, hObject, 'positions', 'hObject', 'pulseDataMap');
channelNames = get(getLocalGh(progmanager, hObject, 'currentChannel'), 'String');

hObject = getParent(hObject, 'figure');
wb = waitbar(0, 'Precaching pulses...');
set(wb, 'Units', get(hObject, 'Units'));
windowPosition = get(hObject, 'Position');
wbPos = get(wb, 'Position');
wbPos(1:2) = windowPosition(1:2) + 0.5 * [0 windowPosition(4)];
set(wb, 'Position', wbPos);

precachedDefinitions = cell(length(positions), length(channelNames));
pulseDataMap = cell(length(positions), length(channelNames));
totalOperations = numel(precachedDefinitions);
for j = 1 : length(positions)
    for i = 1 : length(channelNames)
        pos = pj_positionArray2positionStruct(positions{j}, channelNames{i});
        
        %  TO090506E - Gracefully handle null pulses in cycles. -- Tim O'Connor 9/5/06
        if ~isempty(pos.pulseSetName) && ~isempty(pos.pulseName)
            %Load data.
            precachedDefinitions{j, pos.channelIndex} = pj_loadSignal(hObject, pos.pulseSetName, pos.pulseName);
            try
                %Update the header information.
                pulseDataMap{i, j} = toStruct(precachedDefinitions{j, pos.channelIndex});
            catch
                warning('pj_precacheDefinitions: Failed to properly cache pulse information for the header: %s', lasterr);
            end
        else
            pulseDataMap{i, j} = [];
        end
        
        waitbar(i * j / totalOperations, wb);
    end
end

setLocalBatch(progmanager, hObject, 'precachedDefinitions', precachedDefinitions, 'pulseDataMap', pulseDataMap);
delete(wb);

return;
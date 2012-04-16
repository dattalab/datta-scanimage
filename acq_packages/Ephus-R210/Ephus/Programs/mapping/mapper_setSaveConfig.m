% mapper_setSaveConfig - Modify the XSG settings for the current mapper-based acquisition.
%
% SYNTAX
%  mapper_setSaveConfig(hObject, type)
%   type - 'flash' or 'map'.
%
% USAGE
%
% NOTES
%  See TO020206B (creation of this function).
%
% CHANGES
%  TO042106C - Use xsg_getPath instead of directly accessing the value. Uncheck the path augmentations. -- Tim O'Connor 4/21/06
%  TO042806E - Make sure not to append initials to the directory (had been forgotten originally). -- Tim O'Connor 4/28/06
%
% Created 2/2/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_setSaveConfig(hObject, type)

[mapNumber flashNumber] = getLocalBatch(progmanager, hObject, 'mapNumber', 'flashNumber');

xsg = xsg_getHandle;
[initials experimentNumber] = getLocalBatch(progmanager, xsg, 'initials', 'experimentNumber');

directory = xsg_getPath;

switch lower(type)
    case 'flash'
        if exist(fullfile(directory,  'flashes')) ~= 7
            mkdir(directory, 'flashes');
        end
        directory = fullfile(directory, 'flashes');
        setLocalBatch(progmanager, xsg, 'directory', directory, 'acquisitionNumber', num2str(flashNumber), ...
            'addExperimentNumberToPath', 0, 'addSetIDToPath', 0, 'addInitialsToPath', 0);%TO042106C, TO042806E
    case 'map'
        mapNumStr = num2str(mapNumber);
        if length(mapNumStr) == 1
            mapNumStr = ['0' mapNumStr];
        end
        if exist(fullfile(directory, ['map' mapNumStr])) ~= 7
            mkdir(directory, ['map' mapNumStr]);
        end
        directory = fullfile(directory, ['map' mapNumStr]);
%         directory = fullfile(directory, [initials experimentNumber], 'traces', ['map' num2str(mapNumber)]);
        setLocalBatch(progmanager, xsg, 'directory', directory, 'acquisitionNumber', '0001', ...
            'addExperimentNumberToPath', 0, 'addSetIDToPath', 0, 'addInitialsToPath', 0);%TO042106C, TO042806E
    otherwise
        error('Invalid mapper action: %s', type);
end

return;
% switch lower(type)
%     case 'flash'
%         directory = fullfile(directory, [initials experimentNumber], 'flashes');
%         if exist(fullfile(directory, [initials experimentNumber])) ~= 7
%             mkdir(directory, [initials experimentNumber]);
%         end
%         if exist(fullfile(directory, [initials experimentNumber], 'flashes')) ~= 7
%             mkdir(fullfile(directory, [initials experimentNumber]), 'flashes');
%         end
%         setLocalBatch(progmanager, xsg, 'directory', directory, 'acquisitionNumber', num2str(flashNumber));
%     case 'map'
%         directory = fullfile(directory, [initials experimentNumber], 'traces', ['map' num2str(mapNumber)]);
%         if exist(fullfile(directory, [initials experimentNumber])) ~= 7
%             mkdir(directory, [initials experimentNumber]);
%         end
%         if exist(fullfile(directory, [initials experimentNumber], 'traces')) ~= 7
%             mkdir(fullfile(directory, [initials experimentNumber]), 'traces');
%         end
%         if exist(directory) ~= 7
%             mkdir(fullfile(directory, [initials experimentNumber], 'traces'), ['map' num2str(mapNumber)]);
%         end
% %         directory = fullfile(directory, [initials experimentNumber], 'traces', ['map' num2str(mapNumber)]);
%         setLocalBatch(progmanager, xsg, 'directory', directory, 'acquisitionNumber', '0001');
%     otherwise
%         error('Invalid mapper action: %s', type);
% end
% 
% return;
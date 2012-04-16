% pj_updateProgramPulses - Sets hijacked programs to use the currently selected pulses, increments the position.
%
% SYNTAX
%  pj_updateProgramPulses(hObject)
%    hObject - The program handle.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO091106G - Only update programs that are set to external trigger. -- Tim O'Connor 9/11/06
%  TO101707D - Port to nimex. -- Tim O'Connor 10/17/07D
%
% Created 9/5/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_updateProgramPulses(hObject)
error('Deprecated - See TO101707D - Port to nimex.\n');%TO101707D
[positions, currentPosition, mappedProgramHandles] = getLocalBatch(progmanager, hObject, 'positions', 'currentPosition', 'mappedProgramHandles');
channelNames = getLocalGh(progmanager, hObject, 'currentChannel', 'String');

% fprintf(1, 'pj_updateProgramPulses: Loading data for position %s...\n', num2str(currentPosition));
for i = 1 : length(channelNames)
    %TO091106G
    if getLocal(progmanager, mappedProgramHandles(i), 'externalTrigger')
        pos = pj_positionArray2positionStruct(positions{currentPosition}, channelNames{i});
        if ~isempty(pos)
            idx = [];
%             [pulseSetNameArray, pulseNameArray] = getLocalBatch(progmanager, mappedProgramHandles(i), 'pulseSetNameArray', 'pulseNameArray');
            if startsWith(channelNames{i}, 'ephys')
                channelList = getLocalGh(progmanager, mappedProgramHandles(i), 'amplifierList', 'String');
            elseif startsWith(channelNames{i}, 'stim')
                channelList = getLocalGh(progmanager, mappedProgramHandles(i), 'channelList', 'String');
            else
                warning('Unidentified pulse hijacked program: %s', channelNames{i});
                continue;
            end
            delimiter = find(channelNames{i} == ':');
            for j = 1 : length(channelList)
                if startsWith(channelNames{i}(delimiter+1:end), channelList{j})
                    idx = j;
                    break;
                end
            end
            if ~isempty(idx)
%                 pulseSetNameArray{idx} = pos.pulseSetName;
%                 pulseNameArray{idx} = pos.pulseName;
%                 setLocalBatch(progmanager, mappedProgramHandles(i), 'pulseSetNameArray', pulseSetNameArray, 'pulseNameArray', pulseNameArray);
                if startsWith(channelNames{i}, 'ephys')
                    ephys_selectAmplifier(mappedProgramHandles(i), idx);
                elseif startsWith(channelNames{i}, 'stim')
                    stim_selectChannel(mappedProgramHandles(i), idx);
                else
                    warning('Unidentified pulse hijacked program: %s', channelNames{i});
                end
                fObject = getFunctionHandle(progmanager, mappedProgramHandles(i));
                setLocal(progmanager, mappedProgramHandles(i), 'pulseSetName', pos.pulseSetName);
                feval(fObject, 'pulseSetName_Callback', mappedProgramHandles(i), [], mappedProgramHandles);
                if ~isempty(pos.pulseSetName)
                    setLocal(progmanager, mappedProgramHandles(i), 'pulseName', pos.pulseName);
                    feval(fObject, 'pulseName_Callback', mappedProgramHandles(i), [], mappedProgramHandles(i));
                end
% fprintf(1, 'pj_updateProgramPulses: Set ''%s'' to ''%s:%s''\n', channelNames{i}, pos.pulseSetName, pos.pulseName);
            end
        else
            warning('Failed to locate channel in program - %s', channelNames{i});
        end
    end
end

return;
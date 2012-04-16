% stim_updateOutputSignals - Make sure all output signals are up to date.
%
% SYNTAX
%  stim_updateOutputSignals(hObject)
%
% USAGE
%
% NOTES
%  This is a copy & paste job from ephys_updateOutputSignals.m, with some editting where necessary.
%
% CHANGES
%  TO092305B: Switched to using pulseSetNameArray/pulseNameArray instead of pulseSetName/pulseName. - Tim O'Connor 9/23/05
%  TO092605J: Properly handle the case where no pulse and/or pulse set is selected for a given amplifier. -- Tim O'Connor 9/26/05
%  TO050506A: Insert a structure with the pulse parameters, for now. Change this to something more sophisticated later. -- Tim O'Connor 5/5/06
%  TO062806C: Implement "turbo" cycles, allow for multiple pulses to be chained. -- Tim O'Connor 6/28/06
%  TO062806E: Delete pulse children automatically. Delete pulses when loading new ones from disk. -- Tim O'Connor 6/28/06
%  TO062906D: Use parentheses to ensure logical operator precedence. -- Tim O'Connor 6/29/06
%  TO070306A: Unbinding signals clears the preprocessor, so just replace the signal with empty. -- Tim O'Connor 7/3/06
%
% Created 11/22/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function stim_updateOutputSignals(hObject)

[directory, pulseTimestamps, sampleRate, channels, ...
        pulseSetNameArray, pulseNameArray, aom, pulseSelectionHasChanged, pulseSetCacheList, pulseNameCacheList, ...
        traceLengthArray, chainedPulses, status] = ...
    getLocalBatch(progmanager, hObject, 'pulseSetDir', 'pulseTimestamps', 'sampleRate', 'channels', ...
    'pulseSetNameArray', 'pulseNameArray', 'aomux', 'pulseSelectionHasChanged', 'pulseSetCacheList', 'pulseNameCacheList', ...
    'traceLengthArray', 'chainedPulses', 'status');%TO062806C

dm = getDaqmanager;

%TO062806C
if chainedPulses
    setLocal(progmanager, hObject, 'status', 'Chaining pulses...');
else
    pulseSetCacheList = {pulseSetNameArray};
    pulseNameCacheList = {pulseNameArray};
end

%TO062806C
for j = 1 : length(pulseSetCacheList)
    pulseSetNameArray = pulseSetCacheList{j};
    pulseNameArray = pulseNameCacheList{j};

    for i = 1 : length(channels)
        updatePulse = 0;
        
        %TO062806C %TO062906D
        if (isempty(pulseSetNameArray{i}) | isempty(pulseNameArray{i})) & ~chainedPulses
            if hasChannel(dm, channels(i).channelName)
                sig = getSignal(aom, channels(i).channelName);
                if ~isempty(sig)
                    try
                        delete(sig);
                    catch
                        %Might've been deleted elsewhere, it's probably not a memory leak, I'm just being overaggressive with deletion. -- Tim O'Connor 6/28/06
                    end
                end
                bind(aom, channels(i).channelName, []);%TO070306A
                continue;
            end
        end
        
        %TO092605J - The signal has been unbound, now just leave it empty.
        if isempty(pulseSetNameArray{i}) | isempty(pulseNameArray{i})
            %No pulse selected.
            continue;
        end
        
        filename = fullfile(directory, pulseSetNameArray{i}, [pulseNameArray{i} '.signal']);
        fileinfo = dir(filename);
        filetimestamp = datevec(fileinfo.date);
        if isempty(pulseTimestamps{i})
            updatePulse = 1;
        elseif pulseSelectionHasChanged | etime(pulseTimestamps{i}, filetimestamp) ~= 0
            updatePulse = 1;
        end
        
        %TO062806C
        if updatePulse | chainedPulses
            if ~hasChannel(dm, channels(i).channelName)
                nameOutputChannel(dm, channels(i).boardID, channels(i).channelID, channels(i).channelName);
                enableChannel(dm, channels(i).channelName);
            end

%             %TO062806E
%             if ~chainedPulses
%                 if hasChannel(dm, channels(i).channelName)
%                     sig = getSignal(aom, channels(i).channelName);
%                     if ~isempty(sig)
%                         try
%                             delete(sig);
% fprintf(1, 'stim_updateOutputSignals: Deleted ''%s'' signal from AOMUX (~chainedPulsees).\n', channels(i).channelName);
%                         catch
%                             %Might've been deleted elsewhere, it's probably not a memory leak, I'm just being overaggressive with deletion. -- Tim O'Connor 6/28/06
%                         end
%                     end
%                 end
%             end
            
            data = load(filename, '-mat');
            %TO062806C
            if chainedPulses
                appendSignal(aom, channels(i).channelName, data.signal, traceLengthArray(j));%TO120205A%TO122205A
            else
                bind(aom, channels(i).channelName, data.signal);
            end

            set(data.signal, 'SampleRate', sampleRate, 'deleteChildrenAutomatically', 1);%TO062806E

            %TO062806C
            if ~chainedPulses
                pulseTimestamps{i} = filetimestamp;
                setLocal(progmanager, hObject, 'pulseTimestamps', pulseTimestamps);
            end
            
            try
                %TO050506A: Insert a structure with the pulse parameters, for now. Change this to something more sophisticated later. -- Tim O'Connor 5/5/06
                tempPulseParameters = getLocal(progmanager, hObject, 'TEMP_PulseParameters');
                %TO062806C
                if chainedPulses
                    tempPulseParameters{i + j} = toStruct(data.signal);
                else
                    tempPulseParameters{i} = toStruct(data.signal);
                end
                setLocal(progmanager, hObject, 'TEMP_PulseParameters', tempPulseParameters);
            catch
                warning('Failed to store pulse ''%s'' in header: %s', get(data.signal, 'Name'), lasterr);
            end
        end
    end
end

if chainedPulses
    setLocalBatch(progmanager, hObject, 'status', status, 'pulseSetCacheList', {}, 'pulseNameCacheList', {}, ...
        'traceLengthArray', [], 'chainedPulses', 0, 'pulseSelectionHasChanged', 1);
end

return;
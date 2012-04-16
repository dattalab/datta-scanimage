% ephys_updateOutputSignals - Make sure all output signals are up to date.
%
% SYNTAX
%  ephys_updateOutputSignals(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO092305B: Switched to using pulseSetNameArray/pulseNameArray instead of pulseSetName/pulseName. - Tim O'Connor 9/23/05
%  TO092605J: Properly handle the case where no pulse and/or pulse set is selected for a given amplifier. -- Tim O'Connor 9/26/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO120905C - Allow traces to be taken when no pulses are loaded (acquisition only). -- Tim O'Connor 12/9/05
%  TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%  TO050506A - Insert a structure with the pulse parameters, for now. Change this to something more sophisticated later. -- Tim O'Connor 5/5/06
%  TO062806C - Implement "turbo" cycles, allow for multiple pulses to be chained. -- Tim O'Connor 6/28/06
%  TO062806E - Delete pulse children automatically. Delete pulses when loading new ones from disk. -- Tim O'Connor 6/28/06
%  TO062906D - Use parentheses to ensure logical operator precedence. -- Tim O'Connor 6/29/06
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% Created 9/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephys_updateOutputSignals(hObject)

[directory, pulseTimestamps, ampIndex, sampleRate, amplifiers, ...
        pulseSetNameArray, pulseNameArray,  pulseSelectionHasChanged, pulseSetCacheList, pulseNameCacheList, ...
        traceLengthArray, chainedPulses, status] = ...
    getLocalBatch(progmanager, hObject, 'pulseSetDir', 'pulseTimestamps', 'amplifierList', 'sampleRate', 'amplifiers', ...
    'pulseSetNameArray', 'pulseNameArray', 'pulseSelectionHasChanged', 'pulseSetCacheList', 'pulseNameCacheList', ...
    'traceLengthArray', 'chainedPulses', 'status');%TO062806C

%TO120905C
if isempty(directory)
    return;
end

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
    
    for i = 1 : length(amplifiers)
        updatePulse = 0;
        
        %TO062806C %TO062906D
        if (isempty(pulseSetNameArray{i}) | isempty(pulseNameArray{i})) & ~chainedPulses
            channelName = getVComChannelName(amplifiers{i});%TO120205A
            sig = getPulse(pulseMap('acquisition'), channelName);
            if ~isempty(sig)
                try
                    delete(sig);
                catch
                    %Might've been deleted elsewhere, it's probably not a memory leak, I'm just being overaggressive with deletion. -- Tim O'Connor 6/28/06
                end
            end
            continue;
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
            
            data = load(filename, '-mat');
            %TO062806C
            if chainedPulses
                appendPulse(pulseMap('acquisition'), getVComChannelName(amplifiers{i}), data.signal);
%                 appendSignalToAOMUX(amplifiers{i}, aom, data.signal, traceLengthArray(j));%TO120205A%TO122205A
            else
                setPulse(pulseMap('acquisition'), getVComChannelName(amplifiers{i}), data.signal);
%                 bindToAOMUX(amplifiers{i}, aom, data.signal);%TO120205A%TO122205A
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
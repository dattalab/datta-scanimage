% ephys_updateOutputSignals - Make sure all output signals are up to date.
%
% SYNTAX
%  ephys_updateOutputSignals(hObject)
%
% USAGE
%
% NOTES
%  Adapted from ephys_updateOutputSignals.m See TO101707F
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
%  TO101707D - Change over to nimex.  Removed the chainedPulses concept. -- Tim O'Connor 10/17/07
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO121307E - Allow old configurations to be loaded after the startup file has changed. Fixed TO101707D by removing TO062806C completely. -- Tim O'Connor 12/13/07
%  TO121307F - Check for pulses in the pulseMap before retrieving them to clear them, to avoid a warning message. -- Tim O'Connor 12/13/07
%  VI052908A - Don't get pulseParameters variable again within the loop
%  TO060208C - Clear lasterr on try/catch. -- Tim O'Connor 6/2/08
%
% Created 9/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function shared_updateOutputSignals(hObject)
% fprintf(1, 'shared_updateOutputSignals\n');
[directory, pulseTimestamps, sampleRate, amplifiers, channels, ...
        pulseSetNameArray, pulseNameArray,  pulseSelectionHasChanged, pulseSetCacheList, pulseNameCacheList, ...
        traceLengthArray, status, pulseParameters, stimOnArray] = ...
    getLocalBatch(progmanager, hObject, 'pulseSetDir', 'pulseTimestamps', 'sampleRate', 'amplifiers', 'channels', ...
    'pulseSetNameArray', 'pulseNameArray', 'pulseSelectionHasChanged', 'pulseSetCacheList', 'pulseNameCacheList', ...
    'traceLengthArray', 'status', 'pulseParameters', 'stimOnArray');%TO062806C %TO101707D

%TO120905C
if isempty(directory)
    return;
end

if isempty(amplifiers)
    outputDeviceCount = length(channels);
    outputChannelNames = {channels(:).channelName};
else
    outputDeviceCount = length(amplifiers);
    outputChannelNames = cell(outputDeviceCount, 1);
    for i = 1 : outputDeviceCount
        outputChannelNames{i} = getVComChannelName(amplifiers{i});
    end
end

%Watch out for these, rather rampant, errors where some of the "shared" fields are screwed up across programs.
if length(pulseSelectionHasChanged) < outputDeviceCount
    pulseSelectionHasChanged = ones(outputDeviceCount, 1);
end

%pulseParameters = getLocal(progmanager, hObject, 'pulseParameters'); %VI052908A
for i = 1 : outputDeviceCount
    updatePulse = 0;

    %TO062806C %TO062906D
    if (isempty(pulseSetNameArray{i}) || isempty(pulseNameArray{i}))
        if hasPulse(pulseMap('acquisition'), outputChannelNames{i})
            sig = getPulse(pulseMap('acquisition'), outputChannelNames{i});
            if ~isempty(sig)
                try
                    delete(sig);
                catch
                    %Might've been deleted elsewhere, it's probably not a memory leak, I'm just being overaggressive with deletion. -- Tim O'Connor 6/28/06
                    lasterr('');%TO060208C - Clear lasterr on try/catch.
                end
            end
        end
        continue;
    end

    %TO092605J - The signal has been unbound, now just leave it empty.
    if isempty(pulseSetNameArray{i}) || isempty(pulseNameArray{i})
        %No pulse selected.
        continue;
    end

    filename = fullfile(directory, pulseSetNameArray{i}, [pulseNameArray{i} '.signal']);

    fileinfo = dir(filename);
    filetimestamp = datevec(fileinfo.date);
    if isempty(pulseTimestamps{i})
        updatePulse = 1;
    elseif length(pulseTimestamps) ~= outputDeviceCount
        updatePulse = 1;
    elseif pulseSelectionHasChanged(i) || etime(pulseTimestamps{i}, filetimestamp) ~= 0
        updatePulse = 1;
    end

    %TO062806C
    if updatePulse
        data = load(filename, '-mat');

        %TO062806C
        setPulse(pulseMap('acquisition'), outputChannelNames{i}, data.signal);
        set(data.signal, 'SampleRate', sampleRate, 'deleteChildrenAutomatically', 1);%TO062806E
        %TO062806C
        pulseTimestamps{i} = filetimestamp;
        pulseSelectionHasChanged(i) = 0;
        setLocal(progmanager, hObject, 'pulseTimestamps', pulseTimestamps);

        try
            %TO050506A: Insert a structure with the pulse parameters, for now. Change this to something more sophisticated later. -- Tim O'Connor 5/5/06
            %pulseParameters = getLocal(progmanager, hObject, 'pulseParameters'); %VI052908A
            pulseParameters{i} = toStruct(data.signal);
        catch
            warning('Failed to store pulse ''%s'' in header: %s', get(data.signal, 'Name'), lasterr);
        end
    end
end

setLocalBatch(progmanager, hObject, 'pulseSelectionHasChanged', pulseSelectionHasChanged, 'pulseTimestamps', pulseTimestamps, 'pulseParameters', pulseParameters);

return;
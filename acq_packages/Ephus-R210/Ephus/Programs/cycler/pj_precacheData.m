% pj_precacheData - Precache the actual data for the acquisition (required fixed trace lengths across acquisitions).
%
% SYNTAX
%  pj_precacheData(hObject)
%    hObject - The program handle.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO090506E - Gracefully handle null pulses in cycles. -- Tim O'Connor 9/5/06
%  TO090706E - Print a notice to alert users to the lack of online preprocessing of data. -- Tim O'Connor 9/7/06
%  TO091506B - Make sure the sampleRate of the signal is properly set. Speed things up by pulling getLocalBatch out of the loop. -- Tim O'Connor 9/15/06
%  TO101707D - Port to nimex. Removed the 'cachedPulsesUsed' variable. Removed preprocessing -- Tim O'Connor 10/17/07
%
% Created 8/30/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_precacheData(hObject)

%TO101707D - No need to warn about the preprocessing anymore... for now. -- Tim O'Connor 10/17/07
%fprintf(1, 'pj_precacheData - Note: All cached data is being preprocessed now.\n                        Future state changes (amplifiers, scale factors, etc) will not be taken into account until data is recached.\n');

[positions, mappedProgramHandles, pulseDataMap] = getLocalBatch(progmanager, hObject, 'positions', 'mappedProgramHandles', 'pulseDataMap');
channelNames = get(getLocalGh(progmanager, hObject, 'currentChannel'), 'String');

hObject = getParent(hObject, 'figure');
wb = waitbar(0, 'Precaching data...');
set(wb, 'Units', get(hObject, 'Units'));
windowPosition = get(hObject, 'Position');
wbPos = get(wb, 'Position');
wbPos(1:2) = windowPosition(1:2) + 0.5 * [0 windowPosition(4)];
set(wb, 'Position', wbPos);

%TO091506B
mappedSampleRates = zeros(size(mappedProgramHandles));
mappedTraceLengths = zeros(size(mappedProgramHandles));
for i = 1 : length(mappedProgramHandles)
    [traceLength, sampleRate] = getLocalBatch(progmanager, mappedProgramHandles(i), 'traceLength', 'sampleRate');
    mappedSampleRates(i) = sampleRate;
    mappedTraceLengths(i) = traceLength;
end

precachedData = cell(length(positions), length(channelNames));
pulseDataMap = cell(length(positions), length(channelNames));
totalOperations = numel(precachedData);
for j = 1 : length(positions)
    for i = 1 : length(channelNames)
        pos = pj_positionArray2positionStruct(positions{j}, channelNames{i});

        %  TO090506E - Gracefully handle null pulses in cycles. -- Tim O'Connor 9/5/06
        if ~isempty(pos.pulseSetName) && ~isempty(pos.pulseName)
            %Load data.
            s = pj_loadSignal(hObject, pos.pulseSetName, pos.pulseName);
            try
                set(s, 'SampleRate', mappedSampleRates(i));%TO091506B
                precachedData{j, pos.channelIndex} = getdata(s, mappedTraceLengths(i));
            catch
                warning('pj_precacheData: Failed to properly cache pulse data @%s-%s: %s', num2str(j), pos.channelName, lasterr);
            end
            try
                %Update header info.
                pulseDataMap{i, j} = toStruct(s);
            catch
                warning('pj_precacheData: Failed to properly cache pulse information for the header: %s', lasterr);
            end
            %TO101707D - No data preprocessing is done here now. Maybe we'll add a hook into nimex to allow this later.
            try
                delete(s);
            catch
                warning('pj_precacheData: Failed to properly clean up @signalobject: %s', lasterr);
            end
        else
            precachedData{j, pos.channelIndex}  = [];
        end
% fprintf(1, 'pj_precacheData: precached %s samples for ''%s-->%s:%s''\n', num2str(length(precachedData{j, pos.channelIndex})), channelNames{i}, pos.pulseSetName, pos.pulseName);
        
        waitbar(i * j / totalOperations, wb);
    end
end

setLocalBatch(progmanager, hObject, 'precachedData', precachedData, 'pulseDataMap', pulseDataMap);
delete(wb);

return;
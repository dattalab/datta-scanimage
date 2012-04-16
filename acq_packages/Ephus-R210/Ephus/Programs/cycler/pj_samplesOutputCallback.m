% pj_samplesOutputCallback - Process the samplesOutput event(s), replacing data based on cycle definitions.
%
% SYNTAX
%  pj_samplesOutputCallback(hObject, programName, channelName)
%    hObject - The program handle.
%    programObject - The handle to the program being hijacked.
%    programName - The name of the program that spawned the event.
%    channelName - The name of the channel that spawned the event.
%
% USAGE
%
% NOTES
%  This is where the magic happens.... bow-chicka-bow-wow.
%
% CHANGES
%  TO090506E - Gracefully handle null pulses in cycles. -- Tim O'Connor 9/5/06
%  TO090506G - Only increment the counter if the loop is supposed to continue, and only once per iteration. -- Tim O'Connor 9/5/06
%  TO090706D - Cached data is already preprocessed, don't preprocess it a second time. -- Tim O'Connor 9/7/06
%  TO090706F - Make the position loading more intuitive, because pulses are loaded at the end of the previous trace, then the cycler appears 2 steps ahead. -- Tim O'Connor 9/7/06
%  TO091106A - Count number of running boards, for iterating during the loop. -- Tim O'Connor 9/11/06
%  TO101707D - Port to nimex. -- Tim O'Connor 10/17/07D
%
% Created 8/28/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_samplesOutputCallback(hObject, programObject, programName, channelName)

error('Deprecated - See TO101707D - Port to nimex.\n');%TO101707D
% fprintf(1, '%s - pj_samplesOutputCallback: ''%s:%s''\n', datestr(now), programName, channelName);
[enable, currentPosition, precacheDefinitions, precachedDefinitions, precacheData, precachedData, positions, lastPulsesUsed, ...
        cachedPulsesUsed, loopCompleted, iterationCounter, iterationFactor] = getLocalBatch(progmanager, hObject, ...
    'enable', 'currentPosition', 'precacheDefinitions', 'precachedDefinitions', 'precacheData', 'precachedData', 'positions', 'lastPulsesUsed', ...
    'cachedPulsesUsed', 'loopCompleted', 'iterationCounter', 'iterationFactor');%TO090506G %TO091106A
if ~enable
    return;
end

currentPosition = currentPosition + 1;%TO090706F
if currentPosition > length(positions)
    currentPosition = 1;
end

[aom, traceLength] = getLocalBatch(progmanager, programObject, 'aomux', 'traceLength');

dm = getDaqmanager;
ao = getAO(dm, channelName);
if length(ao.Channel) > 1
    channelNames = ao.Channel.ChannelName;
    if strcmpi(class(channelNames), 'char')
        channelNames = {channelNames};
    end
else
    channelNames = {channelName};
end

%TO090506E
activeChannelIndices = [];
data = cell(size(channelNames));
for i = 1 : length(channelNames)
    %Load data.
    pos = pj_programInsensitivePositionArray2positionStruct(positions{currentPosition}, channelNames{i});
    if isempty(pos)
        data{i} = getDaqData(dm, channelNames{i});
% fprintf(1, 'pj_samplesOutputCallback: No position information found for channel ''%s'' using previous %s samples.\n', channelNames{i}, num2str(length(data{i})));
    elseif isempty(pos.pulseSetName) | isempty(pos.pulseName)
        data{i} = getDaqData(dm, channelNames{i});
% fprintf(1, 'pj_samplesOutputCallback: No cycle information found for channel ''%s'' using previous %s samples.\n', channelNames{i}, num2str(length(data{i})));
    else
        if precacheData
            data{i} = precachedData{currentPosition, pos.channelIndex};
% fprintf(1, 'pj_samplesOutputCallback: Loading data for position %s...\n', num2str(currentPosition));
% fprintf(1, 'pj_samplesOutputCallback: Retrieving precached data %s samples in precachedData{%s, %s} for channel''%s''\n', num2str(length(data{i})), num2str(currentPosition), num2str(pos.channelIndex), channelNames{i});
% fprintf(1, 'pj_samplesOutputCallback: Retrieving precached data %s samples in %s:%s for channel ''%s''.\n', num2str(length(data{i})),  pos.pulseSetName, pos.pulseName, channelNames{i});
            try
                lastPulsesUsed.(['channel_' strrep(channelNames{i}, '-', '_')]) = cachedPulsesUsed(currentPosition, pos.channelIndex);
            catch
                warning('pj_samplesOutputCallback: Failed to properly update pulse information in header from cached data: %s', lasterr);
            end
        elseif precacheDefinitions
            data{i} = getData(precachedDefinitions{currentPosition, pos.channelIndex}, traceLength);
% fprintf(1, 'pj_samplesOutputCallback: Retrieving precached definition %s samples in precachedDefinitions{%s, %s} for channel''%s''.\n', num2str(length(data{i})), num2str(currentPosition), num2str(pos.channelIndex), channelNames{i});
            try
                lastPulsesUsed.(['channel_' strrep(channelNames{i}, '-', '_')]) = cachedPulsesUsed(currentPosition, pos.channelIndex);
            catch
                warning('pj_samplesOutputCallback: Failed to properly update pulse information in header from cached definitions: %s', lasterr);
            end
        else
            s = pj_loadSignal(hObject, pos.pulseSetName, pos.pulseName);
            try
                %Update the header information.
                lastPulsesUsed.(['channel_' strrep(channelNames{i}, '-', '_')]) = toStruct(s);
            catch
                warning('pj_samplesOutputCallback: Failed to properly update pulse information in header: %s.', lasterr);
            end
            data{i} = getData(s, traceLength);
% % if endsWithIgnoreCase(channelNames{i}, 'pockelsCell')
% %     figure, plot(data{i}); title(get(s, 'Name'))
% % % s
% % end
% fprintf(1, 'pj_samplesOutputCallback: Retrieving pulse from disk %s samples in %s:%s for channel''%s''.\n', num2str(length(data{i})),  pos.pulseSetName, pos.pulseName, channelNames{i});
            delete(s);
        end
    end

    %TO090506E
    if ~isempty(data{i})
        %TO090706D
        %Preprocess data.
        if ~precacheData
            data{i} = applyPreprocessor(aom, channelNames{i}, data{i});
        end
        activeChannelIndices(length(activeChannelIndices) + 1) = i;
    end
end

% fprintf(1, 'pj_samplesOutputCallback: Putting retriggered daq data...\n');
%Put the data out to the channel.
putDaqDataRetriggered(dm, {channelNames{activeChannelIndices}}, {data{activeChannelIndices}});%TO090506E

setLocal(progmanager, hObject, 'lastPulsesUsed', lastPulsesUsed);
%TO090506G
if ~loopCompleted
    lg = lg_factory;
    lg_iterationCounter = getLocal(progmanager, lg, 'iterationCounter');
    setLocal(progmanager, hObject, 'iterationCounter', iterationCounter + 1);
% fprintf(1, 'pj_samplesOutputCallback: lg_iterationCounter=%s, iterationCounter=%s, iterationFactor=%s, currentPosition=%s\n', num2str(lg_iterationCounter), num2str(iterationCounter), num2str(iterationFactor), num2str(currentPosition));
    %TO091106A
    if iterationCounter >= iterationFactor * lg_iterationCounter - 1
% fprintf(1, 'pj_samplesOutputCallback: Incrementing...\n');
        pj_increment(hObject);
    end
end
% fprintf(1, 'pj_samplesOutputCallback: completed.\n');
return;
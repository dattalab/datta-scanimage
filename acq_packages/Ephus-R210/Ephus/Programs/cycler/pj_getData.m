% pj_getData - Return data, emulating the signature of @signalobject/getdata.
%
% SYNTAX
%  data = pj_getData(hObject, programHandle, channelIndex, channelName, time)
%  data = pj_getData(hObject, programHandle, channelIndex, channelName, samples, 'Samples')
%   data - The requested signal data.
%   hObject - The handle to the pulseJacker.
%   programHandle - The handle to the program that owns the channel.
%   channelIndex - The index, into the pulseJacker arrays, for the channel's data.
%   channelName - The channel for which to retrieve data.
%   time - The amount of data in time [seconds].
%   samples - The amount of data in samples.
%             This only applies if followed by the string 'Samples' as the next argument.
%
% USAGE
%  This may choose to return a different amount of data than requested, depending on caching preferences.
%
% NOTES
%
% CHANGES
%
% Created 10/17/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function data = pj_getData(hObject, programHandle, channelNameIndex, channelName, time, varargin)
% fprintf(1, '%s - pj_getData\n', datestr(now));
[precacheDefinitions, precacheData, enable, precachedDefinitions, precachedData, currentPosition, positions, loopEventData, pulseDataMap] = getLocalBatch(progmanager, hObject,...
    'precacheDefinitions', 'precacheData', 'enable', 'precachedDefinitions', 'precachedData', 'currentPosition', 'positions', 'loopEventData', 'pulseDataMap');
% fprintf(1, '%s - pj_getData\n%s', datestr(now), getStackTraceString);
if ~enable
    fprintf(2, 'Call to pj_getData while pulseJacker is not enabled. Not returning data for channel ''%s''.\n', channelName);
    return;
end

extraArguments = varargin;

data = [];
sampleRate = getLocal(progmanager, programHandle, 'sampleRate');
numberOfSamples = time * sampleRate;

if isempty(loopEventData)
    iterations = 1;
else
    if ~strcmpi(loopEventData.eventType, 'loopstartprecisetiming')
        iterations = 1;
    else
        iterations = loopEventData.totalIterations;
        time = loopEventData.interval;
        numberOfSamples = time * sampleRate;
        extraArguments = {};
        data = zeros(time * getLocal(progmanager, programHandle, 'sampleRate'), 1);
    end
end

updatePulseDataMapForHeader = 0;
positionsUsed = zeros(iterations, 1);

offset = 1;
for i = 1 : iterations
    positionsUsed(i) = currentPosition;
    if precacheData
        if isempty(precachedData{currentPosition, channelNameIndex})
            if iterations == 1
                data = [];
                fprintf(2, 'pj_getData - Warning: Not generating data because no precached data is available for ''%s''.\n', channelName);
            else
                data(offset : offset + numberOfSamples - 1) = 0;
                fprintf(2, 'pj_getData - Warning: Generating NULL data because no precached data is available for ''%s''.\n', channelName);
            end
        else
            data(offset : offset + numberOfSamples - 1) = precachedData{currentPosition, channelNameIndex};
        end
    elseif precacheDefinitions
        if isempty(precachedDefinitions{currentPosition, channelNameIndex})
            if iterations == 1
                data = [];
                fprintf(2, 'pj_getData - Warning: Not generating data because no precached definition is available for ''%s''.\n', channelName);
            else
                data(offset : offset + numberOfSamples - 1) = 0;
                fprintf(2, 'pj_getData - Warning: Generating NULL data because no precached definition is available for ''%s''.\n', channelName);
            end
        else
            set(precachedDefinitions{currentPosition, channelNameIndex}, 'SampleRate', getLocal(progmanager, programHandle, 'sampleRate'))
            data(offset : offset + numberOfSamples - 1) = getdata(precachedDefinitions{currentPosition, channelNameIndex}, time, extraArguments{:});
        end
    else
        idx = pj_positionArray2positionIndex(positions{currentPosition}, [getProgramName(progmanager, programHandle) ':' channelName]);
        if isempty(idx)
            if iterations == 1
                data = [];
                fprintf(2, 'pj_getData - Warning: Not generating data because no pulse is specified for ''%s''.\n', channelName);
            else
                data(offset : offset + numberOfSamples - 1) = 0;
                fprintf(2, 'pj_getData - Warning: Generating NULL data because no pulse is specified for ''%s''.\n', channelName);
            end
        else
            pos = positions{currentPosition}(idx);
            if isempty(pos)
                if iterations == 1
                    data = [];
                    fprintf(2, 'pj_getData - Warning: Not generating data because no pulse is specified (2) for ''%s''.\n', channelName);
                else
                    data(offset : offset + numberOfSamples - 1) = 0;
                    fprintf(2, 'pj_getData - Warning: Generating NULL data because no pulse is specified (2) for ''%s''.\n', channelName);                    
                end
            elseif isempty(pos.pulseSetName) || isempty(pos.pulseName)
                if iterations == 1
                    data = [];
                    fprintf(2, 'pj_getData - Warning: Not generating data because pulseSetName/pulseName does not exist for ''%s''.\n', channelName);
                else
                    data(offset : offset + numberOfSamples - 1) = 0;
                    fprintf(2, 'pj_getData - Warning: Generating NULL data because pulseSetName/pulseName does not exist for ''%s''.\n', channelName);
                end
            else
                %Load the pulse from disk.
                s = pj_loadSignal(hObject, pos.pulseSetName, pos.pulseName);
                set(s, 'SampleRate', getLocal(progmanager, programHandle, 'sampleRate'));%TO091506B
% fprintf(1, '%s - pj_getData - ''%s'' - %s:%s\n', datestr(now), channelName, pos.pulseSetName, pos.pulseName);
                %Update the header info.
                pulseDataMap{channelNameIndex, currentPosition + 1} = toStruct(s);
                updatePulseDataMapForHeader = 1;

                %Return the data.
                data(offset : offset + numberOfSamples - 1) = getdata(s, time, extraArguments{:});
% if strcmpi(pos.pulseName, '-100pa100ms100ms_1')
%     figure, plot(data);
% end
                %Clean up.
                delete(s);
            end
        end
    end
    
    %Iterate.
    if iterations > 1
        pj_increment(hObject);
        currentPosition = getLocal(progmanager, hObject, 'currentPosition');
        offset = offset + numberOfSamples;
    end
end

%This needs to go into the header.
if updatePulseDataMapForHeader
    setLocalBatch(progmanager, hObject, 'positionsUsed', positionsUsed, 'pulseDataMap', pulseDataMap);
else
    setLocalBatch(progmanager, hObject, 'positionsUsed', positionsUsed);
end

if size(data, 2) > size(data, 1)
    data = data';
end
% fprintf(1, '%s - pj_getData: COMPLETE\n', datestr(now));
return;
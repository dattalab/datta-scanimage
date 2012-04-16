% shared_recordData - Store data that is dispatched to this listener, for saving later.
%
% SYNTAX
%  shared_recordData(hObject, bufferName, channelName, sc, data, sampleRate)
%   hObject - The program handle.
%   channelName - The channel the incoming data is associated with.
%   sc - The scopeObject associated with the channel.
%   data - The incoming data.
%   sampleRate - The sample rate for the acquired data.
%
% USAGE
%  This is meant to be called by the data acquisition system via the samplesAcquired/everyN event.
%
% NOTES
%  Refactored out of ephys_configureAimux. -- Tim O'Connor 8/14/07 TO073107B
%  Adapted from ephys_recordData.m See TO101707F.
%
% CHANGES
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO123005B - Initiate automatic data saving when all the data has been read. -- Tim O'Connor 12/30/05
%  TO012606B - Implemented the expectedDataSourceList variable in the xsg. -- Tim O'Connor 1/26/06
%  TO012706A - Push the call to flush input data into the xsg. -- Tim O'Connor 1/27/06
%  TO012706B - Deprecated xsg_removeExpectedDatSource. See @startmanager/removeExpectedDataSource and @startmanager/removeExpectedDataSink -- Tim O'Connor 1/27/06
%  TO031306A - Allow access to the samplesAcquired event as a user function, for processing before completion when using board timing. -- Tim O'Connor 3/13/06
%  TO032106D - Only clear the buffer when data is first acquired after a restart. Use a flag to indicate a reset is desired. -- Tim O'Connor 3/22/06
%  TO032206B - Have to check all channels before stopping. -- Tim O'Connor 3/22/06
%  TO032306C - Update conditions for alternate channel checking when stopping. See TO032206B. -- Tim O'Connor 3/23/06
%  TO033006A - Pass the name of the most recently updated buffer to the ephys:SamplesAcquired UserFcn. -- Tim O'Connor 3/30/06
%  TO080306A - Allow multiple acquisitions to be prequeued, and sequentially triggered. -- Tim O'Connor 8/3/06
%  TO091106F - Update the TriggerRepeat property on AI objects in the event that segmentedAcquisition has been set externally. See TO091106E. -- Tim O'Connor 9/11/06
%  TO102306A - Apparently, the SamplesPerTrigger value can not be relied on to count SamplesAcquiredFcn calls. Add a field to the buffer instead. --Tim O'Connor 10/23/06
%  TO110206A - Moved startmanager event conditions, but this may not have been strictly necessary (see other TO110206A). -- Tim O'Connor 11/2/06
%  TO110906A - Get the channel's SamplesPerTrigger, not the (possibly shared) ai object's. -- Tim O'Connor 11/9/06
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%  TO080607A - Watch 64-bit datatypes that don't support most math operations. -- Tim O'Connor 8/5/07
%  TO101407A - Nimex port. The done event can be relied upon to stop the acquisition now. -- Tim O'Connor 10/14/07
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO033008C - Check to see if this program is running. -- Tim O'Connor 3/30/08
%  TO043008E - Keep timestamps for each data append. -- Tim O'Connor 4/30/08
%  TO021510F - Implemented disk streaming. -- Tim O'Connor 2/15/10
%  TO021610G - Clear the scope display when clearing the buffers. -- Tim O'Connor 2/16/10
%  TO030210D - Force clearing of the buffers in continuous mode, if they are not empty. -- Tim O'Connor 3/2/10
%  TO030210H - Take the scopeObject, for the associated channel, as an argument. -- Tim O'Connor 3/2/10
%  TO032510C - Added more conditions, because saving the data clears resetOnNextSamplesAcquired, which results in the clear never occuring.
%  TO042010A - Implement a TraceAcquired event, which will replace SamplesAcquired in most cases. -- Tim O'Connor 4/20/10
%  TO052110A - Add a flag (dataToBeSaved) to indicate that there is data that needs to be saved. -- Tim O'Connor 5/21/10
%
% Created 8/14/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function shared_recordData(hObject, bufferName, channelName, sc, data, sampleRate)
% lg = lg_factory;
% fprintf(1, '\n=================\niteration: %s\n', num2str(getLocal(progmanager, lg, 'iterationCounter')));
% fprintf(1, '%s - ''%s''_recordData: %s samples\n', datestr(now), getProgramName(progmanager, hObject), num2str(length(data)));
% fprintf(1, '%s - ''%s''_recordData\n', datestr(now), getProgramName(progmanager, hObject));
[startButton, externalTrigger, buffers, boardBasedTimingEvent, continuousAcqMode, ...
    traceLengthArray, traceLength, acqOnArray, sampleCount] = ...
    getLocalBatch(progmanager, hObject, 'startButton', 'externalTrigger', 'saveBuffers', 'boardBasedTimingEvent', 'continuousAcqMode', ...
    'traceLengthArray', 'traceLength', 'acqOnArray', 'sampleCount');

%TO033008C - Check to see if this program is running, in the event that other programs caused data to be dispatched to here.
if ~(startButton || externalTrigger)
    %Do we need to print anything here?
    % fprintf(1, '''%s''_recordData - Program not running. Ignoring data...\n', getProgramName(progmanager, hObject));
    return;
end

%TO032510C - Added more conditions, because saving the data clears resetOnNextSamplesAcquired, which results in the clear never occuring.
if buffers.(bufferName).resetOnNextSamplesAcquired || (isempty(buffers.(bufferName).data) && ~xsg_isDiskStreamingEnabled)
    if buffers.(bufferName).resetOnNextSamplesAcquired
        %fprintf(1, '%s - ''%s''_recordData - Clearing buffer...\n', datestr(now), getProgramName(progmanager, hObject));
        buffers = shared_resetBuffer(buffers, bufferName, buffers.(bufferName).channelName, buffers.(bufferName).amplifierName, sampleRate);%TO030210C
    end

    %TODO: Only clear the channel related to the data that was just acquired. -- Tim O'Connor 3/2/10 - TO030210H == DONE
    %TO021610G - Use this as the cue for when to clear the scope's display as well.
    %TO030210H - The scopeObject comes in as an argument now, no need to search for the right one(s).
    if ~get(sc, 'holdOn')
        clearData(sc);
    end
end

buffers.(bufferName).dataEventTimestamps(end + 1) = now;%TO043008E
buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter + 1;%TO102306A

if ~xsg_isDiskStreamingEnabled
%fprintf(1, '%s - ''%s''_recordData: Appending %s samples to a buffer of %s samples...\n', datestr(now), getProgramName(progmanager, hObject), num2str(length(data)), num2str(length(buffers.(bufferName).data)));
    buffers.(bufferName).data = cat(1, buffers.(bufferName).data, data);
    dataToBeSaved = 1;%TO052110A
else
    fHandle = xsg_getStreamingFileHandle(channelName);
    if ~isempty(fHandle)
        fwrite(fHandle, data);
    end
    buffers.(bufferName).data = [];
    dataToBeSaved = 0;%TO052110A
end

index = (strcmpi(fieldnames(buffers), bufferName));
sampleCount(index) = sampleCount(index) + length(data);
if continuousAcqMode
    if isempty(boardBasedTimingEvent)
        if any(sampleCount) >= traceLength * sampleRate
            fprintf(1, '%s - ''%s''_sharedRecord: Stopping continuous-mode acquisition.\n', datestr(now), getProgramName(progmanager, hObject));
            shared_Stop(hObject);
        end
    else
        if any(sampleCount) >= traceLength * sampleRate * boardBasedTimingEvent.totalIterations
            fprintf(1, '%s - ''%s''_sharedRecord: Stopping continuous-mode acquisition.\n', datestr(now), getProgramName(progmanager, hObject));
            shared_Stop(hObject);
        end
    end
    if ~isempty(buffers.(bufferName).data) %TO030210D
        buffers = shared_resetBuffer(buffers, bufferName, buffers.(bufferName).channelName, buffers.(bufferName).amplifierName, sampleRate);%TO030210C
    end
else
    if isempty(boardBasedTimingEvent)
        if length(buffers.(bufferName).data) >= traceLength * sampleRate
            buffers.(bufferName).resetOnNextSamplesAcquired = 1;
        end
    else
        if length(buffers.(bufferName).data) >= traceLength * sampleRate * boardBasedTimingEvent.totalIterations
            buffers.(bufferName).resetOnNextSamplesAcquired = 1;
        end
    end
end

% %TO101407A - Moved this up here, since the saveBuffers field is now only set up here, the counters would be lost otherwise.
% [lg, lm] = lg_factory;%TO021610G - This now needs to be conditional upon being in a loop and having acquired a full trace's worth of samples.
% if get(lm, 'started') && isempty(boardBasedTimingEvent)
%     if ~isempty(traceLengthArray)
%         traceLength = traceLengthArray(index);
%     end
%     if length(buffers.(bufferName).data) >= traceLength * sampleRate
%         buffers.(bufferName).resetOnNextSamplesAcquired = 1;
%     end
% else
%     buffers.(bufferName).resetOnNextSamplesAcquired = 0;
% end

setLocalBatch(progmanager, hObject, 'saveBuffers', buffers, 'sampleCount', sampleCount, 'dataToBeSaved', dataToBeSaved);%TO052110A

% fprintf(1, '%s - ''%s''_recordData: Acquired %s samples (%s of %s samples) for ''%s''.\n', datestr(now), getProgramName(progmanager, hObject), num2str(length(data)), num2str(length(buffers.(bufferName).data)), num2str(get(ai, 'SamplesPerTrigger')), bufferName);
fireEvent(getUserFcnCBM, [getProgramName(progmanager, hObject) ':SamplesAcquired'], data, bufferName);%TO031306A %TO033006A
% fprintf(1, '%s - ''%s''_recordData: Complete.\n', datestr(now), getProgramName(progmanager, hObject));

%TO042010A
if length(buffers.(bufferName).data) >= traceLength * sampleRate
    fireEvent(getUserFcnCBM, [getProgramName(progmanager, hObject) ':TraceAcquired'], buffers.(bufferName).data, bufferName);
end

return;
% ephys_Start - Start an acquisition.
%
% SYNTAX
%  ephys_Start(hObject)
%
% USAGE
%  Simply pass in the handle to the ephys program and an acquisition will get started.
%
% NOTES
%
% CHANGES
%  TO081005C - Refresh pulse definitions from their file. -- Tim O'Connor 8/10/05
%  TO091405A - Load proper pulses from files, if necessary. -- Tim O'Connor 9/14/05
%  TO100405C - Make sure the scopes are visible. -- Tim O'Connor 10/4/05
%  TO100705A - Don't clear the scope before taking a trace now, this may change again. -- Tim O'Connor 10/7/05
%  TO100705F - Set a flag ('acquiring'), and rely on it, to determine the status of the program. This will optimize stopping. -- Tim O'Connor 10/7/05
%  TO100705H - Make sure multiple callbacks to stop don't step on new starts. -- Tim O'Connor 10/7/05
%  TO100705I - Make sure displays are updated throughout a loop. -- Tim O'Connor 10/7/05
%  TO112205B - Set status string on trigger event, which makes more sense for external control. -- Tim O'Connor 11/22/05
%  TO112205C - Allow per-channel event listeners. Implement all state/lifecycle listeners using the @CALLBACKMANAGER. -- Tim O'Connor 11/22/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO120205G - Clearing of data: As of now, it's back on (I like it, it makes it very clean and clear. Especially if the trace length is modified.) -- Tim O'Connor 12/2/05
%  TO120905F - Clearing of data: And now it's off again. Karel doesn't like it. -- Tim O'Connor 12/9/05
%  TO121505E - Don't try to stop channels prior to using them, consider it to be an error if they are in use. -- Tim O'Connor 12/15/05
%  TO123005C - Rely on ephys_Start/stopFcn_Callback to handle board initiated stopping. -- Tim O'Connor 12/30/05
%  TO123005D - Process error events with the RuntimeErrorFcn and DataMissed properties. -- Tim O'Connor 12/30/05
%  TO123005G - Implement various userFcn calls. -- Tim O'Connor 12/30/05
%  TO010506D - Enabling/disabling of UserFcn callbacks is handled by the callbackManager object directly. -- Tim O'Connor 1/5/06
%  TO012606B - Implemented the expectedDataSourceList variable in the xsg. -- Tim O'Connor 1/26/06
%  TO012706B - Moved the expectedDataSourceList into the @startmanager. -- Tim O'Connor 1/27/06
%  TO013106E - Added the 'externallyTriggered' field in @startmanager to keep track of external hardware triggered starts. -- Tim O'Connor 1/31/06
%  TO031306A: Implemented board-based (precise) timing. As only one trigger is issued, cycles have no effect. -- Tim O'Connor 3/13/06
%  TO031306B: Batched up some `getLocal` calls. -- Tim O'Connor 3/13/06
%  TO032106D - Only clear the buffer when data is first acquired after a restart. Use a flag to indicate a reset is desired. -- Tim O'Connor 3/21/06
%  TO032106E - Make sure it works when no input channels are enabled (this included fixing a cut & paste error and/or typo). -- Tim O'Connor 3/21/06
%  TO032306B - Watch out for length mismatches in lists of channel names and amplifiers. See TO032106E. -- Tim O'Connor 3/23/06
%  TO032906C - Only show scopes for channels that are acquiring. -- Tim O'Connor 3/29/06
%  TO033106F - Update scopeObject's visible property, not the figure directly. -- Tim O'Connor 3/31/06
%  TO040706C - Carry the figure visibility back to the associated scope object. -- Tim O'Connor 4/7/06
%  TO062806C - Implement "turbo" cycles, allow for multiple traces to be chained. -- Tim O'Connor 6/28/06
%  TO080306A - Allow multiple acquisitions to be prequeued, and sequentially triggered. -- Tim O'Connor 8/3/06
%  TO080306B - Imported `samplesOutputFcn_Callback` from stim_Start.m to end acquisitions that record nothing. -- Tim O'Connor 8/3/06
%  TO080206C - Renamed variables for clarity: totalSamples-->samplesPerTrigger, outputTime-->traceLength -- Tim O'Connor 8/3/06
%  TO081106A - Moved return based on acqOnArray so data output may occur. -- Tim O'Connor 8/11/06
%  TO081106B - Make sure that transmissionsRemainingCounter is set. -- Tim O'Connor 8/11/06
%  TO081106C - A channelName is required to get a signal from an @aomux object. -- Tim O'Connor 8/11/06
%  TO081406A - Created @daqmanager/updateOutputData. Continued fixes from TO081106C. -- Tim O'Connor 8/14/06
%  TO081606B - RepeatOutput needs to be 0 when inserting new data in the SamplesOutputFcn. -- Tim O'Connor 8/16/06
%  TO081606C - Update the status when inserting new data in the SamplesOutputFcn. -- Tim O'Connor 8/16/06
%  TO081806A - Preprocess data before putting it out in a segmented acquisition. -- Tim O'Connor 8/16/06
%  TO082206A - When doing CPU loops, make sure RepeatOutput is set. -- Tim O'Connor 8/21/06
%  TO082406A - Make sure RepeatOutput is set to one less than the number of iterations in precise timing mode. -- Tim O'Connor 8/24/06
%  TO082506C - Allow access to the samplesOutput event as a user function, this is intended for use by the pulseJacker gui. -- Tim O'Connor 8/25/06
%  TO082806A - Continuation of TO082506C. -- Tim O'Connor 8/28/06
%  TO082806B - Handle multiple channels on a single board (1 SamplesOutput event per board). -- Tim O'Connor 8/29/06
%  TO102306A - Apparently, the SamplesPerTrigger value can not be relied on to count SamplesAcquiredFcn calls. Add a field to the buffer instead. --Tim O'Connor 10/23/06
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% Created 5/26/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephys_Start(hObject)
% fprintf(1, 'ephys_Start\n');
% getStackTraceString
setLocal(progmanager, hObject, 'startButton', 1);
setLocalGh(progmanager, hObject, 'startButton', 'String', 'Stop', 'ForegroundColor', [1 0 0]);

%TO123005G
fireEvent(getUserFcnCBM, 'ephys:Start', hObject);%TO120505B, TO010506D

drawnow expose;%TO100705I %TO042309A - Not using expose can cause C-spawned events to fire out of order.

[traceLength, sampleRate, amplifiers, sc, selfTrigger, boardBasedTimingEvent, acqOnArray, traceLengthArray, segmentedAcquisition] = getLocalBatch(progmanager, hObject, ...
    'traceLength', 'sampleRate', 'amplifiers', 'scopeObject', 'selfTrigger', 'boardBasedTimingEvent', 'acqOnArray', 'traceLengthArray', 'segmentedAcquisition');%TO031306A %TO031306B %TO062806C %TO080206A

repetitions = 0;%TO031306A
repeatOutput = 0;%TO081606B %TO082206A
%TO031306A - Cache the total time for the trace.
samplesPerTrace = ceil(traceLength * sampleRate);
if ~isempty(boardBasedTimingEvent)
    repeatOutput = boardBasedTimingEvent.totalIterations - 1;%TO082206A %TO082406A
    repetitions = boardBasedTimingEvent.totalIterations;
    samplesPerTrigger = samplesPerTrace * boardBasedTimingEvent.totalIterations;
else
    samplesPerTrigger = samplesPerTrace;
end

samplesAcquiredFcnCount = samplesPerTrace;
triggerRepeat = 0;

%TO062806C
if ~isempty(traceLengthArray)
    traceLength = sum(traceLengthArray);
    repeatOutput = length(traceLengthArray) - 1;%TO081606B
    %TO080306A
    if segmentedAcquisition
        samplesPerTrigger = samplesPerTrace;
        triggerRepeat = length(traceLengthArray);
        setLocalBatch(progmanager, hObject, 'acquisitionsRemainingCounter', triggerRepeat, 'transmissionsRemainingCounter', triggerRepeat);%TO081106B
        repetitions = length(traceLengthArray) - 1;%TO081406A
        repeatOutput = 0;%TO081606B
    else
        samplesPerTrigger = ceil(traceLength * sampleRate);
        samplesAcquiredFcnCount = ceil(min(traceLengthArray) * sampleRate);
    end
end
expectedSampleCount = ceil(traceLength * sampleRate) *  (repetitions + 1);

% fprintf(1, 'ephys_Start -\n samplesPerTrace: %s\n samplesPerTrigger: %s\n traceLength: %s\n segmentedAcquisition: %s\n triggerRepeat: %s\n', ...
%     num2str(samplesPerTrace), num2str(samplesPerTrigger), num2str(traceLength), num2str(segmentedAcquisition), num2str(triggerRepeat));

inputChannels = ephys_getInputChannelNames(hObject);
outputChannels = ephys_getOutputChannelNames(hObject);

ephys_updateOutputSignals(hObject);%TO091405A

job = daqjob('acquisition');
setTriggerRepeats(job, triggerRepeat);
for i = 1 : length(inputChannels)
    setTaskProperty(job, inputChannels{i}, 'samplingRate', sampleRate', 'sampsPerChanToAcquire', samplesPerTrigger, 'everyNSamples', samplesAcquiredFcnCount);
end
bindEventListener(job, 'jobTrigger', {@triggerFcn_Callback, hObject}, 'ephys_Start');%TO112205C, TO120205A
bindEventListener(job, 'jobStop', {@stopFcn_Callback, hObject}, 'ephys_Start');
bindEventListener(job, 'jobDone', {@doneFcn_Callback, hObject}, 'ephys_Start');

%TO032106E %TO032306B
for i = 1 : length(amplifiers)
    %TO100405C: Make sure the scopes are visible.
    %TO032906C
    f = get(sc(i), 'figure');
    if acqOnArray(i)
        set(sc(i), 'Visible', 'On');%TO033106F
    elseif strcmpi(get(f, 'Visible'), 'Off')
        %TO040706C
        set(sc(i), 'Visible', 'Off');
    end
    
    update(amplifiers{i});%TO120205A

    if get(amplifiers{i}, 'current_clamp')
        set(sc(i), 'yUnitsString', 'mV', 'gridOn', 0);
    else
        set(sc(i), 'yUnitsString', 'pA', 'gridOn', 0);
    end
end

for i = 1 : length(outputChannels)
    setTaskProperty(job, outputChannels{i}, 'samplingRate', sampleRate', 'sampsPerChanToAcquire', samplesPerTrigger, 'everyNSamples', samplesAcquiredFcnCount);
end

stackTrace = getStackTraceString;
buffers = getLocal(progmanager, hObject, 'saveBuffers');%TO032106D
for i = 1 : length(amplifiers)
    %TO032106D
    bufferName = ['trace_' num2str(i)];
    if isempty(buffers)
        buffers.(bufferName).data = [];
        buffers.(bufferName).amplifierName = get(amplifiers{i}, 'name');%TO120205A
        buffers.(bufferName).debug.creationStackTrace = getStackTraceString;
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
        buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
    elseif ~isfield(buffers, bufferName)
        buffers.(bufferName).data = [];
        buffers.(bufferName).amplifierName = get(amplifiers{i}, 'name');%TO120205A
        buffers.(bufferName).debug.creationStackTrace = getStackTraceString;
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
        buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
    elseif ~acqOnArray(i)
        buffers.(bufferName).data = [];
        buffers.(bufferName).amplifierName = get(amplifiers{i}, 'name');%TO120205A
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
        buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
    else
        %Make sure the name is in sync with whatever's displayed in the gui.
        buffers.(bufferName).amplifierName = get(amplifiers{i}, 'name');%TO120205A
    end
    buffers.(bufferName).resetOnNextSamplesAcquired = 1;
end
setLocalBatch(progmanager, hObject, 'saveBuffers', buffers, 'acquiring', 1, 'status', 'Waiting...');%TO100705F, TO100705H, TO112205B

%TO062806C
if isempty(traceLengthArray)
    set(sc, 'xUnitsPerDiv', traceLength / 10);
else
    set(sc, 'xUnitsPerDiv', min(traceLengthArray) / 10);
end

start(job, inputChannels{:}, outputChannels{:});
if getLocal(progmanager, hObject, 'selfTrigger')
    trigger(job);
end

return;

%------------------------------------------------------
% TO112205B: Wait for the trigger to set the status to 'Acquiring...'
% TO080906B: Record an individual trigger time in every program.
function triggerFcn_Callback(hObject, channels)
% lg = lg_factory;
% fprintf(1, '\n=================\niteration: %s\n', num2str(getLocal(progmanager, lg, 'iterationCounter')));
% fprintf(1, '%s - ephys_Start/triggerFcn_Callback\n', datestr(now));
% getAO(getDaqmanager, '700A-1-VCom')
%TO112205C
% analogObject = varargin{1};
% eventData = varargin{2};

setLocalBatch(progmanager, hObject, 'status', 'Acquiring...', 'triggerTime', clock);%TO080906B
% fprintf(1, '%s - ephys_Start/triggerFcn_Callback\n', datestr(now));

return;

%------------------------------------------------------
% TO100705H: Make sure multiple callbacks to stop don't step on new starts.
function stopFcn_Callback(hObject, channels)
% fprintf(1, '%s - ephys_Start/stopFcn_Callback - quitting (NO_OP)...\n', datestr(now));

setLocalBatch(progmanager, hObject, 'status', '', 'startButton', 0);%TO031306B: Batch these calls.
setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0 0.6 0]);
setLocalBatch(progmanager, hObject, 'segmentedAcquisition', 0, 'acquisitionsRemainingCounter', 0);

return;

%------------------------------------------------------
function doneFcn_Callback(hObject, channels)

ephys_Stop(hObject);

%TO101607F - Just call ephys_Stop now. -- Tim O'Connor 10/16/07
% outputChannels = ephys_getAllOutputChannelNames(hObject);
% if ~isempty(outputChannels)
%     job = daqjob('acquisition');
%     if isStarted(job)
%         stop(job, outputChannels{:});
%     end
%     putSample(job, outputChannels, 0);
% end

return;

%------------------------------------------------------
% TO080306B: Added to ephys, taken from stim_Start.m
% TO031506A: Track samples output, to figure out when to stop
function samplesOutputFcn_Callback(daqobj, eventdata, hObject, expectedSampleCount, channelName)

% fprintf(1, '%s - ephys_Start/samplesOutputFcn_Callback: Transmitted %s of %s samples.\n', datestr(now), ...
%     num2str(get(daqobj, 'SamplesOutput')), num2str(expectedSampleCount));
% fprintf(1, '^^^^^^^^^^^^^^^^^^^^^ Elapsed Time: %s\n', num2str(etime(clock, get(startmanager('acquisition'), 'TriggerTime'))));
% daqobj
% get(daqobj)

%TO082506C
fireEvent(getUserFcnCBM, 'ephys:SamplesOutput', channelName);%TO082806A

[acqOnArray, segmentedAcquisition, transmissionsRemainingCounter, traceLength, pulseHijacked] = getLocalBatch(progmanager, hObject, 'acqOnArray', ...
    'segmentedAcquisition', 'transmissionsRemainingCounter', 'traceLength', 'pulseHijacked');%TO080306A %TO082806A

if get(daqobj, 'SamplesOutput') >= expectedSampleCount
    %TO080306B - Allow sample acquisition to determine stopping time, if data is being logged. -- Tim O'Connor 8/3/06
    %TO081106A - Moved so data output may occur. -- Tim O'Connor 8/11/06
    if any(acqOnArray)
        return;
    end
    %This will block subsequent calls from being executed via the daq object's StopFcn.
    ephys_Stop(hObject);
elseif segmentedAcquisition
    transmissionsRemainingCounter = transmissionsRemainingCounter - 1;
    setLocalBatch(progmanager, hObject, 'transmissionsRemainingCounter', transmissionsRemainingCounter, 'status', 'Waiting...');%TO081606C
    %TO082806A
    if transmissionsRemainingCounter >= 1 && ~pulseHijacked
% fprintf(1, '%s - ephys_Start/samplesOutputFcn_Callback: Updating output data...\n', datestr(now));
        nimex_updateDataSourceByCallback(getTask(daqjob('acquisition'), channelName));
    elseif ~pulseHijacked
% fprintf(1, '%s - ephys_Start/samplesOutputFcn_Callback: Stopping segmented acquisition...\n', datestr(now));
        %TO080306B - Allow sample acquisition to determine stopping time, if data is being logged. -- Tim O'Connor 8/3/06
        %TO081106A - Moved so data output may occur. -- Tim O'Connor 8/11/06
        if any(acqOnArray)
            return;
        end
        ephys_Stop(hObject);
    end
end

return;
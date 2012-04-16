% acq_Start - Start an acquisition.
%
% SYNTAX
%  acq_Start(hObject)
%
% USAGE
%  Simply pass in the handle to the ephys program and an acquisition will get started.
%
% NOTES
%  This is a copy & paste job from ephys_Start.m, with some editting where necessary.
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
%  TO032106D - Only clear the buffer when data is first acquired after a restart. Use a flag to indicate a reset is desired. -- Tim O'Connor 3/22/06
%  TO032106E - Make sure it works when no input channels are enabled. -- Tim O'Connor 3/21/06
%  TO032906C - Only show scopes for channels that are acquiring. -- Tim O'Connor 3/29/06
%  TO033106F - Update scopeObject's visible property, not the figure directly. -- Tim O'Connor 3/31/06
%  TO040706C - Carry the figure visibility back to the associated scope object. -- Tim O'Connor 4/7/06
%  TO062806C - Implement "turbo" cycles, allow for multiple traces to be chained. -- Tim O'Connor 6/28/06
%  TO080306A - Allow multiple acquisitions to be prequeued, and sequentially triggered. -- Tim O'Connor 8/3/06
%  TO080206C - Renamed variables for clarity: totalSamples-->samplesPerTrigger, outputTime-->traceLength -- Tim O'Connor 8/3/06
%  TO102306A - Apparently, the SamplesPerTrigger value can not be relied on to count SamplesAcquiredFcn calls. Add a field to the buffer instead. --Tim O'Connor 10/23/06
%
% Created 12/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function acq_Start(hObject)
% fprintf(1, 'acq_Start\n');
% getStackTraceString
warning('Deprecated.');
setLocal(progmanager, hObject, 'startButton', 1);
setLocalGh(progmanager, hObject, 'startButton', 'String', 'Stop', 'ForegroundColor', [1 0 0]);

%TO123005G
fireEvent(getUserFcnCBM, 'acq:Start', hObject);%TO120505B, TO010506D

drawnow expose;%TO100705I %TO042309A - Not using expose can cause C-spawned events to fire out of order.

[traceLength, sampleRate, channels, sc, selfTrigger, boardBasedTimingEvent, acqOnArray, traceLengthArray, segmentedAcquisition] = getLocalBatch(progmanager, hObject, ...
    'traceLength', 'sampleRate', 'channels', 'scopeObject', 'selfTrigger', 'boardBasedTimingEvent', 'acqOnArray', 'traceLengthArray', 'segmentedAcquisition');%TO031306B %TO062806C %TO080206A

%TO031306A - Cache the total time for the trace.
samplesPerTrace = ceil(traceLength * sampleRate);
if ~isempty(boardBasedTimingEvent)
    samplesPerTrigger = samplesPerTrace * boardBasedTimingEvent.totalIterations;
else
    samplesPerTrigger = samplesPerTrace;
end

samplesAcquiredFcnCount = samplesPerTrace;
triggerRepeat = 0;

%TO062806C
if ~isempty(traceLengthArray)
    traceLength = sum(traceLengthArray);
    %TO080306A
    % samplesPerTrigger = ceil(traceLength * sampleRate);
    % samplesPerTrace = samplesPerTrigger;
    % samplesAcquiredFcnCount = ceil(min(traceLengthArray) * sampleRate);
    if segmentedAcquisition
        triggerRepeat = length(traceLengthArray);
        samplesPerTrigger = samplesPerTrace;
        setLocal(progmanager, hObject, 'acquisitionsRemainingCounter', triggerRepeat);
    else
        samplesPerTrigger = ceil(traceLength * sampleRate);
        samplesAcquiredFcnCount = ceil(min(traceLengthArray) * sampleRate);
    end
end

% fprintf(1, 'acq_Start -\n samplesPerTrace: %s\n samplesPerTrigger: %s\n traceLength: %s\n segmentedAcquisition: %s\n triggerRepeat: %s\n', ...
%     num2str(samplesPerTrace), num2str(samplesPerTrigger), num2str(traceLength), num2str(segmentedAcquisition), num2str(triggerRepeat));

inputChannels = acq_getInputChannelNames(hObject);

% samplesAcquiredFcnCount = min(3 * sampleRate, max(traceLength * sampleRate / 4, sampleRate / 2));

%TO100705A - Don't clear the scope before taking a trace now, this may change again. -- Tim O'Connor 10/7/05
%TO120205G - As of now, it's back on (I like it, it makes it very clean and clear. Especially if the trace length is modified. -- Tim O'Connor 12/2/05
%TO120905F - And now it's off again. Karel doesn't like it. -- Tim O'Connor 12/9/05
% clearData(getLocal(progmanager, hObject, 'scopeObject'));
dm = getDaqmanager;

startID = rand;
for i = 1 : length(inputChannels)
    %There could be performance optimization here, for example by setting the SampleRate to 512 or something else that's low and keeping the SamplesAcquiredFcnCount low.
    %This relies on telegraphs for any Axopatch 200Bs to be on separate boards from the control/acquisition.
    if acqOnArray(i) %TO032106E
        setAIProperty(dm, inputChannels{i}, 'SampleRate', sampleRate, 'SamplesAcquiredFcnCount', samplesAcquiredFcnCount, ...
            'TriggerType', 'HwDigital', 'SamplesPerTrigger', samplesPerTrigger, 'TriggerRepeat', triggerRepeat, ...
            'DataMissedFcn', {@dataMissedFcn_Callback, hObject, inputChannels{i}}, 'RuntimeErrorFcn', {@runtimeErrorFcn_Callback, hObject, inputChannels{i}});%TO100705H, TO112205C, TO123005D, TO031306A
        setChannelStopListener(dm, inputChannels{i}, {@stopFcn_Callback, hObject, startID, ['trace_' num2str(i)]}, 'acq_Start');%TO112205C
        setChannelTriggerListener(dm, inputChannels{i}, {@triggerFcn_Callback, hObject}, 'stim_Start');%TO112205C, TO120205A
    end
end

stackTrace = getStackTraceString;
buffers = getLocal(progmanager, hObject, 'saveBuffers');%TO032106D
for i = 1 : length(channels)
    %TO032106D
    bufferName = ['trace_' num2str(i)];
    if isempty(buffers)
        buffers.(bufferName).data = [];
        buffers.(bufferName).channelName = channels(i).channelName;%TO120205A
        buffers.(bufferName).debug.creationStackTrace = getStackTraceString;
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
        buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
    elseif ~isfield(buffers, bufferName)
        buffers.(bufferName).data = [];
        buffers.(bufferName).channelName = channels(i).channelName;%TO120205A
        buffers.(bufferName).debug.creationStackTrace = getStackTraceString;
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
        buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
    elseif ~acqOnArray(i)
        buffers.(bufferName).data = [];
        buffers.(bufferName).channelName = channels(i).channelName;%TO120205A
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
        buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
    else
        %Make sure the name is in sync with whatever's displayed in the gui.
        buffers.(bufferName).channelName = channels(i).channelName;%TO120205A
    end
    buffers.(bufferName).resetOnNextSamplesAcquired = 1;
    
    %TO100405C: Make sure the scopes are visible.
    f = get(sc(i), 'figure');
    if acqOnArray(i)
        set(sc(i), 'Visible', 'On');%TO033106F
    elseif strcmpi(get(f, 'Visible'), 'Off')
        %TO040706C
        set(sc(i), 'Visible', 'Off');
    end
end
setLocalBatch(progmanager, hObject, 'saveBuffers', buffers, 'acquiring', 1, 'status', 'Waiting...', 'startID', startID);%TO100705F, TO100705H, TO112205B

%TO062806C
if isempty(traceLengthArray)
    set(sc, 'xUnitsPerDiv', traceLength / 10);
else
    set(sc, 'xUnitsPerDiv', min(traceLengthArray) / 10);
end

% setLocal(progmanager, hObject, 'status', 'Acquiring...');%TO100705F

sm = startmanager('acquisition');
%TO121505E - It would be nice to add some sort of error notification here... -- Tim O'Connor 12/15/05
% stopChannel(getDaqmanager, getQueue(sm));%Make sure none of the channels are already running.

addExpectedDataSource(sm, 'acq');%TO012606B, TO012706B
enqueue(sm, inputChannels{:});
if getLocal(progmanager, hObject, 'selfTrigger')
    trigger(sm);
end

%TO032106E
if ~any(acqOnArray)
    acq_Stop(hObject);
end

% fprintf(1, 'acq_Start: ''700B-1_scaledOutput'':SamplesPerTrigger = %s\n', num2str(getAIProperty(getDaqmanager, '700B-1_scaledOutput', 'SamplesPerTrigger')));

return;

%------------------------------------------------------
% TO112205B: Wait for the trigger to set the status to 'Acquiring...'
% TO080906B: Record an individual trigger time in every program.
function triggerFcn_Callback(varargin)

%TO112205C
% analogObject = varargin{1};
% eventData = varargin{2};
hObject = varargin{1};

externallyTriggered(startmanager('acquisition'));%TO013106E
setLocalBatch(progmanager, hObject, 'status', 'Acquiring...', 'triggerTime', clock);%TO080906B
% fprintf(1, '%s - acq_Start/triggerFcn_Callback\n', datestr(now));

return;

%------------------------------------------------------
% TO100705H: Make sure multiple callbacks to stop don't step on new starts.
function stopFcn_Callback(varargin)
% fprintf(1, '%s - acq_Start/stopFcn_Callback - quitting (NO_OP)...\n', datestr(now));
return;
%TO112205C
% analogObject = varargin{1};
% eventData = varargin{2};

hObject = varargin{1};
startID = varargin{2};
if isnumeric(varargin{3})
    bufferName = varargin{3};
else
    bufferName = [];
end

if startID == getLocal(progmanager, hObject, 'startID')
    %This will block subsequent calls from being executed via the daq object's StopFcn.
    setLocal(progmanager, hObject, 'startID', rand);
    %TO123005C - Assume that all the data will get collected and that will trigger the GUI to stop. Errors should be handled elsewhere. (See TO123005D)
    if ~isempty(bufferName)
        buffers = getLocal(progmanager, hObject, 'saveBuffers');
        if length(buffers.(bufferName).data) == get(ai, 'SamplesPerTrigger')
            ephys_Stop(hObject);
        else
            flushInputChannel(getDaqmanager, ai.Channel(1).ChannelName);
        end
    end
end

return;

%------------------------------------------------------
% TO123005D: Stop the program, issue error messages.
function dataMissedFcn_Callback(hObject, channelName, varargin)

%This is the default behavior by Matlab, so execute this as well.
daqcallback(varargin{:});
fprintf(2, '%s - Error: acquirer missed data on channel ''%s''.', datestr(now), channelName);

acq_Stop(hObject);

return;

%------------------------------------------------------
% TO123005D: Stop the program, issue error messages.
function runtimeErrorFcn_Callback(hObject, channelName, varargin)

%This is the default behavior by Matlab, so execute this as well.
daqcallback(varargin{:});
fprintf(2, '%s - Error: acquirer encountered a runtime error for channel ''%s'' - %s', datestr(now), channelName, lasterr);

acq_Stop(hObject);

return;
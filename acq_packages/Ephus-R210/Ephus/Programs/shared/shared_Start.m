% shared_Start - Start an acquisition.
%
% SYNTAX
%  shared_Start(hObject)
%
% USAGE
%  Simply pass in the handle to the program and an acquisition will get started.
%
% NOTES
%  Adapted from ephys_Start.m. See TO101707F
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
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO101907A - Restarting for externalTrigger is now handled directly in nimex. -- Tim O'Connor 10/19/07
%  TO102307B - Check for no channels before executing a start command. -- Tim O'Connor 10/23/07
%  TO102507A - Typo, changed `length(scopeCount)` to `scopeCount` in the for-loop declaration. -- Tim O'Connor 10/25/07
%  TO043008E - Keep timestamps for each data append. -- Tim O'Connor 4/30/08
%  TO072208A - Allow multiple digital lines to appear separate in the GUI, but actually be grouped underneath. -- Tim O'Connor 7/22/08
%  TO073008A - Backed out TO072208A, moved that functionality into @daqjob. -- Tim O'Connor 7/30/08
%  TO121008B - Make sure the cell arrays' sizes are consistent for concatenation. -- Tim O'Connor 12/10/08
%  TO021510G - Added 'updatesPerTrace', to allow inputs to get updated more than once per trace. -- Tim O'Connor 2/15/10
%  TO021610A - Changed 'updatesPerTrace' to 'updateRate'. -- Tim O'Connor 2/15/10
%  TO021610C - Clear the trace window when starting a new acquisition. -- Tim O'Connor 2/16/10
%  TO021610E - Handle some idiotic problems with `cat(2, ...` not tolerating appending a cell array with only one element. -- Tim O'Connor 2/16/10
%  TO021610H - Added the displayWidth and autoDisplayWidth variables. -- Tim O'Connor 2/16/10
%  TO021610I - Make sure the oscilloscope is stopped before doing anything. -- Tim O'Connor 2/16/10
%  TO022010A - More special-case nonsense to handle the buffer configuration when using a non-conforming updateRate. -- Tim O'Connor 2/20/10
%  TO030210C - Created shared_resetBuffers, to centralize buffer initialization. -- Tim O'Connor 3/2/10
%  TO030210G - Made the amplifier/scope update conditional upon acqOn for that channel. -- Tim O'Connor 3/2/10
%  VI030310A - Check that ephysScopeAccessory is an active program, before trying to stop it. -- Tim O'Connor 3/3/10
%  TO031010A - Make sure the pulseJacker exists, before trying to probe its variables. GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
%  TO031010C - Fixed VI030310A to check for the correct program ('ScopeGui', not 'ephysScopeAccessory'). GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
%  TO033110E - Disable controls that are not updated while running. -- Tim O'Connor 3/31/10
%  TO032004C - Added the autoUpdateRate variable. -- Tim O'Connor 4/20/10
%  TO042010D - Enable/disable the updateRate and displayWidth handles, as a special case. -- Tim O'Connor 4/20/10
%  TO061110B - Only worry about the updateRate computation for input-enabled acquisitions. -- Tim O'Connor 6/11/10
%  TO072310A - The XSG needs to be flagged to know a new acquisition has been started when externally triggered. Not sure why this didn't come up many times before. -- Tim O'Connor 7/23/10
%
% Created 5/26/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function shared_Start(hObject)
% fprintf(1, '''%s''_Start\n%s', getProgramName(progmanager, hObject), getStackTraceString);
% fprintf(1, '%s - ''%s''_Start\n', datestr(now), getProgramName(progmanager, hObject));
% getStackTraceString
setLocal(progmanager, hObject, 'startButton', 1);
setLocalGh(progmanager, hObject, 'startButton', 'String', 'Stop', 'ForegroundColor', [1 0 0]);

%TO021610I - Make sure the oscilloscope is stopped before doing anything.
if isprogram(progmanager, 'ScopeGui') %VI030310A %TO031010C
    ephysAcc = getGlobal(progmanager, 'hObject', 'ephysScopeAccessory', 'ScopeGui');
    if getLocal(progmanager, ephysAcc, 'startButton')
        setLocal(progmanager, ephysAcc, 'startButton', 0);
        ephysScopeAccessory('startButton_Callback', ephysAcc, [], guidata(ephysAcc));
    end
end

programName = getProgramName(progmanager, hObject);
%TO123005G
fireEvent(getUserFcnCBM, [programName ':Start'], hObject);%TO120505B, TO010506D

% drawnow expose;%TO100705I %TO042309A - Not using expose can cause C-spawned events to fire out of order.
[traceLength, sampleRate, amplifiers, channels, sc, externalTrigger, boardBasedTimingEvent, acqOnArray, stimOnArray, traceLengthArray, ...
    segmentedAcquisition, buffers, updateRate, displayWidth, autoDisplayWidth, disableHandles, autoUpdateRate] = getLocalBatch(progmanager, hObject, ...
    'traceLength', 'sampleRate', 'amplifiers', 'channels', 'scopeObject', 'externalTrigger', 'boardBasedTimingEvent', 'acqOnArray', 'stimOnArray', 'traceLengthArray', ...
    'segmentedAcquisition', 'saveBuffers', 'updateRate', 'displayWidth', 'autoDisplayWidth', 'disableHandles', 'autoUpdateRate');%TO031306A %TO031306B %TO062806C %TO080206A %TO032106D %TO033110E %TO032004C

%TO033110E - Disable controls that are not updated while running. -- Tim O'Connor 3/31/10
set(disableHandles, 'Enable', 'Off');

%repetitions = 0;%TO031306A
repeatOutput = 0;%TO081606B %TO082206A
%TO031306A - Cache the total time for the trace.
samplesPerTrace = ceil(traceLength * sampleRate);
outputSampsPerChanToAcquire = samplesPerTrace;
inputSampsPerChanToAcquire = samplesPerTrace;
if ~isempty(boardBasedTimingEvent)
    %Here's the one bit of coded needed to play nice with the pulseJacker.
    %TO031010A - Make sure the pulseJacker exists.
    if isprogram(progmanager, 'pulseJacker')
        if ~getGlobal(progmanager, 'enable', 'pulseJacker', 'pulseJacker')
            repeatOutput = boardBasedTimingEvent.totalIterations;%TO082206A %TO082406A
            %repetitions = boardBasedTimingEvent.totalIterations;
        else
            outputSampsPerChanToAcquire = samplesPerTrace * boardBasedTimingEvent.totalIterations;
        end
    else
        outputSampsPerChanToAcquire = samplesPerTrace * boardBasedTimingEvent.totalIterations;
    end
    inputSampsPerChanToAcquire = samplesPerTrace * boardBasedTimingEvent.totalIterations;
end

%TO042010C
if autoUpdateRate
    updateRate = 1 / traceLength;
    setLocal(progmanager, hObject, 'updateRate', updateRate);
end

%TO022010A - More special-case nonsense to handle the buffer configuration when using a non-conforming updateRate. -- Tim O'Connor 2/20/10
samplePerTraceLimit = 16384000;%16777216 or 33554432 maximum, due to hardware constraints. Value chosen such that a 64x64 map taken at 10kHz won't switch modes.
everyN = samplesPerTrace;
samplesPerUpdate = min(samplesPerTrace, max(round(sampleRate / 5), round(sampleRate / updateRate)));%Try something simple, assuming it works out to an integer naturally.
if inputSampsPerChanToAcquire <= samplePerTraceLimit && (samplesPerTrace / samplesPerUpdate) ~= round(samplesPerTrace / samplesPerUpdate)
    %TO022010A - The real meat of the changes are here.
    updateIntervalRatio = traceLength / updateRate;
    samplesPerUpdate = floor(samplesPerTrace / floor(updateIntervalRatio));%Should produce an integer, which is equal to the number of updates per trace.
    %TO061110B - Only worry about this computation for input-enabled acquisitions. -- Tim O'Connor 6/11/10
    if any(acqOnArray) && (samplesPerTrace / samplesPerUpdate) ~= round(samplesPerTrace / samplesPerUpdate)
        fprintf(1, '%s - ''%s''_Start: Could not find a suitable samplesPerUpdate value, defaulting to 1 update per trace.\n', datestr(now), getProgramName(progmanager, hObject));
        samplesPerUpdate = samplesPerTrace;
    end
end
% samplesPerUpdate = samplesPerTrace;
triggerRepeat = 0;

% if inputSampsPerChanToAcquire > 16777216
%     fprintf(2, 'The maximum number of input samples per acquisition is 33554432. The recording will be truncated to %s seconds.\n', num2str(16777216 / sampleRate));
%     inputSampsPerChanToAcquire = 16777216;%33554432
% end
% if outputSampsPerChanToAcquire > 33554432
%     fprintf(2, 'The maximum number of output samples per acquisition is 33554432. The recording will be truncated to %s seconds.\n', num2str(33554432 / sampleRate));
%     outputSampsPerChanToAcquire = 33554432;
% end
% inputSampleRatio = inputSampsPerChanToAcquire / samplesPerUpdate;

% if inputSampleRatio ~= floor(inputSampleRatio)
%     samplesPerUpdate = floor(inputSampsPerChanToAcquire / inputSampleRatio);
% end

job = daqjob('acquisition');
setTriggerRepeats(job, triggerRepeat);
bindEventListener(job, 'jobTrigger', {@triggerFcn_Callback, hObject}, [programName '_Start']);%TO112205C, TO120205A
bindEventListener(job, 'jobStop', {@stopFcn_Callback, hObject}, [programName '_Start']);
bindEventListener(job, 'jobDone', {@doneFcn_Callback, hObject}, [programName '_Start']);

%Configure outputs, as needed.
if any(stimOnArray)
    outputChannels = shared_getOutputChannelNames(hObject);
    setLocal(progmanager, hObject, 'continuousAcqMode', 0);
    for i = 1 : length(outputChannels)
        %TO101907A
        setTaskProperty(job, outputChannels{i}, 'autoRestart', 0, 'samplingRate', sampleRate', 'sampsPerChanToAcquire', outputSampsPerChanToAcquire, 'everyNSamples', everyN, 'repeatOutput', repeatOutput);
        % setTaskProperty(job, outputChannels{i}, 'autoRestart', 0, 'samplingRate', sampleRate', 'sampsPerChanToAcquire', outputSampsPerChanToAcquire, 'everyNSamples', everyN, 'repeatOutput', 0);%TO102307E - No repeatOutput, for now...
    end
    shared_updateOutputSignals(hObject);%TO091405A
else
    outputChannels = {};
end

%Configure inputs, as needed.
if ~isempty(acqOnArray)
    inputChannels = shared_getInputChannelNames(hObject);

    setLocal(progmanager, hObject, 'continuousAcqMode', 0);
    for i = 1 : length(inputChannels)
        %TO101907A
        setTaskProperty(job, inputChannels{i}, 'autoRestart', externalTrigger, 'samplingRate', sampleRate', 'sampsPerChanToAcquire', inputSampsPerChanToAcquire, ...
            'everyNSamples', samplesPerUpdate, 'sampleMode', 'DAQmx_Val_FiniteSamps');
        if inputSampsPerChanToAcquire > samplePerTraceLimit
            fprintf(1, '%s - ''%s''_sharedStart: Starting acquisition on continuous mode.\n', datestr(now), getProgramName(progmanager, hObject));
            setTaskProperty(job, inputChannels{i}, 'sampleMode', 'DAQmx_Val_ContSamps', 'sampsPerChanToAcquire', 10 * samplesPerUpdate);
            setLocal(progmanager, hObject, 'continuousAcqMode', 1);
        end
    end

    %TO032106E %TO032306B
    if isempty(amplifiers)
        scopeCount = length(channels);
    else
        scopeCount = length(amplifiers);
    end

    if ~isempty(amplifiers)
        for i = 1 : length(amplifiers)
            %TO032106D
            bufferName = ['trace_' num2str(i)];
            if isempty(buffers)
                buffers = shared_resetBuffer(buffers, bufferName, '', get(amplifiers{i}, 'name'), sampleRate);%TO030210C
            elseif ~isfield(buffers, bufferName)
                buffers = shared_resetBuffer(buffers, bufferName, '', get(amplifiers{i}, 'name'), sampleRate);%TO030210C
            elseif ~acqOnArray(i)
                buffers = shared_resetBuffer(buffers, bufferName, '', get(amplifiers{i}, 'name'), sampleRate);%TO030210C
            else
                %Make sure the name is in sync with whatever's displayed in the gui.
                buffers.(bufferName).amplifierName = get(amplifiers{i}, 'name');%TO120205A
            end
            buffers.(bufferName).resetOnNextSamplesAcquired = 1;
        end
    else
        for i = 1 : length(channels)
            %TO032106D
            bufferName = ['trace_' num2str(i)];
            if isempty(buffers)
                buffers = shared_resetBuffer(buffers, bufferName, channels(i).channelName, '', sampleRate);%TO030210C
            elseif ~isfield(buffers, bufferName)
                buffers = shared_resetBuffer(buffers, bufferName, channels(i).channelName, '', sampleRate);%TO030210C
            elseif ~acqOnArray(i)
                buffers = shared_resetBuffer(buffers, bufferName, channels(i).channelName, '', sampleRate);%TO030210C
            else
                %Make sure the name is in sync with whatever's displayed in the gui.
                buffers.(bufferName).channelName = channels(i).channelName;%TO120205A
                buffers.(bufferName).sampleRate = sampleRate;
            end
            buffers.(bufferName).resetOnNextSamplesAcquired = 1;
        end
    end

    %TO102507A
    for i = 1 : scopeCount
        %TO100405C: Make sure the scopes are visible.
        %TO032906C
        if acqOnArray(i)
            set(sc(i), 'Visible', 'On');%TO033106F
            if ~isempty(amplifiers) %TO030210G
                update(amplifiers{i});%TO120205A
                if get(amplifiers{i}, 'current_clamp')
                    set(sc(i), 'yUnitsString', 'mV', 'gridOn', 0);
                else
                    set(sc(i), 'yUnitsString', 'pA', 'gridOn', 0);
                end
            end
            %TO021610C - This is back, again. %TO030210G - Moved over from its own loop.
            if ~get(sc(i), 'holdOn')
                clearData(sc(i));
            end
            %TO062806C %TO021610H %TO030210G - Moved.
            if autoDisplayWidth
                if isempty(traceLengthArray)
                    set(sc(i), 'xUnitsPerDiv', traceLength / 10);
                else
                    set(sc(i), 'xUnitsPerDiv', min(traceLengthArray(acqOnArray)) / 10);
                end
            else
                set(sc(i), 'xUnitsPerDiv', displayWidth / 10);
            end
        else
            %TO030210G - Only get the figure handle if acqOn is true for this channel.
            f = get(sc(i), 'figure');
            if strcmpi(get(f, 'Visible'), 'Off')
                %TO040706C
                set(sc(i), 'Visible', 'Off');
            end
        end
    end
else
    inputChannels = {};
end

if ~isempty(acqOnArray)
    setLocal(progmanager, hObject, 'sampleCount', zeros(size(acqOnArray)));
else
    setLocal(progmanager, hObject, 'sampleCount', zeros(size(stimOnArray)));
end

try
    %TO102307B - Check for no channels.
    if ~isempty(inputChannels) || ~isempty(outputChannels)
        if size(outputChannels, 1) > size(outputChannels, 2)
            outputChannels = outputChannels';
        end

        %TO121008B - Make sure the cell arrays' sizes are consistent for concatenation. -- Tim O'Connor 12/10/08
        if size(inputChannels, 1) > size(inputChannels, 2)
            if size(outputChannels, 1) < size(outputChannels, 2)
                outputChannels = outputChannels';
            end
        else
            if size(outputChannels, 1) > size(outputChannels, 2)
                outputChannels = outputChannels';
            end
        end
        
        %TO021610E - Handle some idiotic problems with `cat(2, ...` not tolerating appending a cell array with only one element.
        if numel(inputChannels) > 1 && numel(outputChannels) == 1
            channelNames = inputChannels;
            channelNames{end + 1} = outputChannels{1};
        elseif numel(inputChannels) == 1 && numel(outputChannels) > 1
            channelNames = outputChannels;
            channelNames{end + 1} = inputChannels{1};
        else
            channelNames = cat(2, inputChannels, outputChannels);
        end
        start(job, channelNames{:});
    end

    setLocalBatch(progmanager, hObject, 'saveBuffers', buffers, 'acquiring', 1, 'status', 'Waiting...');%TO100705F, TO100705H, TO112205B
catch
    err = lasterror;
    fprintf(2, '''%s''_Start - Error - Failed to start channels on @daqjob object: %s\n%s', getProgramName(progmanager, hObject), lasterr, getStackTraceString(err.stack));
    setLocalBatch(progmanager, hObject, 'status', '', 'startButton', 0);%TO031306B: Batch these calls.
    setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0 0.6 0]);
    setLocalGh(progmanager, hObject, 'externalTrigger', 'ForegroundColor', [0 0.6 0]);
    %TO033110E - Disable controls that are not updated while running. -- Tim O'Connor 3/31/10
    set(disableHandles, 'Enable', 'On');
    %TO042010D - Update these two handles, as a special case. -- Tim O'Connor 4/20/10
    if any(strcmpi(getProgramName(progmanager, hObject), {'ephys', 'acquirer'}))
        if autoUpdateRate
            setLocalGh(progmanager, hObject, 'updateRate', 'Enable', 'Off');
        end
        if autoDisplayWidth
            setLocalGh(progmanager, hObject, 'displayWidth', 'Enable', 'Off');
        end
    end
    try
        stop(job, inputChannels{:}, outputChannels{:});
    catch
    end
end
if ~externalTrigger
    try
        trigger(job);
    catch
        fprintf(2, '''%s''_Start - Error - Failed to trigger acquisition.\n', getProgramName(progmanager, hObject));
    end
end

return;

%------------------------------------------------------
% TO112205B: Wait for the trigger to set the status to 'Acquiring...'
% TO080906B: Record an individual trigger time in every program.
function triggerFcn_Callback(hObject, channels)
% lg = lg_factory;
% fprintf(1, '\n=================\niteration: %s\n', num2str(getLocal(progmanager, lg, 'iterationCounter')));
% fprintf(1, '%s - ''%s''_Start/triggerFcn_Callback\n', datestr(now), getProgramName(progmanager, hObject));
% getAO(getDaqmanager, '700A-1-VCom')
%TO112205C
% analogObject = varargin{1};
% eventData = varargin{2};
[startButton] = getLocalBatch(progmanager, hObject, 'startButton');
if startButton
    setLocalBatch(progmanager, hObject, 'status', 'Working...', 'triggerTime', clock);%TO080906B
end
% fprintf(1, '%s - ''%s''_Start/triggerFcn_Callback\n', datestr(now), getProgramName(progmanager, hObject));

return;

%------------------------------------------------------
% TO100705H: Make sure multiple callbacks to stop don't step on new starts.
function stopFcn_Callback(hObject, channels)
% fprintf(1, '%s - ''%s''_Start/stopFcn_Callback - quitting (NO_OP)...\n', datestr(now), getProgramName(progmanager, hObject));

% shared_Stop(hObject);
% setLocalBatch(progmanager, hObject, 'status', '', 'startButton', 0);%TO031306B: Batch these calls.
% setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0 0.6 0]);
% setLocalBatch(progmanager, hObject, 'segmentedAcquisition', 0, 'acquisitionsRemainingCounter', 0);

return;

%------------------------------------------------------
function doneFcn_Callback(hObject, channels)
% fprintf(1, '%s - ''%s''_Start/doneFcn_Callback\n', datestr(now), getProgramName(progmanager, hObject));

[traceLength, sampleRate, externalTrigger, boardBasedTimingEvent, resetTaskWhenDone] = getLocalBatch(progmanager, hObject, ...
    'traceLength', 'sampleRate', 'externalTrigger', 'boardBasedTimingEvent', 'resetTaskWhenDone');

if ~externalTrigger
    shared_Stop(hObject);
else
% fprintf(1, '%s - ''%s''_Start/doneFcn_Callback: Detected external trigger.\n', datestr(now), getProgramName(progmanager, hObject));
    if ~isempty(boardBasedTimingEvent) || resetTaskWhenDone
% fprintf(1, '%s - ''%s''_Start/doneFcn_Callback: Resetting tasks via @daqjob...\n', datestr(now), getProgramName(progmanager, hObject));
        outputChannels = shared_getOutputChannelNames(hObject);
        setLocalBatch(progmanager, hObject, 'boardBasedTimingEvent', [], 'resetTaskWhenDone', resetTaskWhenDone);
        try
            if ~isempty(outputChannels)
                job = daqjob('acquisition');
                % commit(job, outputChannels{:});
                stop(job, outputChannels{:});
                start(job, outputChannels{:});
            end
        catch
            err = lasterror;
            fprintf(2, '%s - ''%s''_Start/doneFcn_Callback - Failed to restart channel(s) for external triggering: %s\n%s', ...
                datestr(now), getProgramName(progmanager, hObject), lasterr, getStackTraceString(err.stack));
        end
%         setLocalBatch(progmanager, hObject, 'boardBasedTimingEvent', [], 'resetTaskWhenDone', resetTaskWhenDone);
%         samplesPerTrace = ceil(traceLength * sampleRate);
%         job = daqjob('acquisition');
%         inputChannels = shared_getInputChannelNames(hObject);
%         outputChannels = shared_getOutputChannelNames(hObject);
%         try
%             stop(job, inputChannels{:}, outputChannels{:});
%             for i = 1 : length(inputChannels)
%                 setTaskProperty(job, inputChannels{i}, 'autoRestart', 1, 'sampsPerChanToAcquire', samplesPerTrace, 'everyNSamples', samplesPerTrace);
%             end
%             for i = 1 : length(outputChannels)
%                 setTaskProperty(job, outputChannels{i}, 'autoRestart', 0, 'sampsPerChanToAcquire', samplesPerTrace, 'everyNSamples', samplesPerTrace, 'repeatOutput', 0);
%             end
%             start(job, inputChannels{:}, outputChannels{:});
%         catch
%             fprintf(2, '%s - ''%s''_Start/doneFcn_Callback - Failed to restart channels for external triggering: %s\n', ...
%                 datestr(now), getProgramName(progmanager, hObject), lasterr);
%         end
    else
% fprintf(1, '%s - ''%s''_Start/doneFcn_Callback: Resetting via NIMEX...\n', datestr(now), getProgramName(progmanager, hObject));
        outputChannels = shared_getOutputChannelNames(hObject);
        if ~isempty(outputChannels)
            job = daqjob('acquisition');
            tasks = unique(getTasksByChannelNames(job, outputChannels{:}));
            for i = 1 : length(tasks)
                try
                    nimex_stopTask(tasks(i));
                    nimex_startTask(tasks(i));
                    %TO072310A - This may not be the best way to do this, but it'll work for now. The XSG needs to know a new acquisition has begun. -- Tim O'Connor 7/23/10
                    fireEvent(getCallbackManager(daqjob('acquisition')), 'jobStart', outputChannels);
                catch
                    err = lasterror;
                    fprintf(2, '%s - ''%s''_Start/doneFcn_Callback - Failed to restart channel(s) for external triggering: %s\n%s', ...
                        datestr(now), getProgramName(progmanager, hObject), lasterr, getStackTraceString(err.stack));
                end
            end
        end
        
        inputChannels = shared_getInputChannelNames(hObject);
        if ~isempty(inputChannels)
            job = daqjob('acquisition');
            tasks = unique(getTasksByChannelNames(job, inputChannels{:}));
            for i = 1 : length(tasks)
                try
                    nimex_stopTask(tasks(i));
                    nimex_startTask(tasks(i));
                    %TO072310A - This may not be the best way to do this, but it'll work for now. The XSG needs to know a new acquisition has begun. -- Tim O'Connor 7/23/10
                    fireEvent(getCallbackManager(daqjob('acquisition')), 'jobStart', inputChannels);
                catch
                    err = lasterror;
                    fprintf(2, '%s - ''%s''_Start/doneFcn_Callback - Failed to restart channel(s) for external triggering: %s\n%s', ...
                        datestr(now), getProgramName(progmanager, hObject), lasterr, getStackTraceString(err.stack));
                end
            end
        end
    end
end

%TO101607F - Just call shared_Stop now. -- Tim O'Connor 10/16/07
% outputChannels = shared_getAllOutputChannelNames(hObject);
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

% fprintf(1, '%s - ''%s''_Start/samplesOutputFcn_Callback: Transmitted %s of %s samples.\n', datestr(now), getProgramName(progmanager, hObject), ...
%     num2str(get(daqobj, 'SamplesOutput')), num2str(expectedSampleCount));
% fprintf(1, '^^^^^^^^^^^^^^^^^^^^^ Elapsed Time: %s\n', num2str(etime(clock, get(startmanager('acquisition'), 'TriggerTime'))));
% daqobj
% get(daqobj)

%TO082506C
fireEvent(getUserFcnCBM, [getProgramName(progmanager, hObject) ':SamplesOutput'], channelName);%TO082806A

return;


% stim_Start - Start an acquisition.
%
% SYNTAX
%  stim_Start(hObject)
%
% USAGE
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
%  TO123005D - Process error events with the RuntimeErrorFcn and property. -- Tim O'Connor 12/30/05
%  TO123005G - Implement various userFcn calls. -- Tim O'Connor 12/30/05
%  TO010506D - Enabling/disabling of UserFcn callbacks is handled by the callbackManager object directly. -- Tim O'Connor 1/5/06
%  TO011906C - Stopping all channels results in loss of data collection in other programs. Rely on them to stop themselves. -- Tim O'Connor 1/19/06
%  TO012706B - Implemented the expectedDataSinks list in the @startmanager. -- Tim O'Connor 1/27/06
%  TO013106E - Added the 'externallyTriggered' field in @startmanager to keep track of external hardware triggered starts. -- Tim O'Connor 1/31/06
%  TO031306A: Implemented board-based (precise) timing. As only one trigger is issued, cycles have no effect. -- Tim O'Connor 3/13/06
%  TO031506A: Implement a SamplesOutputFcn, to handle premature calls to the StopFcn when executing board-based (precise) loop timing. -- Tim O'Connor 3/15/06
%  TO062806C - Implement "turbo" cycles, allow for multiple traces to be chained. -- Tim O'Connor 6/28/06
%  TO080206C - Renamed variables for clarity: outputTime-->traceLength -- Tim O'Connor 8/3/06
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
%  TO090506F - Update the status to 'Waiting...' when being pulse hijacked. -- Tim O'Connor 9/5/06
%
% Created 11/21/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function stim_Start(hObject)
% fprintf(1, '%s - stim_Start\n', datestr(now));
%  getStackTraceString
% global stim_Start_counter;
% stim_Start_counter = stim_Start_counter + 1;
% fprintf(1, 'stim_Start_counter: %s\n%s', num2str(stim_Start_counter), getStackTraceString);
setLocal(progmanager, hObject, 'startButton', 1);
setLocalGh(progmanager, hObject, 'startButton', 'String', 'Stop', 'ForegroundColor', [1 0 0]);

%TO123005G
fireEvent(getUserFcnCBM, 'stim:Start', hObject);%TO120505B, TO010506D

[traceLength, sampleRate, channels, aom, boardBasedTimingEvent, traceLengthArray, segmentedAcquisition] = getLocalBatch(progmanager, hObject, ...
    'traceLength', 'sampleRate', 'channels', 'aomux', 'boardBasedTimingEvent', 'traceLengthArray', 'segmentedAcquisition');%TO031306A %TO062806C %TO080206A
repetitions = 0;%TO031306A
repeatOutput = 0;%TO081606B %TO082206A
if ~isempty(boardBasedTimingEvent)
    repeatOutput = boardBasedTimingEvent.totalIterations - 1;%TO082206A %TO082406A
    repetitions = boardBasedTimingEvent.totalIterations;%TO031306A
    expectedSampleCount = ceil(traceLength * sampleRate) * repetitions;
else
    expectedSampleCount = ceil(traceLength * sampleRate);
end

% fprintf(1, 'stim_Start -\n expectedSampleCount: %s\n repetitions: %s\n traceLength: %s\n%s\n', ...
%     num2str(expectedSampleCount), num2str(repetitions), num2str(traceLength), getStackTraceString);

set(aom, 'outputTime', traceLength);

%TO062806C
if ~isempty(traceLengthArray)
    repeatOutput = length(traceLengthArray) - 1;%TO081606B
    if segmentedAcquisition
        setLocal(progmanager, hObject, 'transmissionsRemainingCounter', length(traceLengthArray));
        repetitions = length(traceLengthArray) - 1;%TO081406A
        repeatOutput = 0;%TO081606B
    else
        traceLength = sum(traceLengthArray);
    end
    expectedSampleCount = ceil(traceLength * sampleRate);
end

outputChannels = stim_getOutputChannelNames(hObject);

stim_updateOutputSignals(hObject);%TO091405A

dm = getDaqmanager;

startID = rand;

channels = getLocal(progmanager, hObject, 'channels');
for i = 1 : length(outputChannels)
    setAOProperty(dm, outputChannels{i}, 'SampleRate', sampleRate, 'TriggerType', 'HwDigital', 'RepeatOutput', repeatOutput, ...
        'RuntimeErrorFcn', {@runtimeErrorFcn_Callback, hObject, outputChannels{i}}, 'SamplesOutputFcnCount', expectedSampleCount, ...
        'SamplesOutputFcn', {@samplesOutputFcn_Callback, hObject, startID, expectedSampleCount * (repetitions + 1), outputChannels{i}});%TO100705H, TO112205B, TO112205C, TO123005D, TO031306A, TO031506A, TO081606B
%     setChannelStartListener(dm, outputChannels{i}, {@testFcn_Callback, 'StartFcn'}, 'stim_Start');%TO112205C
    setChannelStopListener(dm, outputChannels{i}, {@stopFcn_Callback, hObject, startID, expectedSampleCount}, 'stim_Start');%TO112205C, TO031506A
%     setChannelTriggerListener(dm, outputChannels{i}, {@testFcn_Callback, 'TriggerFcn'}, 'stim_Start');%TO112205C
    setChannelTriggerListener(dm, outputChannels{i}, {@triggerFcn_Callback, hObject}, 'stim_Start');%TO112205C
end

setLocalBatch(progmanager, hObject, 'transmitting', 1, 'status', 'Waiting...', 'startID', startID);%TO100705F, TO100705H

% setLocal(progmanager, hObject, 'status', 'Acquiring...');%TO100705F

sm = startmanager('acquisition');

%stopChannel(getDaqmanager, getQueue(sm));%Make sure none of the channels are already running. %Removed TO011906C
% ao = getAO(dm, 'shutter0')
% getStackTraceString

enqueue(sm, outputChannels{:});
% addExpectedDataSink(sm, 'stim');%TO012706B
if getLocal(progmanager, hObject, 'selfTrigger')
    trigger(sm);
end

% ao
% get(ao)

% fprintf(1, '\n\nstim_Start: COMPLETED\n\n\n');

return;

%------------------------------------------------------
% TO112205B: Wait for the trigger to set the status to 'Transmitting...'
% TO112205C - Implement @daqmanager listeners using the @callbackManager.
% TO080906B: Record an individual trigger time in every program.
function triggerFcn_Callback(hObject, channelName, daqobj, eventdata)
% fprintf(1, 'stim_Start/triggerFcn_Callback\n');
% getAO(getDaqmanager, 'shutter0')
externallyTriggered(startmanager('acquisition'));%TO013106E
setLocalBatch(progmanager, hObject, 'status', 'Transmitting...', 'triggerTime', clock);%TO080906B

return;

%------------------------------------------------------
function testFcn_Callback(arg, arg2, daqobj, eventdata)

fprintf(1, '%s - testFcn_Callback: %s\n', datestr(now), arg);

return;

%------------------------------------------------------
% TO100705H: Make sure multiple callbacks to stop don't step on new starts.
% TO112205C - Implement @daqmanager listeners using the @callbackManager.
function stopFcn_Callback(hObject, startID, expectedSampleCount, channelName, daqobj, eventdata)

% fprintf(1, '%s - stim_Start/stopFcn_Callback\n', datestr(now));
% fprintf(1, '^^^^^^^^^^^^^^^^^^^^^ Elapsed Time: %s\n', num2str(etime(clock, get(startmanager('acquisition'), 'TriggerTime'))));
% daqobj
% get(daqobj)

%TO031506A: Make sure all samples have been put out. -- Tim O'Connor 3/15/06
if startID == getLocal(progmanager, hObject, 'startID') & get(daqobj, 'SamplesOutput') >= expectedSampleCount
    %This will block subsequent calls from being executed via the daq object's StopFcn.
    setLocal(progmanager, hObject, 'startID', rand);
    stim_Stop(hObject);
end

return;

%------------------------------------------------------
% TO123005D: Stop the program, issue error messages.
function runtimeErrorFcnFcn_Callback(hObject, channelName, varargin)

%This is the default behavior by Matlab, so execute this as well.
daqcallback(varargin{:});
fprintf(2, '%s - Error: stimulator encountered a runtime error for channel ''%s'' - %s', datestr(now), channelName, lasterr);

stim_Stop(hObject);

return;

%------------------------------------------------------
% TO031506A: Track samples output, to figure out when to stop.
function samplesOutputFcn_Callback(daqobj, eventdata, hObject, startID, expectedSampleCount, channelName)

% fprintf(1, '%s - stim_Start/samplesOutputFcn_Callback: Transmitted %s of %s samples.\n', datestr(now), ...
%     num2str(get(daqobj, 'SamplesOutput')), num2str(expectedSampleCount));
% fprintf(1, '^^^^^^^^^^^^^^^^^^^^^ Elapsed Time: %s\n', num2str(etime(clock, get(startmanager('acquisition'), 'TriggerTime'))));
% daqobj
% get(daqobj)

%TO082506C
fireEvent(getUserFcnCBM, 'stim:SamplesOutput', channelName);%TO082806A

[segmentedAcquisition, transmissionsRemainingCounter, aom, traceLength, pulseHijacked] = getLocalBatch(progmanager, hObject, 'segmentedAcquisition', ...
    'transmissionsRemainingCounter', 'aomux', 'traceLength', 'pulseHijacked');%TO080306A %TO082806A

if pulseHijacked
    setLocalBatch(progmanager, hObject, 'status', 'Waiting...');%TO090506F
end

if startID == getLocal(progmanager, hObject, 'startID') & get(daqobj, 'SamplesOutput') >= expectedSampleCount
    %This will block subsequent calls from being executed via the daq object's StopFcn.
    setLocal(progmanager, hObject, 'startID', rand);
    stim_Stop(hObject);
elseif segmentedAcquisition
    transmissionsRemainingCounter = transmissionsRemainingCounter - 1;
    setLocalBatch(progmanager, hObject, 'transmissionsRemainingCounter', transmissionsRemainingCounter, 'status', 'Waiting...');%TO081606C
    %TO082806A
    if transmissionsRemainingCounter >= 1 & ~pulseHijacked
% fprintf(1, '%s - stim_Start/samplesOutputFcn_Callback: Restarting object...\n', datestr(now));
        startFcn = get(daqobj, 'StartFcn');
        stopFcn = get(daqobj, 'StopFcn');
        set(daqobj, 'StopFcn', '');
        dm = getDaqmanager;
        if length(daqobj.Channel) > 1
            channelNames = daqobj.Channel.ChannelName;
            if strcmpi(class(channelNames), 'char')
                channelNames = {channelNames};
            end
        else
            channelNames = {channelName};
        end
        for i = 1 : length(channelNames)
            channelName = channelNames{i};
            sig = getSignal(aom, channelName);%TO081106C
            kids = get(sig, 'Children');
            data{i} = applyPreprocessor(aom, channelName, getdata(kids(length(kids) - transmissionsRemainingCounter + 1), traceLength));%TO081806A
% fprintf(1, 'stim_Start/samplesOutputFcn_Callback: Accessing pulse ''%s'' for channel ''%s''\n', get(kids(length(kids) - transmissionsRemainingCounter + 1), 'Name'), channelName);
% if strcmpi(channelName, 'pockelsCell')
%     figure, plot(getdata(kids(length(kids) - transmissionsRemainingCounter + 1), traceLength)), title('Raw Pulse Data');
% %     kids(length(kids) - transmissionsRemainingCounter + 1)
% end
        end
        
        putDaqDataRetriggered(dm, channelNames, data);
%         set(dm, 'restartingChannelForChannelAddition', 1);
%         stop(daqobj);
%         %TO082806B: Handle multiple channels on a single board (1 SamplesOutput event per board). -- Tim O'Connor 8/29/06
%         if length(daqobj.Channel) > 1
%             channelNames = daqobj.Channel.ChannelName;
%             if strcmpi(class(channelNames), 'char')
%                 channelNames = {channelNames};
%             end
%         else
%             channelNames = {channelName};
%         end
%         for i = 1 : length(channelNames)
%             channelName = channelNames{i};
%             sig = getSignal(aom, channelName);%TO081106C
%             kids = get(sig, 'Children');
%             data = applyPreprocessor(aom, channelName, getdata(kids(length(kids) - transmissionsRemainingCounter + 1), traceLength));%TO081806A
%             putDaqData(dm, channelName, data);
% fprintf(1, 'stim_Start/samplesOutputFcn_Callback: Accessing pulse ''%s'' for channel ''%s''\n', get(kids(length(kids) - transmissionsRemainingCounter + 1), 'Name'), channelName);
%             updateOutputData(dm, channelName);%TO081406A
%         end
%         set(daqobj, 'StartFcn', startFcn, 'StopFcn', stopFcn);
%         start(daqobj);
%         set(dm, 'restartingChannelForChannelAddition', 0);
% fprintf(1, 's - stim_Start/samplesOutputFcn_Callback: Restarted object.\n', datestr(now));
    elseif ~pulseHijacked
% fprintf(1, '%s - stim_Start/samplesOutputFcn_Callback: Stopping segmented acquisition...\n', datestr(now));
        setLocal(progmanager, hObject, 'startID', rand);
        stim_Stop(hObject);
    end
end

return;
% acq_Stop - Stop an acquisition.
%
% SYNTAX
%  acq_Stop(hObject)
%  acq_Stop(analogObject, eventData, hObject) - For use as a StopFcn callback.
%
% USAGE
%
% NOTES
%  This is a copy & paste job from ephys_Stop.m, with some editting where necessary.
%
% CHANGES
%  TO092605K: Watch out for array shapes in channel lists (`cat` barfs over dimensions) -- Tim O'Connor 9/26/05
%  TO100705F: Set a flag ('acquiring'), and rely on it, to determine the status of the program. This will optimize stopping. -- Tim O'Connor 10/7/05
%  TO100705G: This was outside the if statement, which means it got used twice sometimes. -- Tim O'Connor 10/7/05
%  TO100705I: Make sure displays are updated throughout a loop. -- Tim O'Connor 10/7/05
%  TO101105C: Flush the data before stopping the acquisition, otherwise stopping via the daqmanager deletes the data when it removes the channels. -- Tim O'Connor 10/11/05
%  TO112205D: Dequeue channels when stopped. -- Tim O'Connor 11/22/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO120505B: Begin implementation of user functions (phase it in as a command-line utility then add the GUI interface). -- Tim O'Connor 12/5/05
%  TO121305B: Wait for all data to flush into the buffer. -- Tim O'Connor 12/12/05
%  TO123005B: Allow acq_configureAimux/recordAcquirerData to initiate automatic saving of data. -- Tim O'Connor 12/30/05
%  TO123005C: Rely on acq_Start/stopFcn_Callback to handle board initiated stopping. -- Tim O'Connor 12/30/05
%  TO010506C: Rework triggering scheme for ease of use and simpler looping. Switch to a checkbox for external, which leaves it always started. -- Tim O'Connor 1/5/06
%  TO010506D: Enabling/disabling of UserFcn callbacks is handled by the callbackManager object directly. -- Tim O'Connor 1/5/06
%  TO010606C: All the flushing should be handled inside the daqmanager, no need to check with an external loop. Obsoletes TO121305B. -- Tim O'Connor 1/6/06
%  TO011706A: Fixed case sensitivity for Matlab 7.1. -- Tim O'Connor 1/17/06
%  TO012606B - Implemented the expectedDataSourceList variable in the xsg. -- Tim O'Connor 1/26/06
%  TO012706B - Moved the expectedDataSourceList into the @startmanager. -- Tim O'Connor 1/27/06
%  TO031005H: Remove some of the button dancing by not resetting the state if things are externally triggered. -- Tim O'Connor 3/11/06
%  TO031306A: Implemented board-based (precise) timing. As only one trigger is issued, cycles have no effect. -- Tim O'Connor 3/13/06
%  TO031306B: Batched up some `setLocal` calls. -- Tim O'Connor 3/13/06
%  TO031306G: Try doing away with calls to `flushAllInputChannels`, and make sure any calls that do exist come before checking the trigger type. -- Tim O'Connor 3/13/06
%  TO033106D: Remove all calls to flushInputChannel, the semaphores should handle all of this cleanly now. -- Tim O'Connor 3/31/06
%  TO080306A: Allow multiple acquisitions to be prequeued, and sequentially triggered. -- Tim O'Connor 8/3/06
%
% Created 12/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function acq_Stop(varargin)
% fprintf(1, 'acq_Stop\n');
% getStackTraceString
if length(varargin) == 1
    hObject = varargin{1};
    %TO100705F: Set a flag, and rely on it, to determine the status of the program. This will optimize stopping.
    if ~getLocal(progmanager, hObject, 'acquiring')
        return;
    end
    
    inputChannels = acq_getInputChannelNames(hObject);   
    channelNames = inputChannels;
%TO123005C - This should never be called, now that acq_Start/stopFcn_Callback is filtering the arguments. -- Tim O'Connor 13/20/05
% elseif length(varargin) == 3
%     analogObject = varargin{1};
%     eventData = varargin{2};
%     hObject = varargin{3};
%     
%     %TO100705F: Set a flag, and rely on it, to determine the status of the program. This will optimize stopping.
%     if ~getLocal(progmanager, hObject, 'acquiring')
%         return;
%     end
% 
%     if isempty(analogObject.Channel)
%         channelNames = {};
%     else
%         channelNames = {analogObject.Channel(:).ChannelName};
%         nonEmptyIndices = [];
%         if ~isempty(channelNames)
%             if strcmpi(class(channelNames{1}), 'cell')
%                 channelNames = channelNames{1};
%             end
%         end
%         for i = 1 : length(channelNames)
%             if ~isempty(channelNames{i})
%                 nonEmptyIndices(length(nonEmptyIndices) + 1) = i;
%             end
%         end
%         channelNames = channelNames(nonEmptyIndices);
%     end
%     
%     %TO100705G - This was outside the if statement, which means it got used twice sometimes. -- Tim O'Connor 10/7/05
%     inputChannels = acq_getInputChannelNames(hObject);
end
% fprintf(1, 'acq_Stop\n');
dm = getDaqmanager;

%TO101105C, TO121305B
[channels, sampleRate, traceLength, buffers, startButton, boardBasedTimingEvent] = ...
    getLocalBatch(progmanager, hObject, 'channels', 'sampleRate', 'traceLength', 'saveBuffers', 'startButton', 'boardBasedTimingEvent');%TO121305B %TO031306A

%TO031306A: Only clear this if it's not already empty, this should save the time of making an unnecessary `setLocalBatch` call. -- Tim O'Connor 3/13/06
repetitions = 1;
if ~isempty(boardBasedTimingEvent)
    repetitions = boardBasedTimingEvent.totalIterations;
    setLocal(progmanager, hObject, 'boardBasedTimingEvent', []);
end

expectedBufferSize = sampleRate * traceLength * repetitions;%TO121305B %TO031306A
counter = 0;
% flushInputChannel(dm, channelNames);%TO010606C
% for i = 1 : length(channels)
%     %TO121305B - Added this stupid `while` loop. -- Tim O'Connor 12/13/05
%     %TO010606C - Check if a trigger has been executed. -- Tim O'Connor 1/6/06
%     while sprintf('length(buffers.trace_%s.data) < expectedBufferSize', num2str(i)) & counter < 15 & ...
%             getAIProperty(dm, channels, 'TriggersExecuted') > 0
%         counter = counter + 1;
% %         fprintf(1, '%s - acq_Stop - @damanager/flushInputChannel(''%s'')\n', datestr(now), channels(i).channelName);
%         flushInputChannel(dm, channels);%TO120205A
%         buffers = getLocal(progmanager, hObject, 'saveBuffers');
%     end
% end

if ~isempty(channelNames)
    stopChannel(dm, channelNames{:});
end

%TO112205D - Dequeue channels when stopped. -- Tim O'Connor 11/22/05
%TO011706A - Fixed case sensitivity for Matlab 7.1. -- Tim O'Connor 1/17/06
sm = startmanager('acquisition');
dequeue(sm, channelNames{:});

removeExpectedDataSource(sm, 'acq');%TO012606B, TO012706B

%Make sure all channels are stopped, then reset the button back to 'Start'.
if length(varargin) == 3
    for i = 1 : length(inputChannels)
        if strcmpi(get(getAI(dm, inputChannels{i}), 'Running'), 'On')
            return;
        end
    end
end

%TO123005B
% if getLocal(progmanager, hObject, 'startButton') & xsg_getAutosave
%     acq_saveTrace(hObject);
% end

drawnow expose;%TO100705I %TO042309A - Not using expose can cause C-spawned events to fire out of order.

fireEvent(getUserFcnCBM, 'acq:Stop', hObject);%TO120505B, TO010506D

% flushAllInputChannels(dm);%TO031306G
%TO010506C - Restart automatically if externally triggered. -- Tim O'Connor 1/5/06
if getLocal(progmanager, hObject, 'externalTrigger')
% fprintf(1, 'acq_Stop: %s\n', getProgramName(progmanager, hObject));
    acq_Start(hObject);
else
    %TO031005H
    setLocalBatch(progmanager, hObject, 'status', '', 'startButton', 0);%TO031306B: Batch these calls.
    setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0 0.6 0]);
end

%TO080306A
setLocalBatch(progmanager, hObject, 'segmentedAcquisition', 0, 'acquisitionsRemainingCounter', 0);

return;
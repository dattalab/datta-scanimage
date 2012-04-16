% ephys_Stop - Stop an acquisition.
%
% SYNTAX
%  ephys_Stop(hObject)
%  ephys_Stop(analogObject, eventData, hObject) - For use as a StopFcn callback.
%
% USAGE
%
% NOTES
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
%  TO123005C: Rely on ephys_Start/stopFcn_Callback to handle board initiated stopping. -- Tim O'Connor 12/30/05
%  TO010506C: Rework triggering scheme for ease of use and simpler looping. Switch to a checkbox for external, which leaves it always started. -- Tim O'Connor 1/5/06
%  TO010506D: Enabling/disabling of UserFcn callbacks is handled by the callbackManager object directly. -- Tim O'Connor 1/5/06
%  TO010606C: Make sure a channel has been triggered before trying to flush its data. -- Tim O'Connor 1/6/06
%  TO011706A: Fixed case sensitivity for Matlab 7.1. -- Tim O'Connor 1/17/06
%  TO012606B - Implemented the expectedDataSourceList variable in the xsg. -- Tim O'Connor 1/26/06
%  TO012706B - Moved the expectedDataSourceList into the @startmanager. -- Tim O'Connor 1/27/06
%  TO031005H: Remove some of the button dancing by not resetting the state if things are externally triggered. -- Tim O'Connor 3/11/06
%  TO031306A: Implemented board-based (precise) timing. As only one trigger is issued, cycles have no effect. -- Tim O'Connor 3/13/06
%  TO031306B: Batched up some `setLocal` calls. -- Tim O'Connor 3/13/06
%  TO031306G: Try doing away with calls to `flushAllInputChannels`, and make sure any calls that do exist come before checking the trigger type. -- Tim O'Connor 3/13/06
%  TO032306D: Watch the dimensions on the cell array concatenation. -- Tim O'Connor 3/23/06
%  TO033106D: Remove all calls to flushInputChannel, the semaphores should handle all of this cleanly now. -- Tim O'Connor 3/31/06
%  TO080306A: Allow multiple acquisitions to be prequeued, and sequentially triggered. -- Tim O'Connor 8/3/06
%  TO080206A: Make sure to 0 all channels when stopped. -- Tim O'Connor 8/2/06
%  TO090706A: Created ephys_getAllOutputChannelNames. -- Stop all channels, not just the ones in use, in case of state inconsistencies. -- Tim O'Connor 9/7/06
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%  TO101207E - More debugging of the nimex port. -- Tim O'Connor 10/12/07
%
% Created 5/26/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephys_Stop(varargin)
% fprintf(1, 'ephys_Stop\n');
% getStackTraceString
% if length(varargin) == 1
%     fprintf(1, '%s - ephys_Stop (timer)\n', datestr(now));
% %     getStackTraceString
% elseif length(varargin) == 2
%     fprintf(1, '%s - ephys_Stop (board)\n', datestr(now));
%     varargin = {varargin{1}};
% end
if length(varargin) == 1
    hObject = varargin{1};
    %TO100705F: Set a flag, and rely on it, to determine the status of the program. This will optimize stopping.
    if ~getLocal(progmanager, hObject, 'acquiring')
        return;
    end
    
    inputChannels = ephys_getInputChannelNames(hObject);
    outputChannels = ephys_getAllOutputChannelNames(hObject);%TO090706A - Stop all channels, not just the ones in use, in case of state inconsistencies. -- Tim O'Connor 9/7/06
    
    if size(inputChannels, 1) > size(inputChannels, 2)
        inputChannels = inputChannels';
    end
    if size(outputChannels, 1) > size(outputChannels, 2)
        outputChannels = outputChannels';
    end


    channelNames = cat(2, inputChannels, outputChannels);
end

%TO101105C, TO121305B
[amplifiers, sampleRate, traceLength, buffers, startButton, boardBasedTimingEvent ] = ...
    getLocalBatch(progmanager, hObject, 'amplifiers', 'sampleRate', 'traceLength', 'saveBuffers', 'startButton', 'boardBasedTimingEvent');%TO121305B %TO031606A

%TO031306A: Only clear this if it's not already empty, this should save the time of making an unnecessary `setLocalBatch` call. -- Tim O'Connor 3/13/06
repetitions = 1;
if ~isempty(boardBasedTimingEvent)
    repetitions = boardBasedTimingEvent.totalIterations;
    setLocal(progmanager, hObject, 'boardBasedTimingEvent', []);
end

expectedBufferSize = sampleRate * traceLength * repetitions;%TO121305B %TO031306A
counter = 0;

job = daqjob('acquisition');
if isStarted(job)
    if ~isempty(channelNames)
        stop(job, channelNames{:});
    end
end
%TO080406D - Make sure to 0 all channels when stopped. -- Tim O'Connor 8/4/06
%TO101207E - Moved this line inside the if statement, otherwise the done event will handle it. -- Tim O'Connor 10/12/07
%TO101607F - Moved back outside, the doneEvent is just calling ephys_Stop now. -- Tim O'Connor 10/16/07
putSample(job, outputChannels, 0);

% drawnow expose;%TO100705I %TO042309A - Not using expose can cause C-spawned events to fire out of order.

fireEvent(getUserFcnCBM, 'ephys:Stop', hObject);%TO120505B, TO010506D

% flushAllInputChannels(dm);%TO031306G
%TO010506C - Restart automatically if externally triggered. -- Tim O'Connor 1/5/06
if getLocal(progmanager, hObject, 'externalTrigger')
% fprintf(1, 'ephys_Stop: %s\n', getProgramName(progmanager, hObject));
% fprintf(1, '%s - ephys_Stop: restarting...\n%s', datestr(now), getStackTraceString);
    ephys_Start(hObject);
else
    %TO031005H
    setLocalBatch(progmanager, hObject, 'status', '', 'startButton', 0);%TO031306B: Batch these calls.
    setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0 0.6 0]);
end

%TO080306A
setLocalBatch(progmanager, hObject, 'segmentedAcquisition', 0, 'acquisitionsRemainingCounter', 0);

return;
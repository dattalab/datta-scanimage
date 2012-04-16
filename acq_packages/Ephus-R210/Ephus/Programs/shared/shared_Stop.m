% shared_Stop - Stop an acquisition.
%
% SYNTAX
%  shared_Stop(hObject)
%  shared_Stop(hObject, channelName, ...)
%   hObject - The program name.
%   channelName - A list of channel names is accepted for all extra arguments.
%                 This is to support the @daqjob's 'jobDone' event, which passes the names of all channels involved in an acquisition.
%
% USAGE
%
% NOTES
%  Adapted from ephys_Stop.m See TO101707F.
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
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO101807E - Don't vectorize putSample, go through each call individually, so it can be tried/caught. This should be more resilient to errors. -- Tim O'Connor 10/18/07
%  TO101907A - Restarting for externalTrigger is now handled directly in nimex. -- Tim O'Connor 10/19/07
%  TO033008C - Check to see if this program is running. -- Tim O'Connor 3/30/08
%  TO043008B - When putting out the 0 sample, check other programs for external triggering before issuing an error. This isn't perfect, but it will usually be right. -- Tim O'Connor 4/30/08
%  TO072208A - Allow multiple digital lines to appear separate in the GUI, but actually be grouped underneath. -- Tim O'Connor 7/22/08
%  TO073008A - Backed out TO072208A, moved that functionality into @daqjob. -- Tim O'Connor 7/30/08
%  TO102308A - Implemented zeroChannelsOnStop, to prevent unnecessary attempts at writing to lines when stopping multiple programs that share boards. -- Tim O'Connor 10/23/08
%  TO111908I - Optionally, clear buffers when done. -- Tim O'Connor 11/19/08
%  TO021610J - Added stopRequested to help when aborting an acquisition. -- Tim O'Connor 2/16/10
%  TO030210C - Created shared_resetBuffers, to centralize buffer initialization. -- Tim O'Connor 3/2/10
%  TO033110E - Disable controls that are not updated while running. -- Tim O'Connor 3/31/10
%  TO042010D - Enable/disable the updateRate and displayWidth handles, as a special case. -- Tim O'Connor 4/20/10
%
% Created 5/26/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function shared_Stop(hObject, varargin)
% fprintf(1, '''%s''_Stop\n%s', getProgramName(progmanager, hObject), getStackTraceString);
% getStackTraceString
% if isempty(varargin)
%     fprintf(1, '%s - ''%s''_Stop (timer)\n', datestr(now), getProgramName(progmanager, hObject));
% %     getStackTraceString
% else
%     fprintf(1, '%s - ''%s''_Stop (board)\n', datestr(now), getProgramName(progmanager, hObject));
%     varargin = {varargin{1}};
% end
%TO101105C, TO121305B
[amplifiers, sampleRate, traceLength, buffers, startButton, boardBasedTimingEvent, externalTrigger, zeroChannelsOnStop, stopRequested, disableHandles] = ...
    getLocalBatch(progmanager, hObject, 'amplifiers', 'sampleRate', 'traceLength', 'saveBuffers', 'startButton', 'boardBasedTimingEvent', 'externalTrigger', ...
    'zeroChannelsOnStop', 'stopRequested', 'disableHandles');%TO121305B %TO031606A %TO021610J %TO033110E

%TO033008C - Check to see if this program is running, in the event that other programs caused data to be dispatched to here.
if ~(startButton || externalTrigger || stopRequested)
    %fprintf(1, '''%s''_Stop - Program not running. Ignoring call...\n', getProgramName(progmanager, hObject));
    return;
end

%TO101907A
if externalTrigger
    setLocal(progmanager, hObject, 'status', 'Waiting...');
    return;
end

setLocal(progmanager, hObject, 'stopRequested', 0);%TO021610J

inputChannels = shared_getInputChannelNames(hObject);
if size(inputChannels, 1) > size(inputChannels, 2)
    inputChannels = inputChannels';
end
outputChannels = shared_getAllOutputChannelNames(hObject);%TO090706A - Stop all channels, not just the ones in use, in case of state inconsistencies. -- Tim O'Connor 9/7/06
if size(outputChannels, 1) > size(outputChannels, 2)
    outputChannels = outputChannels';
end
channelNames = cat(2, inputChannels, outputChannels);

%TO031306A: Only clear this if it's not already empty, this should save the time of making an unnecessary `setLocalBatch` call. -- Tim O'Connor 3/13/06
if ~isempty(boardBasedTimingEvent)
    setLocal(progmanager, hObject, 'boardBasedTimingEvent', []);
end

job = daqjob('acquisition');
if ~isempty(channelNames)
    stop(job, channelNames{:});
end

%TO102308A
if zeroChannelsOnStop
    if ~isempty(outputChannels)
        %TO080406D - Make sure to 0 all channels when stopped. -- Tim O'Connor 8/4/06
        %TO101207E - Moved this line inside the if statement, otherwise the done event will handle it. -- Tim O'Connor 10/12/07
        %TO101607F - Moved back outside, the doneEvent is just calling ephys_Stop now. -- Tim O'Connor 10/16/07
        %TO101807E - Don't vectorize this, go through each call individually, so it can be tried/caught. This should be more resilient to errors. -- Tim O'Connor 10/18/07
        for i = 1 : length(outputChannels)
            try
                if getTaskProperty(job, outputChannels{i}, 'started')
                    fprintf(2, 'Warning - ''%s''_Stop: Failed to set 0V for channel ''%s'' when stopping acquisition because the device is in use.\n', getProgramName(progmanager, hObject), outputChannels{i});
                else
                    putSample(job, outputChannels{i}, 0);
                end
            catch
                %TO043008B - When putting out the 0 sample, check other programs for external triggering before issuing an error. This isn't perfect, but it will usually be right. -- Tim O'Connor 4/30/08
                printErr = 1;
                if strcmpi(getProgramName(progmanager, hObject), 'ephys')
                    if getGlobal(progmanager, 'externalTrigger', 'stimulator', 'stimulator')
                        printErr = 0;
                    end
                elseif strcmpi(getProgramName(progmanager, hObject), 'stimulator')
                    if getGlobal(progmanager, 'externalTrigger', 'ephys', 'ephys')
                        printErr = 0;
                    end
                end
                if printErr
                    fprintf(2, '%s - ''%s''_Stop: Failed to put sample on channel ''%s'' - %s\nRoot cause: %s', datestr(now), getProgramName(progmanager, hObject), outputChannels{i}, getLastErrorStack);
                end
            end
        end
        % %Now's a good time to force an update of output signals, for example, if they've been hijacked and lost.
        % setLocal(progmanager, hObject, 'pulseSelectionHasChanged', ones(length(outputChannels), 1));
        % shared_updateOutputSignals(hObject);
    end
end

%TO033110E - Disable controls that are not updated while running. -- Tim O'Connor 3/31/10
set(disableHandles, 'Enable', 'On');
%TO042010D - Update these two handles, as a special case. -- Tim O'Connor 4/20/10
if any(strcmpi(getProgramName(progmanager, hObject), {'ephys', 'acquirer'}))
    [autoUpdateRate, autoDisplayWidth] = getLocalBatch(progmanager, hObject, 'autoUpdateRate', 'autoDisplayWidth');
    if autoUpdateRate
        setLocalGh(progmanager, hObject, 'updateRate', 'Enable', 'Off');
    end
    if autoDisplayWidth
        setLocalGh(progmanager, hObject, 'displayWidth', 'Enable', 'Off');
    end
end

% drawnow expose;%TO100705I %TO042309A - Not using expose can cause C-spawned events to fire out of order.

fireEvent(getUserFcnCBM, [getProgramName(progmanager, hObject) ':Stop'], hObject);%TO120505B, TO010506D

%TO101907A - When externally triggered, we won't get this far anymore.
% % flushAllInputChannels(dm);%TO031306G
% %TO010506C - Restart automatically if externally triggered. -- Tim O'Connor 1/5/06
% if getLocal(progmanager, hObject, 'externalTrigger')
% % fprintf(1, '''%s''_Stop: %s\n', getProgramName(progmanager, hObject), getProgramName(progmanager, hObject));
% % fprintf(1, '%s - ''%s''_Stop: restarting...\n%s', datestr(now), getProgramName(progmanager, hObject), getStackTraceString);
%     shared_Start(hObject);
% else
%TO031005H
setLocalBatch(progmanager, hObject, 'status', '', 'startButton', 0);%TO031306B: Batch these calls.
setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0 0.6 0]);

try
    %TO111908I - Optionally, clear buffers when done.
    if getLocal(progmanager, hObject, 'clearBuffersWhenNotRunning')
        % fprintf(1, '%s - ''%s''_Stop - Clearing buffer...\n', datestr(now), getProgramName(progmanager, hObject));
        saveBuffers = getLocal(progmanager, hObject, 'saveBuffers');
        bufferNames = fieldnames(saveBuffers);
        for i = 1 : length(saveBuffers)
            %TO030210C
            buffers = shared_resetBuffer(buffers, bufferNames{i}, buffers.(bufferNames{i}).channelName, buffers.(bufferNames{i}).amplifierName, buffers.(bufferNames{i}).sampleRate);
        end
        setLocal(progmanager, hObject, 'saveBuffers', saveBuffers);
    end
catch
    fprintf(2, '''%s''_Stop: Failed to clear buffer (clearBuffersWhenNotRunning) - %s\n', getLastErrorStack);
end

%TO080306A

return;
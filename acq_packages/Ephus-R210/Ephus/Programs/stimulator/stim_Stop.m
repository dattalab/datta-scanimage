% stim_Stop - Stop an acquisition.
%
% SYNTAX
%  ephys_Stop(hObject)
%  ephys_Stop(analogObject, eventData, hObject) - For use as a StopFcn callback.
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
%  TO123005G - Implement various userFcn calls. -- Tim O'Connor 12/30/05
%  TO010506C: Rework triggering scheme for ease of use and simpler looping. Switch to a checkbox for external, which leaves it always started. -- Tim O'Connor 1/5/06
%  TO010506D: Enabling/disabling of UserFcn callbacks is handled by the callbackManager object directly. -- Tim O'Connor 1/5/06
%  TO011706A: Fixed case sensitivity for Matlab 7.1. -- Tim O'Connor 1/17/06
%  TO012706B: Implemented the expectedDataSinks list in the @startmanager. -- Tim O'Connor 1/27/06
%  TO031005H: Remove some of the button dancing by not resetting the state if things are externally triggered. -- Tim O'Connor 3/11/06
%  TO031306A: Implemented board-based (precise) timing. As only one trigger is issued, cycles have no effect. -- Tim O'Connor 3/13/06
%  TO031306B: Batched up some `setLocal` calls. -- Tim O'Connor 3/13/06
%  TO031306G: Try doing away with calls to `flushAllInputChannels`, and make sure any calls that do exist come before checking the trigger type. -- Tim O'Connor 3/13/06
%  TO033106D: Remove all calls to flushInputChannel, the semaphores should handle all of this cleanly now. -- Tim O'Connor 3/31/06
%  TO080306A: Allow multiple acquisitions to be prequeued, and sequentially triggered. -- Tim O'Connor 8/3/06
%  TO090706A: Created ephys_getAllOutputChannelNames. -- Stop all channels, not just the ones in use, in case of state inconsistencies. -- Tim O'Connor 9/7/06
%
% Created 11/21/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function stim_Stop(varargin)
% fprintf(1, 'stim_Stop\n');
% getStackTraceString
if length(varargin) == 1
    hObject = varargin{1};
    %TO100705F: Set a flag, and rely on it, to determine the status of the program. This will optimize stopping.
    if ~getLocal(progmanager, hObject, 'transmitting')
        return;
    end
    
    outputChannels = stim_getOutputChannelNames(hObject);
    channelNames = outputChannels;
elseif length(varargin) == 3
    analogObject = varargin{1};
    eventData = varargin{2};
    hObject = varargin{3};
    
    %TO100705F: Set a flag, and rely on it, to determine the status of the program. This will optimize stopping.
    if ~getLocal(progmanager, hObject, 'transmitting')
        return;
    end

    if isempty(analogObject.Channel)
        channelNames = {};
    else
        channelNames = {analogObject.Channel(:).ChannelName};
        nonEmptyIndices = [];
        if ~isempty(channelNames)
            if strcmpi(class(channelNames{1}), 'cell')
                channelNames = channelNames{1};
            end
        end
        for i = 1 : length(channelNames)
            if ~isempty(channelNames{i})
                nonEmptyIndices(length(nonEmptyIndices) + 1) = i;
            end
        end
        channelNames = channelNames(nonEmptyIndices);
    end
    
    %TO100705G - This was outside the if statement, which means it got used twice sometimes. -- Tim O'Connor 10/7/05
    %TO090706A - Stop all channels, not just the ones in use, in case of state inconsistencies. -- Tim O'Connor 9/7/06
    outputChannels = stim_getAllOutputChannelNames(hObject);
end
% fprintf(1, 'stim_Stop\n');
dm = getDaqmanager;

if ~isempty(channelNames)
    stopChannel(dm, channelNames{:});
end

%TO112205D - Dequeue channels when stopped. -- Tim O'Connor 11/22/05
%TO011706A - Fixed case sensitivity for Matlab 7.1. -- Tim O'Connor 1/17/06
sm = startmanager('acquisition');
dequeue(sm, channelNames{:});

removeExpectedDataSink(sm, 'stim');%TO012706B

setLocal(progmanager, hObject, 'boardBasedTimingEvent', []);%TO031606A

%Make sure all channels are stopped, then reset the button back to 'Start'.
if length(varargin) == 3
    for i = 1 : length(outputChannels)
        if strcmpi(get(getAO(dm, outputChannels{i}), 'Running'), 'On')
            return;
        end
    end
end

drawnow expose;%TO100705I %TO042309A - Not using expose can cause C-spawned events to fire out of order.

%TO123005G
fireEvent(getUserFcnCBM, 'stim:Stop', hObject);%TO120505B, TO010506D

% flushAllInputChannels(dm);%TO031306G
%TO010506C - Restart automatically if externally triggered. -- Tim O'Connor 1/5/06
if getLocal(progmanager, hObject, 'externalTrigger')
% fprintf(1, 'stim_Stop: %s\n', getProgramName(progmanager, hObject));
    stim_Start(hObject);
else
    %TO031005H
    setLocalBatch(progmanager, hObject, 'status', '', 'startButton', 0);%TO031306B: Batch these calls.
    setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0 0.6 0]);
end

%TO080306A
setLocalBatch(progmanager, hObject, 'segmentedAcquisition', 0, 'transmissionsRemainingCounter', 0);

return;
% SYNTAX
%   ephysAcc_amplifierStateListenerFcn(hObject)
%     hObject - @progmanager handle
%
% USAGE
%   Propogates changes in the amplifier state to the scope accessory display.
%
% CHANGES
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO032406F - Use a start ID to safely ignore superfluous calls to the amplifier state change listener function. -- Tim O'Connor 3/24/06
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%  TO012308B - Reworked logic for updating multiple amplifiers. Now the ampIndex must be an argument. -- Tim O'Connor 1/23/08
%  VITO022110A: Removed - This short-circuits reset of ephysAcc below for state changes not related to mode (e.g. units/scale factor) -- Vijay Iyer/Tim O'Connor 2/21/10
%
% Created 6/24/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function ephysAcc_amplifierStateListenerFcn(hObject, ampIndex)

if ~getLocal(progmanager, hObject, 'startButton')
    return;
end

amplifiers = getLocal(progmanager, hObject, 'amplifiers');
amp = amplifiers(ampIndex);
mode = get(amp{1}, 'modeString');%TO120205A - This will always be a cell array so it's okay to always index into it.

%%%VITO022110A: Removed - This short-circuits reset of ephysAcc below for state changes not related to mode (e.g. units/scale factor)
% if strcmpi(getLocal(progmanager, hObject, 'mode'), mode)
%     return;
% end

setLocal(progmanager, hObject, 'mode', mode);

% dm = getLocal(progmanager, hObject, 'daqmanager');
if isStarted(daqjob('scope')) && getLocal(progmanager, hObject, 'startButton')
% if getLocal(progmanager, hObject, 'startButton')
%     if strcmpi(getAOProperty(dm, get(amp{1}, 'vCom'), 'running'), 'On')
%         for i = 1 : length(amplifiers)
%             setLocal(progmanager, hObject, 'restarting', 1);
%             setChannelStopListener(dm, getScaledOutputChannelName(amplifiers{i}), {@ephysAcc_restart, hObject}, ['ephysAcc_restart_' num2str(i)]);
%             setChannelStopListener(dm, getScaledOutputChannelName(amplifiers{i}), [], 'ephysAcc_updateInput_channelStopListener');%TO112205C, TO120205A, TO122205A, TO032406F
%             setChannelStopListener(dm, getScaledOutputChannelName(amplifiers{i}), {@ephysAcc_restart, hObject}, 'ephysAcc_updateInput_channelStopListener');%TO112205C, TO120205A, TO122205A, TO032406F
%         end
% fprintf(1, 'Stopping channels...\n');
%         stopChannel(getLocal(progmanager, hObject, 'daqmanager'), getQueue(startmanager('ephysAcc')));
% fprintf(1, 'Stopping scope (for restart)...\n');
        ephysAcc_stop(hObject);
% fprintf(1, 'Starting...\n');
        ephysAcc_start(hObject);
% fprintf(1, 'Restart completed.\n');
% end
%     end
end

return;

%-----------------------------------------------------
%TO032406F - Try to get this stupid thing to restart, even though the events from the boards come in completely retarded orders.
function ephysAcc_restart(hObject, channelName, daqObject, eventdata)
% fprintf(1, 'ephysAcc_restart\n');

[restart, amplifiers, dm] = getLocalBatch(progmanager, hObject, 'restart', 'amplifiers', 'daqmanager');
if restart
    setLocalBatch(progmanager, hObject, 'restart', 0, 'restarting', 0);
%     for i = 1 : length(amplifiers)
%         setChannelStopListener(dm, getScaledOutputChannelName(amplifiers{i}), [], 'ephysAcc_updateInput_channelStopListener');%TO112205C, TO120205A, TO122205A, TO032406F
%         setChannelStopListener(dm, getScaledOutputChannelName(amplifiers{i}), {@ephysAcc_stop, hObject, getLocal(progmanager, hObject, 'startID')}, 'ephysAcc_updateInput_channelStopListener');%TO112205C, TO120205A, TO122205A, TO032406F
%     end
    ephysAcc_start(hObject);
end

return;
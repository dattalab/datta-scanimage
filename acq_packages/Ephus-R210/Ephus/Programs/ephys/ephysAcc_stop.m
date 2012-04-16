% ephysAcc_stop - Stop running the scope via the ephysAccessory GUI.
%
% SYNTAX
%  ephysAcc_stop(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO120205I - Add timer that counts from the last click of the break-in button. -- Tim O'Connor 12/2/05
%  TO120205J - It was grabbing eventdata thinking it was the hObject. -- Tim O'Connor 12/2/05
%  TO032406F - Use a start ID to safely ignore superfluous calls to the amplifier state change listener function. -- Tim O'Connor 3/24/06
%  TO080206A - Make sure to 0 all channels when stopped. -- Tim O'Connor 8/2/06
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO060108E - Handle errors in putSample, when ephys is using the hardware (while switching configurations). -- Tim O'Connor 6/1/08
%
% Created 2/25/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephysAcc_stop(varargin)
% fprintf(1, 'ephysAcc_stop\n%s\n', getStackTraceString);

if length(varargin) == 1
    hObject = varargin{1};
%     [dm, amplifiers] = getLocalBatch(progmanager, hObject, 'daqmanager', 'amplifiers');
%     for i = 1 : length(amplifiers)
%         setChannelStopListener(dm, getScaledOutputChannelName(amplifiers{i}), ...
%             {@ephysAcc_stop, hObject, getLocal(progmanager, hObject, 'startID')}, 'ephysAcc_updateInput_channelStopListener');%TO112205C, TO120205A, TO122205A, TO032406F
%     end
elseif ishandle(varargin{1}) %TO120205J
    hObject = varargin{1};
    if length(varargin) > 1
        if isnumeric(varargin{2})
            %TO032406F
% fprintf(1, 'Checking start ID... %s :: %s\n', num2str(varargin{2}), num2str(getLocal(progmanager, hObject, 'startID')));
            if varargin{2} ~= getLocal(progmanager, hObject, 'startID')
                return;
            end
        end
    end
else
    hObject = varargin{end};
end

%Consider it running, until the stop is successfully completed.
setLocalBatch(progmanager, hObject, 'startButton', 1, 'startID', rand);%TO032406F

inputChannels = shared_getInputChannelNames(hObject);%TO101707F
outputChannels = shared_getOutputChannelNames(hObject);%TO101707F

%Stop
job = daqjob('scope');
if isStarted(job)
    stop(job);
end

%TO080206A - Make sure to 0 all channels when stopped. -- Tim O'Connor 8/2/06
for i = 1 : length(outputChannels)
    try
        %TO060108E
        if ~getGlobal(progmanager, 'externalTrigger', 'ephys', 'ephys')
            putSample(job, outputChannels{i}, 0);
        end
    catch
        fprintf(2, 'Warning: ephysAcc_stop - Failed to put 0V sample on ''%s''. Channel may be in use.\n', outputChannels{i});
        fprintf(2, '                         This is a non-fatal error and is not uncommon when loading a configuration set.\n');
        fprintf(2, '                         If this occurred when not loading a configuration set, other conflicts may be present on the system.\n');
    end
end
% stopChannel(getDaqmanager, inputChannels{:}, outputChannels{:});

%Update the GUI to show this is not running.
setLocal(progmanager, hObject, 'startButton', 0);
setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [.2 .8 .2]);
if getLocal(progmanager, hObject, 'selfTrigger')
    setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Inactive');
end

% getAI(getLocal(progmanager, hObject, 'daqmanager')
% setLocalGh(progmanager, hObject, 'breakIn', 'String', 'Break-In');%TO120205I - The time is only meaningful while the scope is running.

return;

% if length(varargin) == 1
%     hObject = varargin{1};
% else
%     hObject = varargin{end};
% end
% 
% %Update the GUI to show this is running.
% setLocal(progmanager, hObject, 'startButton', 0);
% setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [.2 .8 .2]);
% 
% %Get the amplifiers and input channels.
% amps = getLocal(progmanager, hObject, 'amplifiers');
% inputChannels = ephys_getInputChannelNames(hObject);
% 
% %Get the output channel names.
% %Configure the output multiplexing.
% outputChannels = {};
% for i = 1 : length(amps)
%     outputChannels{length(outputChannels) + 1} = get(amps{i}, 'commandInputChannel');%TO120205A
% end
% 
% %Stop
% dm = getDaqManager;
% stopChannel(dm, outputChannels{:}, inputChannels{:});
% 
% return;
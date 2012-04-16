% pj_currentPosition - Update gui and internal variables to reflect the currentPosition variable.
%
% SYNTAX
%  pj_currentPosition(hObject)
%  pj_currentPosition(hObject, currentPosition)
%    hObject - The program handle.
%    currentPosition - The new current position.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO102107B - Force update of buffer when changing position, if necessary. -- Tim O'Connor 10/21/07
%  TO060108G - Added currentPosition as an optional argument. -- Tim O'Connor 6/1/08
%
% Created 8/28/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_currentPosition(hObject, varargin)

if isempty(varargin)
    [positions, currentPosition, enable, programHandles, loopEventData] = getLocalBatch(progmanager, hObject, ...
        'positions', 'currentPosition', 'enable', 'programHandles', 'loopEventData');
else
    currentPosition = varargin{1};
    [positions, enable, programHandles, loopEventData] = getLocalBatch(progmanager, hObject, ...
        'positions', 'enable', 'programHandles', 'loopEventData');
    setLocal(progmanager, hObject, 'currentPosition', currentPosition);
end

if isempty(positions) || currentPosition == 0
    setLocalGhBatch(progmanager, hObject, {'currentPosition', 'positionIncrementSlider', 'positionDecrementSlider', ...
            'pulseSetName', 'pulseName', 'currentChannel', 'deletePosition'}, 'Enable', 'Off');
    setLocalBatch(progmanager, hObject, 'pulseSetName', '', 'pulseName', '');
elseif ~enable
    setLocalGhBatch(progmanager, hObject, {'currentPosition', 'positionIncrementSlider', 'positionDecrementSlider', ...
            'pulseSetName', 'pulseName', 'currentChannel', 'deletePosition'}, 'Enable', 'On');
    pj_currentChannel(hObject);
else
    setLocalGhBatch(progmanager, hObject, {'currentPosition', 'positionIncrementSlider', 'positionDecrementSlider', ...
            'currentChannel'}, 'Enable', 'On');
    setLocalGhBatch(progmanager, hObject, {'pulseSetName', 'pulseName'}, 'Enable', 'Off');
    pj_currentChannel(hObject);
end

if enable && isempty(loopEventData)
    job = daqjob('acquisition');
    for i = 1 : length(programHandles)
        if getLocal(progmanager, programHandles(i), 'externalTrigger')
            outputChannels = shared_getOutputChannelNames(programHandles(i));
            if ~isempty(outputChannels)
                tasks = unique(getTasksByChannelNames(job, outputChannels{:}));
                for j = 1 : length(tasks)
                    try
                        nimex_stopTask(tasks(j));
                        nimex_startTask(tasks(j));
                    catch
                        fprintf(2, '%s - pj_currentPosition - Failed to restart channel(s) for external triggering: %s\n', ...
                            datestr(now), getProgramName(progmanager, hObject), getLastErrorStack);
                    end
                end
            end
        end
    end
end
return;
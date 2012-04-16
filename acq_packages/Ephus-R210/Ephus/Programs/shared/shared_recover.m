% shared_recover - Attempt to restore to nominal working state after non-fatal error.
%
% SYNTAX
%  shared_recover
%  shared_recover(hObject)
%   hObject - The program's handle.
%
% USAGE
%  Run this if things get into a weird or unusable state, to attempt to return to normality.
%  This is not intended for regular/frequent use. It is only to be used when we know
%  things are screwed up.
%
% NOTES
%
% CHANGES
%  TO050308A - Added the no argument option, which will try to recover stimulator, acquirer, and ephys. -- Tim O'Connor 5/3/08
%  TO050308B - Stop any tasks, so we're back to a nice clean initial state. -- Tim O'Connor 5/3/08
%  TO042010D - Enable/disable the updateRate and displayWidth handles, as a special case. -- Tim O'Connor 4/20/10
%
% Created - Tim O'Connor 10/18/07
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function shared_recover(varargin)
% fprintf(1, '%s - ''%s''_recover\n', datestr(now), getProgramName(progmanager, hObject));

%TO050308A
if nargin == 0
    %Try stimulator, acquirer, and ephys here.
    if isprogram(progmanager, 'ephys')
        shared_recover(getGlobal(progmanager, 'hObject', 'ephys', 'ephys'));
    end
    if isprogram(progmanager, 'stimulator')
        shared_recover(getGlobal(progmanager, 'hObject', 'stimulator', 'stimulator'));
    end
    if isprogram(progmanager, 'acquirer')
        shared_recover(getGlobal(progmanager, 'hObject', 'acquirer', 'acquirer'));
    end
    return;
else
    hObject = varargin{1};
end

[stimOnArray, acqOnArray] = getLocalBatch(progmanager, hObject, 'stimOnArray', 'acqOnArray');

%TO050308B - Stop any tasks, so we're back to a nice clean initial state.
stopAllTasks(daqjob('acquisition'));

%Reset to the easiest state...
setLocalBatch(progmanager, hObject, 'externalTrigger', 0, 'startButton', 0, 'selfTrigger', 1);

%Re-enable any, potentially, non-functional GUI objects.
uiElements = {'externalTrigger', 'startButton'};
if ~isempty(stimOnArray)
    uiElements = cat(2, uiElements, {'pulseSetName', 'pulseName', 'stimOn'});
end
if ~isempty(acqOnArray)
    uiElements = cat(2, uiElements, {'acqOn'});
end
setLocalGhBatch(progmanager, hObject, uiElements, 'Enable', 'On');

%Force reset of datasources.
if ~isempty(stimOnArray)
    [pulseSelectionHasChanged] = getLocalBatch(progmanager, hObject, 'pulseSelectionHasChanged');
    try
        pulseSelectionHasChanged(:) = 1;
        setLocalBatch(progmanager, hObject, 'pulseSelectionHasChanged', pulseSelectionHasChanged);        
    catch
        fprintf(2, '%s - ''%s''_recover: Failed to flag reset of output channel data sources - %s\n', datestr(now), getProgramName(progmanager, hObject), lasterr);
    end
end

try
    shared_Stop(hObject);
    %TO050308A - Make things look nicer after recovering.
    setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0 0.6 0]);
    setLocal(progmanager, hObject, 'status', '');
catch
    fprintf(2, '%s - ''%s''_recover: Failed to stop program - %s\n', datestr(now), getProgramName(progmanager, hObject), lasterr);
    
    %Try another reset, but don't retry the stop. At least this may leave things workable for the user.
    %Maybe they need to reset hardware, for example.
    setLocalBatch(progmanager, hObject, 'externalTrigger', 0, 'startButton', 0);
    setLocalGhBatch(progmanager, hObject, uiElements, 'Enable', 'On');
end

%TO033110E - Disable controls that are not updated while running. -- Tim O'Connor 3/31/10
try
    disableHandles = getLocal(progmanager, hObject, 'disableHandles');
    if ~isempty(disableHandles)
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
    end
%     if any(strcmpi({'ephys', 'acquirer'}, getProgramName(progmanager, hObject)))
%         setLocalGh(progmanager, hObject, 'displayWidth', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'autoDisplayWidth', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'updateRate', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'acqOn', 'Enable', 'On');
%     end
%     if any(strcmpi({'ephys', 'stimulator'}, getProgramName(progmanager, hObject)))
%         setLocalGh(progmanager, hObject, 'stimOn', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'pulseSetName', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'pulseNumber', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'pulseNumberSliderUp', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'pulseNumberSliderDown', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'extraGain', 'Enable', 'On');
%     end
%     setLocalGh(progmanager, hObject, 'traceLength', 'Enable', 'On');
%     setLocalGh(progmanager, hObject, 'pmExtTriggerSource', 'Enable', 'On');
catch
end

return;
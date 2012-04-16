% cycler_currentPosition_Callback - Callback for updating the selected position.
%
% SYNTAX
%  cycler_currentPosition_Callback(hObject, eventdata, handles)
%  cycler_currentPosition_Callback(hObject, eventdata, handles, autoLoadPosition)
%    autoLoadPosition - Automatically load the entire position after all necessary GUI updates are made.
%
% USAGE
%
% NOTES
%  Broke out of cycler.m, so it could be accessed by cycler_loopListener.m
%
% CHANGES
%  TO092605B: Added the positionRepeats & positionRepeatsArray variables. -- Tim O'Connor 9/26/05
%  TO120905H: - Changed enableControlsByCycleSelection to cycler_enableControlsBySelection. -- Tim O'Connor 12/9/05
%  TO022106A: Swapped positionRepeats for positionIterations. -- Tim O'Connor 2/21/06
%  TO022406C: Automatically load positions when enable is on. -- Tim O'Connor 2/24/06
%  TO062806H: Added the `autoLoadPosition` option, for use with "turbo" cycles. See TO062806C. -- Tim O'Connor 6/28/06
%  TO080406B: Add user functions for cycler. -- Tim O'Connor 8/04/06
%
% Created 9/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function cycler_currentPosition_Callback(hObject, eventdata, handles, varargin)

%TO062806H
autoLoadPosition = 1;
if ~isempty(varargin)
    autoLoadPosition = varargin{1};
end

[positions currentPosition enable] = getLocalBatch(progmanager, hObject, 'positions', 'currentPosition', 'enable');

setLocal(progmanager, hObject, 'positions', positions);
if currentPosition > length(positions)
    currentPosition = length(positions);
    setLocal(progmanager, hObject, 'currentPosition', currentPosition);
elseif currentPosition == 0 & ~isempty(positions)
    currentPosition = 1;
    setLocal(progmanager, hObject, 'currentPosition', currentPosition);
end
if currentPosition < 1
    currentPosition = 0;
    setLocal(progmanager, hObject, 'currentPosition', currentPosition);
    setLocalGh(progmanager, hObject, 'selectedConfigurations', 'String', {});
    cycler_enableControlsBySelection(hObject);%TO120905H - Forgot to prefix with `cycler_`. -- Tim O'Connor 12/9/05
    return;
end

%TO092605B %TO022106A
positionIterationsArray = getLocal(progmanager, hObject, 'positionIterationsArray');
setLocal(progmanager, hObject, 'positionIterations', positionIterationsArray(currentPosition));

setLocalGh(progmanager, hObject, 'selectedConfigurations', 'String', positions{currentPosition});
cycler_enableControlsBySelection(hObject);

%TO022406C - Automatically load the current position when enabled. -- Tim O'Connor 2/24/06
%TO062806H
if enable & autoLoadPosition
    cycler_loadEntirePosition(hObject);
end

fireEvent(getUserFcnCBM, 'cycler:PositionUpdate', currentPosition);%TO080406B - Add user functions for cycler position update. -- Tim O'Connor 8/04/06

return;
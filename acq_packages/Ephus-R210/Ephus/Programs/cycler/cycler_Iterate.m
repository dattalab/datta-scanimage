% cycler_Iterate - Callback for handling iteration events.
%
% SYNTAX
%  cycler_Iterate(hObject, eventdata)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO092605B: Added the positionRepeats & positionRepeatsArray variables. -- Tim O'Connor 9/26/05
%  TO012706B: Created cycler_Iterate function to centralize some functionality. -- Tim O'Connor 1/26/06
%  TO022106A: Swapped positionRepeats for positionIterations. -- Tim O'Connor 2/21/06
%  TO062806O: Ignore calls to this function made when in board timing, this is only valid for CPU timing. -- Tim O'Connor 6/28/06
%  TO080306E: Ignore calls to this function when precaching cycles under CPU timing (new checkbox on gui). -- Tim O'Connor 8/3/06
%
% Created 9/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function cycler_Iterate(hObject)
global loopManagers;
% getStackTraceString

%TO062806O
if get(loopManager, 'preciseTimeMode')
    return;
end

%TO092605B %TO022106A
[enable, positions, currentPosition, positionIterationsArray, iterationCounter, precacheAllCycles] = ...
    getLocalBatch(progmanager, hObject, 'enable', 'positions', 'currentPosition', 'positionIterationsArray', 'iterationCounter', 'precacheAllCycles');

%TO080306E
if precacheAllCycles
    return;
end

% pos = positions{currentPosition}
% currentPosition
% positionIterationsArray
% iterationCounter
if ~enable
    return;
end
if ~isempty(positions)
% fprintf(1, 'cycler_Iterate -\n currentPosition: %s\n iterationCounter: %s\n%s', ...
%     num2str(currentPosition), num2str(iterationCounter), getStackTraceString);
    cycler_loadEntirePosition(hObject);

    %TO092605B %TO022106A
    if positionIterationsArray(currentPosition) <= iterationCounter
        if currentPosition == length(positions)
            currentPosition = 1;
        else
            currentPosition = currentPosition + 1;
        end
        iterationCounter = 1;
    else
        iterationCounter = iterationCounter + 1;
    end
% fprintf(1, 'cycler_Iterate (end) -\n currentPosition: %s\n iterationCounter: %s\n', ...
%     num2str(currentPosition), num2str(iterationCounter));
    % psRepArr = positionIterationsArray(currentPosition)
    % repCount = iterationCounter
    % posRepeats = positionIterationsArray(currentPosition) - iterationCounter
    setLocalBatch(progmanager, hObject, 'currentPosition', currentPosition, 'iterationCounter', iterationCounter);
    setLocal(progmanager, hObject, 'positionIterations', positionIterationsArray(currentPosition) - iterationCounter);
    cycler_currentPosition_Callback(hObject);
end
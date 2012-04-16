% cycler_enableControlsBySelection - Sets the various enable states for all the GUI elements.
%
% SYNTAX
%  cycler_enableControlsBySelection(hObject, eventdata)
%
% USAGE
%
% NOTES
%  Broke out of cycler.m, so it could be accessed by cycler_loopListener.m
%
% CHANGES
%  TO092605B: Added the positionRepeats & positionRepeatsArray variables. -- Tim O'Connor 9/26/05
%  TO022106A: Swapped positionRepeats for positionIterations. -- Tim O'Connor 2/21/06
%  TO081606E: Slider functionality changed as of Matlab 7, invalidating most slider code. -- Tim O'Connor 8/16/06
%
% Created 9/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function cycler_enableControlsBySelection(hObject)

if isempty(getLocal(progmanager, hObject, 'cycleName'))
    setLocalGh(progmanager, hObject, 'currentPosition', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'currentPositionSliderUp', 'Enable', 'Off');%TO081606D
    setLocalGh(progmanager, hObject, 'currentPositionSliderDown', 'Enable', 'Off');%TO081606D
    setLocalGh(progmanager, hObject, 'newPosition', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'moveUp', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'deletePosition', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'moveDown', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'availableConfigurations', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'loadConfigurations', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'addConfiguration', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'deleteSelectedConfiguration', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'deleteAvailableConfiguration', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'currentProgram', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'configurationName', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'selectedConfigurations', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'captureConfig', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'positionIterations', 'Enable', 'Off');
else
    if ~isempty(getLocal(progmanager, hObject, 'positions'))%This control only makes sense when they exist.
        setLocalGh(progmanager, hObject, 'currentPosition', 'Enable', 'On');
        setLocalGh(progmanager, hObject, 'currentPositionSliderUp', 'Enable', 'On');%TO081606D
        setLocalGh(progmanager, hObject, 'currentPositionSliderDown', 'Enable', 'On');%TO081606D
    else
        setLocalGh(progmanager, hObject, 'currentPosition', 'Enable', 'Off');
        setLocalGh(progmanager, hObject, 'currentPositionSliderUp', 'Enable', 'Off');%TO081606D
        setLocalGh(progmanager, hObject, 'currentPositionSliderDown', 'Enable', 'Off');%TO081606D
    end
    setLocalGh(progmanager, hObject, 'newPosition', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'moveUp', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'deletePosition', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'moveDown', 'Enable', 'On');
    
    if ~isempty(getLocal(progmanager, hObject, 'availableConfigurations'))%These button only makes sense when one is selected.
        if ~isempty(getLocal(progmanager, hObject, 'positions'))
            setLocalGh(progmanager, hObject, 'addConfiguration', 'Enable', 'On');
            setLocalGh(progmanager, hObject, 'positionIterations', 'Enable', 'On');%TO092605B %TO022106A
        else
            setLocalGh(progmanager, hObject, 'addConfiguration', 'Enable', 'Off');
            setLocalGh(progmanager, hObject, 'positionIterations', 'Enable', 'Off');%TO092605B %TO022106A
        end
        setLocalGh(progmanager, hObject, 'availableConfigurations', 'Enable', 'On');
    else
        if ~isempty(getLocal(progmanager, hObject, 'positions'))
            setLocalGh(progmanager, hObject, 'addConfiguration', 'Enable', 'On');
            setLocalGh(progmanager, hObject, 'positionIterations', 'Enable', 'On');%TO092605B %TO022106A
        else
            setLocalGh(progmanager, hObject, 'addConfiguration', 'Enable', 'Off');
            setLocalGh(progmanager, hObject, 'positionIterations', 'Enable', 'Off');%TO092605B %TO022106A
        end
        setLocalGh(progmanager, hObject, 'availableConfigurations', 'Enable', 'Off');
    end
    if ~isempty(getLocal(progmanager, hObject, 'selectedConfigurations'))%This button only makes sense when one is selected.
        setLocalGh(progmanager, hObject, 'deleteSelectedConfiguration', 'Enable', 'On');
        setLocalGh(progmanager, hObject, 'selectedConfigurations', 'Enable', 'On');
    else
        setLocalGh(progmanager, hObject, 'deleteSelectedConfiguration', 'Enable', 'Off');
        setLocalGh(progmanager, hObject, 'selectedConfigurations', 'Enable', 'Off');
    end
    if ~isempty(getLocalGh(progmanager, hObject, 'selectedConfigurations', 'String'))
        setLocalGh(progmanager, hObject, 'loadConfigurations', 'Enable', 'On');
    else
        setLocalGh(progmanager, hObject, 'loadConfigurations', 'Enable', 'Off');
    end
    if ~isempty(getLocalGh(progmanager, hObject, 'availableConfigurations', 'String'))
        setLocalGh(progmanager, hObject, 'deleteAvailableConfiguration', 'Enable', 'On');
    else
        setLocalGh(progmanager, hObject, 'deleteAvailableConfiguration', 'Enable', 'Off');
    end
    setLocalGh(progmanager, hObject, 'currentProgram', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'configurationName', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'captureConfig', 'Enable', 'On');
end

return;
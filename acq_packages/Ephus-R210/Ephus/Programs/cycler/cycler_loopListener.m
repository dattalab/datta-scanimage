% cycler_loopListener - Callback for handling loop events.
%
% SYNTAX
%  cycler_loopListener(hObject, eventdata)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO092605B: Added the positionRepeats & positionRepeatsArray variables. -- Tim O'Connor 9/26/05
%  TO012706B: Created cycler_Iterate function to centralize some functionality. -- Tim O'Connor 1/26/06
%  TO022106A: Swapped positionRepeats for positionIterations. -- Tim O'Connor 2/21/06
%  TO022406B: Start iteration counter at 1 not 0. -- Tim O'Connor 2/24/06
%  TO031306A: Implemented board-based (precise) timing. As only one trigger is issued, cycles have no effect. -- Tim O'Connor 3/13/06
%  TO062806C: Implemented board-based (precise) timing, fully enabling cycles. -- Tim O'Connor 6/28/06
%  TO062806P: Reload the current position, if a CPU cycle proceeds a board-clock cycle. -- Tim O'Connor 6/28/06
%  TO080306A: Allow multiple acquisitions to be prequeued, and sequentially triggered, for fast CPU timing control. -- Tim O'Connor 8/3/06
%
% Created 9/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function cycler_loopListener(hObject, eventdata)
global loopManagers;

switch lower(eventdata.eventType)
    case 'loopstart'
        %TO080306A
        if getLocal(progmanager, hObject, 'precacheAllCycles')
            if getLocal(progmanager, hObject, 'enable')
                cycler_precacheEntireCycle(hObject);%TO062806C
            end
        else
            if getLocal(progmanager, hObject, 'enable')
                setLocal(progmanager, hObject, 'iterationCounter', 1);%TO092605B %TO022106A %TO022406B
                if getLocal(progmanager, hObject, 'refreshPosition')
                    cycler_loadEntirePosition(hObject);
                    setLocal(progmanager, hObject, 'refreshPosition', 0);
                end
            end
        end
        
    case 'loopstartprecisetiming'
        %TO062806C
        %if getLocal(progmanager, hObject, 'enable')
        %    warndlg('Cycler is enabled, but does not support DAQ Board timed loops. Cycle position update will only take effect once, at the end of the loop.', 'Not Supported');
        %end
        if getLocal(progmanager, hObject, 'enable')
            cycler_precacheEntireCycle(hObject);%TO062806C
        end
        % warning('NOT_YET_IMPLEMENTED: Loop Event - loopStartPreciseTiming');
        
    case 'loopiteration'
        %TO012706B - This now does nothing. The step is initated through the @startmanager, when applications have finished (it's more efficient this way, too).
        return;
%         %TO092605B %TO022106A
%         [enable, positions, currentPosition, positionRepeatsArray, iterationCounter] = ...
%             getLocalBatch(progmanager, hObject, 'enable', 'positions', 'currentPosition', 'positionRepeatsArray', 'iterationCounter');
% % pos = positions{currentPosition}
% % currentPosition
% % positionRepeatsArray
% % iterationCounter
%         if ~enable
%             return;
%         end        
%         if ~isempty(positions)
%             cycler_loadEntirePosition(hObject);
% 
%             %TO092605B
%             if positionRepeatsArray(currentPosition) <= iterationCounter
%                 if currentPosition == length(positions)
%                     currentPosition = 1;
%                 else
%                     currentPosition = currentPosition + 1;
%                 end
%                 iterationCounter = 1;
%             else
%                 iterationCounter = iterationCounter + 1;
%             end
% % psRepArr = positionRepeatsArray(currentPosition)
% % repCount = iterationCounter
% % posRepeats = positionRepeatsArray(currentPosition) - iterationCounter
%             setLocalBatch(progmanager, hObject, 'currentPosition', currentPosition, 'iterationCounter', iterationCounter);
%             setLocal(progmanager, hObject, 'positionRepeats', positionRepeatsArray(currentPosition) - iterationCounter);
%             cycler_currentPosition_Callback(hObject);
%         end
        
    case 'loopstop'
        
    otherwise
        error('Unsupported loop event recieved by cycler.');
end

return;
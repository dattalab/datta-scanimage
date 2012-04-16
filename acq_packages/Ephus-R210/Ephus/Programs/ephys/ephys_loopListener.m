% ephys_loopListener - Callback for handling loop events.
%
% SYNTAX
%  ephys_loopListener(hObject, eventdata)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO112205F: Only loop when started. -- Tim O'Connor 11/22/05
%  TO120105H: Flag when in the middle of a loop. -- Tim O'Connor 12/1/05
%  TO121505I: Don't stop the acquisition if there's a loopIteration event, issue an error instead. -- Tim O'Connor 12/15/05
%  TO010506C: Rework triggering scheme for ease of use and simpler looping. Switch to a checkbox for external, which leaves it always started. -- Tim O'Connor 1/5/06
%  TO031306A: Implemented board-based (precise) timing. As only one trigger is issued, cycles have no effect. -- Tim O'Connor 3/13/06
%
% Created 6/21/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephys_loopListener(hObject, eventdata)
global loopManagers;
% fprintf(1, '%s - ephys_loopListener\n', datestr(now));
switch lower(eventdata.eventType)
    case 'loopstart'
        %TO112205F
        if getLocal(progmanager, hObject, 'startButton')
            % fprintf(1, '%s - ephys_loopListener - loopstart\n', datestr(now));
            if ~getLocal(progmanager, hObject, 'externalTrigger')
                error('ephys must be set to external triggering for use in a loop.');
                stop(loopManager);
            end
            setLocal(progmanager, hObject, 'looping', 0);
            %TO121505I
            %             setLocal(progmanager, hObject, 'looping', 1);
            %             ephys_stop(hObject);
        end
        %ephys_start(hObject);%TO121505I - This will get picked up in the iteration event...
        
    case 'loopstartprecisetiming'
        %TO062806C
        if isprogram(progmanager, 'cycler')
            if getGlobal(progmanager, 'enable', 'cycler', 'cycler')
                return;
            end
        end
        
        %TO031306A
        [externalTrigger traceLength startButton] = getLocalBatch(progmanager, hObject, 'externalTrigger', 'traceLength', 'startButton');
        if startButton & ~externalTrigger
            error('ephys must be set to external triggering for use in a loop.');
        end

        if externalTrigger
            if traceLength ~= eventdata.interval
                warndlg('ephys: Trace length should be equal to the loop interval when using precise timing. It has been adjusted accordingly');
                setLocal(progmanager, hObject, 'traceLength', eventdata.interval);
            end
            
            setLocal(progmanager, hObject, 'externalTrigger', 0);
            ephys_Stop(hObject);
        end
        setLocal(progmanager, hObject, 'boardBasedTimingEvent', eventdata);
        if externalTrigger
            setLocal(progmanager, hObject, 'externalTrigger', 1);
            ephys_Start(hObject);
        end
        % warning('NOT_YET_IMPLEMENTED: Loop Event - loopStartPreciseTiming');
        
    case 'loopiteration'
        [looping, startButton] = getLocalBatch(progmanager, hObject, 'looping', 'startButton');
%         if startButton & looping
%             %TO121505I
%             fprintf(1, '%s - ephys_loopListener Warning: Loop iteration tried to execute before an acquisition has completed.\n%s\n', datestr(now), getStackTraceString);
%             return;
%             % fprintf(1, '%s - ephys_loopListener - loopiteration - stop\n', datestr(now));
%             %ephys_stop(hObject);%TO121505I
%         end
        if looping
            % fprintf(1, '%s - ephys_loopListener - loopiteration - start\n', datestr(now));
            %TO010506C
            %ephys_start(hObject);
        else
            setLocal(progmanager, hObject, 'looping', 1);
        end
     
    case 'loopstop'
        % fprintf(1, '%s - ephys_loopListener - loopstop\n', datestr(now));
        %TO121505I
        %ephys_stop(hObject);
        setLocal(progmanager, hObject, 'looping', 0);
        
    otherwise
        error('Unsupported loop event recieved by ephys.');
end

return;
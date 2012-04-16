% shared_loopListener - Callback for handling loop events.
%
% SYNTAX
%  shared_loopListener(hObject, eventdata)
%
% USAGE
%
% NOTES
%  Adapted from ephys_loopListener.m
%
% CHANGES
%  TO112205F: Only loop when started. -- Tim O'Connor 11/22/05
%  TO120105H: Flag when in the middle of a loop. -- Tim O'Connor 12/1/05
%  TO121505I: Don't stop the acquisition if there's a loopIteration event, issue an error instead. -- Tim O'Connor 12/15/05
%  TO010506C: Rework triggering scheme for ease of use and simpler looping. Switch to a checkbox for external, which leaves it always started. -- Tim O'Connor 1/5/06
%  TO031306A: Implemented board-based (precise) timing. As only one trigger is issued, cycles have no effect. -- Tim O'Connor 3/13/06
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%
% Created 6/21/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function shared_loopListener(hObject, eventdata)

% fprintf(1, '%s - ''%s_loopListener\n', datestr(now), getProgramName(progmanager, hObject));
switch lower(eventdata.eventType)
    case 'loopstart'
        %TO112205F
        if getLocal(progmanager, hObject, 'startButton')
            % fprintf(1, '%s - ''%s''_loopListener - loopstart\n', datestr(now), getProgramName(progmanager, hObject));
            if ~getLocal(progmanager, hObject, 'externalTrigger')
                stop(loopManager);
                error('''%s'' must be set to external triggering for use in a loop.', getProgramName(progmanager, hObject));
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
        if startButton && ~externalTrigger
            stop(loopManager);
            error('%s must be set to external triggering for use in a loop.', getProgramName(progmanager, hObject));
        end

        if externalTrigger
            if traceLength ~= eventdata.interval
                warndlg('ephys: Trace length should be equal to the loop interval when using precise timing. It has been adjusted accordingly');
                setLocal(progmanager, hObject, 'traceLength', eventdata.interval);
            end
            
            setLocal(progmanager, hObject, 'externalTrigger', 0);
            shared_Stop(hObject);
        end
        setLocal(progmanager, hObject, 'boardBasedTimingEvent', eventdata);
        if externalTrigger
            setLocal(progmanager, hObject, 'externalTrigger', 1);
            shared_Start(hObject);
        end
        % warning('NOT_YET_IMPLEMENTED: Loop Event - loopStartPreciseTiming');

    case 'loopiteration'
        [looping, startButton] = getLocalBatch(progmanager, hObject, 'looping', 'startButton');
        % if startButton & looping
        %    %TO121505I
        %    fprintf(1, '%s - ''%s''_loopListener Warning: Loop iteration tried to execute before an acquisition has completed.\n%s\n', datestr(now), getProgramName(progmanager, hObject), getStackTraceString);
        %    return;
        %    % fprintf(1, '%s - e''%s''_loopListener - loopiteration - stop\n', datestr(now), getProgramName(progmanager, hObject));
        %    %ephys_stop(hObject);%TO121505I
        % end
        if looping
            % fprintf(1, '%s - ''%s''_loopListener - loopiteration - start\n', datestr(now), getProgramName(progmanager, hObject));
            %TO010506C
            %ephys_start(hObject);
        else
            setLocal(progmanager, hObject, 'looping', 1);
        end

    case 'loopstop'
        % fprintf(1, '%s - ''%s''_loopListener - loopstop\n', datestr(now), getProgramName(progmanager, hObject));
        %TO121505I
        %ephys_stop(hObject);
% fprintf(1, '%s - ''%s''_loopListener: Got ''loopstop'' event, disabling ''autoRestart'' for all channels. Flagging that task reset is needed.\n', datestr(now), getProgramName(progmanager, hObject));
%         dj = daqjob('acquisition');
%         inputChannels = shared_getInputChannelNames(hObject);
%         for i = 1 : length(inputChannels)
%             setTaskProperty(dj, inputChannels{i}, 'autoRestart', 0);
%         end
%         outputChannels = shared_getOutputChannelNames(hObject);
%         for i = 1 : length(outputChannels)
%             setTaskProperty(dj, outputChannels{i}, 'autoRestart', 0);
%         end
%         setLocalBatch(progmanager, hObject, 'looping', 0, 'resetTaskWhenDone', 1);

    otherwise
        error('Unsupported loop event recieved by %s.', getProgramName(progmanager, hObject));
end

return;
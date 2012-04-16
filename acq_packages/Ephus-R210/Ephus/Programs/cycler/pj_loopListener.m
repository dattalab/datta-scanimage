% pj_loopListener - Callback for handling loop events.
%
% SYNTAX
%  pj_loopListener(hObject, eventdata)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO090706F - Make the position loading more intuitive, because pulses are loaded at the end of the previous trace, then the cycler appears 2 steps ahead. -- Tim O'Connor 9/7/06
%  TO091106A - Count number of running boards, for iterating during the loop. -- Tim O'Connor 9/11/06
%  TO091106E - Make sure that the callbacks are set up and the programs are hijacked on loopStart, since things may have been reset externally since the enable event. -- Tim O'Connor 9/11/06
%  TO101006B - Quit if not enabled. -- Tim O'Connor 10/10/06
%  TO101607G - Port to nimex. -- Tim O'Connor 10/16/07
%  TO101707D - Port to nimex. -- Tim O'Connor 10/17/07
%  TO102107A - We can't use the autoRestart feature with the pulseJacker, because some restarts will happen before @daqjob kicks the doneEvent up. -- Tim O'Connor 10/21/07
%  TO121307A - Force the current pulse to get updated. Which may not have occurred already if ephys/stim changed something before the loop started. -- Tim O'Connor 12/13/07
%
% Created 9/5/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function pj_loopListener(hObject, eventdata)

%TO101006B
if ~getLocal(progmanager, hObject, 'enable')
    return;
end

switch lower(eventdata.eventType)
    case 'loopstart'
        setLocal(progmanager, hObject, 'loopEventData', []);
        pj_hijack(hObject);%TO101707D
        aggregatedOutputChannels = {};%TO121307A
        %TO102107A
        programHandles = getLocal(progmanager, hObject, 'programHandles');
        for i = 1 : length(programHandles)
            if getLocalBatch(progmanager, programHandles(i), 'externalTrigger')
                outputChannelNames = shared_getOutputChannelNames(programHandles(i));
                job = daqjob('acquisition');
                for j = 1 : length(outputChannelNames)
                    setTaskProperty(job, outputChannelNames{j}, 'autoRestart', 0);
                end
                setLocal(progmanager, programHandles(i), 'resetTaskWhenDone', 1);

                %TO121307A
                if size(outputChannelNames, 1) > size(outputChannelNames, 2) || size(aggregatedOutputChannels, 1) > size(aggregatedOutputChannels, 2)
                    aggregatedOutputChannels = cat(1, aggregatedOutputChannels, outputChannelNames);
                else
                    aggregatedOutputChannels = cat(2, aggregatedOutputChannels, outputChannelNames);
                end
            end
        end

        %TO121307A - Force the current pulse to get updated. Which may not have occurred already if ephys/stim changed something before the loop started.
        stop(job, aggregatedOutputChannels{:});
        start(job, aggregatedOutputChannels{:});

        return;
        
    case 'loopstartprecisetiming'
        setLocal(progmanager, hObject, 'loopEventData', eventdata);
        pj_hijack(hObject);%TO101707D
        %TO102107A
        programHandles = getLocal(progmanager, hObject, 'programHandles');
        for i = 1 : length(programHandles)
            if getLocalBatch(progmanager, programHandles(i), 'externalTrigger')
                try
                    outputChannels = shared_getOutputChannelNames(programHandles(i));
                    if ~isempty(outputChannels)
                        job = daqjob('acquisition');
                        % commit(job, outputChannels{:});
                        stop(job, outputChannels{:});
                        start(job, outputChannels{:});
                    end
                catch
                    fprintf(2, '%s - pj_loopListener - Failed to restart channel(s) for external triggering for ''%s'': %s\n', ...
                        datestr(now), getProgramName(progmanager, programHandles(i)), lasterr);
                end
            end
        end
        return;
        
    case 'loopiteration'
        return;
        
    case 'loopstop'
        setLocal(progmanager, hObject, 'loopEventData', []);
        %TO102107A
%         programHandles = getLocal(progmanager, hObject, 'programHandles');
%         for i = 1 : length(programHandles)
%             if getLocalBatch(progmanager, programHandles(i), 'externalTrigger')
%                 outputChannelNames = shared_getOutputChannelNames(programHandles(i));
%                 job = daqjob('acquisition');
%                 for j = 1 : length(outputChannelNames)
%                     setTaskProperty(job, outputChannelNames{j}, 'autoRestart', 1);
%                 end
%             end
%         end
        return;
        
    otherwise
        error('Unsupported loop event recieved by pulseJacker: %s', eventdata.eventType);
end

return;
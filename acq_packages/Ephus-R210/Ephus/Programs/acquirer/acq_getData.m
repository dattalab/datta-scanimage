% acq_getData - Retrieve data that needs to be saved.
%
% SYNTAX
%  acq_getData(hObject)
%
% USAGE
%
% NOTES
%  This is a copy & paste job from acq_saveTrace.m, with some editting where necessary.
%
% CHANGES
%  TO032106D - The buffers have not been cleared from here for a long time. -- Tim O'Connor 3/22/06
%  TO050806B - Index traces by fields, not number of buffers (typo). -- Tim O'Connor 5/8/06
%  TO062306A - Only warn of an empty buffer if acquisition is enabled for that channel. -- Tim O'Connor 6/23/06
%  TO062806A - Changed reference to acqOn to look at acqOnArray instead. -- Tim O'Connor 6/28/06
%  BS062110A - full error report when data missing
%
% SEE ALSO
%  acq_saveTrace (TO123005E)
%
% Created 12/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function data = acq_getData(hObject)
% fprintf(1, '%s - acq_getData\n', datestr(now));
data = [];
[buffers status acqOnArray] = getLocalBatch(progmanager, hObject, 'saveBuffers', 'status', 'acqOnArray');%TO062806A
if isempty(buffers)
    return;
end
for i = 1 : length(buffers)
    if eval(sprintf('~isempty(buffers.trace_%s.data)', num2str(i)))
        break;
    end
    if i == length(buffers)
        return;
    end
end

setLocal(progmanager, hObject, 'status', 'Marshalling data...');

fields = fieldnames(buffers);
%TO050806B
for i = 1 : length(fields)
    if eval(sprintf('~isempty(buffers.trace_%s.data)', num2str(i)))
        eval(sprintf('data.trace_%s = buffers.trace_%s.data;', num2str(i), num2str(i)));
% fprintf(1, '%s - acq_getData: length=%s\n', datestr(now), eval(sprintf('length(trace_%s.data);', num2str(i))));
%         if exist(fname) == 2
%             eval(sprintf('save(''%s'', ''trace_%s'', ''-mat'', ''-append'');', fname, num2str(i)));
%         else
%             eval(sprintf('save(''%s'', ''trace_%s'', ''-mat'');', fname, num2str(i)));
%         end
    else
        %TO062306A %TO062806A
        if acqOnArray(i)
            msg = sprintf('Warning: Ignoring call to save acquirer trace_%s because buffer %s is empty.\n', num2str(i), num2str(i));
            reportError(msg, fields, hObject, buffers, acqOnArray);
        end
    end
end

%TO032106D - Clear the buffers on the beginning of the next acquisition, instead. -- Tim O'Connor 3/21/06
%TO121205A - Clear buffers immediately after saving, and do not save empty buffers.
% setLocalBatch(progmanager, hObject, 'status', status, 'saveBuffers', buffers);
setLocalBatch(progmanager, hObject, 'status', status);
% fprintf(1, '%s - acq_getData - Status set to ''%s''\n', datestr(now), status);
return;

end

function reportError(msg, fields, hObject, buffers, acqOnArray)
        autonotes_addNote(msg);
        warndlg(msg);
        fprintf(2, '%s\n%s', msg, getStackTraceString);
        beep;
        fprintf(1, '\n************************\nProgram state:');
        [sampleRate, traceLength, updateRate, displayWidth, boardBasedTimingEvent, continuousAcqMode, sampleCount] = getLocalBatch(progmanager, hObject, ...
            'sampleRate', 'traceLength', 'updateRate', 'displayWidth', 'boardBasedTimingEvent', 'continuousAcqMode', 'sampleCount')
        acqOnArray
        fprintf(1, '\n************************\nBuffer contents:');
        buffers
        try
            for j = 1 : length(fields)
                buffers.(fields{i})
                if isfield(buffers.(fields{i}), 'debug')
                    debugInfo = buffers.(fields{i}).debug
                    creationStackTrace = buffers.(fields{i}).debug.creationStackTrace %TO042210D
                    resetStackTrace = buffers.(fields{i}).debug.resetStackTrace %TO042210D
                end
            end
        catch
            fprintf(2, 'Failed to dump buffer contents: %s\n', lasterr);
        end
        fprintf(1, '\n************************\n\n\n\n\n\n');
end

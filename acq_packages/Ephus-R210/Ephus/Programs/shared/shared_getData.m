% shared_getData - Retrieve data that needs to be saved.
%
% SYNTAX
%  data = shared_getData(hObject)
%   hObject - The program's handle.
%   data - The program's acquired data.
%
% USAGE
%
% NOTES
%  This is a copy & paste job from acquirer_getData.m, with some editting where necessary.
%  Adapted from ephys_getData.m
%
% CHANGES
%  TO032106D - The buffers have not been cleared from here for a long time. -- Tim O'Connor 3/22/06
%  TO050806B - Index traces by fields, not number of buffers (typo). -- Tim O'Connor 5/8/06
%  TO062306A - Only warn of an empty buffer if acquisition is enabled for that channel. -- Tim O'Connor 6/23/06
%  TO062806A - Changed reference to acqOn to look at acqOnArray instead. -- Tim O'Connor 6/28/06
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO043008E - Keep timestamps for each data append. Store other informational fields, if possible. -- Tim O'Connor 4/30/08
%  TO041609B - Reworked the optimizations that check for empty buffers and quit early. The previous implementation was buggy. -- Tim O'Connor 4/16/09
%  TO021510F - Implemented disk streaming. -- Tim O'Connor 2/15/10
%  TO021610F - For some reason, this never needed to conditionally check 'channelName' before, but it does now. This seems right as it is now. -- Tim O'Connor 2/16/10
%  TO030210E - Added clearBuffersOnGetData. See also TO032106D and TO121205A. -- Tim O'Connor 3/2/10
%  TO030210F - Replaced sprintf calls with array concatenation (using square brackets). -- Tim O'Connor 3/2/10
%  TO031510A - Fixed a bunch of the logic in here, to clean it up and solve a big where the channelName field wasn't getting carried over. -- Tim O'Connor 3/15/10
%  TO042010B - Add more instrumentation for the case when the buffer(s) are empty. -- Tim O'Connor 4/20/10
%  TO042210D - Possibly return immediately if acquisitions aren't enabled? Some more debugging, as per TO042010B, too. -- Tim O'Connor 4/22/10
%  TO052110A - Add a flag (dataToBeSaved) to indicate that there is data that needs to be saved. -- Tim O'Connor 5/21/10
%  BS062110A - full error report when data missing
%
% SEE ALSO
%  ephys_saveTrace (TO123005E) --> shared_saveTrace (TO101707F)
%
% Created 12/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function data = shared_getData(hObject)
% fprintf(1, '%s - ''%s''_getData\n', datestr(now), getProgramName(progmanager, hObject));
data = [];

if xsg_isDiskStreamingEnabled
    return;
end

[buffers, status, acqOnArray, clearBuffersOnGetData, startButton, dataToBeSaved] = getLocalBatch(progmanager, hObject, ...
    'saveBuffers', 'status', 'acqOnArray', 'clearBuffersOnGetData', 'startButton', 'dataToBeSaved');%TO062806A %TO042210D

if isempty(buffers)
    return;
end
%TO042210D
% if ~any(acqOnArray)
%     return;
% end

fields = fieldnames(buffers);
for i = 1 : length(fields)
    if ~isempty(buffers.(fields{i}).data)
        break;
    end
    if dataToBeSaved && i == length(fields) && any(acqOnArray) %TO042210D %TO052110A
        msg = sprintf('Warning: Ignoring call to save ''%s'' data because all buffers are empty.', getProgramName(progmanager, hObject));
        reportError(msg, fields, hObject, buffers, acqOnArray);
    end
end

setLocal(progmanager, hObject, 'status', 'Marshalling data...');

%acqOn = getLocal(progmanager, hObject, 'acqOn');%TO062306A%TO062806A
%TO050806B
for i = 1 : length(fields)
    iStr = num2str(i);%TO030210F
    bufferName = fields{i};%TO030210F %TO031510A
    if eval(['~isempty(buffers.' bufferName '.data)'])
        eval(['data.' bufferName ' = buffers.' bufferName '.data;']);
        eval(['data.dataEventTimestamps_' iStr ' = buffers.' bufferName '.dataEventTimestamps;']);%TO043008E
        %TO021610F - For some reason, this never needed to conditionally check 'channelName' before, but it does now. This seems right as it is now. -- Tim O'Connor 2/16/10
        if isfield(buffers.(bufferName), 'channelName')
            eval(['data.channelName_' iStr ' = buffers.' bufferName '.channelName;']);%TO043008E
        end
        if isfield(buffers.(bufferName), 'amplifierName')
            eval(['data.amplifierName_' iStr ' = buffers.' bufferName '.amplifierName;']);%TO043008E
        end
        if clearBuffersOnGetData %TO030210E
            buffers = shared_resetBuffer(buffers, bufferName, buffers.(bufferName).channelName, buffers.(bufferName).amplifierName, buffers.(bufferName).sampleRate);
        end
% fprintf(1, ' Returning %s samples for trace_%s.\n', num2str(length(data.(bufferName))), iStr);
% fprintf(1, '%s - ''%s''_getData: length=%s\n', datestr(now), getProgramName(progmanager, hObject), eval(sprintf('length(trace_%s.data);', num2str(i))));
%         if exist(fname) == 2
%             eval(sprintf('save(''%s'', ''trace_%s'', ''-mat'', ''-append'');', fname, num2str(i)));
%         else
%             eval(sprintf('save(''%s'', ''trace_%s'', ''-mat'');', fname, num2str(i)));
%         end
    else
% fprintf(1, 'shared_getData: Found no data in trace_%s.\n', num2str(i));
        %TO062306A %TO062806A %TO042210D
        if acqOnArray(i) && startButton
            msg = sprintf('Warning: Ignoring call to ''%s''_getData for trace_%s because buffer %s is empty.\n', getProgramName(progmanager, hObject), iStr, iStr);
            reportError(msg, fields, hObject, buffers, acqOnArray);
        end
    end
end

%TO032106D - Clear the buffers on the beginning of the next acquisition, instead. -- Tim O'Connor 3/21/06
%TO121205A - Clear buffers immediately after saving, and do not save empty buffers.
% setLocalBatch(progmanager, hObject, 'status', status, 'saveBuffers', buffers);
setLocalBatch(progmanager, hObject, 'status', status, 'saveBuffers', buffers, 'dataToBeSaved', 0);%TO030210E %TO052110A
% fprintf(1, '%s - ephys_getData - Status set to ''%s''\n', datestr(now), status);

return;

%--------------------------------------------------------------------------
function reportError(hObject, fields, msg, buffers, acqOnArray)

autonotes_addNote(msg);
warndlg(msg);
fprintf(2, '%s\n%s', msg, getStackTraceString);
beep;

fprintf(1, '\n************************\nProgram state:');
[sampleRate, traceLength, updateRate, displayWidth, boardBasedTimingEvent, continuousAcqMode, sampleCount] = getLocalBatch(progmanager, hObject, ...
    'sampleRate', 'traceLength', 'updateRate', 'displayWidth', 'boardBasedTimingEvent', 'continuousAcqMode', 'sampleCount')
acqOnArray
daqjob('acquisition')
fprintf(1, '\n************************\nBuffer contents:');
buffers
for i = 1 : length(fields)
    try
        fprintf(1, 'buffers.(%s: ''%s'') - \n', num2str(i), fields{i});
        fprintf(1, '\tsize: %s\n', mat2str(size(buffers.(fields{i}))));
        fprintf(1, '\tclass: %s\n', class(buffers.(fields{i})));
        if isfield(buffers.(fields{i}), 'debug')
            debugInfo = buffers.(fields{i}).debug
            creationStackTrace = buffers.(fields{i}).debug.creationStackTrace %TO042210D
            resetStackTrace = buffers.(fields{i}).debug.resetStackTrace %TO042210D
        end
    catch
        fprintf(2, 'Failed to dump buffer contents: %s\n', lasterr);
    end
end
fprintf(1, '\n************************\n\n\n\n\n\n');

return;
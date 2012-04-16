% acq_saveTrace - Save the previously acquired trace to a given file.
%
% SYNTAX
%  acq_saveTrace(hObject)
%  acq_saveTrace(hObject, filename)
%   filename - The file in which to save the trace.
%
% USAGE
%
% NOTES
%  This is a copy & paste job from ephys_saveTrace.m, with some editting where necessary.
%
% CHANGES
%  TO100405A: Added the 'filename' option, to allow 'SaveAs' functionality. -- Tim O'Connor 10/4/05
%  TO120105A: Implemented real headers. -- Tim O'Connor 12/1/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO120205B: Optimization. -- Tim O'Connor 12/2/05
%  TO121205A: Don't save empty buffers? -- Tim O'Connor 12/6/05
%  TO121305B: Wait for all data to flush into the buffer. -- Tim O'Connor 12/12/05
%  TO121605B: Check for data to save before prompting to overwrite a file. -- Tim O'Connor 12/16/05
%  TO123005E: Created acq_getData and ephys_getData. -- Tim O'Connor 12/30/05
%  TO123005F: Moved primary saving responsibility into xsg_saveData. Only clear the buffers on start. -- Tim O'Connor 12/30/05
%  TO071906D - Make sure `save` makes Matlab v6 compatible files. -- Tim O'Connor 7/19/06
%
% Created 12/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function acq_saveTrace(hObject, varargin)
% getStackTraceString
% fprintf(1, '%s - acq_saveTrace\n', datestr(now));

%TO123005E
% %TO121605B - Check for data to save before prompting to overwrite a file. -- Tim O'Connor 12/16/05
% buffers = getLocal(progmanager, hObject, 'saveBuffers');
% for i = 1 : length(buffers)
%     if eval(sprintf('~isempty(buffers.trace_%s.data)', num2str(i)))
%         break;
%     end
%     if i == length(buffers)
% % fprintf(1, '%s - ephys_saveTrace: NO_DATA_1\n', datestr(now));
%         return;
%     end
% end
% 
% %TO100405A
% buffers = getLocal(progmanager, hObject, 'saveBuffers');%TO121305B

if isempty(varargin)
    fname = [xsg_getFilename '.acq'];
    
    if exist(fname) == 2
        yesOrNo = questdlg(sprintf('%s\nFile exists. Overwrite?', fname), 'Overwrite file?', 'No');
        if strcmpi(yesOrNo, 'No')
            fname = uiputfile('*.acq', 'Save Trace');
            if fname == 0
                return;
            end
            if ~endsWithIgnoreCase(fname, '.acq')
                fname = [fname '.acq'];
            end
        elseif strcmpi(yesOrNo, 'Cancel')
            return;
        end
    end
else
    fname = varargin{1};
end

% triggerTime = getTriggerTime(startmanager('acquisition'));
% [buffers, amplifiers] = getLocalBatch(progmanager, hObject, 'saveBuffers', 'amplifiers');%TO120205B: Optimization. -- Tim O'Connor 12/2/05

setLocal(progmanager, hObject, 'status', 'Writing data...');

% fields = fieldnames(buffers);

%TO120105A
header = getHeaders(progmanager);
data = acq_getData(hObject);%TO123005E

setLocal(progmanager, hObject, 'status', 'Writing data...');
saveCompatible(fname, 'header', 'data');%TO071906D

%TO123005E
% for i = 1 : length(buffers)
%     if eval(sprintf('~isempty(buffers.trace_%s.data)', num2str(i))) %TO121205A - Don't save empty buffers? -- Tim O'Connor 12/6/05
%         eval(sprintf('trace_%s.data = buffers.trace_%s.data;', num2str(i), num2str(i)));
% % fprintf(1, '%s - acq_saveTrace: length=%s\n', datestr(now), eval(sprintf('length(trace_%s.data);', num2str(i))));
%         eval(sprintf('trace_%s.header = header;', num2str(i)));
%         if exist(fname) == 2
%             eval(sprintf('save(''%s'', ''trace_%s'', ''-mat'', ''-append'');', fname, num2str(i)));
%         else
%             eval(sprintf('save(''%s'', ''trace_%s'', ''-mat'');', fname, num2str(i)));
%         end
%     else
%         fprintf(2, 'Warning: Ignoring call to save trace because buffers are empty.\n');
%     end
%
%     %TO121205A - Clear the buffer.
%     buffers.(['trace_' num2str(i)]).data = [];
%     buffers.(['trace_' num2str(i)]).debug.resetStackTrace = getStackTraceString;
% end

%TO121205A - Clear buffers immediately after saving, and do not save empty buffers.
setLocalBatch(progmanager, hObject, 'status', '');%TO123005F - Only clear the buffers on start.

return;
% autonotes_addNote - Add a new entry to the current autonotes file/gui.
%
% SYNTAX
%  autonotes_addNote(note)
%  autonotes_addNote(note, ...)
%    note - A text message to be added to the file/gui, a timestamp will be automatically prepended.
%           The fprintf syntax is supported directly by this function.
%
% NOTES
%  Strings and variables may be formatted directly when calling this function, as with `fprintf`.
%
% CHANGES
%  TO082907A - Limit display size to 1024 characters. -- Tim O'Connor 8/29/07
%  TO031610B - Handle cases when the autonotes program isn't running. --Tim O'Connor 3/16/10
%
% Created 12/9/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function autonotes_addNote(varargin)

%TO082907A - Don't process empty notes.
if isempty(varargin)
    return;
end
if isempty(varargin{1})
    return;
end

note = sprintf(varargin{:});%Process any formatting commands.
note = [datestr(now, 13) ' - ' note];%Timestamp and carriage return.

%TO031610B
if ~isprogram(progmanager, 'autonotes')
    fprintf(2, 'Message sent to autnotes (which is not currently running):\n');
    fprintf(1, '\t%s\n', note);
    return;
end

hObject = getGlobal(progmanager, 'hObject', 'autonotes', 'autonotes');
[filename, displayActive, log] = getLocalBatch(progmanager, hObject, 'filename', 'displayActive', 'log');

if ~isempty(filename)
    if ~endsWithIgnoreCase(filename, '.txt')
        filename = [filename '.txt'];
    end
    [fid message] = fopen(filename, 'at');
    if ~isempty(message)
        error('Failed to open file ''%s'' - %s', filename, message);
    end
    % fprintf(fid, '%s %s\r\n', datestr(now, 2), note);
    fprintf(fid, '%s\r\n', note);
    setGlobalGh(progmanager, 'filename', 'autonotes', 'autonotes', 'ForegroundColor', [0 0 0]);

    fclose(fid);
else
    warning('No autonotes file selected.');
end

% fprintf(1, 'autonotes: %s\n', note);

if displayActive
    if length(log) > 2048
        log = log(end - 2048 : end);
    end
    s = [log note sprintf('\n')];
    setLocalBatch(progmanager, hObject, 'log', s, 'textSlider', 0);
    autonotes_setScroll(hObject);
end

return;
% autonotes_setFilename - Set the output file, for logging notes.
%
% SYNTAX
%  autonotes_setFilename(filename)
%   filename - The new file in which to log data.
%
% NOTES
%
% CHANGES
%
% Created 8/29/07 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function autonotes_setFilename(filename)

if ~isprogram(progmanager, 'autonotes')
    return;
end

if ~endsWithIgnoreCase(filename, '.txt')
    filename = [filename '.txt'];
end
setGlobal(progmanager, 'filename', 'autonotes', 'autonotes', filename);

autonotes_clearGui;
[fid message] = fopen(filename, 'at');
if ~isempty(message)
    error('Failed to open file ''%s'' - %s', filename, message);
end
fprintf(fid, '%s New notes initialized.\r\n', datestr(now));
setGlobalGh(progmanager, 'filename', 'autonotes', 'autonotes', 'ForegroundColor', [0 0 0]);

fclose(fid);

return;
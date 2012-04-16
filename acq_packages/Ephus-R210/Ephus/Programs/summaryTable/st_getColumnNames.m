% columnNames = st_getColumnNames(hObject)
%
% Get the column names of a running summaryTable program, represented by the hObject handle.
%
% Created: Tim O'Connor 12/16/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function columnNames = st_getColumnNames(hObject)

columnNames = getLocal(progmanager, hObject, 'columnNames');

return;
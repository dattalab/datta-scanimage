% st_getTableData(hObject)
%
% Get the table data displayed by a running summaryTable program.
%
% Created: Tim O'Connor 1/10/05
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function tableData = st_getTableData(hObject)

tableData = getLocal(progmanager, hObject, 'tableData');

return;
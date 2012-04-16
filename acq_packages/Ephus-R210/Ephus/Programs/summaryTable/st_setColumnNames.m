% st_setColumnNames(hObject, columnNames)
%
% Set the column names of a running summaryTable program, represented by the hObject handle.
%
% NOTE: The columnNames must be a cell array with a length equal to the length of the second
%       dimension of the table data.
%
% Created: Tim O'Connor 12/14/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_setColumnNames(hObject, columnNames)

if length(columnNames) ~= size(getLocal(progmanager, hObject, 'tableData'), 2)
    error('The length of columnNames must match the number of columns in the tableData.');
end

setLocal(progmanager, hObject, 'columnNames', columnNames);
st_refreshColumnNames(hObject);

return;
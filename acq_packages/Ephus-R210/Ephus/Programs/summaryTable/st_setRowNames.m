% st_setRowNames(hObject, rowNames)
%
% Set the row names of a running summaryTable program, represented by the hObject handle.
%
% NOTE: The rowNames must be a cell array with a length equal to the length of the first
%       dimension of the table data.
%
% Created: Tim O'Connor 12/14/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_setRowNames(hObject, rowNames)

if length(rowNames) ~= size(getLocal(progmanager, hObject, 'tableData'), 1)
    error('The length of rowNames must match the number of rows in the tableData.');
end

setLocal(progmanager, hObject, 'rowNames', rowNames);
st_refreshRowNames(hObject);

return;
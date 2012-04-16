% st_setSingleElementValue(hObject, row, column, value)
%
% Set the value of a single table cell identified by row and column.
%
% The value must be a string or a number.
%
% Created: Tim O'Connor 12/29/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_setSingleElementValue(hObject, row, column, value)

tableData = getLocal(progmanager, hObject, 'tableData');

if row > size(tableData, 1)
    error('Row out of range.');
elseif column > size(tableData, 2)
    error('Column out of range.');
end

if isnumeric(value)
    value = num2str(value);
end

tableData{row, column} = value;

setLocal(progmanager, hObject, 'tableData', tableData);

st_refreshDataDisplay(hObject, row, column);

return;
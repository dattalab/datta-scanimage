% st_setSingleElementColor(hObject, row, column, color)
%
% Set the value of a single table cell identified by row and column.
%
% The value must be a string or a number.
%
% Created: Tim O'Connor 12/29/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_setSingleElementColor(hObject, row, column, color)

if length(color) ~= 3
    error('Color must be specified as a 3 element RGB vector.');
end

tableColors = getLocal(progmanager, hObject, 'tableColors');
if isempty(tableColors)
    tableColors = cell(size(getLocal(progmanager, hObject, 'tableData')));
    tableColors(:, :) = {[1 1 1]};
end

checkForEmpties = 0;
if size(tableColors, 1) < row | size(tableColors, 2) < column
    maxRow = size(tableColors, 1);
    maxColumn = size(tableColors, 2);
    checkForEmpties = 1;
end

tableColors{row, column} = color;

if checkForEmpties
%         for i = 1 : max(row, size(tableColors, 1))
%         for j = 1 : max(column, size(tableColors, 2))
    for i = max(1, maxRow - 1) : row
        for j = max(1, maxColumn - 1) : column
            if isempty(tableColors{i, j})
                tableColors{i, j} = [1 1 1];
            end
        end
    end
end

setLocal(progmanager, hObject, 'tableColors', tableColors);

st_refreshColors(hObject, row, column);

return;
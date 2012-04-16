% st_setAllFields(summaryTable, tableData, rowNames, columnNames, colors)
%
% Set all the table's mutable fields at once.
%
% Created: Tim O'Connor 1/10/05
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function st_setAllFields(hObject, tableData, rowNames, columnNames, tableColors)

if ~isempty(rowNames) & length(rowNames) ~= size(tableData, 1)
    error('Number of row names must equal the number of data rows.');
elseif ~isempty(columnNames) & length(columnNames) ~= size(tableData, 2)
    error('Number of column names must equal the number of data rows.');
elseif ~isempty(tableColors) & any(size(tableColors) ~= size(tableData))
    error('Number of color specifications must equal the number of data elements.');
end

if getLocal(progmanager, hObject, 'rowOffset') + 20 > size(tableData, 1)
    setLocal(progmanager, hObject, 'rowOffset', max(1, size(tableData, 1) - 20));
end
if size(tableData, 1) < 20
    setLocal(progmanager, hObject, 'rowOffset', 0);
end

if getLocal(progmanager, hObject, 'columnOffset') + 8 > size(tableData, 2)
    setLocal(progmanager, hObject, 'columnOffset', max(1, size(tableData, 2) - 8));
end
if size(tableData, 2) < 8
    setLocal(progmanager, hObject, 'columnOffset', 0);
end

if isnumeric(tableData)
    cellData = cell(size(tableData));
    
    for i = 1 : size(tableData, 1)
        for j = 1 : size(tableData, 2)
            cellData{i, j} = num2str(tableData(i, j));
        end
    end
    
    tableData = cellData;
end

setLocal(progmanager, hObject, 'tableData', tableData);

if ~isempty(rowNames)
    setLocal(progmanager, hObject, 'rowNames', rowNames);
end
if ~isempty(columnNames)
    setLocal(progmanager, hObject, 'columnNames', columnNames);
end
if ~isempty(tableColors)
    setLocal(progmanager, hObject, 'tableColors', tableColors);
end

st_refreshDataDisplay(hObject);
st_refreshColors(hObject);

return;
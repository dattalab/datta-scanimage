% st_setTableData(hObject, tableData)
%
% Set the table data to be displayed by a running summaryTable program. The data must be
% a 2 dimensional numeric array or cell array of strings.
%
% Created: Tim O'Connor 12/14/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_setTableData(hObject, tableData)

if length(size(tableData)) > 2
    error('Table data must be a 2 dimensional cell array of strings.');
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

% if getLocal(progmanager, hObject, 'rowOffset') + 20 > size(tableData, 1)
%     setLocal(progmanager, hObject, 'rowOffset', size(tableData, 1));
% end
% if getLocal(progmanager, hObject, 'columnOffset') + 8 > size(tableData, 2)
%     setLocal(progmanager, hObject, 'columnOffset', size(tableData, 2));
% end
if getLocal(progmanager, hObject, 'rowOffset') + 20 > size(tableData, 1)
    setLocal(progmanager, hObject, 'rowOffset', max(1, size(tableData, 1) - 20));
end
if getLocal(progmanager, hObject, 'columnOffset') + 8 > size(tableData, 2)
    setLocal(progmanager, hObject, 'columnOffset', max(1, size(tableData, 2) - 8));
end

rowNames = getLocal(progmanager, hObject, 'rowNames');
if  ~isempty(rowNames) | length(rowNames) < size(tableData, 1)
    for i = length(rowNames) + 1 : size(tableData, 1)
        rowNames{i} = '';
    end
end

columnNames = getLocal(progmanager, hObject, 'columnNames');
if  ~isempty(columnNames) | length(columnNames) < size(tableData, 2)
    for i = length(columnNames) + 1 : size(tableData, 2)
        columnNames{i} = '';
    end
end

if ~strcmpi(class(tableData), 'cell')
    error('Table data must be a 2 dimensional cell array of strings.');
end

setLocal(progmanager, hObject, 'tableData', tableData);

st_refreshDataDisplay(hObject);

return;
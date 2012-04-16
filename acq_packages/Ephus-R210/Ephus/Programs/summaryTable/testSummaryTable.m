%Initialize a summaryTable program, with basically arbitrary data in the table.
%Specifying any argument to this function will cause it to use custom names for the columns/rows,
%while invoking this without any args will cause the program to use the default names.
%
% It returns the handle to the running program, you can then call the functions
% associated with the program manually to test stuff out.
function hObject = testSummaryTable(varargin)

openProgram(progmanager, program('TestSummaryTable', 'summaryTable'))

hObject = getGlobal(progmanager, 'hObject', 'summaryTable', 'TestSummaryTable');

numberOfRows = 52;
numberOfColumns = 40;

c = cell(numberOfRows, numberOfColumns);
for i = 1 : numberOfRows
    for j = 1 : numberOfColumns
        c{i, j} = [num2str(i) '-' num2str(j)];
    end
end

st_setTableData(hObject, c);

st_setCellSelectionCallback(hObject, {@cellSelectionCallback, 'testarg'});

if ~isempty(varargin)
    rowNames = cell(numberOfRows, 1);
    for i = 1 : numberOfRows
        rowNames{i} = ['Row-' num2str(i)];
    end
    st_setRowNames(hObject, rowNames);
    
    columnNames = cell(numberOfColumns, 1);
    for i = 1 : numberOfColumns
        columnNames{i} = ['Column-' num2str(i)];
    end
    st_setColumnNames(hObject, columnNames);
end

return;

%---------------------------------------------------------------
function cellSelectionCallback(testarg, row, column)

msgbox(sprintf('%s - row: %s column: %s\n', testarg, num2str(row), num2str(column)));

return;
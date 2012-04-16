% st_refreshColors(hObject)
% st_refreshColors(hObject, row, column)
%
% Update the color coding of a running summaryTable program, represented by the hObject handle.
%
% Specifying a row and column will update only the specified cell(s), for efficiency.
%
% Created: Tim O'Connor 12/29/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_refreshColors(hObject, varargin)

colors = getLocal(progmanager, hObject, 'tableColors');
if isempty(colors)
    return;
end

data = getLocal(progmanager, hObject, 'tableData');
rowOffset = getLocal(progmanager, hObject, 'rowOffset');
columnOffset = getLocal(progmanager, hObject, 'columnOffset');

maxRow = max(size(data, 1), 20);
maxColumn = max(size(data, 2), 8);

if length(varargin) == 2
    %Do only specified cells.
    row = varargin{1};
    column = varargin{2};
    
    for i = 1 : length(row)
        for j = 1 : length(column)
            if row(i) > size(data, 1)
                error('Row out of range.');
            elseif column(i) > size(data, 2)
                error('Column out of range.');
            end
            
            if row(i) > rowOffset & row(i) <= maxRow & ...
                column(i) > columnOffset & column <= maxColumn

                set(st_getCellHandle(hObject, row(i) - rowOffset, column(i) - columnOffset), 'BackgroundColor', ...
                    colors{row(i), column(i)});
            end
        end
    end
else
    for i = 1 : min(size(data, 1), 20)
        for j = 1 : min(size(data, 2), 8)
            if (i + rowOffset) > size(colors, 1) | (j + columnOffset) > size(colors, 2)
                set(st_getCellHandle(hObject, i, j), 'BackgroundColor', [1 1 1]);
            else
                set(st_getCellHandle(hObject, i, j), 'BackgroundColor', colors{i + rowOffset, j + columnOffset});
            end
        end
    end
    
    for i = min(size(data, 1), 20) + 1 : 20
        for j = min(size(data, 2), 8) + 1 : 8
            set(st_getCellHandle(hObject, i, j), 'BackgroundColor', [1 1 1]);
        end
    end
end

return;
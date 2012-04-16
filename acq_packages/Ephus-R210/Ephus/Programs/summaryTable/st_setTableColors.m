% st_setTableColors(hObject, tableColors)
%
% Set the table colors to be displayed by a running summaryTable program. The colors must be
% a 2 dimensional cell array of color specifications (RBG values). The size must match
% the size of the table data.
%
% Created: Tim O'Connor 12/29/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_setTableColors(hObject, tableColors)

if length(size(tableColors)) > 2
    error('Table colors must be a 2 dimensional cell array of RGB values.');
end

if ~strcmpi(class(tableData), 'cell')
    error('Table colors must be a 2 dimensional cell array of RGB values.');
end

if any(size(tableColors) ~= size(getLocal(progmanager, hObject, 'tableData')))
    error('Table color specification must be a 1 to 1 mapping of table data.');
end

setLocal(progmanager, hObject, 'tableColors', tableColors);
st_refreshColors(hObject);

return;
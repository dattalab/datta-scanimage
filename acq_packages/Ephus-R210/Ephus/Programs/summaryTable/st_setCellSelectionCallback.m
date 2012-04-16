% st_setCellSelectionCallback(hObject, cellSelectionCallback)
%
% Set the cellSelectionCallback of a running summaryTable program, represented by the hObject handle.
%
% NOTE: The cellSelectionCallback must be a handle to a function which takes a row number and a column 
%       number as its last two arguments. It may also be a cell array, a function and a set of arguments, to
%       which the row and column number will be appended.       
%
% Created: Tim O'Connor 12/14/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_setCellSelectionCallback(hObject, cellSelectionCallback)

if strcmpi(class(cellSelectionCallback), 'cell')
    if ~strcmpi(class(cellSelectionCallback{1}), 'function_handle')
        error('The first element of the cellSelectionCallback cell array must be a function_handle.');
    end
elseif ~strcmpi(class(cellSelectionCallback), 'function_handle')
    error('cellSelectionCallback must be a function_handle.');
end

setLocal(progmanager, hObject, 'cellSelectionCallback', cellSelectionCallback);

return;
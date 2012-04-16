% st_setColumnSelectionCallback(hObject, rowSelectionCallback)
%
% Set the columnSelectionCallback of a running summaryTable program, represented by the hObject handle.
%
% NOTE: The columnSelectionCallback must be a handle to a function which takes a column number last two argument. 
%       It may also be a cell array, a function and a set of arguments, to which the column number will be appended.       
%
% Created: Tim O'Connor 12/17/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_setColumnSelectionCallback(hObject, columnSelectionCallback)

if strcmpi(class(columnSelectionCallback), 'cell')
    if ~strcmpi(class(columnSelectionCallback{1}), 'function_handle')
        error('The first element of the columnSelectionCallback cell array must be a function_handle.');
    end
elseif ~strcmpi(class(columnSelectionCallback), 'function_handle')
    error('columnSelectionCallback must be a function_handle.');
end

setLocal(progmanager, hObject, 'columnSelectionCallback', columnSelectionCallback);

return;
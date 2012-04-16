% st_setRowSelectionCallback(hObject, rowSelectionCallback)
%
% Set the rowSelectionCallback of a running summaryTable program, represented by the hObject handle.
%
% NOTE: The rowSelectionCallback must be a handle to a function which takes a row number last two argument. 
%       It may also be a cell array, a function and a set of arguments, to which the row number will be appended.       
%
% Created: Tim O'Connor 12/17/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_setRowSelectionCallback(hObject, rowSelectionCallback)

if strcmpi(class(rowSelectionCallback), 'cell')
    if ~strcmpi(class(rowSelectionCallback{1}), 'function_handle')
        error('The first element of the rowSelectionCallback cell array must be a function_handle.');
    end
elseif ~strcmpi(class(rowSelectionCallback), 'function_handle')
    error('rowSelectionCallback must be a function_handle.');
end

setLocal(progmanager, hObject, 'rowSelectionCallback', rowSelectionCallback);

return;
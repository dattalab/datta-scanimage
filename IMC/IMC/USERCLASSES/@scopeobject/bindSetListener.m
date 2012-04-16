% bindSetListener - Bind a listener for calls to the 'set' method.
%
% SYNTAX
%   bindSetListener(SCOPEOBJECT, listenerFunction)
%       listenerFunction - A string, cell array (starting with a function_handle), or a function_handle.
%
% USAGE
%
% NOTES:
%   This is intended for GUIs to use, to know when to update themselves to match the object.
%
% CHANGES:
%
% Created 2/4/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function bindSetListener(this, listenerFunction)
global scopeObjects;

if strcmpi(class(listenerFunction), 'cell')
    if ~strcmpi(class(listenerFunction{1}), 'function_handle')
        error('Cell array based callbacks must have a function_handle as the first element.');
    end
elseif ~ismember(lower(class(listenerFunction)), {'function_handle', 'char'})
    error('Callbacks must be a cell array, function_handle, or string.');
end

scopeObjects(this.ptr).setListeners{length(scopeObjects(this.ptr).setListeners) + 1} = listenerFunction;

return;
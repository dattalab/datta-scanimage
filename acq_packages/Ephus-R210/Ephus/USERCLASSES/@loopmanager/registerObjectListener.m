% loopManager/registerObjectListener - Register a callback, to recieve object mutation events.
%
% SYNTAX
%  registerObjectListener(loopManager_instance, callback)
%   loopManager_instance - The loopManager instance.
%   callback - A valid callback specification (see the `eval` and `feval` functions for details).
%   callbackID - A unique identifier (number, string, or object that implements the `eq` method). This identifier
%                is needed to change registrations later (including removal).
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 6/21/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = registerObjectListener(this, callback, callbackID)
global loopManagers;

c = class(callback);
if ~strcmpi(c, 'function_handle') & ~strcmpi(c, 'cell') & ~strcmpi(c, 'char')
    error('Callbacks for loopManager/registerObjectListener must be strings, function_handles, or cell arrays (with a function handle as the first element).');
elseif strcmpi(c, 'cell')
    if isempty(callback)
        error('Empty cell arrays are not valid callbacks for the loopManager object.');
    else
        if ~strcmpi(class(callback{1}), 'function_handle')
            error('Cell array callbacks must have a function_handle as their first element.');
        end
    end
elseif isempty(callback)
    error('[], {}, and '''' are not valid callbacks.');
end

addCallback(loopManagers(this.ptr).callbackManager, 'objectUpdate', callback, callbackID);

return;
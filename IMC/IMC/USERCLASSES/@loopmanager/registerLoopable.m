% loopManager/registerLoopable - Register a callback, to recieve loop events.
%
% SYNTAX
%  registerLoopable(loopManager_instance, callback)
%  registerLoopable(loopManager_instance, callback, priority)
%   loopManager_instance - The loopManager instance.
%   callback - A function_handle or a cell array (that has a function_handle as its first element).
%              It is the responsibility of the calling function to know the syntax of the supplied callback
%              which MUST accept the event arguments as laid out in the loopManager constructor's documentation.
%   callbackID - A unique identifier (number, string, or object that implements the `eq` method). This identifier
%                is needed to change registrations later (including removal).
%   priority   - Any number between 1 and 10, such that the lower the number, the more likely this callbackSpec is to be executed first (no gaurantees).
%                Default: 5
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO101707K - Added optional priority. -- Tim O'Connor 10/17/07
%
% Created 6/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = registerLoopable(this, callback, callbackID, varargin)
global loopManagers;

c = class(callback);
if ~strcmpi(c, 'function_handle') & ~strcmpi(c, 'cell')
    error('Callbacks for the loopManager must be function_handles or cell arrays (with a function handle as the first element).');
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

addCallback(loopManagers(this.ptr).callbackManager, 'loopStart', callback, callbackID, varargin{:});
addCallback(loopManagers(this.ptr).callbackManager, 'loopStartPreciseTiming', callback, callbackID, varargin{:});
addCallback(loopManagers(this.ptr).callbackManager, 'loopIterate', callback, callbackID, varargin{:});
addCallback(loopManagers(this.ptr).callbackManager, 'loopStop', callback, callbackID, varargin{:});
% addEvent(loopManagers(this.ptr).callbackManager, 'loopStart');
% addEvent(loopManagers(this.ptr).callbackManager, 'loopStartPreciseTiming');
% addEvent(loopManagers(this.ptr).callbackManager, 'loopIterate');
% addEvent(loopManagers(this.ptr).callbackManager, 'loopStop');
% addEvent(loopManagers(this.ptr).callbackManager, 'objectUpdate');

return;
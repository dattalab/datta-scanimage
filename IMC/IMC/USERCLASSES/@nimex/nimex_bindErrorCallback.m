% @nimex/nimex_bindErrorCallback - Adds a callback listener for the specified event.
% 
% SYNTAX
%  nimex_bindErrorCallback(nimextask, channelName, callback, name, priority)
%   nimextask - An instance of the nimex class.
%   callback - Any value that may be interpreted by Matlab's built-in `feval` function.
%   name - A unique (in channel-scope) string identifying this callback.
%   priority - A value between 0 and 5, lower values indicate higher priorities.
%              A best effort is made to execute functions in priority order, but no guarantees are made.
%
%
% NOTES
%  This callback will get called when the task is detected to be in an error state.
%  Relies on NIMEX_bindEventListener.mexw32.
%  See TO101807B.
%
% CHANGES
%  
% Created
%  Timothy O'Connor 10/18/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_bindErrorCallback(this, callback, name, priority)

if ~strcmpi(class(callback), 'function_handle')
    if iscell(callback)
        if ~strcmpi(class(callback{1}), 'function_handle')
            error('Invalid callback type. Must be a function_handle or a cell array whose first element is a function_handle.');
        end
    else
        error('Invalid callback type. Must be a function_handle or a cell array whose first element is a function_handle.');
    end
end

NIMEX_bindEventListener(this.NIMEX_TaskDefinition, 'error', callback, name, priority);

% fprintf(1, 'nimex_bindErrorCallback: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
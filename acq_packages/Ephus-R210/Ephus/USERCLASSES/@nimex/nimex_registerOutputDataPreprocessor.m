% @nimex/nimex_registerOutputDataPreprocessor - Adds a listener for the specified channels data.
% 
% SYNTAX
%  nimex_registerOutputDataPreprocessor(nimextask, channelName, callback, name, priority)
%   nimextask - An instance of the nimex class.
%   channelName - The physical channel to from which recieve to recieve data.
%   callback - Any value that may be interpreted by Matlab's built-in `feval` function
%   name - A unique (in channel-scope) string identifying this callback.
%   priority - A value between 0 and 5, lower values indicate higher priorities.
%              A best effort is made to execute functions in priority order, but no guarantees are made.
%  
% NOTES
%  Relies on NIMEX_registerOutputDataPreprocessor.mex32.
%
%  The specified callback MUST return the preprocessed result.
%
% CHANGES
%  
% Created
%  Timothy O'Connor 1/7/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_registerOutputDataPreprocessor(this, channelName, callback, name, priority)

if ~strcmpi(class(callback), 'function_handle')
    if strcmpi(class(callback), 'cell')
        if ~strcmpi(class(callback{1}), 'function_handle')
            error('Invalid callback type. Must be a function_handle or a cell array whose first element is a function_handle.');
        end
    else
        error('Invalid callback type. Must be a function_handle or a cell array whose first element is a function_handle.');
    end
end

NIMEX_registerOutputDataPreprocessor(this.NIMEX_TaskDefinition, channelName, callback, name, priority);

% fprintf(1, 'nimex_registerOutputDataPreprocessor: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
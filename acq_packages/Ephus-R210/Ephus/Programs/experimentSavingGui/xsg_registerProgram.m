% xsg_registerProgram - Register a program with savable data.
%
% SYNTAX
%  xsg_registerProgram
%  xsg_registerProgram(programObject, callback)
%   programObject - The handle to the program.
%   callback - Any evalable string, function_handle, or cell array (whose first element is a function_handle) that will return the appropriate data to be saved.
%
% USAGE
%
% NOTES
%  See TO123005F (in experimentSavingGui.m).
%
% CHANGES
%
% Created 12/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function xsg_registerProgram(programObject, callback)

if strcmpi(class(callback), 'char')
    if ~endsWith(callback, ';')
        warning('Registering char-based callback to save data which is not terminated with at '';'', this may cause excessive printing to the console.');
    end
elseif strcmpi(class(callback), 'cell')
    if ~strcmpi(class(callback{1}), 'function_handle')
        error('Cell array callbacks registered by xsg_registerProgram.m must have a function_handle as their first element.');
    end
elseif ~strcmpi(class(callback), 'function_handle')
    error('Callbacks registered by xsg_registerPogram.m must be an evalable string, a function_handle, or a cell array whose first element is a function_handle: %s', ...
        class(callback));
end

hObject = xsg_getHandle;

[programHandles, programCallbacks] = getLocalBatch(progmanager, hObject, 'programHandles', 'dataCreatingGuiCallbacks');

programHandles(length(programHandles) + 1) = programObject;
programCallbacks{length(programCallbacks) + 1} = callback;

setLocalBatch(progmanager, hObject, 'programHandles', programHandles, 'dataCreatingGuiCallbacks', programCallbacks);

return;
% @nimex/nimex_setTaskProperty - Set a task-level property.
% 
% SYNTAX
%  data = nimex_setTaskProperty(nimextask, propertyName, propertyValue, ...)
%   nimextask - An instance of nidaqmextask.
%   propertyName - The property to be modified.
%   propertyValue - The new property value.
%  
% NOTES
%  Relies on NIMEX_setTaskProperty.mex32.
%  Some of the common NI hardware only supports PFI7 as the clockExportTerminal.
%
%  Multiple property name-value pairs may be specified.
%
%  See nimex.m for property names and types.
%  
% CHANGES
%  TO040407A: Documentation update. -- Tim O'Connor 4/4/07
%
% Created
%  Timothy O'Connor 12/8/06
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function nimex_setTaskProperty(this, varargin)

NIMEX_setTaskProperty(this.NIMEX_TaskDefinition, varargin{:});

% fprintf(1, 'nimex_setTaskProperty: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
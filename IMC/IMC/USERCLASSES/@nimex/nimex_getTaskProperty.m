% @nimex/nimex_getTaskProperty - Query channel property.
%
% SYNTAX
%  propertyValue = nimex_getTaskProperty(nimextask, propertyName, ...)
%   nimextask - An instance of nidaqmextask.
%   propertyName - The property to be retrieved.
%   propertyValue - The property value.
%
% NOTES
%  Relies on NIMEX_getTaskProperty.mex32.
%
%  Multiple property name-value pairs may be specified.
%
%  See nimex.m for property names and types.
%
% CHANGES
%  TO040407A: Documentation update. -- Tim O'Connor 4/4/07
%
% Created
%  Timothy O'Connor 1/7/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function varargout = nimex_getTaskProperty(this, varargin)

varargout = NIMEX_getTaskProperty(this.NIMEX_TaskDefinition, varargin{:});

% fprintf(1, 'nimex_getTaskProperty: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
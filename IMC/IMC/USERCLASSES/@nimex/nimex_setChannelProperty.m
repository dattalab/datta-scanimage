% @nimex/nimex_setChannelProperty - Set channel property.
% 
% SYNTAX
%  nimex_setChannelProperty(nimextask, channelName, propertyName, propertyValue, ...)
%   nimextask - An instance of nidaqmextask.
%   channelName - The channel to whose properties to modify.
%   propertyName - The property to be modified.
%   propertyValue - The new property value.
%  
% NOTES
%  Relies on NIMEX_setChannelProperty.mex32.
%
%  Multiple property name-value pairs may be specified.
%
%  See nimex.m for property names and types.
%  
% CHANGES
%  TO040407A: Documentation update. -- Tim O'Connor 4/4/07
%  
% Created
%  Aleksander Sobczyk & Timothy O'Connor 11/16/06
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function nimex_setChannelProperty(this, varargin)

NIMEX_setChannelProperty(this.NIMEX_TaskDefinition, varargin{:});

% fprintf(1, 'nimex_setChannelProperty: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
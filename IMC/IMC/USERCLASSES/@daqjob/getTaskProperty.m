% getChannelProperty - Retrieve a task specific property from the underlying @nimex object.
% 
% SYNTAX
%  propertyValue = getTaskProperty(dj, propertyName)
%  [propertyValue, ...] = getTaskProperty(dj, propertyName, ...)
%   dj - @daqjob instance.
%   propertyName - The name of the property to retrieve.
%                  Multiple property names may be specified.
%   propertyValue - The value of the property with the corresponding propertyName.
%  
% NOTES
%
% CHANGES
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%  
% Created
%  Timothy O'Connor 7/30/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function varargout = getTaskProperty(this, channelName, varargin)

channelName = channelNamesToRealChannels(this, channelName);%TO073008A

task = getTaskByChannelName(this, channelName);

varargout = cell(size(varargin));
[varargout{:}] = nimex_getTaskProperty(task, varargin{:});

return;
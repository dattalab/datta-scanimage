%  - 
% 
% SYNTAX
%  
% NOTES
%
% CHANGES
%  
% Created
%  Timothy O'Connor 7/30/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function setTaskProperty(this, channelName, varargin)

task = getTaskByChannelName(this, channelName);

nimex_setTaskProperty(task, varargin{:});

return;
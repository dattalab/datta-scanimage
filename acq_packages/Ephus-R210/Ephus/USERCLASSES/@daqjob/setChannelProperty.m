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
function setChannelProperty(this, channelName, varargin)
global daqjobGlobalStructure;

channelInfo = slice(daqjobGlobalStructure(this.ptr).channelMap, channelName);
task = getTaskBySubsystemName(this, channelInfo{2});

nimex_setChannelProperty(task, [channelInfo{2} channelInfo{3}], varargin{:});

return;
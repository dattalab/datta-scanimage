% getChannelProperty - Retrieve a channel specific property from the underlying @nimex object.
% 
% SYNTAX
%  propertyValue = getChannelProperty(dj, channelName, propertyName)
%  [propertyValue, ...] = getChannelProperty(dj, channelName, propertyName, ...)
%   dj - @daqjob instance.
%   channelName - The mnemonic name of the channel whose properties to retrieve.
%   propertyName - The name of the property to retrieve.
%                  Multiple property names may be specified.
%   propertyValue - The value of the property with the corresponding propertyName.
%  
% NOTES
%
% CHANGES
%  TO043008C - Handle the distribution to varargout properly, specifically in the single property case. -- Tim O'Connor 4/30/08
%  TO043008F - Issue a channel not found error if `slice` returns empty. -- Tim O'Connor 4/30/08
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%  
% Created
%  Timothy O'Connor 7/30/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function varargout = getChannelProperty(this, channelName, varargin)
global daqjobGlobalStructure;

channelName = channelNamesToRealChannels(this, channelName);%TO073008A

channelInfo = slice(daqjobGlobalStructure(this.ptr).channelMap, channelName);
if isempty(channelInfo)
    error('Channel ''%s'' not found.', channelName);
end
task = getTaskBySubsystemName(this, channelInfo{2});

%TO043008C - Follows how it is done in @dajob/getTaskProperty.
varargout = cell(size(varargin));
[varargout{:}] = nimex_getChannelProperty(task, [channelInfo{2} channelInfo{3}], varargin{:});

return;
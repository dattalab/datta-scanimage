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
function bool = isChannel(this, channelName)
global daqjobGlobalStructure;

%Assume it exists.
bool = 1;

%Lookup the channel name.
index = indexOf(daqjobGlobalStructure(this.ptr).channelMap, channelName);
if isempty(index)
    bool = 0;%Not found.
end

return;
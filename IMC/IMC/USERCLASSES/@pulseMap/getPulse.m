%  - 
%
% SYNTAX
%
% NOTES
%
% CHANGES
%
% Created
%  Timothy O'Connor 8/13/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function pulse = getPulse(this, channelName)
global pulseMapGlobalStructure;

index = indexOf(this, channelName);
if isempty(index)
    fprintf(2, '@pulseMap/getPulse: No pulse found for ''%s''.\n', channelName);
    pulse = [];
    return;
end
pulse = pulseMapGlobalStructure(this.ptr).map{index, 2};

return;
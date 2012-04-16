% @pulseMap/removePulse - Removes a @signalobject from the specified channel.
%
% SYNTAX
%  removePulse(pm, channelName)
%   pm - @pulseMap instance.
%   channelName - The name of the channel from which bind the @signalobject.
%
% NOTES
%
% CHANGES
%
% Created
%  Timothy O'Connor 11/9/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function removePulse(this, channelName, pulse)
global pulseMapGlobalStructure;
% getStackTraceString

index = indexOf(this, channelName);
if isempty(index)
    return;
end
pulseMapGlobalStructure(this.ptr).map{index, 2} = pulse;
pulseMapGlobalStructure(this.ptr).shadowMap{index, 2} = pulseMapGlobalStructure(this.ptr).map;

return;
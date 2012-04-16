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
function appendPulse(this, channelName, pulse)
global pulseMapGlobalStructure;

if isstruct(pulse)
    if isfield(pulse, 'signal')
        pulse = pulse.signal;
    else
        warning('Pulse object seems to be a raw struct, which is not supported, should be of type ''signalobject'' or contain a field called ''signal''.');
    end
end

index = indexOf(channelName);
if isempty(index)
    index = size(pulseMapGlobalStructure(this.ptr).map, 1) + 1;
    pulseMapGlobalStructure(this.ptr).map{index, 1} = channelName;
    pulses = pulse;
else
    pulses = pulseMapGlobalStructure(this.ptr).map{index, 2};
    pulses(end + 1) = pulse;
end
pulseMapGlobalStructure(this.ptr).map{index, 2} = pulses;

return;
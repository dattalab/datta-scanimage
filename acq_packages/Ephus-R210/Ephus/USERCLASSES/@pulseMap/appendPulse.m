% @pulseMap/appendPulse - Set a pulse or append a pulse to an array of pulses.
%
% SYNTAX
%  appendPulse(pm, channelName, pulse)
%   pm - @pulseMap instance.
%   channelName - The name of the channel to bind the @signalobject to.
%   pulse - @signalobject instance.
%
% NOTES
%
% CHANGES
%  TO040710C - Handle the error condition of multiple instances of the same channel name in the map. -- Tim O'Connor 4/7/10
%  TO040710B - Documentation update. -- Tim O'Connor 4/7/10
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

index = indexOf(this, channelName);
if isempty(index)
    setPulse(this, channelName, pulse);
else
    pulses = pulseMapGlobalStructure(this.ptr).map{index, 2};
    pulses(end + 1) = pulse;
    setPulse(this, channelName, pulses);
end

return;
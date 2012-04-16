% @pulseMap/setPulse - Binds a @signalobject to the specified channel. 
%
% SYNTAX
%  setPulse(pm, channelName, pulse)
%   pm - @pulseMap instance.
%   channelName - The name of the channel to bind the @signalobject to.
%   pulse - @signalobject instance.
%
% NOTES
%  When data is requested for a specified channel, it is drawn from this mapped @signalobject (or conforming callback - See @pulseMap/setCallback.m).
%
% CHANGES
%  TO101907B - Created a shadow map, to protect the real map when it's swapped out externally. -- Tim O'Connor 10/18/07
%  TO102307D - Allow locking of pulses. -- Tim O'Connor 10/23/07
%
% Created
%  Timothy O'Connor 8/13/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function setPulse(this, channelName, pulse)
global pulseMapGlobalStructure;
% getStackTraceString

%TO102307D
if ismember(lower(channelName), lower(pulseMapGlobalStructure(this.ptr).lockedChannels))
% fprintf(1, '@pulseMap/setPulse: Channel ''%s'' has been locked.\n%s', channelName, getStackTraceString);
    return;
end
% fprintf(1, '@pulseMap/setPulse: Setting pulse for ''%s''.\n%s', channelName, getStackTraceString);

if isstruct(pulse)
    if isfield(pulse, 'signal')
        pulse = pulse.signal;
    else
        warning('Pulse object seems to be a raw struct, which is not supported, should be of type ''signalobject'' or contain a field called ''signal''.');
    end
end

if ~strcmpi(class(pulse), 'signalobject')
    error('Invalid pulse, must be @signalobject instance: ''%s''', class(pulse));
end

index = indexOf(this, channelName);
if isempty(index)
    index = size(pulseMapGlobalStructure(this.ptr).map, 1) + 1;
    pulseMapGlobalStructure(this.ptr).map{index, 1} = channelName;
    pulseMapGlobalStructure(this.ptr).shadowMap{index, 1} = channelName;%TO101907B
end
pulseMapGlobalStructure(this.ptr).map{index, 2} = pulse;
pulseMapGlobalStructure(this.ptr).shadowMap{index, 2} = pulse;%TO101907B

return;
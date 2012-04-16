% @pulseMap/hasPulse - Check if a pulse (or callback) is bound for a specified channel.
%
% SYNTAX
%  pulseFound = hasPulse(pm, channelName)
%   pm - A @pulseMap instance.
%   channelName - The channel for which to look for a pulse.
%   pulseFound - 1 if a pulse was found, 0 otherwise.
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
function pulse = hasPulse(this, channelName)

pulse = 1;
index = indexOf(this, channelName);
if isempty(index)
    pulse = 0;
end

return;
%  @pulseMap/lockPulse - Prevent a pulse from being overwritten (until a call to restoreMap occurs).
%
% SYNTAX
%  data = getdata(pm, channelName)
%   pm - @pulseMap instance.
%   channelName - The channel to be locked.
%
% NOTES
%  See TO102307D.
%
% CHANGES
%
% Created
%  Timothy O'Connor 8/23/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function lockPulse(this, channelName)
global pulseMapGlobalStructure;

pulseMapGlobalStructure(this.ptr).lockedChannels{end + 1} = channelName;

return;
% @pulseMap/restoreMap - Restores the map to values entered only by setPulse, recovers from
%                        possibly corrupting setMap calls.
%
% SYNTAX
%  restoreMap(pm)
%   pm - @pulseMap instance.
%
% NOTES
%  See TO101807B.
%
% CHANGES
%  TO102307D - Allow locking of pulses. -- Tim O'Connor 10/23/07
%
% Created
%  Timothy O'Connor 10/18/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function restoreMap(this, map)
global pulseMapGlobalStructure;
% getStackTraceString
pulseMapGlobalStructure(this.ptr).map = pulseMapGlobalStructure(this.ptr).shadowMap;
pulseMapGlobalStructure(this.ptr).lockedChannels = {};%TO102307D

return;
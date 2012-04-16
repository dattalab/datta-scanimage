% @pulseMap/setMap - Insert the entire table of mapping strings to pulses/callbacks.
%
% SYNTAX
%  setMap(pm, map)
%   pm - @pulseMap instance.
%   map - A 2xN cell array of format {char, @signalobject | callback; ...}.
%         Where callback is a cell array or a function_handle.
%
% NOTES
%  This was made mainly as a convenience for the pulseJacker to use.
%
% CHANGES
%
% Created
%  Timothy O'Connor 10/17/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function setMap(this, map)
global pulseMapGlobalStructure;
% getStackTraceString
pulseMapGlobalStructure(this.ptr).map = map;

return;
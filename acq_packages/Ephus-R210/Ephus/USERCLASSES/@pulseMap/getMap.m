% @pulseMap/getMap - Returns a table mapping strings to pulses/callbacks.
%
% SYNTAX
%  map = getMap(pm)
%   pm - @pulseMap instance.
%   map - A 2xN cell array of format {char, @signalobject | callback; ...}.
%         Where callback is a cell array or a function_handle.
%
% NOTES
%
% CHANGES
%
% Created
%  Timothy O'Connor 10/16/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function map = getMap(this)
global pulseMapGlobalStructure;

map = pulseMapGlobalStructure(this.ptr).map;

return;
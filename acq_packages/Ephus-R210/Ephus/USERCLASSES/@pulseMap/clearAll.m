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
function clearAll(this)
global pulseMapGlobalStructure;

for i = 1 : size(pulseMapGlobalStructure(this.ptr).map, 1)
    pulseMapGlobalStructure(this.ptr).map{index, i} = [];
end

return;
%  - 
% 
% SYNTAX
%  
% NOTES
%
% CHANGES
%  
% Created
%  Timothy O'Connor 7/30/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function index = indexOf(this, name)
global pulseMapGlobalStructure;

if isempty(pulseMapGlobalStructure(this.ptr).map)
    index = [];
    return;
end

%Find the row for the given name.
index = find(strcmpi({pulseMapGlobalStructure(this.ptr).map{:, 1}}, name));

return;
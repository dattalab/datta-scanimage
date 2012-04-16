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
function index = indexOf(map, name)

if isempty(map)
    index = [];
    return;
end

%Find the row for the given name.
index = find(strcmpi({map{:, 1}}, name));

return;
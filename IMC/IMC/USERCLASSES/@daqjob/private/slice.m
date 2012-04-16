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
function row = slice(map, name)

if isempty(map)
    row = {};
    return;
end

%Find the row for the given name.
index = find(strcmpi({map{:, 1}}, name));
row = {map{index, :}};

return;
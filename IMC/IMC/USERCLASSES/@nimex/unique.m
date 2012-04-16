% @nimex/unique - Returns the input array of @nimex objects, with no repetitions.
%
% SYNTAX
%  tasks = unique(taskArray)
%   taskArray - An array of @nimex objects.
%   tasks - The same array of @nimex objects, but with no repetitions.
%
% NOTES
%
% CHANGES
%
% Created
%  Timothy O'Connor 8/22/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function these = unique(this)

these = this(1);
for i = 2 : length(this)
    if ~any(this(i).NIMEX_TaskDefinition == [these(:).NIMEX_TaskDefinition])
        these(end + 1) = this(i);
    end
end

return;
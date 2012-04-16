% @daqjob/setPropertyForAllTasks - Sets a given set of properties for all tasks in the job.
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
function setPropertyForAllTasks(this, varargin)
global daqjobGlobalStructure;

for i = 1 : size(daqjobGlobalStructure(this.ptr).taskMap, 1)
    nimex_setTaskProperty(daqjobGlobalStructure(this.ptr).taskMap{i, 2}, varargin{:});
end

return;
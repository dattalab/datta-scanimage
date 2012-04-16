% @nimex/nimex_delete - Deletes all resources associated with a nimex instance.
% 
% SYNTAX
%  nimex_delete(nimextask, ...)
%   nimextask - An instance of the nimex class.
%  
% NOTES
%  Relies on NIMEX_deleteTask.mex32.
%
% Created
%  Timothy O'Connor 4/1/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_delete(this)

NIMEX_deleteTask([this(:).NIMEX_TaskDefinition]);

% fprintf(1, 'nimex_delete: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
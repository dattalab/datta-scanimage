% @nimex/nimex_commitTask - Commits a task, as per the NIDAQmx documentation.
% 
% SYNTAX
%  nimex_commitTask(nimextask)
%   nimextask - An instance of the nimex class.
%
% USAGE
%  A large portion of the overhead involved in updating a task is handled here.
%  In principle, calling this function will lead to significantly faster subsequent calls
%  to nimex_startTask. It will also detect errors in the task's configuration.
%  
%  
% NOTES
%  Relies on NIMEX_commitTask.mex32.
%  See See TO101708J.
%  
% Created
%  Timothy O'Connor 10/18/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_commitTask(this)
fprintf(1, 'nimex_commitTask: @%s\n', num2str(this.NIMEX_TaskDefinition));
% getStackTraceString
NIMEX_commitTask(this.NIMEX_TaskDefinition);

% fprintf(1, 'nimex_commitTask: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
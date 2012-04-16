% @nimex/nimex_startTask - Starts a fully configured NIDAQmex task.
% 
% SYNTAX
%  nimex_startTask(nimextask)
%   nimextask - An instance of the nimex class.
%  
% NOTES
%  Relies on NIMEX_startTask.mex32.
%  
% Created
%  Aleksander Sobczyk & Timothy O'Connor 11/16/06
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function nimex_startTask(this)
% fprintf(1, 'nimex_startTask: @%s\n', num2str(this.NIMEX_TaskDefinition));
% getStackTraceString
NIMEX_startTask(this.NIMEX_TaskDefinition);
% fprintf(1, 'nimex_startTask: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
% @nimex/nimex_stopTask - Stops a NIDAQmex task.
% 
% SYNTAX
%  stopTask(nimextask)
%   nimextask - An instance of nidaqmextask.
%  
% NOTES
%  Relies on NIDAQmex_stopTask.mex32.
%  
% Created
%  Aleksander Sobczyk & Timothy O'Connor 11/16/06
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function nimex_stopTask(this)
% fprintf(1, 'nimex_stopTask: @%s\n', num2str(this.NIMEX_TaskDefinition));
NIMEX_stopTask(this.NIMEX_TaskDefinition);

% fprintf(1, 'nimex_stopTask: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
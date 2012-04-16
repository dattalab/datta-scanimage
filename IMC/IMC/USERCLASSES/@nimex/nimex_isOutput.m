% @nimex/nimex_isOutput - Determines if a task is configured for output.
% 
% SYNTAX
%  isOutput = nimex_isOutput(nimextask, channelName)
%   nimextask - An instance of the nimex class.
%   isOutput - 1 if the task is configured for output, 0 otherwise.
%  
% NOTES
%  Relies on NIMEX_isOutput.mex32.
%  
% Created
%  Timothy O'Connor 5/3/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function isOutput = nimex_isOutput(this)

isOutput = NIMEX_isOutput(this.NIMEX_TaskDefinition);

% fprintf(1, 'nimex_isOutput: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
% @nimex/nimex_addCOTime - Adds a counter output time channel to the task definition.
% 
% SYNTAX
%  nimex_addCOTime(nimextask, channelName)
%   nimextask - An instance of the nimex class.
%   channelName - A string, which acts as a NIDAQmx physical device specification.
%                 Example: '/dev1/ctr0'
%  
% NOTES
%  Relies on NIMEX_addCOTime.mex32.
%  
% Created
%  Timothy O'Connor 1/27/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_addCOTime(this, channelName)

NIMEX_addCOTime(this.NIMEX_TaskDefinition, channelName);

% fprintf(1, 'nimex_addCOTime: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
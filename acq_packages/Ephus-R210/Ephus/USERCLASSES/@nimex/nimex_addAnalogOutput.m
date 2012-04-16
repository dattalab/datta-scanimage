% @nimex/nimex_addAnalogOutput - Adds an analog input channel to the task definition.
% 
% SYNTAX
%  nimex_addAnalogOutput(nimextask, channelName)
%   nimextask - An instance of the nimex class.
%   channelName - A string, which acts as a NIDAQmx physical device specification.
%                 Example: '/dev1/ao0'
%  
% NOTES
%  Relies on NIMEX_addAnalogInputChannel.mex32.
%  
% Created
%  Timothy O'Connor 11/29/06
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function nimex_addAnalogInput(this, channelName)

% getStackTraceString
NIMEX_addAnalogOutputChannel(this.NIMEX_TaskDefinition, channelName);

% fprintf(1, 'nimex_addAnalogOutput: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
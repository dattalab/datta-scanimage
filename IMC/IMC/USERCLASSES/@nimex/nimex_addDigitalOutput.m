% @nimex/nimex_addDigitalOutput - Adds a digital output channel to the task definition.
% 
% SYNTAX
%  nimex_addDigitalOutput(nimextask, channelName)
%   nimextask - An instance of the nimex class.
%   channelName - A string, which acts as a NIDAQmx physical device specification.
%                 Example: '/dev1/ao0'
%  
% NOTES
%  Relies on NIMEX_addDigitalOutpuChannel.mex32.
%  
% Created
%  Timothy O'Connor 1/27/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_addDigitalOutput(this, channelName)

NIMEX_addDigitalOutputChannel(this.NIMEX_TaskDefinition, channelName);

% fprintf(1, 'nimex_addDigitalOutput: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
% @nimex/nimex_addDigitalInput - Adds a digital input channel to the task definition.
% 
% SYNTAX
%  nimex_addDigitalInput(nimextask, channelName)
%   nimextask - An instance of the nimex class.
%   channelName - A string, which acts as a NIDAQmx physical device specification.
%                 Example: '/dev1/ao0'
%  
% NOTES
%  Relies on NIMEX_addDigitalInputChannel.mex32.
%  
% Created
%  Timothy O'Connor 8/1/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_addDigitalInput(this, channelName)

NIMEX_addDigitalInputChannel(this.NIMEX_TaskDefinition, channelName);

% fprintf(1, 'nimex_addDigitalInput: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
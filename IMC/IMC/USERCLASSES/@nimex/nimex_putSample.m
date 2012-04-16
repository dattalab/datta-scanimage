% @nimex/nimex_putSample - Write a single 32-bit unsigned digital value or 64-bit floating point value.
% 
% SYNTAX
%  nimex_putSample(nimextask, channelName, data)
%   nimextask - An instance of the nimex class.
%   channelName - The channel for which to write data.
%   data - The sample to be written.
%  
% NOTES
%  Relies on NIMEX_putSample.mex32.
%  
% Created
%  Timothy O'Connor 8/14/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_putSample(this, channelName, data)
% fprintf(1, 'nimex_putSample: @%s\n', num2str(this.NIMEX_TaskDefinition));

NIMEX_putSample(this.NIMEX_TaskDefinition, channelName, data);

% fprintf(1, 'nimex_putSample: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
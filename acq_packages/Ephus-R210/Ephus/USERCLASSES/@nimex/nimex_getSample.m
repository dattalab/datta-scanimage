% @nimex/nimex_getSample - Read a single 32-bit unsigned digital value or 64-bit floating point value.
% 
% SYNTAX
%  data = nimex_getSample(nimextask, channelName)
%   nimextask - An instance of the nimex class.
%   channelName - The channel for which to read data.
%   data - The sample which was read.
%  
% NOTES
%  Relies on NIMEX_getSample.mex32.
%  
% Created
%  Timothy O'Connor 8/18/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function data = nimex_getSample(this, channelName)

data = NIMEX_getSample(this.NIMEX_TaskDefinition, channelName);

% fprintf(1, 'nimex_getSample: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
% @nimex/nimex_clearBuffer - Clears the channel's data buffer in C.
% 
% SYNTAX
%  nimex_clearBuffer(nimextask, channelName)
%   nimextask - An instance of the nimex class.
%   channelName - The channel for which to clear data.
%  
% NOTES
%  Relies on NIMEX_clearBuffer.mex32.
%  
% Created
%  Timothy O'Connor 5/3/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function nimex_clearBuffer(this, channelName)

NIMEX_clearBuffer(this.NIMEX_TaskDefinition, channelName);

% fprintf(1, 'nimex_clearBuffer: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
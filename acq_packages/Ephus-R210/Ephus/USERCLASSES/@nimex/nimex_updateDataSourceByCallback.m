% @nimex/nimex_updateDataSourceByCallback - Execute all callbacks associated with an output channel's data source, and store the buffer in C.
% 
% SYNTAX
%  nimex_updateDataSourceByCallback(nimextask, channelName)
%   nimextask - An instance of the nimex class.
%   channelName - The channel for which to update data.
%  
% NOTES
%  Relies on NIMEX_updateDataSourceByCallback.mex32.
%  
% Created
%  Timothy O'Connor 8/14/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_updateDataSourceByCallback(this, channelName)

NIMEX_updateDataSourceByCallback(this.NIMEX_TaskDefinition, channelName);

% fprintf(1, 'nimex_updateDataSourceByCallback: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
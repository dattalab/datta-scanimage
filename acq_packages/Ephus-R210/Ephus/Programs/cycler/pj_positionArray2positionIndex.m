% pj_positionArray2positionIndex - From an array of position structures, determine the index corresponding to a channel.
%
% SYNTAX
%  index = pj_positionArray2positionIndex(hObject, channelName)
%    hObject - The program handle.
%    channelName - The name of the channel of interest.
%    index - The index of the specified channel.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/28/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function index = pj_positionArray2positionIndex(pos_array, channelName)
% fprintf(1, 'pj_positionArray2positionStruct: %s (%s)\n%s', channelName, class(channelName), getStackTraceString);

index = find(strcmpi({pos_array(:).channelName}, channelName));

return;
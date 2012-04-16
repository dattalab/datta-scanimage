% pj_programInsensitivePositionArray2positionStruct - From an array of position structures, extract a single struct, corresponding to a channel.
%                                                     This function ignores the program portion of the channel name.
%
% SYNTAX
%  pj_programInsensitivePositionArray2positionStruct(hObject, channelName)
%    hObject - The program handle.
%    channelName - The name of the channel of interest.
%
% USAGE
%
% NOTES
%  Does not issue an error when no corresponding position is found, instead it returns [].
%
% CHANGES
%
% Created 8/29/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pos_struct = pj_programInsensitivePositionArray2positionStruct(pos_array, channelName)

index = pj_programInsensitivePositionArray2positionIndex(pos_array, channelName);
if isempty(index)
    pos_struct = [];
else
    pos_struct = pos_array(index);
end

return;
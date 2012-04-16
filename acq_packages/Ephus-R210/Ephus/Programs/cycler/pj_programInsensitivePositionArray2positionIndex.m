% pj_programInsensitivePositionArray2positionIndex - From an array of position structures, find the index corresponding to a channel.
%                                                     This function ignores the program portion of the channel name.
%
% SYNTAX
%  index = pj_programInsensitivePositionArray2positionIndex(hObject, channelName)
%    hObject - The program handle.
%    channelName - The name of the channel of interest.
%    index - The index of the named channel.
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
function index = pj_programInsensitivePositionArray2positionIndex(pos_array, channelName)

index = [];
for i = 1 : length(pos_array)
    delimiter = find(pos_array(i).channelName == ':');
    if isempty(delimiter)
        delimiter = 0;
    end
    if strcmpi(pos_array(i).channelName(delimiter+1 : end), channelName)
        index = i;
        return;
    end
end

return;
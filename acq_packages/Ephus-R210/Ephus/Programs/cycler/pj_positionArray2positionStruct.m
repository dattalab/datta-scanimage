% pj_positionArray2positionStruct - From an array of position structures, extract a single struct, corresponding to a channel.
%
% SYNTAX
%  pos_struct = pj_positionArray2positionStruct(pos_array, channelName)
%    pos_array - The position array.
%    channelName - The name of the channel of interest.
%    pos_struct - The structure corresponding to the given channel name.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/28/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pos_struct = pj_positionArray2positionIndext(pos_array, channelName)
% fprintf(1, 'pj_positionArray2positionStruct: %s (%s)\n%s', channelName, class(channelName), getStackTraceString);

index = pj_positionArray2positionIndex(pos_array, channelName);

if isempty(index)
    error('No structure found for channel ''%s'' at current position.', channelName);
end

if length(index) > 1
    warning('Ambiguous position structure definition(s) for channel ''%s'' at current position.', channelName);
end

pos_struct = pos_array(index);

return;
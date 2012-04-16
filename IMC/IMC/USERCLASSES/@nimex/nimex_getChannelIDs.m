% @nimex/nimex_getChannelIDs - Gets board & channel ID associated with named NIMEX channel.
%
% SYNTAX
%   [boardID, chanID] = nimex_getChannelIDs(this,channelName)
%       this - A @nimex task object.
%       channelName - String, indicating channel associated with this @nimex task, for which board/channel IDs should be retrieved.
%       boardID - NI board ID (i.e. 'dev#') of specified channelName.
%       chanID - NI channel ID (i.e. 'dev1/ao#') of specified channelName.
% NOTES
%   This function is provided for convenience to legacy code which still hangs onto board/chan IDs
%   In principle, this should never be required
%
% CHANGES
%
% Created
%  Vijay Iyer - ??/??/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute/Janelia Farm Research Center 2008
function [boardID, chanID] = nimex_getChannelIDs(this, channelName)

physChan = nimex_getChannelProperty(this, channelName, 'physicalChannel');

s = regexpi(physChan, '/dev(?<boardID>\d*)/[a-z]*(?<chanID>\d*)', 'names');
boardID = str2double(s.boardID);
chanID = str2double(s.chanID);

return;

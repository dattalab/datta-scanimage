% @AMPLFIER/getVComChannelName - Get the channel name of the command voltage for this amplifier object.
%
% SYNTAX
%   channelName = setVComChannelName(AMPLIFIER)
%    AMPLIFIER - Object instance.
%    channelName - The name of the command volrage channel from the amplifier.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 3/31/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function channelName = getVComChannelName(this)
global amplifierObjects;

channelName = amplifierObjects(this.ptr).vCom;

return;
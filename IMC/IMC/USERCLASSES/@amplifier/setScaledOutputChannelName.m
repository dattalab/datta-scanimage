% @AMPLFIER/setScaledOutputChannelName - Set the channel name of the scaled output for this amplifier object.
%
% SYNTAX
%   setScaledOutputChannelName(AMPLIFIER, channelName)
%    AMPLIFIER - Object instance.
%    channelName - The name of the scaledOutput channel from the amplifier (this is an input channel, entering the computer).
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 2/25/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function setScaledOutputChannelName(this, channelName)
global amplifierObjects;

amplifierObjects(this.ptr).scaledOutputChannelName = channelName;

return;
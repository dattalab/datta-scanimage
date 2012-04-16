% @AMPLFIER/getScaledOutputChannelName - Retrieve the channelname of the scaled output for this amplifier object.
%
% SYNTAX
%  channelName = getScaledOutputChannelName(AMPLIFIER)
%    AMPLIFIER - Object instance.
%    channelName - The name of the scaledOutput channel from the amplifier (this is an input channel, entering the computer).
%
% USAGE
%  All subclasses are responsible for setting this property when they are configured.
%
% NOTES
%
% CHANGES
%
% Created 2/25/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function channelName = getScaledOutputChannelName(this)
global amplifierObjects;

channelName = amplifierObjects(this.ptr).scaledOutputChannel;

return;
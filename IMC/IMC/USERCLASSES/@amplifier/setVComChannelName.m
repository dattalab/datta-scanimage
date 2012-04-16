% @AMPLFIER/setVComChannelName - Set the channel name of the command voltage for this amplifier object.
%
% SYNTAX
%   setVComChannelName(AMPLIFIER, channelName)
%    AMPLIFIER - Object instance.
%    channelName - The name of the command volrage channel from the amplifier.
%
% USAGE
%
% NOTES
%
% CHANGES
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%   TO081696H - Switched case convention. See TO122205A. -- Tim O'Connor 8/16/06
%
% Created 3/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function setVComChannelName(this, channelName)
global amplifierObjects;

%TO070505A - This could cause setOutputChannelNames to error, because setVComChannelName isn't a method of the calling subclass.
if ~strcmpi(class(this), 'amplifier')
    obj = struct(this);
    this = obj.amplifier;%TO122205A %TO081606H
end

amplifierObjects(this.ptr).vCom = channelName;
setOutputChannelNames(this, channelName);

return;
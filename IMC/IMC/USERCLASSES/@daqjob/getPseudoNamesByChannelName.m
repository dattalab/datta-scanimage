% @daqjob/getPseudoNamesByChannelName - Convert an actual channel name into pseudochannels.
%
% SYNTAX
%  mnemonicChannelNames = getPseudoNamesByChannelName(this, channelName)
%   this - The @daqjob instance.
%   channelName - The real channel name(s).
%   mnemonicChannelNames - The mnemonic channel names, as shown on the GUI.
%
% NOTES
%  This is intended for times when the channel names on the GUI do not directly map to mnemonic channel names
%  in Nimex.
%
%  This can be used to implement one-to-many and many-to-one mappings, a prime example is the case of 
%  grouped digital lines being treated as independent channels in the Stimulator. See TO072208A.
%
%  See TO073008A.
%
% CHANGES
%
% Created
%  Timothy O'Connor 7/30/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function mnemonicChannelNames = getPseudoNamesByChannelName(this, channelName)

mnemonicChannelNames = channelNamesToPseudoChannels(this, channelName);

return;
% @daqjob/getChannelStructure - Return a corresponding channel structure for the named channel.
%
% SYNTAX
%  mnemonicChannelNames = getPseudoNamesByDeviceName(this, physicalName)
%   this - The @daqjob instance.
%   physicalName - The real channel name(s), as used in Nimex.
%   mnemonicChannelNames - The mnemonic channel names, as shown on the GUI.
%
% NOTES
%  The channel structure matches that used for stimulator/acquirer. The fields are as follows:
%   .channelName - The mnemonic name of the channel.
%   .boardID - The NI board ID.
%   .channelID - The NI channel ID. Empty if it's not an analog line.
%   .portID - The NI port ID. Empty if it's not a digital line.
%   .lineID - The NI line ID. Empty if it's not a digital line.
%
%  See TO073008D and TO073108D.
%
% CHANGES
%
% Created
%  Timothy O'Connor 7/31/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function chanStruct = getChannelStructure(this, channelName)

deviceName = getDeviceNameByChannelName(this, channelName);

chanStruct.channelName = getChannelNameByDeviceName(this, deviceName);%Second look-up to cut through pseudochannels to the true mnemonic name.
if deviceName(1) ~= '/' %We should always be starting with a '/', but let's just be careful here anyway.
    deviceName = ['/' deviceName];
end
slashIndices = find(deviceName == '/');

chanStruct.boardID = str2double(deviceName(5 : slashIndices(2)-1));%'/dev<boardID>/...'
if isempty(strfind(deviceName, 'line'))
    %analog
    chanStruct.channelID = str2double(deviceName(slashIndices(2) + 3 : end));%'/dev<boardID>/[ao | ai]<channelID>'
    chanStruct.portID = [];
    chanStruct.lineID = [];
else
    %digital
    chanStruct.channelID = [];
    chanStruct.portID = str2double(deviceName(slashIndices(2) + 5 : slashIndices(3)-1));
    chanStruct.lineID = eval(deviceName(slashIndices(3) + 5 : end));%'/dev<boardID>/port<portID>/line<lineID | lineIDArraySpecifier>'
end

return;
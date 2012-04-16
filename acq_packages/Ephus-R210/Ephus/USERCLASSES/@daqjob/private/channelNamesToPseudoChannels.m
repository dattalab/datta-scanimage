% @daqjob/channelNamesToPseudoChannels - Convert real channel names into pseudochannels.
%
% SYNTAX
%  mnemonicChannelNames = channelNamesToPseudoChannels(this, actualChannelNames)
%   this - The @daqjob instance.
%   actualChannelNames - The real channel names, as used in Nimex.
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
%  TO102508D - Complete fix for this function. -- Tim O'Connor 10/25/08
%
% Created
%  Timothy O'Connor 7/30/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function mnemonicChannelNames = channelNamesToPseudoChannels(this, actualChannels)
global daqjobGlobalStructure;

if isempty(actualChannels)
    mnemonicChannelNames = {};
    return;
end
if isempty(daqjobGlobalStructure(this.ptr).pseudoChannelMap)
    mnemonicChannelNames = actualChannels;
    return;
end

if ~iscell(actualChannels)
    actualChannels = {actualChannels};
end

mnemonicChannelNames = {};
for i = 1 : length(actualChannels)
    indices = find(strcmpi(actualChannels{i}, {daqjobGlobalStructure(this.ptr).pseudoChannelMap{:, 2}}));
    if ~isempty(indices)
        mnemonicChannelNames = cat(1, mnemonicChannelNames, {daqjobGlobalStructure(this.ptr).pseudoChannelMap{indices, 1}});
    end
end
% 
% [mnemonicChannels, actualIndices, mapIndices] = intersect(actualChannels, {daqjobGlobalStructure(this.ptr).pseudoChannelMap{:, 2}});
% daqjobGlobalStructure(this.ptr).pseudoChannelMap
% mnemonicChannels
% actualIndices
% mapIndices
% mapIndices = find(strcmp(actualChannels, {daqjobGlobalStructure(this.ptr).pseudoChannelMap{:, 2}}));
% mapIndices
% mnemonicChannelNames = cell(size(mapIndices));
% for i = 1 : length(mapIndices)
%     mnemonicChannelNames{i} = daqjobGlobalStructure(this.ptr).pseudoChannelMap{mapIndices(i), 1};
% end

mnemonicChannelNames = unique(mnemonicChannelNames);

return;
% @daqjob/channelNamesToRealChannels - Convert pseudochannels into real channel names.
%
% SYNTAX
%  actualChannelNames = channelNamesToRealChannels(this, mnemonicChannelNames)
%   this - The @daqjob instance.
%   mnemonicChannelNames - The mnemonic channel names, as shown on the GUI.
%   actualChannelNames - The real channel names, as used in Nimex.
%
% NOTES
%  This is intended for times when the channel names on the GUI do not directly map to mnemonic channel names
%  in Nimex.
%
%  This can be used to implement one-to-many and many-to-one mappings, a prime example is the case of 
%  grouped digital lines being treated as independent channels in the Stimulator. See TO072208A.
%
% CHANGES
%  TO073008A - Moved channelIndirection functionality from the programs (ephys, stimulator, acquirer, etc) into @daqjob. -- Tim O'Connor 7/30/08
%  VI082108A - Use mapIndices, rather than mnemonicIndices, to index into pseudochannelMap
%  TO101208B - Fixed VI082108A. Indexing was wrong and channels were not stopping correctly. -- Tim O'Connor 10/25/08
%
% Created
%  Timothy O'Connor 7/22/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function actualChannelNames = channelNamesToRealChannels(this, mnemonicChannelNames)
global daqjobGlobalStructure;

if isempty(mnemonicChannelNames)
    actualChannelNames = {};
    return;
end
if isempty(daqjobGlobalStructure(this.ptr).pseudoChannelMap)
    actualChannelNames = mnemonicChannelNames;
    return;
end

actualChannelNames = mnemonicChannelNames;
if ~iscell(actualChannelNames)
    actualChannelNames = {actualChannelNames};
end

[pseudoChannels, mnemonicIndices, mapIndices] = intersect(mnemonicChannelNames, {daqjobGlobalStructure(this.ptr).pseudoChannelMap{:, 1}});

%TO101208B
for i = 1 : length(mnemonicIndices)
    actualChannelNames{mnemonicIndices(i)} = daqjobGlobalStructure(this.ptr).pseudoChannelMap{mapIndices(i), 2}; %VI082108A
end

actualChannelNames = unique(actualChannelNames);
if length(actualChannelNames) == 1
    actualChannelNames = actualChannelNames{1};
end

return;
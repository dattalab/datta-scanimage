% @daqjob/addPseudoChannel - Add a pseudo-channel.
%
% SYNTAX
%  addPseudoChannel(job, channelName)
%  addPseudoChannel(job, channelName, linkedChannelNames)
%   job - A @daqjob instance.
%   channelName - A mnemonic name for the channel.
%                 May be a cell array, listing multiple pseudochannels.
%   linkedChannelNames - The name of the real channel that is addressed by the pseudochannel.
%                        May be a cell array, listing multiple real channels.
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
%
% Created
%  Timothy O'Connor 7/30/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function addPseudoChannel(this, channelName, varargin)
global daqjobGlobalStructure;
% if iscell(channelName)
%     for i = 1 : length(channelName)
%         fprintf(1, '%s, ', channelName{i});
%     end
% %     fprintf(1, '\n%s\n', getStackTraceString);
% else
%     fprintf(1, '%s: %s\n', channelName, getStackTraceString);
% end

if iscell(channelName)
    for i = 1 : length(channelName)
        addPseudoChannel(this, channelName{i}, varargin{:});
    end
    return;
end

if ~isempty(indexOf(daqjobGlobalStructure(this.ptr).channelMap, channelName))
    error('A channel with the name ''%s'' already exists.', channelName);
end

if ismember(channelName, daqjobGlobalStructure(this.ptr).pseudoChannelMap)
    error('A pseudochannel with the name ''%s'' already exists.', channelName);
end

if isempty(varargin)
    daqjobGlobalStructure(this.ptr).pseudoChannelMap{size(daqjobGlobalStructure(this.ptr).pseudoChannelMap, 1) + 1, 1} = channelName;
    return;
end

index = size(daqjobGlobalStructure(this.ptr).pseudoChannelMap, 1) + 1;
targetChannels = varargin{1};
if ~iscell(targetChannels)
    targetChannels = {targetChannels};
end

if any(ismember(targetChannels, {daqjobGlobalStructure(this.ptr).pseudoChannelMap{:, 1}}))
    error('Currently, pseudochannels may not refer to other pseudochannels.');
end
[matches] = ismember(targetChannels, {daqjobGlobalStructure(this.ptr).channelMap{:, 1}});
if ~all(matches)
    indices = find(matches == 0);
    for i = 1 : length(indices)
        fprintf(2, ' @daqjob/addPseudoChannel: Failed to map ''%s'' --> ''%s'': ''%s'' does not exist.\n', channelName, targetChannels{indices(i)}, targetChannels{indices(i)});
    end
    error('Can not map pseudochannels to target channels that do not exist.');
end

for i = 1 : length(targetChannels)
    daqjobGlobalStructure(this.ptr).pseudoChannelMap{index, 1} = channelName;
    daqjobGlobalStructure(this.ptr).pseudoChannelMap{index, 2} = targetChannels{i};
end

return;
% @daqjob/getChannelNameByDeviceName - Look up a mnemonic channel name based on the NIDAQmx device name.
% 
% SYNTAX
%  channelName = getChannelNameByDeviceName(job, deviceName)
%   deviceName - A NIDAQmx style device name, such as '/dev1/ai0'. May be a cell array of names.
%   channelName - The mnemonic name corresponding to deviceName. May be a cell array of names.
%  
% NOTES
%
% CHANGES
%  TO033008A - Fixed a typo error in the cell array case, where it was calling getDeviceNameByChannelName. -- Tim O'Connor 3/30/08
%  
% Created
%  Timothy O'Connor 10/21/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function channelName = getChannelNameByDeviceName(this, deviceName)
global daqjobGlobalStructure;

if iscell(deviceName)
    channelName = cell(size(deviceName));
    for i = 1 : length(deviceName)
        channelName{i} = getChannelNameByDeviceName(this, deviceName{i});%TO033008A - From `getDeviceNameByChannelName` to `getChannelNameByDeviceName`.
    end
    return;
end

slashIdx = find(deviceName == '/');
for i = slashIdx(end) : length(deviceName)
    if any(deviceName(i) == ['0123456789'])
        digitIdx = i;
        break;
    end
end
subSystemName = deviceName(1 : digitIdx - 1);
channelId = deviceName(digitIdx : end);

indices = find(strcmpi(channelId, {daqjobGlobalStructure(this.ptr).channelMap{:, 3}}));
if isempty(indices)
    error('Failed to find device name ''%s''.', deviceName);
end
index = find(strcmpi(subSystemName, daqjobGlobalStructure(this.ptr).channelMap(indices, 2)));
if isempty(index)
    error('Failed to find device name ''%s''.', deviceName);
end

channelName = daqjobGlobalStructure(this.ptr).channelMap{indices(index), 1};

% index = indexOf(daqjobGlobalStructure(this.ptr).channelMap, channelName);
% if isempty(index)
%     error('Failed to find mnemonic channel name ''%s''.', channelName);
% end
% 
% deviceName = [daqjobGlobalStructure(this.ptr).channelMap{index, 2}, daqjobGlobalStructure(this.ptr).channelMap{index, 3}];

return;
% @daqjob/getSample - Gets a single sample from the named channel.
% 
% SYNTAX
%  sample = getSample(dj, channelName)
%   dj - @daqjob instance.
%   channelName - The name of the channel from which to read a sample.
%   sample - The requested sample.
%  
% NOTES
%  Basically just does a task look-up and calls through to @nimex.
%  See @nimex/nimex_getSample.
%
% CHANGES
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%  
% Created
%  Timothy O'Connor 8/18/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function sample = getSample(this, channelName)
% global daqjobGlobalStructure;

channelName = channelNamesToRealChannels(this, channelName);%TO073008A

if iscell(channelName)
    for i = 1 : length(channelName)
        if length(sample) > 1
            sample(i) = getSample(this, channelName{i});
        else
            sample = getSample(this, channelName{i});
        end
    end
    return;
end

if channelName(1) ~= '/'
    channelName = getDeviceNameByChannelName(this, channelName);
end

task = getTaskByDeviceName(this, channelName);
% sample = nimex_getSample(daqjobGlobalStructure(this.ptr).taskMap{1, 2}, channelName);
sample = nimex_getSample(task, channelName);

return;
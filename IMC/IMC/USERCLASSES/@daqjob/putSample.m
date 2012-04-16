%  - 
% 
% SYNTAX
%  
% NOTES
%
% CHANGES
%  
% Created
%  Timothy O'Connor 8/14/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function putSample(this, channelName, sample)
global daqjobGlobalStructure;
% fprintf(1, '@daqjob/putSample: %s\n', channelName);
if iscell(channelName)
    for i = 1 : length(channelName)
        if length(sample) > 1
            putSample(this, channelName{i}, sample(i));
        else
            putSample(this, channelName{i}, sample);
        end
    end
    return;
end

if channelName(1) ~= '/'
    channelName = getDeviceNameByChannelName(this, channelName);
end

nimex_putSample(daqjobGlobalStructure(this.ptr).taskMap{1, 2}, channelName, sample);

return;
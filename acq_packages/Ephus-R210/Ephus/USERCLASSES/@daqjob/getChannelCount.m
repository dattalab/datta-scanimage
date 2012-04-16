% @daqjob/getChannelCount - Returns the number of configured channels (regardless of type).
%
% SYNTAX
%  channelCount = getChannelCount(job)
%   job - A @daqjob instance.
%   channelCount - The total number of channels (includes both analog and digital inputs/outputs).
%
% NOTES
%
% CHANGES
%
% Created
%  Timothy O'Connor 6/8/10
%
% Copyright
%  Northwestern University/Howard Hughes Medical Institute 2010
function channelCount = getChannelCount(this)
global daqjobGlobalStructure;

if isempty(daqjobGlobalStructure)
    channelCount = 0;
else
    channelCount = size(daqjobGlobalStructure(this.ptr).channelMap, 1);
end

return;
% @daqjob/getTasksByChannelNames - Batched call to retrieve nimex task objects.
%
% SYNTAX
%
% NOTES
%
% CHANGES
%
% Created
%  Timothy O'Connor 10/21/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function tasks = getTasksByChannelNames(this, varargin)

tasks = [];
if isempty(varargin)
    return;
end

channelNames = {varargin{:}};

for i = 1 : length(channelNames)
    if isempty(tasks)
        tasks = getTaskByChannelName(this, channelNames{i});
    else
        tasks(i) = getTaskByChannelName(this, channelNames{i});
    end
end

return;
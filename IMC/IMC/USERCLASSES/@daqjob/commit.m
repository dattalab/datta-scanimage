% @daqjob/commit - Commit the tasks, down to the NIDAQmx level.
% 
% SYNTAX
%  commit(dj, channelName, callback, ...)
%   dj - @daqjob instance.
%   channelName - The name of the channel(s) to commit (may be pseudochannels).
%  
% NOTES
%  This will have all the effects of committing a NIDAQmx task.
%
% CHANGES
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%  
% Created
%  Timothy O'Connor 10/18/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function commit(this, varargin)
global daqjobGlobalStructure;
% fprintf(1, '@daqjob/commit: ');
% for i = 1 : length(varargin)
%     fprintf(1, '%s, ', varargin{i});
% end
% fprintf(1, '\n');

if isempty(varargin)
    return;
end

channelNames = channelNamesToRealChannels(this, {varargin{:}});%TO073008A
taskList = [];

for i = 1 : length(daqjobGlobalStructure(this.ptr).channelsToStart)
    task = getTaskByChannelName(this, channelNames);
    if isempty(taskList)
        taskList = task;
    else
        if ~any(task == taskList)
            taskList(end + 1) = task;
        end
    end
end

for i = 1 : length(taskList)
    nimex_commitTask(taskList(i));
end
% if (daqjobGlobalStructure(this.ptr).started && daqjobGlobalStructure(this.ptr).waitingForTrigger)
%     taskList = [];
%     for i = 1 : length(daqjobGlobalStructure(this.ptr).channelsToStart)
%         task = getTaskByChannelName(this, daqjobGlobalStructure(this.ptr).channelsToStart{i});
%         if isempty(taskList)
%             taskList = task;
%         else
%             if ~any(task == taskList)
%                 taskList(end + 1) = task;
%             end
%         end
%     end
%     for i = 1 : length(taskList)
%         channels = nimex_getTaskProperty(taskList(i), 'channels');
%         if ismember(channels{i}, daqjobGlobalStructure(this.ptr).channelsToStart)
%             nimex_setChannelProperty(taskList(i), channels{i}, 'enable', 1);
%         else
%             nimex_setChannelProperty(taskList(i), channels{i}, 'enable', 0);
%         end
%         nimex_commitTask(taskList(i));
%         daqjobGlobalStructure(this.ptr).expectedDoneEventCount = daqjobGlobalStructure(this.ptr).expectedDoneEventCount + 1;
%     end
% end

return;
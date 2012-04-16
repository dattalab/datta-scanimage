% @daqjob/stop - Stop the specified channel(s).
% 
% SYNTAX
%  stop(dj, channelName)
%  stop(dj, channelName, ...)
%   dj - @daqjob instance.
%   channelName - The mnemonic name of the channel to stop.
%                 Multiple channel names may be specified.
%
% NOTES
%  This may potentially restart the underlying nimex task(s) if other channels
%  are still in use.
%
% CHANGES
%  TO043008D - Fixed sharing of a single task across multiple programs (ie. ephys+stimulator or ephys+acquirer). -- Tim O'Connor 4/30/08
%  TO050308C - More fixing of the shared task scheme, make sure the buffers are cleared and updated when restarting. -- Tim O'Connor 5/3/08
%  TO050508G - Added a masterSampleClock field. -- Tim O'Connor 5/5/08
%  TO073008A - Moved channelIndirection functionality from the programs (ephys, stimulator, acquirer, etc) into @daqjob. See TO072208A. -- Tim O'Connor 7/30/08
%  TO080108D - Make sure to disable channels when stopping them. -- Tim O'Connor 8/1/08
%
% Created
%  Timothy O'Connor 7/30/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function stop(this, varargin)
global daqjobGlobalStructure;
% fprintf(1, '@daqjob/stop: ');
% for i = 1 : length(varargin)
%     fprintf(1, '%s, ', varargin{i});
% end
% % fprintf(1, '\n%s', getStackTraceString);
% fprintf(1, '\n');

%Do we need/want a warning here?
% if ~daqjobGlobalStructure(this.ptr).started
%     warning('@daqjob ''%s'' instance not started.', daqjobGlobalStructure(this.ptr).name);
% end

if isempty(varargin)
    channelsToStop = {daqjobGlobalStructure(this.ptr).channelMap{:, 1}};
else
    channelsToStop = channelNamesToRealChannels(this, varargin);%TO073008A
    if ~iscell(channelsToStop)
        channelsToStop = {channelsToStop};
    end
end

if ischar(channelsToStop)
    channelsToStop = {channelsToStop};
end

taskList = [];
for i = 1 : length(channelsToStop)
    task = getTaskByChannelName(this, channelsToStop{i});

    if isempty(taskList)
        taskList = task;
    else
        if ~any(task == taskList)
            taskList(end + 1) = task;
        end
    end
end

if ~isempty(daqjobGlobalStructure(this.ptr).masterSampleClock)
% fprintf(1, '@daqjob/stop: Stopping @%s (@%s) [masterSampleClock].\n', dec2hex(nimex_getPointer(daqjobGlobalStructure(this.ptr).masterSampleClock)), num2str(nimex_getPointer(daqjobGlobalStructure(this.ptr).masterSampleClock)));
    nimex_stopTask(daqjobGlobalStructure(this.ptr).masterSampleClock);%TO050508G
end

%Don't mark the whole job as stopped until all subtasks are stopped.
daqjobGlobalStructure(this.ptr).channelsToStart = setdiff(daqjobGlobalStructure(this.ptr).channelsToStart, channelsToStop);
if ischar(daqjobGlobalStructure(this.ptr).channelsToStart)
    daqjobGlobalStructure(this.ptr).channelsToStart = {daqjobGlobalStructure(this.ptr).channelsToStart};
end

daqjobGlobalStructure(this.ptr).waitingForTrigger = 0;
daqjobGlobalStructure(this.ptr).started = 0;

deviceNamesToStop = getDeviceNameByChannelName(this, channelsToStop);%TO080108D
for i = 1 : length(taskList)
    nimex_stopTask(taskList(i));
    channels = nimex_getTaskProperty(taskList(i), 'channels');
    enabledChannelIndices = [];
    for j = 1 : length(channels)
        %TO080108D - Make sure to disable channels when stopping them. -- Tim O'Connor 8/1/08
        if ismember(channels{j}, deviceNamesToStop)
            nimex_setChannelProperty(taskList(i), channels{j}, 'enable', 0);
        elseif nimex_getChannelProperty(taskList(i), channels{j}, 'enable')
            enabledChannelIndices(end + 1) = j;
        end
    end
    channels = {channels{enabledChannelIndices}};
    channelsToRestart = setdiff(channels, getDeviceNameByChannelName(this, channelsToStop));

    daqjobGlobalStructure(this.ptr).channelsToStart = union(getChannelNameByDeviceName(this, channelsToRestart), daqjobGlobalStructure(this.ptr).channelsToStart);
    if ~isempty(channelsToRestart)
        for j = 1 : length(channels)
            %TO043008D - Fixed index for `channels` inside this loop, had been using `i`. Also added the `else` clause, whose statement had just been entirely outside the `if` block.
            if ismember(channels{j}, channelsToRestart)
                nimex_setChannelProperty(taskList(i), channels{j}, 'enable', 1);
                %TO050308C - Forcibly clear and repopulate the buffer here. Otherwise NIMEX may try to be efficient, but end up using stale data. -- Tim O'Connor 5/3/08
                if nimex_isOutput(taskList(i))
                    %fprintf(1, '@daqjob/stop - clearing buffer for %s\n', channels{j});
                    nimex_clearBuffer(taskList(i), channels{j});
                    %fprintf(1, '@daqjob/stop - updating buffer by callback for %s\n', channels{j});
                    nimex_updateDataSourceByCallback(taskList(i), channels{j});
                end
            else
                nimex_setChannelProperty(taskList(i), channels{j}, 'enable', 0);
            end
        end
        nimex_startTask(taskList(i));
%         for j = 1 : length(channels)
%             if ismember(channels{j}, channelsToRestart)
%                 if nimex_getChannelProperty(taskList(i), channels{j}, 'channelType') == 101
%                     nimex_updateDataSourceByCallback(taskList(i), channels{j});
%                 end
%             end
%         end
        daqjobGlobalStructure(this.ptr).waitingForTrigger = 1;
        daqjobGlobalStructure(this.ptr).started = 1;
    end
end

daqjobGlobalStructure(this.ptr).expectedDoneEventCount = 0;
for i = 1 : size(daqjobGlobalStructure(this.ptr).taskMap, 1)
    if nimex_getTaskProperty(daqjobGlobalStructure(this.ptr).taskMap{i, 2}, 'started')
% fprintf(1, '@daqjob/stop - Determining expectedDoneEventCount: ''%s'' is started.\n', daqjobGlobalStructure(this.ptr).taskMap{i, 1});
        daqjobGlobalStructure(this.ptr).expectedDoneEventCount = daqjobGlobalStructure(this.ptr).expectedDoneEventCount + 1;%TO101807I
    end
end

daqjobGlobalStructure(this.ptr).startedChannels = setdiff(daqjobGlobalStructure(this.ptr).startedChannels, channelsToStop);
if ischar(daqjobGlobalStructure(this.ptr).startedChannels)
    daqjobGlobalStructure(this.ptr).startedChannels = {daqjobGlobalStructure(this.ptr).startedChannels};
end

fireEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'jobStop', channelsToStop);
% fprintf('@daqjob/stop - Complete.\n');
return;
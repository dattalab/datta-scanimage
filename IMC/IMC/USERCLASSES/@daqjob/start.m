% @daqjob/start - Start the specified channel(s).
% 
% SYNTAX
%  start(dj, channelName)
%  start(dj, channelName, ...)
%   dj - @daqjob instance.
%   channelName - The mnemonic name of the channel to start.
%                 Multiple channel names may be specified.
%
% NOTES
%  This may potentially restart the underlying nimex task(s) if other channels
%  are already in use.
%
% NOTES
%
% CHANGES
%  TO101807H - Track the done state of each task in C, just examine it from here. -- Tim O'Connor 10/18/07
%  TO101807I - It turns out that a count is needed, but lets not do a running subtraction, lets just look at the done field. -- Tim O'Connor 10/18/07
%  TO050508G - Added a masterSampleClock field. -- Tim O'Connor 5/5/08
%
% Created
%  Timothy O'Connor 7/30/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function start(this, varargin)
global daqjobGlobalStructure;
% fprintf(1, '@daqjob/start: ');
% for i = 1 : length(varargin)
%     fprintf(1, '%s, ', varargin{i});
% end
% % fprintf(1, '\n%s', getStackTraceString);
% fprintf(1, '\n');

%For now, allow this to happen. The rest of the state machine should assure that it's okay to do this.
%Besides, we have no reliable way of testing for external triggers having been sent.
% if (daqjobGlobalStructure(this.ptr).started && ~daqjobGlobalStructure(this.ptr).waitingForTrigger)
%     error('@daqjob instance ''%s'' already in use (trigger has already been issued).', daqjobGlobalStructure(this.ptr).name);
% end

if isempty(varargin)
    fprintf(1, '@daqjob/start - No channels specified in start command. Starting all channels...\n');
    channelsToStart = {daqjobGlobalStructure(this.ptr).channelMap{:, 1}};
else
    channelsToStart = {varargin{:}};
end

if isempty(daqjobGlobalStructure(this.ptr).channelsToStart)
    daqjobGlobalStructure(this.ptr).channelsToStart = channelsToStart;
else
    daqjobGlobalStructure(this.ptr).channelsToStart = unique(cat(2, channelsToStart, daqjobGlobalStructure(this.ptr).channelsToStart));
end
if ischar(daqjobGlobalStructure(this.ptr).channelsToStart)
    daqjobGlobalStructure(this.ptr).channelsToStart = {daqjobGlobalStructure(this.ptr).channelsToStart};
end

taskList = [];
for i = 1 : length(daqjobGlobalStructure(this.ptr).channelsToStart)
    if (daqjobGlobalStructure(this.ptr).channelsToStart{i}(1) == '/')
        task = getTaskByDeviceName(this, daqjobGlobalStructure(this.ptr).channelsToStart{i});
    else
        task = getTaskByChannelName(this, daqjobGlobalStructure(this.ptr).channelsToStart{i});
    end
    if isempty(taskList)
        taskList = task;
    else
        if ~any(task == taskList)
            taskList(end + 1) = task;
        end
    end
end

if (daqjobGlobalStructure(this.ptr).started && daqjobGlobalStructure(this.ptr).waitingForTrigger)
    for i = 1 : length(taskList)
        if nimex_getTaskProperty(taskList(i), 'started')
            nimex_stopTask(taskList(i));
            %daqjobGlobalStructure(this.ptr).outstandingTaskCount = daqjobGlobalStructure(this.ptr).outstandingTaskCount - 1;%TO101807H
        end
    end
end

daqjobGlobalStructure(this.ptr).started = 1;
daqjobGlobalStructure(this.ptr).waitingForTrigger = 1;
daqjobGlobalStructure(this.ptr).done = 0;
daqjobGlobalStructure(this.ptr).doneEventCount = 0;

fireEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'jobStart', daqjobGlobalStructure(this.ptr).channelsToStart);

if ~isempty(daqjobGlobalStructure(this.ptr).masterSampleClock)
% fprintf(1, '@daqjob/start: Stopping @%s (@%s) [masterSampleClock].\n', dec2hex(nimex_getPointer(daqjobGlobalStructure(this.ptr).masterSampleClock)), num2str(nimex_getPointer(daqjobGlobalStructure(this.ptr).masterSampleClock)));
    nimex_stopTask(daqjobGlobalStructure(this.ptr).masterSampleClock);%TO050508G
end

for i = 1 : length(daqjobGlobalStructure(this.ptr).channelsToStart)
    if (daqjobGlobalStructure(this.ptr).channelsToStart{i}(1) == '/')
        channelsToStart{i} = daqjobGlobalStructure(this.ptr).channelsToStart{i};
    else
        channelsToStart{i} = getDeviceNameByChannelName(this, daqjobGlobalStructure(this.ptr).channelsToStart{i});
    end
end

for i = 1 : length(taskList)
    channels = nimex_getTaskProperty(taskList(i), 'channels');
    
    shouldBeEnabled = ismember(channels, channelsToStart);
    for j = 1 : length(channels)
        if shouldBeEnabled(j)
            nimex_setChannelProperty(taskList(i), channels{j}, 'enable', 1);
        else
            nimex_setChannelProperty(taskList(i), channels{j}, 'enable', 0);
        end
    end
    %daqjobGlobalStructure(this.ptr).outstandingTaskCount = daqjobGlobalStructure(this.ptr).outstandingTaskCount + 1;%TO101807H
    if ~nimex_getTaskProperty(taskList(i), 'started')
% fprintf(1, '@daqjob/start: Starting @%s (@%s).\n', dec2hex(nimex_getPointer(taskList(i))), num2str(nimex_getPointer(taskList(i))));
        nimex_startTask(taskList(i));
    end
end

if ~isempty(daqjobGlobalStructure(this.ptr).masterSampleClock)
% fprintf(1, '@daqjob/start: Starting/restarting @%s (@%s) [masterSampleClock].\n', dec2hex(nimex_getPointer(daqjobGlobalStructure(this.ptr).masterSampleClock)), num2str(nimex_getPointer(daqjobGlobalStructure(this.ptr).masterSampleClock)));
    try
        nimex_startTask(daqjobGlobalStructure(this.ptr).masterSampleClock);%TO050508G
    catch
        nimex_stopTask(daqjobGlobalStructure(this.ptr).masterSampleClock);
        nimex_startTask(daqjobGlobalStructure(this.ptr).masterSampleClock);
    end
end

daqjobGlobalStructure(this.ptr).startedChannels = union(daqjobGlobalStructure(this.ptr).startedChannels, varargin);
if ischar(daqjobGlobalStructure(this.ptr).startedChannels)
    daqjobGlobalStructure(this.ptr).startedChannels = {daqjobGlobalStructure(this.ptr).startedChannels};
end

daqjobGlobalStructure(this.ptr).expectedDoneEventCount = 0;
for i = 1 : size(daqjobGlobalStructure(this.ptr).taskMap, 1)
    if nimex_getTaskProperty(daqjobGlobalStructure(this.ptr).taskMap{i, 2}, 'started')
% fprintf(1, '@daqjob/start - Determining expectedDoneEventCount: ''%s'' is started.\n', daqjobGlobalStructure(this.ptr).taskMap{i, 1});
        daqjobGlobalStructure(this.ptr).expectedDoneEventCount = daqjobGlobalStructure(this.ptr).expectedDoneEventCount + 1;%TO101807I
    end
end

% fprintf('@daqjob/start - Complete.\n');
return;
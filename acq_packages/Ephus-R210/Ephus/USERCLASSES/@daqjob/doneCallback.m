% @daqjob/doneCallback - Processes doneEvents from nimex.
% 
% SYNTAX
%  doneCallback(dj, task)
%   dj - @daqjob instance.
%   task - @nimex instance.
%  
% NOTES
%  This function is responsible for demultiplexing doneEvents across tasks.
%  It will initiate the jobDone event when all tasks have completed.
%  It passes a list of all channels involved in the acquisition to listeners for the 'jobDone' event.
%
% CHANGES
%  TO101807H - Track the done state of each task in C, just examine it from here. -- Tim O'Connor 10/18/07
%  TO101807I - It turns out that a count is needed, but lets not do a running subtraction, lets just look at the done field. -- Tim O'Connor 10/18/07
%  TO101907A - Don't stop the task automatically, in case we're auto-restarting for an "external trigger". -- Tim O'Connor 10/19/07
%  TO012508A - Issue a jobStart command, due to the autoRestart handled in nimex. -- Tim O'Connor 1/24/08
%  TO050508G - Added a masterSampleClock field. -- Tim O'Connor 5/5/08
%  TO080108A - Restart the master sample clock, if any autoRestart properties are set. -- Tim O'Connor 8/1/08
%  TO081508A - Make sure the master sample clock exists before trying to manipulate it. -- Tim O'Connor 8/15/08
%  TO082708A - Make sure the master sample clock is stopped before trying to autoRestart it. -- Tim O'Connor 8/27/08
%  
% Created
%  Timothy O'Connor 7/30/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function doneCallback(this, task)
global daqjobGlobalStructure;
% fprintf(1, '%s - @daqjob/doneCallback: @%s\n', datestr(now), num2str(nimex_getPointer(task)));
% getTaskByChannelName(daqjob('acquisition'), 'xMirror')
%nimex_stopTask(task);%TO101907A
daqjobGlobalStructure(this.ptr).doneEventCount = daqjobGlobalStructure(this.ptr).doneEventCount + 1;
if daqjobGlobalStructure(this.ptr).doneEventCount < daqjobGlobalStructure(this.ptr).expectedDoneEventCount
% fprintf(1, '@daqjob/doneCallback: Not all done events have arrived yet...\n\tdoneEventCount: %s\n\texpectedDoneEventCount: %s\n', num2str(daqjobGlobalStructure(this.ptr).doneEventCount), num2str(daqjobGlobalStructure(this.ptr).expectedDoneEventCount));
    return;
end

if ~isempty(daqjobGlobalStructure(this.ptr).masterSampleClock)
% fprintf(1, '@daqjob/doneCallback: Stopping @%s (@%s) [masterSampleClock].\n', dec2hex(nimex_getPointer(daqjobGlobalStructure(this.ptr).masterSampleClock)), num2str(nimex_getPointer(daqjobGlobalStructure(this.ptr).masterSampleClock)));
    nimex_stopTask(daqjobGlobalStructure(this.ptr).masterSampleClock);%TO050508G
end

daqjobGlobalStructure(this.ptr).channelsToStart = {};
daqjobGlobalStructure(this.ptr).waitingForTrigger = 0;
daqjobGlobalStructure(this.ptr).done = 1;
daqjobGlobalStructure(this.ptr).committed = 0;

% % fprintf(1, '%s @daqjob/doneCallback - Propogating event. outstandingTaskCount = %s\n', datestr(now), num2str(daqjobGlobalStructure(this.ptr).outstandingTaskCount));
% if daqjobGlobalStructure(this.ptr).outstandingTaskCount < 0
%     fprintf(2, '%s - @daqjob/doneCallback - Warning outstandingTaskCount (%s) < 0, resetting to 0.\n', datestr(now), num2str(daqjobGlobalStructure(this.ptr).outstandingTaskCount));
%     daqjobGlobalStructure(this.ptr).outstandingTaskCount = 0;
% end
daqjobGlobalStructure(this.ptr).doneEventCount = 0;
% fprintf(1, '%s - @daqjob/doneCallback: Firing ''jobDone'' event...\n', datestr(now));
fireEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'jobDone', daqjobGlobalStructure(this.ptr).startedChannels);
% fprintf(1, '%s - @daqjob/doneCallback: Firing ''jobCompleted'' event...\n', datestr(now));
fireEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'jobCompleted', daqjobGlobalStructure(this.ptr).startedChannels);

%TO012508A - Issue a jobStart command, due to the autoRestart handled in nimex. -- Tim O'Connor 1/24/08
taskList = [];
for i = 1 : length(daqjobGlobalStructure(this.ptr).startedChannels)
    task = getTaskByChannelName(this, daqjobGlobalStructure(this.ptr).startedChannels{i});
    if isempty(taskList)
        taskList = task;
    else
        if ~any(task == taskList)
            taskList(end + 1) = task;
        end
    end
end
autoRestart = 0;%TO080108A
for i = 1 : length(taskList)
    if nimex_getTaskProperty(daqjobGlobalStructure(this.ptr).taskMap{i, 2}, 'autoRestart')
        autoRestart = 1;%TO080108A
        fireEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'jobStart', daqjobGlobalStructure(this.ptr).channelsToStart);
        break;
    end
end
%TO080108A
if autoRestart
    %TO081508A
    if ~isempty(daqjobGlobalStructure(this.ptr).masterSampleClock)
        nimex_stopTask(daqjobGlobalStructure(this.ptr).masterSampleClock);%TO082708A
        nimex_startTask(daqjobGlobalStructure(this.ptr).masterSampleClock);
    end
end

return;
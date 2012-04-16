% @daqjob/stopAllTasks - Stops all tasks, without regard to any @daqjob level states. 
%                        The state is then reset to nominal (as if no start/stop/trigger ever occurred).
%
% SYNTAX
%  stopAllTasks(dj)
%   dj - @daqjob instance.
%
% NOTES
%
% CHANGES
%  TO050508G - Added a masterSampleClock field. -- Tim O'Connor 5/5/08
%
% Created
%  Timothy O'Connor 7/30/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function stopAllTasks(this, varargin)
global daqjobGlobalStructure;

for i = 1 : size(daqjobGlobalStructure(this.ptr).taskMap, 1)
    try
        nimex_stopTask(daqjobGlobalStructure(this.ptr).taskMap{i, 2});
    catch
        fprintf(2, '@daqjob/stopAllTasks: Failed to stop task ''%s'' (@%s): %s', ...
            daqjobGlobalStructure(this.ptr).taskMap{i, 1}, nimex_getPointer(daqjobGlobalStructure(this.ptr).taskMap{i, 2}), lasterr);
    end
end

if ~isempty(daqjobGlobalStructure(this.ptr).masterSampleClock)
    nimex_stopTask(daqjobGlobalStructure(this.ptr).masterSampleClock);%TO050508G
end

daqjobGlobalStructure(this.ptr).channelsToStart = {};
daqjobGlobalStructure(this.ptr).started = 0;
daqjobGlobalStructure(this.ptr).waitingForTrigger = 0;
daqjobGlobalStructure(this.ptr).triggersExecuted = 0;
daqjobGlobalStructure(this.ptr).done = 0;
daqjobGlobalStructure(this.ptr).triggerRepeats = 0;
daqjobGlobalStructure(this.ptr).expectedDoneEventCount = 0;
daqjobGlobalStructure(this.ptr).committed = 0;
daqjobGlobalStructure(this.ptr).doneEventCount = 0;

return;
% @daqjob/delete - Destroy this daqjob instance.
%
% SYNTAX
%  delete(job)
%   job - The daqjob instance to be deleted.
%
% NOTES
%
% CHANGES
%   VI102308A: Handle new triggerDestinations and triggerDestinationIndex properties -- Vijay Iyer 10/23/08
%
% Created
%  Timothy O'Connor 5/31/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function delete(this)
global daqjobGlobalStructure;

%Initialize.
daqjobGlobalStructure(this.ptr).name = '';
for i = 1 : size(daqjobGlobalStructure(this.ptr).taskMap, 1)
    delete(daqjobGlobalStructure(this.ptr).taskMap{i, 2});
end
daqjobGlobalStructure(this.ptr).taskMap = {};%subsystem name (ie. 'dev1/ai'), nimex object
daqjobGlobalStructure(this.ptr).channelMap = {};%mnemonic name, subsystem name, channel id
%daqjobGlobalStructure(this.ptr).outstandingTaskCount = 0;%TO101807H
delete(daqjobGlobalStructure(this.ptr).callbackManager);
daqjobGlobalStructure(this.ptr).callbackManager = {};
daqjobGlobalStructure(this.ptr).channelsToStart = {};
daqjobGlobalStructure(this.ptr).started = 0;
daqjobGlobalStructure(this.ptr).waitingForTrigger = 0;
daqjobGlobalStructure(this.ptr).triggersExecuted = 0;
daqjobGlobalStructure(this.ptr).done = 0;
daqjobGlobalStructure(this.ptr).triggerRepeats = 0;
daqjobGlobalStructure(this.ptr).triggerOrigin = '';
daqjobGlobalStructure(this.ptr).triggerDestinations = {}; %VI102308A
daqjobGlobalStructure(this.ptr).triggerDestinationIndex = []; %VI102308A
daqjobGlobalStructure(this.ptr).sampleClockDestination = '';
delete(daqjobGlobalStructure(this.ptr).preprocessors);
daqjobGlobalStructure(this.ptr).preprocessors = {};
daqjobGlobalStructure(this.ptr).expectedDoneEventCount = 0;%TO101807I
daqjobGlobalStructure(this.ptr).committed = 0;
daqjobGlobalStructure(this.ptr).doneEventCount = 0;
daqjobGlobalStructure(this.ptr).startedChannels = {};
daqjobGlobalStructure(this.ptr).masterSampleClock = [];%TO050508G

return;

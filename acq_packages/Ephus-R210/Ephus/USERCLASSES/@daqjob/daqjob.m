% @daqjob/daqjob - Create/retrieve a @daqjob instance.
%
%% SYNTAX
%  daqjob(name)
%   name - A string that uniquely identifies the @daqjob instance.
%          If a daqjob with the name already exists, that instance will be returned.
%
%% NOTES
%  This is a singleton function, and depending on the name, it may not create a new instance.
%  This feature is convenient for sharing a @daqjob across multiple domains, without having to explicitly
%  store a local reference. It's also helpful for command-line debugging.
%
%% CHANGES
%  TO101807H - Track the done state of each task in C, just examine it from here. -- Tim O'Connor 10/18/07
%  TO101807I - It turns out that a count is needed, but lets not do a running subtraction, lets just look at the done field. -- Tim O'Connor 10/18/07
%  TO033008D - Add clockOrigin and clockDestination. -- Tim O'Connor 3/30/08
%  TO050508C - Reworked the clock synchronization to allow for a sampleClock and a timebaseClock (20MHz). -- Tim O'Connor 5/5/08
%  TO050508G - Added a masterSampleClock field. -- Tim O'Connor 5/5/08
%  VI060608A - Added inputOverflowMode property -- Vijay Iyer 6/6/08
%  TO073008A - Implemented the concept of pseudochannels (channels operating under pseudonyms). See TO072208A. -- Tim O'Connor 7/30/08
%  VI080708A - Renamed inputOverflowMode to readErrorMode -- Vijay Iyer 8/7/08
%  VI102208A - Made triggerDestination a cell array argument (triggerDestinations) and added triggerDestinationIndex property -- Vijay Iyer 10/22/08
%
%% CREDITS
%  Timothy O'Connor 7/30/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function this = daqjob(name)
global daqjobGlobalStructure;

if isempty(daqjobGlobalStructure)
    index = [];
else
    %Look for an existing job with that name.
    index = find(strcmpi({daqjobGlobalStructure(:).name}, name));
end

if ~isempty(index)
    if length(index) > 1
        warning('daqjob - Found multiple object instances that match ''%s''.', name);
    end
    this.ptr = index(1);
else
    this.ptr = length(daqjobGlobalStructure) + 1;
    %Initialize.
    daqjobGlobalStructure(this.ptr).name = name;
    daqjobGlobalStructure(this.ptr).taskMap = {};%subsystem name (ie. 'dev1/ai'), nimex object
    daqjobGlobalStructure(this.ptr).channelMap = {};%mnemonic name, subsystem name, channel id
    %daqjobGlobalStructure(this.ptr).outstandingTaskCount = 0;%TO101807H
    daqjobGlobalStructure(this.ptr).callbackManager = callbackmanager;
    daqjobGlobalStructure(this.ptr).channelsToStart = {};
    daqjobGlobalStructure(this.ptr).started = 0;
    daqjobGlobalStructure(this.ptr).waitingForTrigger = 0;
    daqjobGlobalStructure(this.ptr).triggersExecuted = 0;
    daqjobGlobalStructure(this.ptr).done = 0;
    daqjobGlobalStructure(this.ptr).triggerRepeats = 0;
    daqjobGlobalStructure(this.ptr).triggerOrigin = '/dev1/port0/line0';
    daqjobGlobalStructure(this.ptr).triggerDestinations = {}; %VI102208A
    daqjobGlobalStructure(this.ptr).triggerDestinationIndex = []; %VI102208A
    daqjobGlobalStructure(this.ptr).sampleClockDestination = '';%TO033008D %TO050508C
    %daqjobGlobalStructure(this.ptr).timebaseDestination = '';%TO033008D %TO050508C
    addEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'jobStart');
    addEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'jobTrigger');
    addEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'jobStop');
    addEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'jobDone');
    addEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'jobCompleted');%Comes after jobDone, to ensure proper clean-up.
    addEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'sharedPropertyUpdate');%Event which occurs when one or more of the properties shared by all tasks in the @daqjob are updated
    daqjobGlobalStructure(this.ptr).preprocessors = callbackmanager;%TEMPORARY, Push into nimex.
    daqjobGlobalStructure(this.ptr).expectedDoneEventCount = 0;%TO101807I
    daqjobGlobalStructure(this.ptr).committed = 0;
    daqjobGlobalStructure(this.ptr).doneEventCount = 0;
    daqjobGlobalStructure(this.ptr).startedChannels = {};
    daqjobGlobalStructure(this.ptr).masterSampleClock = [];%TO050508G
    daqjobGlobalStructure(this.ptr).readErrorMode = 'error'; %('error' or 'drop') specify behavior when input data cannot be retrieved before next buffer arrives (VI060608A/VI080708A)
    daqjobGlobalStructure(this.ptr).pseudoChannelMap = {};%TO073008A
    
end

this = class(this, 'daqjob');

return;
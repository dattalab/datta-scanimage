% @daqjob/display - Print the state of the object.
%
% SYNTAX
%  display(job)
%   job - A @daqjob instance.
%
% NOTES
%
% CHANGES
%  TO101807H - Track the done state of each task in C, just examine it from here. -- Tim O'Connor 10/18/07
%  TO032908A - Implement end-to-end digital channel support in Ephus. -- Tim O'Connor 3/29/08
%  TO033008D - Add clockOrigin and clockDestination. -- Tim O'Connor 3/30/08
%  TO033108E - Print channelMap with semi-fixed field widths, to enhance readability. -- Tim O'Connor 3/31/08
%  TO050508C - Reworked the clock synchronization to allow for a sampleClock and a timebaseClock (20MHz). -- Tim O'Connor 5/5/08
%  TO050508G - Added a masterSampleClock field. -- Tim O'Connor 5/5/08
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%  TO080108F - Print out the inputOverflowMode, which should've been done as part of VI060608A. -- Tim O'Connor 8/1/08
%
% Created
%  Timothy O'Connor 10/15/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function display(this)
global daqjobGlobalStructure;

fprintf(1, '@daqjob v0.2\n\tObjectPointer: %s\n\tName: ''%s''\n', num2str(this.ptr), daqjobGlobalStructure(this.ptr).name);
fprintf(1, '\ttaskMap:\n');
for i = 1 : size(daqjobGlobalStructure(this.ptr).taskMap, 1)
    p = nimex_getPointer(daqjobGlobalStructure(this.ptr).taskMap{i, 2});
    fprintf(1, '\t\t''%s'': @%s (@%s)\n', daqjobGlobalStructure(this.ptr).taskMap{i, 1}, dec2hex(p), num2str(p));
end

fprintf(1, '\tchannelMap:\n');
%TO033108E
fieldWidth = [5, 5, 3];%characters.
for i = 1 : size(daqjobGlobalStructure(this.ptr).channelMap, 1)
    fieldWidth(1) = max(fieldWidth(1), min(length(daqjobGlobalStructure(this.ptr).channelMap{i, 1}), 20));
    fieldWidth(2) = max(fieldWidth(2), min(length(daqjobGlobalStructure(this.ptr).channelMap{i, 2}), 20));
    fieldWidth(3) = max(fieldWidth(3), min(length(daqjobGlobalStructure(this.ptr).channelMap{i, 3}), 20));
end
channelMap = daqjobGlobalStructure(this.ptr).channelMap;
for i = 1 : size(channelMap, 1)
    if length(channelMap{i, 1}) < fieldWidth(1)
        channelMap{i, 1} = ['''' channelMap{i, 1} '''' (' ' * ones(1, fieldWidth(1) - length(channelMap{i, 1})))];
    else
        channelMap{i, 1} = ['''' channelMap{i, 1} ''''];
    end
    if length(channelMap{i, 2}) < fieldWidth(1)
        channelMap{i, 2} = ['''' channelMap{i, 2} '''' (' ' * ones(1, fieldWidth(2) - length(channelMap{i, 2})))];
    else
        channelMap{i, 2} = ['''' channelMap{i, 2} ''''];
    end
    if length(channelMap{i, 3}) < fieldWidth(1)
        channelMap{i, 3} = ['''' channelMap{i, 3} '''' (' ' * ones(1, fieldWidth(3) - length(channelMap{i, 3})))];
    else
        channelMap{i, 3} = ['''' channelMap{i, 3} ''''];
    end
end
fprintf(1, ['\t\t Mnemonic' (' ' * ones(1, fieldWidth(1) - length('Mnemonic'))) '      Subsystem ' (' ' * ones(1, fieldWidth(2) - length('Subsystem'))) '    ID     Type\n']);
for i = 1 : size(channelMap, 1)
    if length(num2str(channelMap{i, 3})) < 3
        fprintf(1, '\t\t%s -> %s :  %s   : ''%s''\n', channelMap{i, 1}, channelMap{i, 2}, ...
            num2str(channelMap{i, 3}), channelMap{i, 4});
    else
        fprintf(1, '\t\t%s -> %s : %s : ''%s''\n', channelMap{i, 1}, channelMap{i, 2}, ...
            num2str(channelMap{i, 3}), channelMap{i, 4});
    end
end

%TO073008A
fprintf(1, '\tpseudoChannelMap:\n');
% for i = 1 : size(daqjobGlobalStructure(this.ptr).pseudoChannelMap, 1)
%     fprintf(1, '\t\t''%s'' --> ''%s''\n', daqjobGlobalStructure(this.ptr).pseudoChannelMap{i, 1}, daqjobGlobalStructure(this.ptr).pseudoChannelMap{i, 2});
% end
channelMap = daqjobGlobalStructure(this.ptr).pseudoChannelMap;
for i = 1 : size(channelMap, 1)
    if length(channelMap{i, 1}) < fieldWidth(1)
        channelMap{i, 1} = ['''' channelMap{i, 1} '''' (' ' * ones(1, fieldWidth(1) - length(channelMap{i, 1})))];
    else
        channelMap{i, 1} = ['''' channelMap{i, 1} ''''];
    end
    if length(channelMap{i, 2}) < fieldWidth(1)
        channelMap{i, 2} = ['''' channelMap{i, 2} '''' (' ' * ones(1, fieldWidth(2) - length(channelMap{i, 2})))];
    else
        channelMap{i, 2} = ['''' channelMap{i, 2} ''''];
    end
end
for i = 1 : size(channelMap, 1)
    fprintf(1, '\t\t%s -> %s\n', channelMap{i, 1}, channelMap{i, 2});
end

fprintf(1, '\texpectedDoneEventCount: %s\n', num2str(daqjobGlobalStructure(this.ptr).expectedDoneEventCount));
fprintf(1, '\tchannelsToStart: %s\n', num2str(length(daqjobGlobalStructure(this.ptr).channelsToStart)));
fprintf(1, '\tstarted: %s\n', num2str(daqjobGlobalStructure(this.ptr).started));
fprintf(1, '\twaitingForTrigger: %s\n', num2str(daqjobGlobalStructure(this.ptr).waitingForTrigger));
fprintf(1, '\ttriggersExecuted: %s\n', num2str(daqjobGlobalStructure(this.ptr).triggersExecuted));
fprintf(1, '\tdoneEventCount: %s\n', num2str(daqjobGlobalStructure(this.ptr).doneEventCount));
fprintf(1, '\tdone: %s\n', num2str(daqjobGlobalStructure(this.ptr).done));
fprintf(1, '\ttriggerRepeats: %s\n', num2str(daqjobGlobalStructure(this.ptr).triggerRepeats));
fprintf(1, '\ttriggerOrigin: ''%s''\n', num2str(daqjobGlobalStructure(this.ptr).triggerOrigin));
fprintf(1, '\ttriggerDestination: ''%s''\n', num2str(daqjobGlobalStructure(this.ptr).triggerDestination));
fprintf(1, '\tsampleClockDestination: ''%s''\n', num2str(daqjobGlobalStructure(this.ptr).sampleClockDestination));%TO033008D %TO050508C
%fprintf(1, '\tclockDestination: ''%s''\n', num2str(daqjobGlobalStructure(this.ptr).clockDestination));%TO033008D %TO050508C
if isempty(daqjobGlobalStructure(this.ptr).startedChannels)
    fprintf(1, '\tstartedChannels: NONE\n');
else
    fprintf(1, '\tstartedChannels: ');
    for i = 1 : length(daqjobGlobalStructure(this.ptr).startedChannels) - 1
        fprintf(1, '''%s'', ', daqjobGlobalStructure(this.ptr).startedChannels{i});
    end
    fprintf(1, '''%s''\n', daqjobGlobalStructure(this.ptr).startedChannels{end});
end
if isempty(daqjobGlobalStructure(this.ptr).channelsToStart)
    fprintf(1, '\tchannelsToStart: NONE\n');
else
    fprintf(1, '\tchannelsToStart: ');
    for i = 1 : length(daqjobGlobalStructure(this.ptr).channelsToStart) - 1
        fprintf(1, '''%s'', ', daqjobGlobalStructure(this.ptr).channelsToStart{i});
    end
    fprintf(1, '''%s''\n', daqjobGlobalStructure(this.ptr).channelsToStart{end});
end
if isempty(daqjobGlobalStructure(this.ptr).masterSampleClock)
    fprintf(1, '\tmasterSampleClock: []\n');
else
    fprintf(1, '\tmasterSampleClock: @%s (@%s)\n', dec2hex(nimex_getPointer(daqjobGlobalStructure(this.ptr).masterSampleClock)), num2str(nimex_getPointer(daqjobGlobalStructure(this.ptr).masterSampleClock)));
end
fprintf(1, '\tinputOverflowMode: %s\n', daqjobGlobalStructure(this.ptr).inputOverflowMode);%TO080108F

return;
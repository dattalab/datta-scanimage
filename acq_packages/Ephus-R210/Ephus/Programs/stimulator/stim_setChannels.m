% stim_setChannels - Load a set of channels into the program.
%
% SYNTAX
%  stim_setChannels(hObject, channels)
%    channels - An array of channels, that this program has access to.
%
% USAGE
%
% NOTES
%  This is a copy & paste job from ephys_setAmplifiers.m, with some editting where necessary.
%
% CHANGES
%  TO083005A: Altered pulses to be stored in individual files. -- Tim O'Connor 8/30/05
%  TO091405A: Continuation of TO083005A. -- Tim O'Connor 9/14/05
%  TO100405C: Allow scopes to become invisible. -- Tim O'Connor 10/4/05
%  TO121605B: Implemented 'extraGain' feature, which was there but had been postponed. -- Tim O'Connor 12/16/05
%  TO010506C: Rework triggering scheme for ease of use and simpler looping. Switch to a checkbox for external, which leaves it always started. -- Tim O'Connor 1/5/06
%  TO101707D: Port to nimex. -- Tim O'Connor 10/17/07
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO033108C - Support digital output channels. -- Tim O'Connor 3/31/08
%  TO072208A - Allow multiple digital lines to appear separate in the GUI, but actually be grouped underneath. -- Tim O'Connor 7/22/08
%  TO073008A - Moved channelIndirection functionality from the programs (ephys, stimulator, acquirer, etc) into @daqjob. See TO072208A. -- Tim O'Connor 7/30/08
%  VI081808A - Simplified/corrected identification of board & port cohorts to group into pseudochannels -- Vijay Iyer 8/18/08
%
% Created 11/22/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function stim_setChannels(hObject, channels)

if ~isempty(channels)
    setLocalGh(progmanager, hObject, 'channelList', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'stimOn', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');%Pulses must be mapped before starting.
else
    setLocalGh(progmanager, hObject, 'channelList', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'stimOn', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
end

if ~isempty(channels) && exist(getLocal(progmanager, hObject, 'pulseSetDir'), 'dir') == 7 %TO083005A
    setLocalGh(progmanager, hObject, 'pulseSetName', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'pulseSetName', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'Off');
end

setLocal(progmanager, hObject, 'channels', channels);

names = {channels(:).channelName};
setLocalGh(progmanager, hObject, 'channelList', 'String', names);

%Just check if one of the array variables is right, and assume the rest are in a similar state.
%If the length of the arrays matches the number of channels, assume it's from a loaded configuration, and don't mess with it.
if length(getLocal(progmanager, hObject, 'stimOnArray')) ~= length(channels)
    emptyStrings = cell(length(channels), 1);
    for i = 1 : length(channels)
        emptyStrings{i} = '';
    end
    zs = zeros(length(channels), 1);
    os = ones(length(channels), 1);
    setLocalBatch(progmanager, hObject, 'stimOnArray', zs, 'extraGainArray', os, 'pulseSelectionHasChanged', os, ...
        'pulseSetNameArray', emptyStrings, 'pulseNameArray', emptyStrings, 'pulseTimestamps', emptyStrings);
end

shared_selectChannel(hObject, 1);%TO101707F

if isempty(channels)
    setLocal(progmanager, hObject, 'status', 'NO_CHANNEL(s)');
else
    setLocal(progmanager, hObject, 'status', '');
end

%TO010506C - Check the trigger setting before enabling the 'startButton'. -- Tim O'Connor 1/5/06
if isempty(channels) || exist(getLocal(progmanager, hObject, 'pulseSetDir'), 'dir') ~= 7 || getLocal(progmanager, hObject, 'externalTrigger')
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
else
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
end

job = daqjob('acquisition');
pMap = pulseMap('acquisition');
%TO072208A
if ~isfield(channels(1), 'portID')
    channels(1).portID = [];
    analog = 1:length(channels);
    digital = [];
else
    analog = [];
    digital = [];
    for i = 1 : length(channels)
        if ~isempty(channels(i).channelID)
            analog(end + 1) = i;
        end
        if ~isempty(channels(i).portID)
            if isempty(channels(i).lineID)
                error('Missing lineID field for channel ''%s'' (%s).', channels(i).channelName, num2str(i));
            end
            digital(end + 1) = i;
        end
    end
    if length(union(analog, digital)) ~= (length(analog) + length(digital))
        error('Invalid channel specification(s). Channels may have a channelID or a portID, but not both.');
    end
end

%TO072208A
for i = 1 : length(analog)
    % fprintf(1, 'Setup analog ''%s'' --> ''/dev%s/ao%s''\n', channels(i).channelName, num2str(channels(i).boardID), num2str(channels(i).channelID));
    if ~isChannel(job, channels(analog(i)).channelName)
        addAnalogOutput(job, channels(analog(i)).channelName, ['/dev' num2str(channels(analog(i)).boardID) '/ao'], channels(analog(i)).channelID);
        task = getTaskByChannelName(job, channels(analog(i)).channelName);
        nimex_registerOutputDataPreprocessor(task, getDeviceNameByChannelName(job, channels(analog(i)).channelName), ...
            {@stim_outputDataPreprocessor, hObject, analog(i)}, [channels(analog(i)).channelName '_preprocessor'], 1);
        setChannelProperty(job, channels(analog(i)).channelName, 'dataSource', {@getData, pMap, channels(analog(i)).channelName, job});
    end
end
%TO072208A
sharedDigital = [];
%Figure out which digital channels share ports, if any are exclusively dedicated to a single line, set them up now (just like a standard analog channel).
for i = 1 : length(digital)
    exclusive = 1;
    if ~any([channels(digital(i + 1 : end)).portID] == channels(digital(i)).portID) && ~any([channels(sharedDigital).portID] == channels(digital(i)).portID)
        %This line owns the port (no need to combine the digital signals in binary).
        %fprintf(1, 'Setup digital ''%s'' --> ''/dev%s/port%s/line%s'' (exclusive)\n', ...
        %    channels(digital(i)).channelName, num2str(channels(digital(i)).boardID), num2str(channels(digital(i)).portID), num2str(channels(digital(i)).lineID));
        if ~isChannel(job, channels(digital(i)).channelName)
            %TO033108C
            addDigitalOutput(job, channels(digital(i)).channelName, ['/dev' num2str(channels(digital(i)).boardID) '/port' num2str(channels(digital(i)).portID) '/line'], channels(digital(i)).lineID);
            setChannelProperty(job, channels(digital(i)).channelName, 'dataSource', {@getDigitalData, pMap, channels(digital(i)).channelName, job});
        end
    else
        %fprintf(1, 'Setup digital ''%s'' --> ''/dev%s/port%s/line%s'' (non-exclusive)\n', ...
        %    channels(digital(i)).channelName, num2str(channels(digital(i)).boardID), num2str(channels(digital(i)).portID), num2str(channels(digital(i)).lineID));
        sharedDigital(end + 1) = digital(i);
    end
end
%Now set up the digital lines that share ports. Do a binary combination of the data in the dataSource callback.
boardIDs = [channels(sharedDigital(:)).boardID];
[boardIDs, digitalUnique] = unique(boardIDs);
for j = 1 : length(boardIDs)
    channelsOnBoard = sharedDigital([channels(sharedDigital(:)).boardID] == boardIDs(j)); %VI081808A
    portIDs = [channels(channelsOnBoard(:)).portID]; %VI081808A
    portIDs = unique(portIDs);

    for i = 1 : length(portIDs)
        % fprintf(1, 'Aggregating digital line(s) for port %s.\n', num2str(portIDs(i)));
        channelsOnPort = sharedDigital([channels(channelsOnBoard(:)).portID] == portIDs(i)); %VI081808A
        [lineIDs, order] = sort([channels(channelsOnPort(:)).lineID]); %VI081808A
        aggregatedChannels = {channels(channelsOnPort(order)).channelName}; %VI081808A

        aggregatedChannelName = ['dev' num2str(boardIDs(j)) '_port' num2str(portIDs(i))];
        addDigitalOutput(job, aggregatedChannelName, ['/dev' num2str(boardIDs(j)) '/port' num2str(portIDs(i)) '/line'], lineIDs);
        setChannelProperty(job, aggregatedChannelName, 'dataSource', {@getAggregatedDigitalData, pMap, aggregatedChannels, aggregatedChannelName, job});
        addPseudoChannel(job, {channels(channelsOnPort(order)).channelName}, aggregatedChannelName); %VI081808A
    end
end
% for j = 1 : length(boardIDs)
%     boards = digital(find(channels(digital(:)).boardID == boardIDs(j)));
%     portIDs = [channels(boards(:)).portID];
%     portIDs = unique(portIDs);
%     physicalNameBase = ['/dev' num2str(boardIDs(j)) '/port' num2str(portIDs(i))];
%     physicalName = '';
%     for i = 1 : length(portIDs)
%         lines = digital(find(channels(digital(:)).portID == portIDs(i)));
%         for k = 1 : length(lines)
%             if ~isempty(physicalName)
%                 physicalName = [physicalName ', '];
%             end
%             physicalName = [physicalName num2str(lines(k))];
%         end
%         addDigitalOutput(job, channels(digital(i)).channelName, ['/dev' num2str(boardIDs(j)) '/port' num2str(portIDs(i)) '/line'], ???);
%         setChannelProperty(job, channels(digital(i)).channelName, 'dataSource', {@getDigitalData, pMap, channels(digital(i)).channelName, job});
%     end
% 
% end

nameArray = cell(length(channels), 1);
setLocalBatch(progmanager, hObject, 'pulseNameMapping', nameArray, 'pulseSetMapping', nameArray);

return;

% ------------------------------------------------------------------
%TO101707F - Brought over from stim_configureAomux.m
%TO121605B, TO121905C
%  TO123005M: Convert values into mV (the pulseEditor's units) before they go out to the board. -- Tim O'Connor 12/30/05
function preprocessed = stim_outputDataPreprocessor(hObject, channelIndex, data)
% fprintf(1, 'stim_setChannels/stim_outputDataPreprocessor: InitialRange = [%s %s].\n', num2str(min(data)), num2str(max(data)));

extraGainArray = getLocal(progmanager, hObject, 'extraGainArray');
% fprintf(1, 'stim_setChannels/stim_outputDataPreprocessor: Scaling data by a factor of %s (%s) with channelIndex %s.\n', num2str(extraGainArray(channelIndex)), num2str(extraGainArray(channelIndex) * 0.001), num2str(channelIndex));
preprocessed = data * extraGainArray(channelIndex) * 0.001;%TO123005M

% fprintf(1, 'stim_setChannels/stim_outputDataPreprocessor: FinalRange = [%s %s].\n', num2str(min(preprocessed)), num2str(max(preprocessed)));

return;
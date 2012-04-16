% ephys_setAmplifiers - Load a set of amplifiers into the program.
%
% SYNTAX
%  ephys_setAmplifiers(hObject, amplifiers)
%    amplifiers - An array of amplifiers, that this program has access to.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO083005A: Altered pulses to be stored in individual files. -- Tim O'Connor 8/30/05
%  TO091405A: Continuation of TO083005A. -- Tim O'Connor 9/14/05
%  TO100405C: Allow scopes to become invisible. -- Tim O'Connor 10/4/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO120905C - Allow traces to be taken when no pulses are loaded (acquisition only). -- Tim O'Connor 12/9/05
%  TO123005H - Watch out for the HandleVisibility property on the scope figure. -- Tim O'Connor 12/30/05
%  TO032406F - Use callbackManager instance to notify amplifier state listeners. -- Tim O'Connor 3/24/06
%  TO110906D - Make sure that all V-Com channels are initialized. -- Tim O'Connor 11/9/06
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO012408C - Make sure the correct scope object is bound (index by i). -- Tim O'Connor 1/24/08
%  TO012408D - When manipulating the axes' ColorOrder, the HandleVisibilities must be toggled. -- Tim O'Connor 1/24/08
%  JL020108A - changed the order of the toggled from off to on. This enable the toolbar in the figure
%  VI042808A - Follow Tim O'Connor's fix to allow more than 2 color-differentiated amplifier windows to be displayed
%  TOVJ042808A - Watch out for amplifiers with no output. -- Tim O'Connor/Vijay Iyer 4/28/08
%  TO053008B - Moved common start-up script functionality into the various programs. -- Tim O'Connor 5/30/08
%  TO021610H - Put the extraGain feature back into Ephys. -- Tim O'Connor 2/16/10
%  TO021810A - This had been clobbering the preprocessor for the daqjob by using the same name. -- Tim O'Connor 2/18/10
%  TO030210H - Pass the associated scopeObject into shared_recordData. -- Tim O'Connor 3/2/10
%  TO052710B - Handle amplifiers that do not specify a scaledOutputChannelName or a vComChannelName. -- Tim O'Connor 5/27/10
%  TO060810C - Fixed JL020108A so it doesn't do the same thing 3 times and doesn't cause a blank gui to pop up. -- Tim O'Connor 6/8/10
%
% Created 5/20/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephys_setAmplifiers(hObject, amplifiers)

if ~isempty(amplifiers)
    setLocalGh(progmanager, hObject, 'amplifierList', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'acqOn', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'stimOn', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'showStimInAcq', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');%Pulses must be mapped before starting.
else
    setLocalGh(progmanager, hObject, 'amplifierList', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'acqOn', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'stimOn', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'showStimInAcq', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
end

if ~isempty(amplifiers) && exist(getLocal(progmanager, hObject, 'pulseSetDir'), 'dir') == 7 %TO083005A
    setLocalGh(progmanager, hObject, 'pulseSetName', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'pulseSetName', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'Off');
end

%TO120205A
if ~iscell(amplifiers)
    if length(amplifiers) ~= 1
        error('Invalid amplifier collection class: %s', class(amplifiers));
    end
    amplifiers = {amplifiers};
end

setLocal(progmanager, hObject, 'amplifiers', amplifiers);
[sc] = getLocalBatch(progmanager, hObject, 'scopeObject');%TO123005H %TO110906D

names = {};
job = daqjob('acquisition');
pMap = pulseMap('acquisition');
for i = 1 : length(amplifiers)
    bindToDaqJob(amplifiers{i}, job);%TO053008B
    names{i} = get(amplifiers{i}, 'name');%TO120205A
    bindStateListener(amplifiers{i}, {@ephys_amplifierStateListenerFcn, hObject}, ['ephysAmplifierStateListener_' num2str(i)]);%TO120205A% %TO032406F
    %TO123005H - Only create one when there's not enough scopes, otherwise modify the existing one.
    if i > length(sc)
        if isempty(sc)
            sc = scopeObject('Name', ['Acquisition-' get(amplifiers{i}, 'name')]);%TO120205A
        else
            sc(i) = scopeObject('Name', ['Acquisition-' get(amplifiers{i}, 'name')]);%TO120205A
        end
    else
        set(sc(i), 'Name', ['Acquisition-' get(amplifiers{i}, 'name')]);
    end
    switch (i)
        case 1
            set(sc(i), 'BackgroundColor', [1 1 1], 'ForegroundColor', [0 0 0]);
        case 2
            set(sc(i), 'BackgroundColor', [0.87 0.87 0.87], 'ForegroundColor', [0 0 0]);
        otherwise
            set(sc(i), 'BackgroundColor', [1 1 1] - 0.75 / i, 'ForegroundColor', [0 0 0]); %VI042808A
    end
    %TO100405C
    %TO012408D - When manipulating the axes' ColorOrder, the HandleVisibilities must be toggled. -- Tim O'Connor 1/24/08
    %JL020108A - changed the order of the toggled from off to on. This enable the toolbar in the figure
    %TO060810C - Fixed JL020108A so it doesn't do the same thing 3 times and doesn't cause a blank gui to pop up. -- Tim O'Connor 6/8/10
    [ax, f] = get(sc(i), 'axes', 'figure');
    set([ax, f], 'HandleVisibility', 'On');
    set(ax, 'ColorOrder', hsv);
    set(f, 'CloseRequestFcn', 'set(gcbf, ''Visible'', ''Off'')', 'HandleVisibility', 'Off');
    
    scaledOutputChannelName = getScaledOutputChannelName(amplifiers{i});

    vComChannelName = getVComChannelName(amplifiers{i});
    %TO052710B - Handle amplifiers that do not specify a scaledOutputChannelName.
    if ~isempty(scaledOutputChannelName)
        bindDataListener(job, scaledOutputChannelName, {@shared_recordData, hObject, ['trace_' num2str(i)], scaledOutputChannelName, sc(i)}, 'ephys_recordData');%TO101707F %TO030210H
        bindToDaqjob(sc(i), job, scaledOutputChannelName);%TO012408C
        %TOVJ042808A - Watch out for amplifiers with no output. -- Tim O'Connor/Vijay Iyer 4/28/08
        if ~isempty(vComChannelName)
            setChannelProperty(job, vComChannelName, 'dataSource', {@getData, pMap, vComChannelName, job});
        end
    else
        fprintf(2, 'Warning (ephys): Amplifier ''%s'' (''%s'') does not specify a scaledOutputChannelName, no recording may be done through this amplifier instance.\n', ...
            get(amplifiers{i}, 'name'), class(amplifiers{i}));
    end
    if ~isempty(vComChannelName)
        %TO021810A - This had been clobbering the preprocessor for the daqjob by using the same name.
        nimex_registerOutputDataPreprocessor(getTaskByChannelName(job, vComChannelName), getDeviceNameByChannelName(job, vComChannelName), ...
            {@ephys_outputDataPreprocessor, hObject, i}, [vComChannelName '_extraGainPreprocessor'], 1);%TO021610H
    else
        fprintf(2, 'Warning (ephys): Amplifier ''%s'' (''%s'') does not specify a vComChannelName, no pulses may be sent through this amplifier instance.\n', ...
            get(amplifiers{i}, 'name'), class(amplifiers{i}));
    end
end
setLocal(progmanager, hObject, 'scopeObject', sc);
setLocalGh(progmanager, hObject, 'amplifierList', 'String', names);

%Just check if one of the array variables is right, and assume the rest are in a similar state.
%If the length of the arrays matches the number of amplifiers, assume it's from a loaded configuration, and don't mess with it.
if length(getLocal(progmanager, hObject, 'stimOnArray')) ~= length(amplifiers)
    emptyStrings = cell(length(amplifiers), 1);
    for i = 1 : length(amplifiers)
        emptyStrings{i} = '';
    end
    zs = zeros(length(amplifiers), 1);
    os = ones(length(amplifiers), 1);
    setLocalBatch(progmanager, hObject, 'stimOnArray', zs, 'extraGainArray', os, 'acqOnArray', os, 'pulseSelectionHasChanged', os, ...
        'pulseSetNameArray', emptyStrings, 'pulseNameArray', emptyStrings, 'pulseTimestamps', emptyStrings);
end

shared_selectChannel(hObject, 1);%TO101707F

if isempty(amplifiers)
    setLocal(progmanager, hObject, 'status', 'NO_AMPLIFIER(s)');
else
    setLocal(progmanager, hObject, 'status', '');
end

%TO120905C - Allow traces to be taken when no pulses are loaded (acquisition only). -- Tim O'Connor 12/9/05
% if isempty(amplifiers) | exist(getLocal(progmanager, hObject, 'pulseSetDir')) ~= 7
%     setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
% else
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
% end

nameArray = cell(length(amplifiers), 1);
setLocalBatch(progmanager, hObject, 'pulseNameMapping', nameArray, 'pulseSetMapping', nameArray);

return;

% ------------------------------------------------------------------
%TO101707F - Brought over from stim_configureAomux.m
%TO121605B, TO121905C
%  TO123005M: Convert values into mV (the pulseEditor's units) before they go out to the board. -- Tim O'Connor 12/30/05
function preprocessed = ephys_outputDataPreprocessor(hObject, amplifierIndex, data)
% fprintf(1, 'ephys_setAmplifiers/ephys_outputDataPreprocessor: InitialRange = [%s %s].\n', num2str(min(data)), num2str(max(data)));

extraGainArray = getLocal(progmanager, hObject, 'extraGainArray');
% fprintf(1, 'ephys_setAmplifiers/ephys_outputDataPreprocessor: Scaling data by a factor of %s (%s) with channelIndex %s.\n', num2str(extraGainArray(channelIndex)), num2str(extraGainArray(channelIndex) * 0.001), num2str(channelIndex));
preprocessed = data * extraGainArray(amplifierIndex);%TO123005M

% fprintf(1, 'ephys_setAmplifiers/ephys_outputDataPreprocessor: FinalRange = [%s %s].\n', num2str(min(preprocessed)), num2str(max(preprocessed)));

return;
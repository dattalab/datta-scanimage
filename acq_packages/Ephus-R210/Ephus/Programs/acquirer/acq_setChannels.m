% acq_setChannels - Load a set of channels into the program.
%
% SYNTAX
%  acq_setChannels(hObject, channels)
%    channels - An array of channels, that this program has access to.
%
% USAGE
%
% NOTES
%  This is a copy & paste job from stim_setChannels.m, with some editting where necessary.
%
% CHANGES
%  TO083005A: Altered pulses to be stored in individual files. -- Tim O'Connor 8/30/05
%  TO091405A: Continuation of TO083005A. -- Tim O'Connor 9/14/05
%  TO100405C: Allow scopes to become invisible. -- Tim O'Connor 10/4/05
%  TO121605B: Implemented 'extraGain' feature, which was there but had been postponed. -- Tim O'Connor 12/16/05
%  TO123005H - Watch out for the HandleVisibility property on the scope figure. -- Tim O'Connor 12/30/05
%  TO101907C - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/19/07
%  TO012408C - Make sure the correct scope object is bound (index by i). -- Tim O'Connor 1/24/08
%  TO012408D - When manipulating the axes' ColorOrder, the HandleVisibilities must be toggled. -- Tim O'Connor 1/24/08
%  JL020108A - hanged the order of the toggled from off to on. This enable the toolbar in the figure
%  VI061108A - Handle scope coloring in a way that allows more than 3 channels -- Vijay Iyer 6/11/08
%  TO030210H - Pass the associated scopeObject into shared_recordData. -- Tim O'Connor 3/2/10
%  TO060810C - Fixed JL020108A so it doesn't do the same thing 3 times and doesn't cause a blank gui to pop up. -- Tim O'Connor 6/8/10
%
% Created 12/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function acq_setChannels(hObject, channels)

if ~isempty(channels)
    setLocalGh(progmanager, hObject, 'channelList', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'acqOn', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');%Pulses must be mapped before starting.
else
    setLocalGh(progmanager, hObject, 'channelList', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'acqOn', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
end

setLocal(progmanager, hObject, 'channels', channels);

setLocalGh(progmanager, hObject, 'channelList', 'String', {channels(:).channelName});

%Just check if one of the array variables is right, and assume the rest are in a similar state.
%If the length of the arrays matches the number of channels, assume it's from a loaded configuration, and don't mess with it.
if length(getLocal(progmanager, hObject, 'acqOnArray')) ~= length(channels)
    emptyStrings = cell(length(channels), 1);
    for i = 1 : length(channels)
        emptyStrings{i} = '';
    end
    zs = zeros(length(channels), 1);
    os = ones(length(channels), 1);
    setLocalBatch(progmanager, hObject, 'acqOnArray', os, 'pulseSelectionHasChanged', [], ...
        'pulseSetNameArray', {}, 'pulseNameArray', {}, 'pulseTimestamps', {});
end

job = daqjob('acquisition');
sc = getLocal(progmanager, hObject, 'scopeObject');%TO123005H
for i = 1 : length(channels)
    %TO123005H - Only create one when there's not enough scopes, otherwise modify the existing one.
    if i > length(sc)
        if isempty(sc)
            sc = scopeObject('Name', ['Acquisition-' channels(i).channelName]);%TO120205A
        else
            sc(i) = scopeObject('Name', ['Acquisition-' channels(i).channelName]);%TO120205A
        end
    else
        set(sc(i), 'Name', ['Acquisition-' channels(i).channelName]);
    end
    switch (i)
        case 1
            set(sc(i), 'BackgroundColor', [0.1 0.1 0.5], 'ForegroundColor', [1 1 1]);
        case 2
            set(sc(i), 'BackgroundColor', [0.1 0.1 0.7], 'ForegroundColor', [1 1 1]);
        otherwise
            set(sc(i), 'BackgroundColor', [1 1 1] - 0.35 / i, 'ForegroundColor', [0 0 0]); %VI061108
    end

    %TO100405C
    %TO012408D - When manipulating the axes' ColorOrder, the HandleVisibilities must be toggled. -- Tim O'Connor 1/24/08
    %JL020108A - changed the order of the toggled from off to on. This enable the toolbar in the figure
    %TO060810C - Fixed JL020108A so it doesn't do the same thing 3 times and doesn't cause a blank gui to pop up. -- Tim O'Connor 6/8/10
    [ax, f] = get(sc(i), 'axes', 'figure');
    set([ax, f], 'HandleVisibility', 'On');
    set(ax, 'ColorOrder', hsv);
    set(f, 'CloseRequestFcn', 'set(gcbf, ''Visible'', ''Off'')', 'HandleVisibility', 'Off');

    addAnalogInput(job, channels(i).channelName, ['/dev' num2str(channels(i).boardID) '/ai'], channels(i).channelID);
    bindDataListener(job, channels(i).channelName, {@shared_recordData, hObject, ['trace_' num2str(i)], channels(i).channelName, sc(i)}, 'acquirer_recordData');%TO101707F %TO030210H
    bindToDaqjob(sc(i), job, channels(i).channelName);%TO012408C
end
setLocal(progmanager, hObject, 'scopeObject', sc);

shared_selectChannel(hObject, 1);

if isempty(channels)
    setLocal(progmanager, hObject, 'status', 'NO_CHANNEL(s)');
else
    setLocal(progmanager, hObject, 'status', '');
end

return;
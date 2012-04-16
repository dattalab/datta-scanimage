% ephysAcc_start - Start running the scope via the ephysAccessory GUI.
%
% SYNTAX
%  ephysAcc_start(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO062705C - Clear old scope data and check units. -- Tim O'Connor 6/27/05
%  TO070805A: Cache acquisition parameters, for faster calculations. -- Tim O'Connor 7/8/05
%  TO100405C: Make sure the scopes are visible. -- Tim O'Connor 10/4/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO032406F - Use a start ID to safely ignore superfluous calls to the amplifier state change listener function. -- Tim O'Connor 3/24/06
%  TO032406H - Update the units string on the scope display(s). -- Tim O'Connor 3/24/06
%  TO032906C - Only show scopes for channels that are acquiring. -- Tim O'Connor 3/29/06
%  TO040706C - Carry the figure visibility back to the associated scope object. -- Tim O'Connor 4/7/06
%  TO040706D - Reordered much of the functionality to help with getting the correct scope options and amplifier state. -- Tim O'Connor 4/7/06
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO012308B - Reworked logic for updating multiple amplifiers. Now the ampIndex must be an argument. -- Tim O'Connor 1/23/08
%  VI022110A - Use amplifier object 'input_units' value, rather than determining strictly from mode (both A and V units are possible in either mode, depending on primary output selection in Multiclamp case) -- Vijay Iyer/Tim O'Connor 2/21/10
%  TO032410B - Shut off other programs that are set to be externally triggered. -- Tim O'Connor 3/24/10
%  TO033110A - Make sure the correct programs are being called. -- Tim O'Connor 3/31/10
%  TO042210E - 'stimulator' should be 'stimulatorObj'. -- Tim O'Connor 4/22/10
%  TO052810B - Use a try/catch when updating the amplifier state. -- Tim O'Connor 5/28/10
%
% Created 2/25/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephysAcc_start(hObject)
global ephysScopeAccessory;
% fprintf(1, 'ephysAcc_start\n%s\n', getStackTraceString);

%Update the GUI to show this is running.
setLocal(progmanager, hObject, 'startButton', 1);
setLocalGh(progmanager, hObject, 'startButton', 'String', 'Stop', 'ForegroundColor', [1 0 0]);
setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Off');
setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Off');

%TO032410B - Shut off other programs that are set to be externally triggered.
if isprogram(progmanager, 'ephys')
    ephysObj = getGlobal(progmanager, 'hObject', 'ephys', 'ephys');
    if getLocal(progmanager, ephysObj, 'externalTrigger')
        setLocal(progmanager, ephysObj, 'externalTrigger', 0);
        ephys('externalTrigger_Callback', ephysObj, [], guidata(ephysObj));%TO033110A
    end
end
if isprogram(progmanager, 'acquirer')
    acquirerObj = getGlobal(progmanager, 'hObject', 'acquirer', 'acquirer');
    if getLocal(progmanager, acquirerObj, 'externalTrigger')
        setLocal(progmanager, acquirerObj, 'externalTrigger', 0);
        acquirer('externalTrigger_Callback', acquirerObj, [], guidata(acquirerObj));%TO033110A
    end
end
if isprogram(progmanager, 'stimulator')
    stimulatorObj = getGlobal(progmanager, 'hObject', 'stimulator', 'stimulator');
    if getLocal(progmanager, stimulatorObj, 'externalTrigger') %TO042210E
        setLocal(progmanager, stimulatorObj, 'externalTrigger', 0);
        stimulator('externalTrigger_Callback', stimulatorObj, [], guidata(stimulatorObj));%TO033110A
    end
end

%TO032406F - Use a start ID to safely ignore superfluous calls to the amplifier state change listener function. -- Tim O'Connor 3/24/06
startID = rand;
setLocal(progmanager, hObject, 'startID', startID);

%TO070805A: Cache acquisition parameters, for faster calculations. -- Tim O'Connor 7/8/05
ephysScopeAccessory.calc_cellParams.testPulses = getLocal(progmanager, hObject, 'testPulses');
ephysScopeAccessory.calc_cellParams.sampleRate = getLocal(progmanager, hObject, 'sampleRate');
sc = getMain(progmanager, hObject, 'scopeObject');

[amplifiers acqOnArray] = getLocalBatch(progmanager, hObject, 'amplifiers', 'acqOnArray');%TO032906C
for i = 1 : length(amplifiers)
% fprintf(1, 'amplifier %s\n', num2str(i));
    try
        update(amplifiers{i});%TO120205A
    catch
        fprintf(2, 'ephysAcc_start: Failed to update amplifier ''%s'' -\n%s\n', get(amplifiers{i}, 'name'), getLastErrorStack);%TO052810B
    end
    
    ephysScopeAccessory.calc_cellParams.duration(i) = 2 * ephysAcc_getDuration(hObject, i);
    
    %TO100405C: Make sure the scopes are visible.
    f = get(sc(i), 'figure');
    %TO032906C
    if acqOnArray(i)
        set(sc(i), 'Visible', 'On');
    elseif strcmpi(get(f, 'Visible'), 'Off')
        %TO040706C
        set(sc(i), 'Visible', 'Off');
    end
    
    %%%VITO022110: Removed
    %TO032406H
    %     if get(amplifiers{i}, 'current_clamp')
    %         set(sc(i), 'yUnitsString', 'mV', 'gridOn', 0);
    %     else
    %         set(sc(i), 'yUnitsString', 'pA', 'gridOn', 0);
    %     end
    %%%%%%%%%%%%%%%%%%%%
    
    set(sc(i),'yUnitsString', get(amplifiers{i}, 'input_units'), 'gridOn', 0); %VITO022110
    
%     bindStateListener(amplifiers{i}, {@ephysAcc_amplifierStateListenerFcn, hObject, startID}, ['ephysAccAmplifierStateListener_' num2str(i)]);%TO032406F
%     bindStateListener(amplifiers{i}, {@ephysAcc_amplifierStateListenerFcn, hObject, i}, ['ephysAccAmplifierStateListener_' num2str(i)]);%TO120205A %TO032406F %TO012308B
end
ephysScopeAccessory.calc_cellParams.samples = ephysScopeAccessory.calc_cellParams.duration * ephysScopeAccessory.calc_cellParams.sampleRate;

%TO062705C - Clear old scope data and check units. -- Tim O'Connor 6/27/05
clearData(getMain(progmanager, hObject, 'scopeObject'));
if isguiinprogram(progmanager,getProgramName(progmanager,hObject),'scopeGui')%VI060108A (do this conditionally)
    scg_updateGuiFromScope(getMain(progmanager, hObject, 'hObject'));
end

%TO040706D - Reordered much of the functionality to help with getting the correct scope options and amplifier state. -- Tim O'Connor 4/7/06
inputChannels = shared_getInputChannelNames(hObject);%TO101707F
outputChannels = shared_getOutputChannelNames(hObject);%TO101707F

ephysAcc_updateInput(hObject);

ephysAcc_updateOutput(hObject);

job = daqjob('scope');
start(job, inputChannels{:}, outputChannels{:});
if getLocal(progmanager, hObject, 'selfTrigger')
    trigger(job);
end

% startChannel(getDaqmanager, outputChannels{:}, inputChannels{:});
% 
% %Execute trigger
% if getLocal(progmanager, hObject, 'selfTrigger')
%     triggerLine = getLocal(progmanager, hObject, 'triggerLine');
%     putvalue(triggerLine, 1);
%     putvalue(triggerLine, 0);
%     putvalue(triggerLine, 1);
% end

% for i = 1 : length(outputChannels)
%     getAO(getDaqmanager, outputChannels{i})
% end
% for i = 1 : length(inputChannels)
% %     inputChannels{i}
% %     get(getAI(getDaqmanager, inputChannels{i}))
%     getAI(getDaqmanager, inputChannels{i})
% %    getAIProperty(getDaqmanager, inputChannels{i}, 'SamplesPerTrigger')
% %     samplesPerTrigger = get(getAI(getDaqmanager, inputChannels{i}), 'SamplesPerTrigger')
% %     samplesAcquiredFcnCount = get(getAI(getDaqmanager, inputChannels{i}), 'SamplesAcquiredFcnCount')
% end

return;

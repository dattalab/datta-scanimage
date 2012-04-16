% ephysAcc_setAmplifiers - Load a set of amplifiers into the scope.
%
% SYNTAX
%  ephysAcc_setAmplifiers(hObject, amplifiers)
%    amplifiers - An array of amplifiers, that this scope has access to.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO100405C: Allow scopes to become invisible. -- Tim O'Connor 10/4/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO121405B: New scope setting, 'autoRangeForceFit' set to 0 will reduce jjiitttteeerr. -- Tim O'Connor 12/14/05
%  TO121905A: New scope setting, 'autoRangeUseWaveScaling', to mimic the behavior of the @wave class. -- Tim O'Connor 12/19/05
%  TO032406F - Use callbackManager instance to notify state listeners. -- Tim O'Connor 3/24/06
%  TO050806E - Modified default values. -- Tim O'Connor 5/8/06
%  TO110907A - Implement cell parameters under nimex. -- Tim O'Connor 11/9/07
%  TO012308A - Correctly bind the pulses to the output channels here, instead of in the startup file. -- Tim O'Connor 1/23/08
%  TO012308B - Reworked logic for updating multiple amplifiers. Now the ampIndex must be an argument. -- Tim O'Connor 1/23/08
%  TOVJ042808A - Watch out for amplifiers with no output. -- Tim O'Connor/Vijay Iyer 4/28/08
%  TO053008B - Moved common start-up script functionality into the various programs. -- Tim O'Connor 5/30/08
%  VI060108A - Changes associated with making ephysAcc a stand-alone program, with its own scopeObject array -- Vijay Iyer 6/1/08
%  TO021610K - Made the preset values programmable. -- Tim O'Connor 2/16/10
%  TO052710B - Handle amplifiers that do not specify a scaledOutputChannelName or a vComChannelName. -- Tim O'Connor 5/27/10
%
% Created 4/1/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephysAcc_setAmplifiers(hObject, amplifiers)

if ~isempty(amplifiers)
    setLocalGh(progmanager, hObject, 'amplifierList', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'acqOn', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'stimOn', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'averageOn', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'vClampDuration', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'vClampAmplitude', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'vClampPreset1', 'Enable', 'On');%TO021610K
    setLocalGh(progmanager, hObject, 'vClampPreset2', 'Enable', 'On');%TO021610K
    setLocalGh(progmanager, hObject, 'iClampDuration', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'iClampAmplitude', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'iClampPreset1', 'Enable', 'On');%TO021610K
    setLocalGh(progmanager, hObject, 'iClampPreset2', 'Enable', 'On');%TO021610K
else
    setLocalGh(progmanager, hObject, 'amplifierList', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'acqOn', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'stimOn', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'averageOn', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'vClampDuration', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'vClampAmplitude', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'vClampPreset1', 'Enable', 'Off');%TO021610K
    setLocalGh(progmanager, hObject, 'vClampPreset2', 'Enable', 'Off');%TO021610K
    setLocalGh(progmanager, hObject, 'iClampDuration', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'iClampAmplitude', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'iClampPreset1', 'Enable', 'Off');%TO021610K
    setLocalGh(progmanager, hObject, 'iClampPreset2', 'Enable', 'Off');%TO021610K
end

%TO120205A
if ~iscell(amplifiers)
    if length(amplifiers) ~= 1
        error('Invalid amplifier collection class: %s', class(amplifiers));
    end
    amplifiers = {amplifiers};
end

setLocal(progmanager, hObject, 'amplifiers', amplifiers);

job = daqjob('scope');
sc = getMain(progmanager, hObject, 'scopeObject'); 
names = {};
pm = pulseMap('scope');%TO012308A
for i = 1 : length(amplifiers)
    bindToDaqJob(amplifiers{i}, job);%TO053008B
    %Add a second scope for the other channels.
    if length(sc) < i
        newObj = scopeObject('Name', ['Oscilloscope-' get(amplifiers{i}, 'name')], 'autoRangeUseWaveScaling', 1);%TO120205A, TO121405B, TO121905A
        if isempty(sc) %VI060108A (lame that this seems necessary)
            sc = newObj;
        else
            sc(i) = newObj;
        end
    else
        set(sc(i), 'Name', ['Oscilloscope-' get(amplifiers{i}, 'name')], 'autoRangeUseWaveScaling', 1);%TO120205A, TO121905A
    end
    
    names{i} = get(amplifiers{i}, 'name');%TO120205A
%     bindToAIMUX(amplifiers{i}, getLocal(progmanager, hObject, 'aimux'));%TO120205A
%     bindStateListener(amplifiers{i}, {@ephys_amplifierStateListenerFcn, hObject}, ['ephysAmplifierStateListener_' num2str(i)]);%TO120205A %TO032406F
    bindStateListener(amplifiers{i}, {@ephysAcc_amplifierStateListenerFcn, hObject, i}, ['ephysAccAmplifierStateListener_' num2str(i)]);%TO120205A %TO032406F %TO012308B
    
    switch (i)
        case 1
            set(sc(i), 'BackgroundColor', [0 0 0]);
        case 2
            set(sc(i), 'BackgroundColor', [0 0.3 0]);
        otherwise
            set(sc(i), 'BackgroundColor', [.1 .1 .1] + 0.1 * i);
    end
    
    %TO100405C
    f = get(sc(i), 'figure');
    set(f, 'CloseRequestFcn', 'set(gcbf, ''Visible'', ''Off'')');
    %TO052710B - Handle amplifiers that do not specify a scaledOutputChannelName.
    scaledOutputChannelName = getScaledOutputChannelName(amplifiers{i});
    if ~isempty(scaledOutputChannelName)
        bindToDaqjob(sc(i), job, scaledOutputChannelName);
        bindDataListener(job, scaledOutputChannelName, {@ephysAcc_calcCellParams, hObject, i}, [get(amplifiers{i}, 'name'), '-cellParams']);%TO110907A
    else
        fprintf(2, 'Warning (ephysScope): Amplifier ''%s'' (''%s'') does not specify a scaledOutputChannelName, no recording may be done through this amplifier instance.\n', ...
            get(amplifiers{i}, 'name'), class(amplifiers{i}));
    end
    vCom = getVComChannelName(amplifiers{i});%TO012308A
    %TOVJ042808A - Watch out for amplifiers with no output. -- Tim O'Connor/Vijay Iyer 4/28/08
    if ~isempty(vCom)
        setChannelProperty(job, vCom, 'dataSource', {@getData, pm, vCom, job});%TO012308A
    else
        fprintf(2, 'Warning (ephysScope): Amplifier ''%s'' (''%s'') does not specify a vComChannelName, no pulses may be sent through this amplifier instance.\n', ...
            get(amplifiers{i}, 'name'), class(amplifiers{i}));
    end
    
    updateDisplayOptions(sc(i)); %VI060108A    
end

setLocalGh(progmanager, hObject, 'amplifierList', 'String', names);
setMain(progmanager, hObject, 'scopeObject', sc); 

%Just check if one of the array variables is right, and assume the rest are in a similar state.
%If the length of the arrays matches the number of amplifiers, assume it's from a loaded configuration, and don't mess with it.
if length(getLocal(progmanager, hObject, 'stimOnArray')) ~= length(amplifiers)
	setLocal(progmanager, hObject, 'vClampAmplitudeArray', ones(length(amplifiers), 1) * -5);
	setLocal(progmanager, hObject, 'iClampAmplitudeArray', ones(length(amplifiers), 1) * 100);
	setLocal(progmanager, hObject, 'vClampDurationArray', ones(length(amplifiers), 1) * 0.05);%TO050806E
	setLocal(progmanager, hObject, 'iClampDurationArray', ones(length(amplifiers), 1) * 0.1);%TO050806E
	setLocal(progmanager, hObject, 'stimOnArray', ones(length(amplifiers), 1));
	setLocal(progmanager, hObject, 'acqOnArray', ones(length(amplifiers), 1));
	setLocal(progmanager, hObject, 'averageArray', zeros(length(amplifiers), 1));
end

testPulses = getLocal(progmanager, hObject, 'testPulses');
% map = getMap(pm);
if isempty(testPulses)
    for i = 1 : length(amplifiers)
        vCom = getVComChannelName(amplifiers{i});
        pulses(i) = signalobject('Name', ['scopeGui:' vCom]);
        setPulse(pm, vCom, pulses(i));
%         map{size(map, 1) + 1, 1} = vCom;
%         map{size(map, 1), 2} = {@ephysAcc_outputDataSource, hObject, vCom, {@getdata, pulses(i)}};
    end
    setLocal(progmanager, hObject, 'testPulses', pulses);
%     setMap(pm, map);
end

ephysAcc_selectAmplifier(hObject, 1);
% ephysAcc_configureAimux(hObject);
% ephysAcc_configureAomux(hObject);
% ephysAcc_updateInput(hObject);
% ephysAcc_updateOutput(hObject);

return;

%--------------------------------------------------------------------------
function data = ephysAcc_outputDataSource(hObject, channelName, callback, varargin)

if ~isempty(varargin)
    data = feval(callback{:}, varargin{:});
else
    data = feval(callback{:});
end
data = repmat(data, 10, 1);

return;
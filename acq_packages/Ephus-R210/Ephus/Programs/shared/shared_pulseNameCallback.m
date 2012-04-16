% shared_pulseNameCallback - Exposes what would've typically been in the GUI's m-file.
%
% SYNTAX
%  shared_pulseNameCallback(hObject)
%  shared_pulseNameCallback(hObject, index)
%   hObject - The program handle.
%   index - The index of the amplifier/channel for which to load a pulse.
%
% USAGE
%
% NOTES
%  Adapted from shared_pulseNameCallback.m
%
% CHANGES
%  TO081005D: Allow the amplifier to be specified. -- Tim O'Connor 8/10/05
%  TO083105A: Changed the storage of signals from a single file to a directory tree. -- Tim O'Connor 8/31/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO050408B - Assorted small (non-fatal, often ignored) bug fixes. -- Tim O'Connor 5/4/08
%
% Created 8/9/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function shared_pulseNameCallback(hObject, varargin)

[directory, pulseSetName, pulseName, pulseNameArray, ampIndex, channelIndex, externalTrigger, amplifiers, channels, traceLength, pulseSetNameArray, pulseNameArray, sampleRate, pulseParameters, pulseSelectionHasChanged] = getLocalBatch(progmanager, hObject, ...
    'pulseSetDir', 'pulseSetName', 'pulseName', 'pulseNameArray', 'amplifierList', 'channelList', 'externalTrigger', 'amplifiers', 'channels', 'traceLength', 'pulseSetNameArray', 'pulseNameArray', 'sampleRate', 'pulseParameters', 'pulseSelectionHasChanged');%TO090806A

if isempty(directory)
    warndlg('A pulse directory must be selected before new pulses may be accessed.');
    error('No pulse directory selected. Can not load pulse.');
end

if isempty(pulseSetName)
    warndlg('A pulse set must be selected before new pulses may be accessed.');
    error('No pulse set selected. Can not load pulse.');
end

if ~isempty(pulseName)
    filename = fullfile(directory, pulseSetName, [pulseName '.signal']);
    if exist(filename, 'file') ~= 2    
        errordlg(sprintf('Pulse ''%s:%s'' not found - %s', pulseSetName, pulseName, filename));
        error('Pulse ''%s:%s'' not found - %s', pulseSetName, pulseName, filename);
    end
end

if ~isempty(amplifiers)
    pulseNameArray{ampIndex} = pulseName;
    pulseSelectionHasChanged(ampIndex) = 1;%TO101707D
else
    pulseNameArray{channelIndex} = pulseName;
    pulseSelectionHasChanged(channelIndex) = 1;%TO101707D
end

setLocal(progmanager, hObject, 'pulseNameArray', pulseNameArray);
%TO092605I: Automatically enable stimulation when a valid pulse is selected.
if ~isempty(pulseName)
    stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
    if ~isempty(amplifiers)
        stimOnArray(ampIndex) = 1;
    else
        stimOnArray(channelIndex) = 1;
    end
    setLocalBatch(progmanager, hObject, 'stimOn', 1, 'stimOnArray', stimOnArray);
else
    stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
    if ~isempty(amplifiers)
        stimOnArray(ampIndex) = 0;
    else
        stimOnArray(channelIndex) = 0;
    end
    setLocalBatch(progmanager, hObject, 'stimOn', 0, 'stimOnArray', stimOnArray);    
end

setLocal(progmanager, hObject, 'pulseSelectionHasChanged', pulseSelectionHasChanged);

%TO100305A
num = getNumericSuffix(pulseName);
if ~isempty(num)
    setLocal(progmanager, hObject, 'pulseNumber', num2str(num));
else
    setLocal(progmanager, hObject, 'pulseNumber', '');
end

%TO090806A
if externalTrigger
    if ~isempty(amplifiers)
        channelName = getVComChannelName(amplifiers{ampIndex});
        filename = fullfile(directory, pulseSetNameArray{ampIndex}, [pulseNameArray{ampIndex} '.signal']);
    else
        channelName = channels(channelIndex).channelName;
        filename = fullfile(directory, pulseSetNameArray{channelIndex}, [pulseNameArray{channelIndex} '.signal']);
    end
    pm = pulseMap('acquisition');
    try
        sig = getPulse(pm, channelName);
        clearByName(pm, channelName);
        delete(sig);
    catch
        warning('%s - Failed to properly delete previously loaded pulse from channel ''%s'': %s', getProgramName(progmanager, hObject), channelName, getLastErrorStack);
    end
    try
        s = load(filename, '-mat');
        set(s.signal, 'SampleRate', sampleRate, 'deleteChildrenAutomatically', 1);
        setPulse(pm, channelName, s.signal);
    catch
        warning('%s - Failed to properly bind new pulse to channel ''%s'': %s', getProgramName(progmanager, hObject), channelName, getLastErrorStack);
    end
    try
        if isempty(amplifiers)
            pulseParameters{channelIndex} = toStruct(s.signal);%TO050408B
        else
            pulseParameters{ampIndex} = toStruct(s.signal);
        end
        setLocal(progmanager, hObject, 'pulseParameters', pulseParameters);
    catch
        warning('%s - Failed to properly insert pulse parameters for channel ''%s'' into header: %s', getProgramName(progmanager, hObject), channelName, getLastErrorStack);
    end
end

return;

% %TO081005D
% if isempty(varargin)
%     [ampIndex, channelIndex, amplifiers, channels] = getLocalBatch(progmanager, hObject, 'amplifierList', 'channelList', 'amplifiers', 'channels');
%     if isempty(ampIndex)
%         index = channelIndex;
%     else
%         index = ampIndex;
%     end
% else
%     index = varargin{1};
% end
% 
% pulseNameIndex = getLocal(progmanager, hObject, 'pulseName');
% pulseNameMapping = getLocal(progmanager, hObject, 'pulseNameMapping');
% pulseNameString = pulseNameMapping{index};
% pulseNameMapping
% if pulseNameIndex == 1
%     %Hmm, now what? -- Tim O'Connor, 6/23/05
% end
% 
% pulseSetNameArray = getLocal(progmanager, hObject, 'pulseSetNameArray');
% if isempty(pulseSetNameArray{index})
%     error('No pulse set selected, pulse selection is impossible.');
% end
% 
% if ~isempty(pulseNameString)
%     filename = [fullfile(getLocal(progmanager, hObject, 'pulseSetDir'), pulseNameString) '.signal'];
%     pulse = load(filename, '-mat');
%     if ~isempty(amplifiers)
%         setPulse(pulseMap('acquisition'), getScaledOutputChannelName(amplifiers{index}), pulse);
%     else
% 'a'
% channels(index).channelName
% pulse
%         setPulse(pulseMap('acquisition'), channels(index).channelName, pulse);
%     end
% end
% 
% return;
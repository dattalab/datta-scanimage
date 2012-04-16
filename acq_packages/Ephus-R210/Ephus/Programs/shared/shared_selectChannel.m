% shared_selectChannel - Select a specific amplifier/channel in the GUI.
%
% SYNTAX
%  shared_selectChannel(hObject)
%  shared_selectChannel(hObject, index)
%    index - The index of the amplifier/channel to switch to.
%
% USAGE
%
% NOTES
%  Adapted from ephys_selectAmplifier.m See TO101707F.
%
% CHANGES
%  TO071605A: Optimized using `getLocalBatch` and `setLocalBatch`. Saved about 50ms (a 50% reduction). -- Tim O'Connor 7/16/05
%  TO083005A: Altered pulses to be stored in individual files. -- Tim O'Connor 8/30/05
%  TO091405A: Continuation of TO083005A. -- Tim O'Connor 9/14/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO062806Q - Use ephys_pulseCreation and ephys_pulseSetCreation. -- Tim O'Connor 6/28/06
%  TO062906B - ephys_pulseSetCreation will call ephys_pulseCreation, so don't do it redundantly here. -- Tim O'Connor 6/29/06
%  TO090506C - Only enable the Start button if not in external trigger mode. -- Tim O'Connor 9/5/06
%  TO090506D - Made ampIndex optional. -- Tim O'Connor 9/5/06
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO031010G - Update the extraGain on the GUI. -- Tim O'Connor 3/10/10
%
% Created 5/23/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function shared_selectChannel(hObject, varargin)

[amplifiers, channels, stimOnArray, acqOnArray, showStimArray, pulseSetNameArray, pulseSetName, pulseNameArray, pulseName, ampIndex, channelIndex, pulseSetDir, extraGainArray] = ...
    getLocalBatch(progmanager, hObject, 'amplifiers', 'channels', 'stimOnArray', 'acqOnArray', 'showStimArray', 'pulseSetNameArray', 'pulseSetName', ...
    'pulseNameArray', 'pulseName', 'amplifierList', 'channelList', 'pulseSetDir', 'extraGainArray');%TO090506D

%TO090506D
if ~isempty(varargin)
    index = varargin{1};
    if isempty(channelIndex)
        setLocal(progmanager, hObject, 'amplifierList', index);
    else
        setLocal(progmanager, hObject, 'channelList', index);
    end
elseif isempty(ampIndex)
    index = channelIndex;
else
    index = ampIndex;
end

if index >= 1 && (index <= length(amplifiers) || index <= length(channels))
    if ~isempty(acqOnArray)
        acqOn = acqOnArray(index);
    else
        acqOn = [];
    end
    if ~isempty(stimOnArray)
        pulseSetName = pulseSetNameArray{index};
        pulseName = pulseNameArray{index};
        stimOn = stimOnArray(index);
        shared_pulseSetCreation(hObject);%TO062806Q
    else
        pulseSetName = {};
        pulseName = {};
        stimOn = [];
    end
    
    %TO091405A
    setLocalBatch(progmanager, hObject, 'pulseSetName', pulseSetName, 'pulseName', pulseName, ...
        'acqOn', acqOn, 'stimOn', stimOn);
else
    error('Channel/amplifier index out of range: %s', num2str(index));
end

%TO083005A
if isempty(stimOnArray)
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
elseif ~isempty(pulseSetDir)
    if exist(pulseSetDir, 'dir') == 7 && ~getLocal(progmanager, hObject, 'externalTrigger')
        setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
    end
end

if isempty(stimOnArray) && ~isempty(acqOn)
    setLocalGh(progmanager, hObject, 'acqOn', 'Enable', 'On');
elseif ~isempty(pulseNameArray{index}) && ~isempty(acqOn)
    setLocalGh(progmanager, hObject, 'acqOn', 'Enable', 'On');
else
    %??? Why was this else here? What should get done in this case? - TO071605
end

%TO100305A
if ~isempty(stimOnArray)
    num = getNumericSuffix(pulseNameArray{index});
    if ~isempty(num)
        setLocal(progmanager, hObject, 'pulseNumber', num2str(num));
    else
        setLocal(progmanager, hObject, 'pulseNumber', '');
    end
end

%TO031010G
if ~isempty(extraGainArray)
    setLocal(progmanager, hObject, 'extraGain', extraGainArray(index));
end

return;
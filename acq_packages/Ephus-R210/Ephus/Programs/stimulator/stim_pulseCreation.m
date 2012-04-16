% stim_pulseCreation - Callback for updating the selected pulses when changed externally.
%
% SYNTAX
%  stim_pulseCreation(hObject)
%
% USAGE
%
% NOTES
%  Taken from stim.m/pulseSetName_Callback, see TO022406D.
%
% CHANGES
%  TO022706C: The pulseNumber also needs to get updated here. -- Tim O'Connor 2/27/06
%  TO031006E: Make sure pulseNumber is always defined. -- Tim O'Connor 3/10/06
%  TO081606E: Slider functionality changed as of Matlab 7, invalidating most slider code. -- Tim O'Connor 8/16/06
%
% Created 2/24/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function stim_pulseCreation(hObject)

[currentDir pulseName pulseSetName channelIndex pulseNameArray stimOnArray] = ...
    getLocalBatch(progmanager, hObject, 'pulseSetDir', 'pulseName', 'pulseSetName', 'channelList', 'pulseNameArray', 'stimOnArray');

if isempty(currentDir) | exist(currentDir) ~= 7
    stimOnArray(:) = 0;
    pulseNameArray(:) = {''};
    pulseSetNameArray{channelIndex} = pulseSetName;

    setLocalBatch(progmanager, hObject, 'pulseSelectionHasChanged', 1, 'pulseName', '', 'stimOn', 0, 'stimOnArray', stimOnArray, ...
        'pulseNameArray', pulseNameArray);%TO100605C
end

pulseNames = {''};
if ~isempty(pulseSetName)
    signalList = dir(fullfile(currentDir, pulseSetName, '*.signal'));
    for i = 1 : length(signalList)
        if ~signalList(i).isdir
            pulseNames{length(pulseNames) + 1} = signalList(i).name(1 : length(signalList(i).name) - 7);
        end
    end
end

if length(pulseNames) > 1
    setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);
    setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'On');
    %TO100305A %TO022706C
    num = getNumericSuffix(pulseName);
    if ~isempty(num)
        pulseNumber = num2str(num);
    else
        pulseNumber = '';
    end
    setLocalGh(progmanager, hObject, 'pulseNumber', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'pulseNumberSliderUp', 'Enable', 'On');%TO081606E
    setLocalGh(progmanager, hObject, 'pulseNumberSliderDown', 'Enable', 'On');%TO081606E
else
    pulseNumber = '';%TO031006E
    setLocalGh(progmanager, hObject, 'pulseName', 'String', {''});
    setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'Off');
    %TO100305A
    setLocal(progmanager, hObject, 'pulseNumber', '');
    setLocalGh(progmanager, hObject, 'pulseNumber', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'pulseNumberSliderUp', 'Enable', 'Off');%TO081606E
    setLocalGh(progmanager, hObject, 'pulseNumberSliderDown', 'Enable', 'Off');%TO081606E
end

if length(pulseNames) == 1 | ~ismember(pulseName, pulseNames)
    %TO100605C (see TO092605I): Automatically disable stimulation when no valid pulse is selected.
    stimOnArray(channelIndex) = 0;
    pulseNameArray{channelIndex} = '';
    pulseSetNameArray{channelIndex} = pulseSetName;

    setLocalBatch(progmanager, hObject, 'pulseSelectionHasChanged', 1, 'pulseName', '', 'stimOn', 0, 'stimOnArray', stimOnArray, ...
        'pulseNameArray', pulseNameArray, 'pulseNumber', pulseNumber);%TO100605C %TO022706C
end

return;
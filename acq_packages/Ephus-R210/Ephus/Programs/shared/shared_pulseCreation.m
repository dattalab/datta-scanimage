% shared_pulseCreation - Callback for updating the selected pulses when changed externally.
%
% SYNTAX
%  shared_pulseCreation(hObject)
%
% USAGE
%
% NOTES
%  Taken from ephys.m/pulseSetName_Callback, see TO022406D.
%  Adapted from ephys_pulseCreation.m
%
% CHANGES
%  TO022706C: The pulseNumber also needs to get updated here. -- Tim O'Connor 2/27/06
%  TO030106A: Must set the pulseNumber on the other side of the conditional. -- Tim O'Connor 3/1/06
%  TO031006E: Make sure pulseNumber is always defined. -- Tim O'Connor 3/10/06
%  TO081606E: Slider functionality changed as of Matlab 7, invalidating most slider code. -- Tim O'Connor 8/16/06
%  TO101707D: Port to nimex. -- Tim O'Connor 10/17/07
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  VI012608A - Synax correction, replaces TO121707D
%
% Created 2/24/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function shared_pulseCreation(hObject)

[currentDir, pulseName, pulseSetName, pulseSetNameArray, ampIndex, channelIndex, pulseNameArray, stimOnArray, pulseSelectionHasChanged] = ...
    getLocalBatch(progmanager, hObject, 'pulseSetDir', 'pulseName', 'pulseSetName', 'pulseSetNameArray', 'amplifierList', 'channelList', 'pulseNameArray', 'stimOnArray', 'pulseSelectionHasChanged');

if isempty(ampIndex)
    index = channelIndex;
else
    index = ampIndex;
end

if isempty(currentDir) || exist(currentDir, 'dir') ~= 7
    stimOnArray(:) = 0;
    [pulseNameArray{:}] = deal(''); %VI012608A
    pulseSetNameArray{index} = pulseSetName;
    pulseSelectionHasChanged(:) = 1;%TO101707D - This is now an array.
    setLocalBatch(progmanager, hObject, 'pulseSelectionHasChanged', pulseSelectionHasChanged, 'pulseName', '', 'stimOn', 0, 'stimOnArray', stimOnArray, ...
        'pulseNameArray', pulseNameArray, 'pulseSetNameArray', pulseSetNameArray);%TO100605C %TO101707D
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
    setLocalGh(progmanager, hObject, 'pulseName', 'String', {''});
    setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'Off');
    %TO100305A
    pulseNumber = '';%TO031006E%TO030106A
    setLocalGh(progmanager, hObject, 'pulseNumber', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'pulseNumberSliderUp', 'Enable', 'Off');%TO081606E
    setLocalGh(progmanager, hObject, 'pulseNumberSliderDown', 'Enable', 'Off');%TO081606E
end

if length(pulseNames) == 1 || ~ismember(pulseName, pulseNames)
    %TO100605C (see TO092605I): Automatically disable stimulation when no valid pulse is selected.
    stimOnArray(index) = 0;
    pulseNameArray{index} = '';
    pulseSetNameArray{index} = pulseSetName;
    pulseSelectionHasChanged(:) = 1;%TO101707D

    setLocalBatch(progmanager, hObject, 'pulseSelectionHasChanged', pulseSelectionHasChanged, 'pulseName', '', 'stimOn', 0, 'stimOnArray', stimOnArray, ...
        'pulseNameArray', pulseNameArray, 'pulseNumber', pulseNumber, 'pulseSetNameArray', pulseSetNameArray);%TO100605C %TO022706C %TO101707D
end

return;
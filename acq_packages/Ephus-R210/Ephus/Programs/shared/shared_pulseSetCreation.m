% shared_pulseSetCreation - Callback for updating the selected pulses when changed externally.
%
% SYNTAX
%  shared_pulseSetCreation(hObject)
%
% USAGE
%
% NOTES
%  Taken from ephys.m/loadPulseSetItem_Callback, see TO022406D.
%  Adapted from ephys_pulseSetCreation.m see TO101707F
%
% CHANGES
%  TO022706A: Calls to update the pulse name must go back into the gui's file, there's no external function available. -- Tim O'Connor 2/27/06
%  TO022706C: Update all the appropriate pulseName parameters as well. Make sure they're set after `pulseSetName_Callback` is executed. -- Tim O'Connor 2/27/06
%  TO062906A: Only call ephys/pulseSetName_Callback if pulses have been loaded. -- Tim O'Connor 6/29/06
%  TO062906C: Calling `dir` on an empty string acts as if `pwd` was the directory, this is bad news for searching directories, watch out. -- Tim O'Connor 6/29/06
%  TO101707D: Port to nimex. -- Tim O'Connor 10/17/07
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%
% Created 2/24/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function shared_pulseSetCreation(hObject)

[pulseSetDir, pulseSetNameArray, pulseNameArray, pulseTimestamps, ampIndex, channelIndex, stimOnArray, pulseSelectionHasChanged] = getLocalBatch(progmanager, hObject, ...
    'pulseSetDir', 'pulseSetNameArray', 'pulseNameArray', 'pulseTimestamps', 'amplifierList', 'channelList', 'stimOnArray', 'pulseSelectionHasChanged');

if isempty(ampIndex)
    index = channelIndex;
else
    index = ampIndex;
end

pulseSetNames = {''};
%TO062906C
if ~isempty(pulseSetDir)
    contents = dir(pulseSetDir);
    for i = 1 : length(contents)
        if contents(i).isdir && ~(strcmpi(contents(i).name, '.') || strcmpi(contents(i).name, '..'))
            pulseSetNames{length(pulseSetNames) + 1} = contents(i).name;
        end
    end
end

if isempty(pulseSetNames)
    setLocalGh(progmanager, hObject, 'pulseSetName', 'String', {''});
    setLocalGh(progmanager, hObject, 'pulseSetName', 'Enable', 'Off');

    pulseSetNameArray{:} = '';
    pulseNameArray{:} = '';
    pulseTimestamps{:} = '';
    pulseSelectionHasChanged(:) = 1;%TO101707D - This is now an array.
else
    setLocalGh(progmanager, hObject, 'pulseSetName', 'String', pulseSetNames);
    setLocalGh(progmanager, hObject, 'pulseSetName', 'Enable', 'On');

    for i = 1 : length(pulseSetNameArray)
        if ~ismember(pulseSetNameArray{i}, pulseSetNames)
            pulseSetNameArray{i} = '';
            pulseNameArray{i} = '';
            pulseTimestamps{i} = '';
            stimOnArray(i) = 0;%TO022706C
            pulseSelectionHasChanged(i) = 1;%TO101707D - This is now an array.
        end
    end
end

setLocalBatch(progmanager, hObject, 'pulseSetName', pulseSetNameArray{index}, ...
    'pulseSetNameArray', pulseSetNameArray, 'pulseSelectionHasChanged', pulseSelectionHasChanged, 'pulseTimestamps', pulseTimestamps);%TO101707D

%TO062906A
if isempty(pulseSetDir)
    return;
end

if ~isempty(pulseSetNames)
    %TO062906A
    shared_pulseSetNameCallback(hObject);
    %ephys('pulseSetName_Callback', hObject, [], guidata(hObject));%TO022706A
end

setLocalBatch(progmanager, hObject, 'pulseNameArray', pulseNameArray, 'pulseName', pulseNameArray{index}, ...
    'stimOnArray', stimOnArray, 'stimOn', stimOnArray(index));%TO022706C

return;
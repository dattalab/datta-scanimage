% ephys_pulseSetCreation - Callback for updating the selected pulses when changed externally.
%
% SYNTAX
%  ephys_pulseSetCreation(hObject)
%
% USAGE
%
% NOTES
%  Taken from ephys.m/loadPulseSetItem_Callback, see TO022406D.
%
% CHANGES
%  TO022706A: Calls to update the pulse name must go back into the gui's file, there's no external function available. -- Tim O'Connor 2/27/06
%  TO022706C: Update all the appropriate pulseName parameters as well. Make sure they're set after `pulseSetName_Callback` is executed. -- Tim O'Connor 2/27/06
%  TO062906A: Only call ephys/pulseSetName_Callback if pulses have been loaded. -- Tim O'Connor 6/29/06
%  TO062906C: Calling `dir` on an empty string acts as if `pwd` was the directory, this is bad news for searching directories, watch out. -- Tim O'Connor 6/29/06
%
% Created 2/24/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function ephys_pulseSetCreation(hObject)

[pulseSetDir pulseSetNameArray pulseNameArray pulseTimestamps ampIndex stimOnArray] = getLocalBatch(progmanager, hObject, ...
    'pulseSetDir', 'pulseSetNameArray', 'pulseNameArray', 'pulseTimestamps', 'amplifierList', 'stimOnArray');

pulseSetNames = {''};
%TO062906C
if ~isempty(pulseSetDir)
    contents = dir(pulseSetDir);
    for i = 1 : length(contents)
        if contents(i).isdir & ~(strcmpi(contents(i).name, '.') | strcmpi(contents(i).name, '..'))
            pulseSetNames{length(pulseSetNames) + 1} = contents(i).name;
        end
    end
end

if isempty(pulseSetNames)
    setLocalGh(progmanager, hObject, 'pulseSetName', 'String', {''});
    setLocalGh(progmanager, hObject, 'pulseSetName', 'Enable', 'Off');
    
    pulseSetNameArray(:) = {''};
    pulseNameArray(:) = {''};
    pulseTimestamps(:) = {''};
else
    setLocalGh(progmanager, hObject, 'pulseSetName', 'String', pulseSetNames);
    setLocalGh(progmanager, hObject, 'pulseSetName', 'Enable', 'On');
    
    for i = 1 : length(pulseSetNameArray)
        if ~ismember(pulseSetNameArray{i}, pulseSetNames)
            pulseSetNameArray{i} = '';
            pulseNameArray{i} = '';
            pulseTimestamps{i} = '';
            stimOnArray(i) = 0;%TO022706C
        end
    end
end

setLocalBatch(progmanager, hObject, 'pulseSetName', pulseSetNameArray{ampIndex}, ...
    'pulseSetNameArray', pulseSetNameArray, 'pulseSelectionHasChanged', 1, 'pulseTimestamps', pulseTimestamps);

%TO062906A
if isempty(pulseSetDir)
    return;
end

if ~isempty(pulseSetNames)
    %TO062906A
    ephys('pulseSetName_Callback', hObject, [], guidata(hObject));%TO022706A
end

setLocalBatch(progmanager, hObject, 'pulseNameArray', pulseNameArray, 'pulseName', pulseNameArray{ampIndex}, ...
    'stimOnArray', stimOnArray, 'stimOn', stimOnArray(ampIndex));%TO022706C

return;
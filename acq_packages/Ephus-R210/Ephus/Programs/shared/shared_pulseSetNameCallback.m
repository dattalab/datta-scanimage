% shared_pulseSetNameCallback - Callback for updating the selected pulse set name when changed externally.
%
% SYNTAX
%  shared_pulseSetNameCallback(hObject)
%
% USAGE
%
% NOTES
%  Taken from ephys.m/pulseSetName_Callback, see TO101707F
%
% CHANGES
%
% Created 10/17/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function shared_pulseSetNameCallback(hObject)

[currentDir, pulseSetName, ampIndex, channelIndex, pulseSetNameArray, pulseNameArray, stimOnArray, pulseSelectionHasChanged] = ...
    getLocalBatch(progmanager, hObject, 'pulseSetDir', 'pulseSetName', 'amplifierList', 'channelList', 'pulseSetNameArray', 'pulseNameArray', 'stimOnArray', 'pulseSelectionHasChanged');%TO101707D

if isempty(currentDir) || exist(currentDir, 'dir') ~= 7
    warndlg('A pulse directory must be selected before new pulses may be accessed.');
    error('No pulse directory selected. Can not load pulse.');
end

if isempty(ampIndex)
    index = channelIndex;
else
    index = ampIndex;
end

pulseNameArray{index} = '';
pulseSetNameArray{index} = pulseSetName;
setLocalBatch(progmanager, hObject, 'pulseSetNameArray', pulseSetNameArray, 'pulseNameArray', pulseNameArray);

%TO022406D
shared_pulseCreation(hObject);

stimOnArray(index) = 0;
pulseSelectionHasChanged(index) = 1;%TO101707D
setLocalBatch(progmanager, hObject, 'pulseSelectionHasChanged', pulseSelectionHasChanged, 'pulseName', '', 'stimOn', 0, 'stimOnArray', stimOnArray);%TO100605C %TO022406D

return;
% stim_selectChannel - Select a specific channel in the GUI.
%
% SYNTAX
%  stim_selectChannel(hObject)
%  stim_selectChannel(hObject, chanIndex)
%    chanIndex - The index of the channel to switch to.
%
% USAGE
%
% NOTES
%  This is a copy & paste job from ephys_selectAmplifier.m, with some editting where necessary.
%
% CHANGES
%  TO071605A: Optimized using `getLocalBatch` and `setLocalBatch`. Saved about 50ms (a 50% reduction). -- Tim O'Connor 7/16/05
%  TO083005A: Altered pulses to be stored in individual files. -- Tim O'Connor 8/30/05
%  TO091405A: Continuation of TO083005A. -- Tim O'Connor 9/14/05
%  TO062806Q - Use stim_pulseCreation and stim_pulseSetCreation. -- Tim O'Connor 6/28/06
%  TO062906B - stim_pulseSetCreation will call stim_pulseCreation, so don't do it redundantly here. -- Tim O'Connor 6/29/06
%  TO090506C - Only enable the Start button if not in external trigger mode. -- Tim O'Connor 9/5/06
%  TO090506D - Made chanIndex optional. -- Tim O'Connor 9/5/06
%
% Created 11/22/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function stim_selectChannel(hObject, varargin)

[channels, stimOnArray, pulseSetNameArray, pulseSetName, pulseNameArray, pulseName, chanIndex] = ...
    getLocalBatch(progmanager, hObject, 'channels', 'stimOnArray', 'pulseSetNameArray', 'pulseSetName', ...
    'pulseNameArray', 'pulseName', 'channelList');%TO090506D

%TO090506D
if ~isempty(varargin)
    chanIndex = varargin{1};
    setLocal(progmanager, hObject, 'channelList', chanIndex);
end

if chanIndex >= 1 & chanIndex <= length(channels)
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %TO091405A
%     %Optimize this, for now just make it work.
%     [currentDir pulseSetName chanIndex pulseSetNameArray pulseNameArray] = ...
%         getLocalBatch(progmanager, hObject, 'pulseSetDir', 'pulseSetName', 'channelList', 'pulseSetNameArray', 'pulseNameArray');
%     
%     if ~isempty(currentDir) & exist(currentDir) == 7
%         pulseNames = {''};
%         if ~isempty(pulseSetName)
%             signalList = dir(fullfile(currentDir, pulseSetName, '*.signal'));
%             for i = 1 : length(signalList)
%                 if ~signalList(i).isdir
%                     pulseNames{length(pulseNames) + 1} = signalList(i).name(1 : length(signalList(i).name) - 7);
%                 end
%             end
%         end
%         
%         if length(pulseNames) > 1
%             setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);
%             setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'On');
%         else
%             setLocalGh(progmanager, hObject, 'pulseName', 'String', {''});
%             setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'Off');
%         end
%     end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    stim_pulseSetCreation(hObject);%TO062806Q
    %stim_pulseCreation(hObject);%TO062806Q %TO062906B

%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %TO092305A - Temporary cut & paste, this should be broken out into a separate function (along with the same chunk in pulseSetName_Callback). -- Tim O'Connor 9/23/05
%     pulseNames = {''};
%     if ~isempty(pulseSetName)
%         signalList = dir(fullfile(currentDir, pulseSetNameArray{chanIndex}, '*.signal'));
%         for i = 1 : length(signalList)
%             if ~signalList(i).isdir
%                 pulseNames{length(pulseNames) + 1} = signalList(i).name(1 : length(signalList(i).name) - 7);
%             end
%         end
%     end
%     if length(pulseNames) > 1
%         setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);
%         setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'On');
%     else
%         setLocalGh(progmanager, hObject, 'pulseName', 'String', {''});
%         setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'Off');
%     end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %TO091405A
    setLocalBatch(progmanager, hObject, 'pulseSetName', pulseSetNameArray{chanIndex}, 'pulseName', pulseNameArray{chanIndex}, ...
        'stimOn', stimOnArray(chanIndex));
else
    error('chanIndex out of range.');
end

%TO083005A %TO090506C
if exist(getLocal(progmanager, hObject, 'pulseSetDir')) == 7 & ~getLocal(progmanager, hObject, 'externalTrigger')
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
end

%TO100305A
num = getNumericSuffix(pulseNameArray{chanIndex});
if ~isempty(num)
    setLocal(progmanager, hObject, 'pulseNumber', num2str(num));
else
    setLocal(progmanager, hObject, 'pulseNumber', '');
end

return;
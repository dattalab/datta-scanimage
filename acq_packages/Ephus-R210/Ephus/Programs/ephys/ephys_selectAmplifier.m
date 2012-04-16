% ephys_selectAmplifier - Select a specific amplifier in the GUI.
%
% SYNTAX
%  ephys_selectAmplifier(hObject)
%  ephys_selectAmplifier(hObject, ampIndex)
%    ampIndex - The index of the amplifier to switch to.
%
% USAGE
%
% NOTES
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
%
% Created 5/23/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephys_selectAmplifier(hObject, varargin)

% amplifiers = getLocal(progmanager, hObject, 'amplifiers');
[amplifiers, stimOnArray, acqOnArray, showStimArray, pulseSetNameArray, pulseSetName, pulseNameArray, pulseName, ampIndex] = ...
    getLocalBatch(progmanager, hObject, 'amplifiers', 'stimOnArray', 'acqOnArray', 'showStimArray', 'pulseSetNameArray', 'pulseSetName', ...
    'pulseNameArray', 'pulseName', 'amplifierList');%TO090506D

%TO090506D
if ~isempty(varargin)
    ampIndex = varargin{1};
    setLocal(progmanager, hObject, 'amplifierList', ampIndex);
end

if ampIndex >= 1 & ampIndex <= length(amplifiers)
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %TO091405A
%     %Optimize this, for now just make it work.
%     [currentDir pulseSetName ampIndex pulseSetNameArray pulseNameArray] = ...
%         getLocalBatch(progmanager, hObject, 'pulseSetDir', 'pulseSetName', 'amplifierList', 'pulseSetNameArray', 'pulseNameArray');
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
    ephys_pulseSetCreation(hObject);%TO062806Q
    %ephys_pulseCreation(hObject);%TO062806Q %TO062906B

%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %TO092305A - Temporary cut & paste, this should be broken out into a separate function (along with the same chunk in pulseSetName_Callback). -- Tim O'Connor 9/23/05
%     pulseNames = {''};
%     if ~isempty(pulseSetName)
%         signalList = dir(fullfile(currentDir, pulseSetNameArray{ampIndex}, '*.signal'));
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
    setLocalBatch(progmanager, hObject, 'pulseSetName', pulseSetNameArray{ampIndex}, 'pulseName', pulseNameArray{ampIndex}, ...
        'acqOn', acqOnArray(ampIndex), 'stimOn', stimOnArray(ampIndex), 'showStim', showStimArray(ampIndex));
% %     setLocal(progmanager, hObject, 'amplifierList', ampIndex);
% % 
% %     stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
% %     setLocal(progmanager, hObject, 'stimOn', stimOnArray(ampIndex));
% % 
% %     acqOnArray = getLocal(progmanager, hObject, 'acqOnArray');
% %     setLocal(progmanager, hObject, 'acqOn', acqOnArray(ampIndex));
% % 
% %     showStim = getLocal(progmanager, hObject, 'showStim');
% %     setLocal(progmanager, hObject, 'showStim', showStim(ampIndex));
% %     
% %    pulseSetNameArray = getLocal(progmanager, hObject, 'pulseSetNameArray');
% %    pulseSetList = getLocalGh(progmanager, hObject, 'pulseSetName', 'String');
%    pulseSetIndex = find(strcmp(pulseSetNameArray{ampIndex}, pulseSetList));
%    if isempty(pulseSetIndex)
% %        setLocal(progmanager, hObject, 'pulseSetName', 1);
%        pulseSetName = 1;
%    elseif length(pulseSetIndex) > 1
%        warning('Indeterminate pulse set name detected.');
% %        setLocal(progmanager, hObject, 'pulseSetName', pulseSetIndex(1));
%        pulseSetName = pulseSetIndex(1);
%    else
% %        setLocal(progmanager, hObject, 'pulseSetName', pulseSetIndex);
%        pulseSetName = pulseSetIndex;
%    end
%    
% %    pulseNameArray = getLocal(progmanager, hObject, 'pulseNameArray');
% %    pulseNameList = getLocalGh(progmanager, hObject, 'pulseName', 'String');
%    pulseNameIndex = find(strcmp(pulseNameArray{ampIndex}, pulseNameList));
%    if isempty(pulseNameIndex)
%        setLocal(progmanager, hObject, 'pulseName', 1);
%    elseif length(pulseNameIndex) > 1
%        warning('Indeterminate pulse name detected.');
%        setLocal(progmanager, hObject, 'pulseName', pulseNameIndex(1));
%    else
%        setLocal(progmanager, hObject, 'pulseName', pulseNameIndex);
%    end
% 
%     setLocalBatch(progmanager, hObject, 'amplifierList', ampIndex, 'stimOn', stimOnArray(ampIndex), 'acqOn', acqOnArray(ampIndex), ...
%         'showStim', showStimArray(ampIndex), 'pulseSetName', pulseSetName);
% % [amplifiers, stimOnArray, acqOnArray, showStim, pulseSetNameArray, pulseSetList, pulseSetIndex, pulseNameArray, pulseNameList, pulseNameIndex] = ...
% %     getLocalBatch(progmanager, hObject, 'amplifiers', 'stimOnArray', 'acqOnArray', 'showStim', 'pulseSetNameArray', 'pulseSetList', 'pulseSetIndex', ...
% %     'pulseNameArray', 'pulseNameList', 'pulseNameIndex');
else
    error('ampIndex out of range.');
end

%TO083005A
if exist(getLocal(progmanager, hObject, 'pulseSetDir')) == 7 & ~getLocal(progmanager, hObject, 'externalTrigger')
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
end

if ~isempty(pulseNameArray{ampIndex})
    setLocalGh(progmanager, hObject, 'acqOn', 'Enable', 'On');
else
    %??? Why was this else here? What should get done in this case? - TO071605
end

%TO100305A
num = getNumericSuffix(pulseNameArray{ampIndex});
if ~isempty(num)
    setLocal(progmanager, hObject, 'pulseNumber', num2str(num));
else
    setLocal(progmanager, hObject, 'pulseNumber', '');
end

return;
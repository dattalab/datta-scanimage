% shared_configurationUpdate - Make sure the variables jive with the current configuration, assume channels may have been added/removed.
%
% SYNTAX
%  shared_selectChannel(hObject)
%
% USAGE
%
% NOTES
%  See TO121307E.
%
% CHANGES
%  TO021610J - Fixed a copy & paste error (referencing channels, when it should've been amplifiers). -- Tim O'Connor 2/16/10
%  TO022210B - Fixed conditions for updating pulseSetName/pulseName arrays and fixed references to `amplifiers` in the `channels` section. -- Tim O'Connor 2/22/10
%  TO030210I - Fixed the case where it wants a pulseSetName/pulseName for the scopeGui/ephysScopeAccessory. -- Tim O'Connor 3/2/10
%
% Created 12/13/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function shared_configurationUpdate(hObject, varargin)

[amplifiers, channels, stimOnArray, acqOnArray, pulseSetNameArray, pulseNameArray, ampIndex, channelIndex, extraGainArray] = ...
    getLocalBatch(progmanager, hObject, 'amplifiers', 'channels', 'stimOnArray', 'acqOnArray', 'pulseSetNameArray', 'pulseNameArray', 'amplifierList', 'channelList', 'extraGainArray');%TO090506D

try
    showStimArray = getLocal(progmanager, hObject, 'showStimArray');
catch
    showStimArray = [];
end

%Check against amplifiers...
if ~isempty(amplifiers)
    if length(acqOnArray) ~= length(amplifiers)
        fprintf(2, 'Warning: Number of amplifiers does not match acqOn configuration for ''%s''.\n Updating current variables. Your configuration likely needs to be saved to match the current hardware setup.\n', getProgramName(progmanager, hObject));
        if length(acqOnArray) > length(amplifiers)
            acqOnArray = acqOnArray(1:length(amplifiers));
        else
            acqOnArray(length(acqOnArray)+1 : length(amplifiers)) = 0;
        end
    end
    %TO030210I
    if (length(stimOnArray) ~= length(amplifiers) || length(pulseSetNameArray) ~= length(amplifiers) || length(pulseNameArray) ~= length(amplifiers)) && ~strcmpi(getProgramName(progmanager, hObject), 'scopeGui')
        fprintf(2, 'Warning: Number of amplifiers does not match configuration for ''%s''.\n Updating current variables. Your configuration likely needs to be saved to match the current hardware setup.\n', getProgramName(progmanager, hObject));
        if length(stimOnArray) > length(amplifiers)
            stimOnArray = stimOnArray(1:length(amplifiers));
            if ~isempty(pulseSetNameArray)
                pulseSetNameArray = pulseSetNameArray(1:length(amplifiers));
            else
                pulseSetNameArray = {};
            end
            if ~isempty(pulseNameArray)
                pulseNameArray = pulseNameArray(1:length(amplifiers));
            else
                pulseNameArray = {};
            end
        else
            stimOnArray(end+1 : length(amplifiers)) = 0;
            if ~isempty(pulseSetNameArray)
                for i = length(pulseSetNameArray)+1 : length(amplifiers)
                    pulseSetNameArray{i}  = '';
                end
            else
                pulseSetNameArray = {};
            end
            if ~isempty(pulseNameArray)
                for i = length(pulseNameArray)+1 : length(amplifiers)
                    pulseNameArray{i}  = '';
                end
            else
                pulseNameArray = {};
            end
        end
    end
    if length(showStimArray) ~= length(amplifiers)
        %showStim is neither saved nor loaded and is not settable, so this warning is unnecessary. It's vestigial, but not completely purged from the code (yet), so make sure it doesn't cause problems.
        %fprintf(2, 'Warning: Number of amplifiers does not match showStim configuration for ''%s''.\n Updating current variables. Your configuration likely needs to be saved to match the current hardware setup.\n', getProgramName(progmanager, hObject));
        if length(showStimArray) > length(amplifiers)
            showStimArray = showStimArray(1:length(amplifiers));
        else
            if ~isempty(showStimArray)
                showStimArray(end+1 : length(amplifiers)) = 0;
            else
                showStimArray = [];
            end
        end
    end
    if ~isempty(extraGainArray)
         %TO021610J
        if length(extraGainArray) ~= length(amplifiers)
            fprintf(2, 'Warning: Number of amplifiers does not match extraGain configuration for ''%s''.\n Updating current variables. Your configuration likely needs to be saved to match the current hardware setup.\n', getProgramName(progmanager, hObject));
            if length(extraGainArray) > length(length(amplifiers))
                extraGainArray = extraGainArray(1:length(length(amplifiers)));
            else
                extraGainArray(end+1 : length(length(amplifiers))) = 0;
            end
        end
    end
end

%Check against channels...
if ~isempty(channels)
    if ~isempty(acqOnArray)
        if length(acqOnArray) ~= length(channels)
            fprintf(2, 'Warning: Number of channels does not match acqOn configuration for ''%s''.\n Updating current variables. Your configuration likely needs to be saved to match the current hardware setup.\n', getProgramName(progmanager, hObject));
            if length(acqOnArray) > length(channels)
                acqOnArray = acqOnArray(1:length(channels));
            else
                acqOnArray(end+1 : length(channels)) = 0;
            end
        end
    end
    if ~isempty(stimOnArray)
        if length(stimOnArray) ~= length(channels) || length(pulseSetNameArray) ~= length(channels) || length(pulseNameArray) ~= length(channels)
            fprintf(2, 'Warning: Number of channels does not match configuration for ''%s''.\n Updating current variables. Your configuration likely needs to be saved to match the current hardware setup.\n', getProgramName(progmanager, hObject));
            if length(stimOnArray) > length(channels)
                stimOnArray = stimOnArray(1:length(channels));
                if ~isempty(pulseSetNameArray)
                    pulseSetNameArray = pulseSetNameArray(1:length(channels));
                else
                    pulseSetNameArray = {};
                end
                if ~isempty(pulseNameArray)
                    pulseNameArray = pulseNameArray(1:length(channels));
                else
                    pulseNameArray = {};
                end
            else
                stimOnArray(end+1 : length(channels)) = 0;
                if ~isempty(pulseSetNameArray)
                    for i = length(pulseSetNameArray)+1 : length(channels)
                        pulseSetNameArray{i}  = '';
                    end
                else
                    pulseSetNameArray = {};
                end
                if ~isempty(pulseNameArray)
                    for i = length(pulseNameArray)+1 : length(channels)
                        pulseNameArray{i}  = '';
                    end
                else
                    pulseNameArray = {};
                end
            end
        end
    end
    if length(showStimArray) ~= length(channels)
        %showStim is neither saved nor loaded and is not settable, so this warning is unnecessary. It's vestigial, but not completely purged from the code (yet), so make sure it doesn't cause problems.
        %fprintf(2, 'Warning: Number of channels does not match showStim configuration for ''%s''.\n Updating current variables. Your configuration likely needs to be saved to match the current hardware setup.\n', getProgramName(progmanager, hObject));
        if length(showStimArray) > length(channels)
            showStimArray = showStimArray(1:length(channels));
        else
            if ~isempty(showStimArray)
                showStimArray(end+1 : length(channels)) = 0;
            else
                showStimArray = [];
            end
        end
    end
    if ~isempty(extraGainArray)
        if length(extraGainArray) ~= length(channels)
            fprintf(2, 'Warning: Number of channels does not match extraGain configuration for ''%s''.\n Updating current variables. Your configuration likely needs to be saved to match the current hardware setup.\n', getProgramName(progmanager, hObject));
            if length(extraGainArray) > length(channels)
                extraGainArray = extraGainArray(1:length(channels));
            else
                extraGainArray(end+1 : length(channels)) = 0;
            end
        end
    end
end
ampIndex = 1;
channelIndex = 1;

setLocalBatch(progmanager, hObject, 'stimOnArray', stimOnArray, 'acqOnArray', acqOnArray, 'pulseSetNameArray', pulseSetNameArray, ...
    'pulseNameArray', pulseNameArray, 'showStimArray', showStimArray, 'ampIndex', ampIndex, 'channelIndex', channelIndex, 'extraGainArray', extraGainArray);
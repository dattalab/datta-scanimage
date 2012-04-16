% mapper_makeDeltaTCycle - Creates a cycle that stimulates a set of positions, with individual inter-point timing at each pixel.
%
% SYNTAX
%  mapper_makeDeltaTCycle(xCoords, yCoords, powers, widths, lags, T0, preDelay, postDelay)
%  mapper_makeDeltaTCycle(xCoords, yCoords, powers, widths, lags, T0, preDelay, postDelay, pulseDest)
%  mapper_makeDeltaTCycle(xCoords, yCoords, powers, widths, lags, T0, preDelay, postDelay, pulseDest, cycleName)
%   xCoords - An array indicating the x coordinates for each point.
%             The first xCoord value is taken to be the "reference" point, which is invariant in time (at T0).
%   yCoords - An array indicating the y coordinates for each point.
%             The first yCoord value is taken to be the "reference" point, which is invariant in time (at T0).
%             Must have the same length as yCoords.
%   powers - The optical power for each point.
%            May be a vector of the same length as xCoords, or a scalar.
%   widths - The width for the shutter/modulator pulse, in seconds.
%           The shutter is forced to be 2ms longer.
%           May be a vector, of the same length as xCoords, or a scalar.
%           In cases where (lag - width) is less than 4ms, the shutter is held open.
%   lags - The inter-point timing, in seconds.
%          Should be a vector.
%          One cycle position will be generated for each lag value.
%   T0 - The temporal reference point, in seconds.
%        The invariant time for the occurence of the first position (the time of xCoords(1)), in seconds.
%   preDelay - The minmum delay time before any stimulation, in seconds.
%   postDelay - The trailing time, to be recorded, after all stimulations are completed, in seconds.
%   pulseDest - The directory (the pulse set, within the pulse directory) in which to place pulses.
%               The user will be prompted if this is not specified.
%               Ex: 'C:\Data\User1\pulses\MapSubsetCyclePulses'
%   cycleName - The name of the cycle to be created.
%               The user will be prompted if this is not specified.
%
% NOTES
%  Created by modifying mapper_makeMapSubsetCycle.
%  GS note -- this lives in the following directory: svobodalab\Programs\mapping\
%
% EXAMPLE
%  %laser amplitude of 100%, pulse width of 0.5ms, T0 of 100ms, preDelay of 100ms, postDelay of 0.5s
%  mapper_makeDeltaTCycle(xCoords, yCoords, 100, 0.0005, lags, 0.100, 0.1, 0.5)
%
% CHANGES
%  GS20091109 - fixed shutter bug, for short negative lags - Gordon Shepherd 11/9/09
%
% Created: Timothy O'Connor 10/16/09
% Copyright: Northwestern University/Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2009
function mapper_makeDeltaTCycle(xCoords, yCoords, amplitudes, widths, lags, T0, preDelay, postDelay, varargin)

if length(xCoords) ~= length(yCoords)
    error('The number of xCoords and yCoords must match.');
end

mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
sampleRate = getLocalBatch(progmanager, mapperObj, 'sampleRate');

if length(varargin) < 1
    destDir = getDefaultCacheDirectory(progmanager, 'deltaTPulses');
    if strcmpi(destDir, pwd)
        destDir = getDefaultCacheDirectory(progmanager, 'pulseDir');
    end
    destDir = uigetdir(destDir, 'Choose a pulseSet for the destination of new pulses.');
    if length(destDir) == 1
        if destDir == 0
            return;
        end
    end
else
    destDir = varargin{1};
    if exist(destDir, 'dir') ~= 7
        error('pulseDest must be a valid directory: ''%s'' does not exist.', destDir);
    end
end
setDefaultCacheValue(progmanager, 'deltaTPulses', destDir);
[pulseDir, pulseSetName] = fileparts(destDir);

if length(amplitudes) == 1
    amplitudes = ones(size(xCoords)) * amplitudes;
end
if length(amplitudes) ~= length(xCoords)
    error('The amplitudes value must be scalar or the same size as xCoords.');
end
if length(widths) == 1
    widths = ones(size(xCoords)) * widths;
end
if length(widths) ~= length(xCoords)
    error('The widths value must be scalar or the same size as xCoords.');
end

%Create pulses.
fprintf(1, 'Creating pulses in ''%s''...\n', destDir);
xSig = signalobject('Name', 'xMirrorDeltaTCycle', 'repeatable', 0, 'sampleRate', sampleRate);
ySig = signalobject('Name', 'yMirrorDeltaTCycle', 'repeatable', 0, 'sampleRate', sampleRate);
ephysSig = signalobject('Name', 'ephysDeltaTCycle', 'repeatable', 1, 'sampleRate', sampleRate);
modulatorSig = signalobject('Name', 'modulatorDeltaTCycle', 'repeatable', 0, 'sampleRate', sampleRate);
shutterSig = signalobject('Name', 'shutterDeltaTCycle', 'repeatable', 1, 'sampleRate', sampleRate);

%Configure the pulse parameters.
for i = 1 : length(lags)
    if abs(lags(i)) < max(widths)
        fprintf(2, 'lags(%s) = %s < pulse width, being forced to %s to allow for mirror settling.\n', num2str(i), num2str(lags(i)), num2str(max(widths)));
        if lags(i) == 0
            lags(i) = max(widths) + 0.0005;
        else
            lags(i) = max(widths) + 0.0005 * lags(i) / abs(lags(i));
        end
    end
    if (abs(lags(i)) < 0.0005)
        fprintf(2, 'lags(%s) = %s < 0.0005, being forced to %s to allow for mirror settling.\n', num2str(i), num2str(lags(i)));
        if lags(i) == 0
            lags(i) = 0.0005;
        else
            lags(i) = 0.0005 * lags(i) / abs(lags(i));
        end
    end

    set(xSig, 'Name', ['xMirrorDeltaTCycle' num2str(i)]);
    set(ySig, 'Name', ['yMirrorDeltaTCycle' num2str(i)]);
    set(ephysSig, 'Name', ['ephysDeltaTCycle' num2str(i)]);
    set(modulatorSig, 'Name', ['modulatorDeltaTCycle' num2str(i)]);
    set(shutterSig, 'Name', ['shutterDeltaTCycle' num2str(i)]);

    onsetTimes = preDelay + T0 + (0 : length(xCoords) - 1) * lags(i);
    if (lags(i) < 0)
        onsetTimes = onsetTimes(end:-1:1);
    end

    %Mirror pulses.
    if (lags(i) >= 0)
        stepTimes = [0, onsetTimes(1:end-1) + widths(1:end-1)];
        stepFcn(xSig, xCoords, 0, stepTimes);
        stepFcn(ySig, yCoords, 0, stepTimes);
    else
        stepTimes = [0, onsetTimes(1:end-1) + widths(end-1:-1:1)];
        stepFcn(xSig, xCoords(end : -1 : 1), 0, stepTimes);
        stepFcn(ySig, yCoords(end : -1 : 1), 0, stepTimes);
    end
    
    %Parameterize the ephys pulse, as necessary.
    dc(ephysSig, 0);

    %Parameterize the pockels cell pulse (or maybe some other modulator nowadays). This is where the magic happens.
    %The amplitude is represented by one signal object.
    if lags(i) >= 0
        stepFcn(modulatorSig, amplitudes, 0, onsetTimes, widths, lags(i));
    else
        stepFcn(modulatorSig, fliplr(amplitudes), 0, onsetTimes, widths(end : -1 : 1), abs(lags(i)));
    end
    
    %Parameterize the shutter pulse, as necessary.
    if any(abs(lags(i)) - widths < 0.004)
        if lags(i) < 0
%             stepFcn(shutterSig, 5000, 0, T0 + preDelay - length(xCoords) * abs(lags(i)) - 0.002, ...
%                 length(xCoords) * abs(lags(i)), abs(lags(i)));
            stepFcn(shutterSig, 5000, 0, T0 + preDelay - (length(xCoords)-1) * abs(lags(i)) - 0.002, ...
                length(xCoords) * abs(lags(i)) + widths(1), abs(lags(i))); % GS20091109 - fixed bug
        else
            stepFcn(shutterSig, 5000, 0, T0 + preDelay - 0.002, length(xCoords) * abs(lags(i)) + widths(end), abs(lags(i))); % GS20091109 - fixed bug
        end
    else
        if lags(i) < 0
            stepFcn(shutterSig, 5000, 0, onsetTimes - 0.002, widths + 0.002, abs(lags(i)));
        else
            stepFcn(shutterSig, 5000, 0, onsetTimes - 0.002, widths(end : -1 : 1) + 0.002, lags(i));
        end
    end
    
    %Now save the pulses. Delete them when we're done.
    for signal = [xSig, ySig, ephysSig, shutterSig, modulatorSig]
        fprintf(1, '   Writing pulse to disk - ''%s''...\n', get(signal, 'Name'));
        saveCompatible(fullfile(destDir, [get(signal, 'Name') '.signal']), 'signal', '-mat');
    end
end

for signal = [xSig, ySig, ephysSig, shutterSig, modulatorSig]
    delete(signal);
end

%Update the pulseJacker.
%Get the handle for the pulseJacker program.
pj = getGlobal(progmanager, 'hObject', 'pulseJacker', 'pulseJacker');
%Create a new cycle.
if length(varargin) < 2
    if ~pj_new(pj)
        %The pj_new command was cancelled or failed. Don't go overwriting an existing cycle if someone cancelled.
        return;
    end
else
    if ~pj_new(pj, varargin{2})
        %The pj_new command was cancelled or failed. Don't go overwriting an existing cycle if someone cancelled.
        return;
    end
end
%Make sure the pulse path matches where we just made new pulses.
pj_setPulsePath(pj, pulseDir);
fprintf(1, 'Creating associated cycle ''%s''...\n', getLocal(progmanager, pj, 'cycleName'));
%Get the list of channels that are in the pulseJacker.
channels = getLocalGh(progmanager, pj, 'currentChannel', 'String');
%Populate the cycle.
for i = 1 : length(lags)
    fprintf(1, '   Creating cycle position %s...\n', num2str(i));
    %Create a new cycle position.
    pj_newPosition(pj);
    for j = 1 : length(channels)
        fprintf(1, '      Configuring pulse for channel ''%s''...\n', channels{j});
        %Select the channel we want to edit.
        pj_currentChannel(pj, channels{j});
        %Set the pulseSet for this channel.
        pj_setPulseSetName(pj, pulseSetName);
        %Depending on which channel we currently have selected, choose the appropriate pulse.
        if startsWithIgnoreCase(channels{j}, 'ephys:')
            pj_setPulseName(pj, ['ephysDeltaTCycle', num2str(i)]);
        elseif endsWithIgnoreCase(channels{j}, ':xMirror')
            pj_setPulseName(pj, ['xMirrorDeltaTCycle', num2str(i)]);
        elseif endsWithIgnoreCase(channels{j}, ':yMirror')
            pj_setPulseName(pj, ['yMirrorDeltaTCycle', num2str(i)]);
        elseif endsWithIgnoreCase(channels{j}, ':shutter0')
            pj_setPulseName(pj, ['shutterDeltaTCycle', num2str(i)]);
        elseif endsWithIgnoreCase(channels{j}, ':pockelsCell')
            pj_setPulseName(pj, ['modulatorDeltaTCycle', num2str(i)]);
        end
    end
    pj_currentPosition(pj, 1);%Set the new cycle to the first position.
    pj_currentChannel(pj, channels{1});%Set the new cycle to the first channel.
end

traceLength = preDelay + max(lags) * length(xCoords) + postDelay;
% if isprogram(progmanager, 'ephys')
%     ep = getGlobal(progmanager, 'hObject', 'ephys', 'ephys');
%     setLocalBatch(progmanager, ep, 'traceLength', traceLength, 'selfTrigger', 0, 'externalTrigger', 1);
%     if ~getLocal(progmanager, ep, 'startButton')
%         ephys('externalTrigger_Callback', ep, [], ep);
%     end
% end
% if isprogram(progmanager, 'stimulator')
%     stim = getGlobal(progmanager, 'hObject', 'stimulator', 'stimulator');
%     setLocalBatch(progmanager, stim, 'traceLength', traceLength, 'selfTrigger', 0, 'externalTrigger', 1);
%     if ~getLocal(progmanager, stim, 'startButton')
%         stimulator('externalTrigger_Callback', stim, [], stim);
%     end
% end
% if isprogram(progmanager, 'acquirer')
%     acq = getGlobal(progmanager, 'hObject', 'acquirer', 'acquirer');
%     setLocalBatch(progmanager, acq, 'traceLength', traceLength, 'selfTrigger', 0, 'externalTrigger', 1);
%     if ~getLocal(progmanager, acq, 'startButton')
%         acquirer('externalTrigger_Callback', acq, [], acq);
%     end
% end
% 
% setLocalBatch(progmanager, pj, 'enable', 1);
% pulseJacker('enable_Callback', pj, [], pj);

lm = loopManager;
if get(lm, 'preciseTimeMode')
    set(lm, 'interval', traceLength, 'iterations', length(lags));
else
    set(lm, 'interval', traceLength + 0.2, 'iterations', length(lags));
end
% xsg_setSetID('TLAG');

fprintf(1, 'Storing mapper headers in deltaT userdata header...\n');
mapperHeader = getHeaders(progmanager, mapperObj);
setUserDataHeaderValue(progmanager, 'deltaT', 'mapper', mapperHeader.mapper.mapper);
header.xCoords = xCoords;
header.yCoords = yCoords;
header.amplitudes = amplitudes;
header.widths = widths;
header.lags = lags;
header.T0 = T0;
header.preDelay = preDelay;
header.postDelay = postDelay;
setUserDataHeaderValue(progmanager, 'deltaT', 'parameters', header);

fprintf(1, 'New cycle and pulses complete. Cycle is ready to be executed.\n\n');

return;
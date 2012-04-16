% mapper_vividMap - Creates a set of pulses to execute a high speed map as a single trace, also configures the programs to be ready to run the trace.
%
% SYNTAX
%  mapper_vividMap(powers, ISI, preDelay)
%  mapper_vividMap(powers, ISI, preDelay, pulseDest)
%   powers - The optical power, in percent of total, for each point.
%            May be a vector or a scalar.
%   ISI - The time between stimulations.
%         The shutter opens 1ms after the mirrors have moved, and remains open for 3ms.
%         The Pockels cell is opened 2ms after the shutter, and remains open for 1ms.
%         May be a vector or a scalar.
%   preDelay - The minmum delay time before any stimulation, in seconds.
%   pulseDest - The directory (the pulse set, within the pulse directory) in which to place pulses.
%               The user will be prompted if this is not specified.
%               Ex: 'C:\Data\User1\pulses\MapSubsetCyclePulses'
%
% NOTES
%  Created by modifying mapper_makeDeltaTCycle.
%
% EXAMPLE
%
% CHANGES
% Patrick Sheets & Timothy O'Connor 6/11/10
% Copyright: Northwestern University/Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2009
function mapper_vividMap(powers, isi, preDelay, varargin)

mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
sampleRate = getLocalBatch(progmanager, mapperObj, 'sampleRate');

if length(varargin) < 1
    destDir = getDefaultCacheDirectory(progmanager, 'vividMapPulses');
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
setDefaultCacheValue(progmanager, 'vividMapPulses', destDir);
[pulseDir, pulseSetName] = fileparts(destDir);
[xCoords, yCoords] = mapper_getMapCoordinates(getGlobal(progmanager, 'hObject', 'mapper', 'mapper'));

if length(powers) == 1
    powers = ones(size(xCoords)) * powers;
end
if length(powers) ~= length(xCoords)
    error('The amplitudes value must be scalar or the same size as the number of pixels.');
end
if length(isi) == 1
    widths = ones(size(xCoords)) * isi;
end
if length(widths) ~= length(xCoords)
    error('The widths value must be scalar or the same size as the number of pixels.');
end

%Configure the pulse parameters.
for i = 1 : length(isi)
    if (abs(isi(i)) < 0.0005)
        fprintf(2, 'isi(%s) = %s < 0.0005, being forced to %s to allow for mirror settling.\n', num2str(i), num2str(isi(i)));
        if isi(i) == 0
            isi(i) = 0.0005;
        else
            isi(i) = 0.0005 * isi(i) / abs(isi(i));
        end
    end
end

%Create pulses.
fprintf(1, 'Creating pulses in ''%s''...\n', destDir);
xSig = signalobject('Name', 'xMirrorVividMap', 'repeatable', 0, 'sampleRate', sampleRate);
ySig = signalobject('Name', 'yMirrorVividMap', 'repeatable', 0, 'sampleRate', sampleRate);
ephysSig = signalobject('Name', 'ephysVividMap', 'repeatable', 1, 'sampleRate', sampleRate);
modulatorSig = signalobject('Name', 'modulatorVividMap', 'repeatable', 0, 'sampleRate', sampleRate);
shutterSig = signalobject('Name', 'shutterVividMap', 'repeatable', 1, 'sampleRate', sampleRate);

%Mirror pulses.
stepTimes = preDelay + (0 : length(xCoords) - 1) * isi;
stepFcn(xSig, xCoords, 0, stepTimes);
% plot(xSig, preDelay + max(isi) * length(xCoords) + 0.5 * isi), title('XMirror')
stepFcn(ySig, yCoords, 0, stepTimes);
% plot(ySig, preDelay + max(isi) * length(xCoords) + 0.5 * isi), title('YMirror')

%Parameterize the ephys pulse, as necessary.
dc(ephysSig, 0);

%Power control (Pockels cell and shutter) pulses.
stepFcn(modulatorSig, powers, 0, stepTimes + 0.003, 0.001);
% plot(modulatorSig, preDelay + max(isi) * length(xCoords) + 0.5 * isi), title('Pockels Cell')
stepFcn(shutterSig, 5000, 0, stepTimes + 0.001, 0.003);
% plot(shutterSig, preDelay + max(isi) * length(xCoords) + 0.5 * isi), title('Shutter')

%Now save the pulses.
for signal = [xSig, ySig, ephysSig, shutterSig, modulatorSig]
    fprintf(1, '   Writing pulse to disk - ''%s''...\n', get(signal, 'Name'));
    saveCompatible(fullfile(destDir, [get(signal, 'Name') '.signal']), 'signal', '-mat');
end

%Configure the programs to run with the new pulses and the associated traceLength.
traceLength = preDelay + max(isi) * length(xCoords);
if isprogram(progmanager, 'ephys')
    ep = getGlobal(progmanager, 'hObject', 'ephys', 'ephys');
    ephys_pulseSetCreation(ep);%Tell ephys that new pulses are available.
    setLocalBatch(progmanager, ep, 'traceLength', traceLength, 'selfTrigger', 0, 'externalTrigger', 1);%Configure ephys traceLength and trigger mode.
    %Configure ephys pulseSetName and pulseName.
    [amps, currentAmplifier] = getLocalBatch(progmanager, ep, 'amplifiers', 'amplifierList');
    for i = 1 : length(amps)
        setLocalBatch(progmanager, ep, 'amplifierList',i);
        ephys('amplifierList_Callback', ep, [], ep);%Select the amplifier.
        setLocal(progmanager, ep, 'pulseSetName', pulseSetName);
        ephys('pulseSetName_Callback', ep, [], ep);%Select the pulseSetName.
        setLocal(progmanager, ep, 'pulseName', get(ephysSig, 'Name'));
        ephys('pulseName_Callback', ep, [], ep);%Select the pulseName.
    end
    setLocal(progmanager, ep, 'amplifierList', currentAmplifier);%Put it back where we found it.
    ephys('amplifierList_Callback', ep, [], ep);%Select the amplifier.
    if ~getLocal(progmanager, ep, 'startButton')
        ephys('externalTrigger_Callback', ep, [], ep);%Click the externalTrigger button.
    end
end

if isprogram(progmanager, 'stimulator')
    stim = getGlobal(progmanager, 'hObject', 'stimulator', 'stimulator');
    setLocalBatch(progmanager, stim, 'traceLength', traceLength, 'selfTrigger', 0, 'externalTrigger', 1);%Configure ephys traceLength and trigger mode.
    stim_pulseSetCreation(stim);%Tell stimulator that new pulses are available.
    %Configure stimulator pulseSetName and pulseName.
    [channels, currentChannel] = getLocalBatch(progmanager, stim, 'channels', 'channelList');
    for i = 1 : length(channels)
        setLocal(progmanager, stim, 'channelList', i);
        stimulator('channelList_Callback', stim, [], stim);%Select the channel.
        setLocal(progmanager, stim, 'pulseSetName', pulseSetName);
        stimulator('pulseSetName_Callback', stim, [], stim);%Select the pulseSetName.
        switch lower(channels(i).channelName)
            case 'pockelscell'
                setLocal(progmanager, stim, 'pulseName', get(modulatorSig, 'Name'));
                stimulator('pulseName_Callback', stim, [], stim);%Select the pulseName.
            case 'shutter0'
                setLocal(progmanager, stim, 'pulseName', get(shutterSig, 'Name'));
                stimulator('pulseName_Callback', stim, [], stim);%Select the pulseName.
            case 'xmirror'
                setLocal(progmanager, stim, 'pulseName', get(xSig, 'Name'));
                stimulator('pulseName_Callback', stim, [], stim);%Select the pulseName.
            case 'ymirror'
                setLocal(progmanager, stim, 'pulseName', get(ySig, 'Name'));
                stimulator('pulseName_Callback', stim, [], stim);%Select the pulseName.
        end
    end
    setLocal(progmanager, stim, 'channelList', currentChannel);%Put it back where we found it.
    stimulator('channelList_Callback', stim, [], stim);%Select the channel.
    if ~getLocal(progmanager, stim, 'startButton')
        stimulator('externalTrigger_Callback', stim, [], stim);%Click the externalTrigger button.
    end
end
if isprogram(progmanager, 'acquirer')
    acq = getGlobal(progmanager, 'hObject', 'acquirer', 'acquirer');
    setLocalBatch(progmanager, acq, 'traceLength', traceLength, 'selfTrigger', 1, 'externalTrigger', 0);%Configure ephys traceLength and trigger mode.
    %Leave the acquirer ready so the user can click start when they are ready.
    %if ~getLocal(progmanager, acq, 'startButton')
    %    acquirer('externalTrigger_Callback', acq, [], acq);
    %end
end

%Delete them when we're done.
for signal = [xSig, ySig, ephysSig, shutterSig, modulatorSig]
    delete(signal);
end

fprintf(1, 'Storing mapper headers in vividMap userdata header...\n');
mapperHeader = getHeaders(progmanager, mapperObj);
setUserDataHeaderValue(progmanager, 'vividMap', 'mapper', mapperHeader.mapper.mapper);
header.xCoords = xCoords;
header.yCoords = yCoords;
header.powers = powers;
header.widths = widths;
header.preDelay = preDelay;
setUserDataHeaderValue(progmanager, 'vividMap', 'parameters', header);

fprintf(1, 'New pulses complete. Acquisition is ready to be executed.\n\n');

return;
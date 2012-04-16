% mapper_makeMapSubsetCycle - Creates pulses for a cycle that stimulates a subset of map pixels, with individual power/timing settings at each pixel.
%
% SYNTAX
%  mapper_makeMapSubsetCycle(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth)
%  mapper_makeMapSubsetCycle(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, pulseDest)
%  mapper_makeMapSubsetCycle(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, pulseDest, cycleName)
%   pixelNumbers - An array indicating the indices of the pixels to be included in the cycle.
%                  The locations of these pixels are calculated from the currently selected map pattern along with the other mapper parameters.
%   amplitudes - The amplitudes for each pixel.
%                May be a vector, of the same length as pixelNumbers, or a scalar.
%   delay - The delay for the shutter/modulator pulse, in seconds.
%           The shutter is forced to be 2ms earlier.
%           May be a vector, of the same length as pixelNumbers, or a scalar.
%   width - The width for the shutter/modulator pulse, in seconds.
%           The shutter is forced to be 2ms longer.
%           May be a vector, of the same length as pixelNumbers, or a scalar.
%   pulseISI - The pulse isi, in seconds.
%              This is not equivalent to the pixel isi (which comes directly from the Mapper).
%              May be a vector, of the same length as pixelNumbers, or a scalar.
%   numberOfPulses - The number of shutter/modulator pulses per pixel.
%                    May be a vector, of the same length as pixelNumbers, or a scalar.
%   testPulseAmp - The amplitude of the ephys test pulse.
%   testPulseDelay - The delay of the ephys test pulse, in seconds.
%   testPulseWidth - The width of the test pulse, in seconds.
%   pulseDest - The directory (the pulse set, within the pulse directory) in which to place pulses.
%               The user will be prompted if this is not specified.
%               Ex: 'C:\Data\User1\pulses\MapSubsetCyclePulses'
%   cycleName - The name of the cycle to be created.
%               The user will be prompted if this is not specified.
%
% NOTES
%
% Created: Timothy O'Connor 3/14/09
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2009
function mapper_makeMapSubsetCycle(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, varargin)

mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
[mapPatternArray, mapperISI, sampleRate] = getLocalBatch(progmanager, mapperObj, 'mapPatternArray', 'isi', 'sampleRate');
if isempty(mapPatternArray)
    fprintf(2, 'No mapPatternArray defined.\n\tThis variable is initialized after the first map execution.\n');
    return;
end

if length(varargin) < 1
    destDir = getDefaultCacheDirectory(progmanager, 'mapSubsetCycle');
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
setDefaultCacheValue(progmanager, 'mapSubsetCycle', destDir);
[pulseDir, pulseSetName] = fileparts(destDir);

if length(amplitudes) == 1
    amplitudes = ones(size(pixelNumbers)) * amplitudes;
end
if length(delay) == 1
    delay = ones(size(pixelNumbers)) * delay;
end
if length(width) == 1
    width = ones(size(pixelNumbers)) * width;
end
if length(pulseISI) == 1
    pulseISI = ones(size(pixelNumbers)) * pulseISI;
end
if length(numberOfPulses) == 1
    numberOfPulses = ones(size(pixelNumbers)) * numberOfPulses;
end

%Create pulses.
fprintf(1, 'Creating pulses in ''%s''...\n', destDir);

%Get the map pattern and pack it into pulses.
mapPattern = mapper_getMapPattern(mapperObj);

xSig = signalobject('Name', 'xMirrorMapSubcycle', 'repeatable', 0, 'sampleRate', sampleRate);
ySig = signalobject('Name', 'yMirrorMapSubcycle', 'repeatable', 0, 'sampleRate', sampleRate);
[xCoords, yCoords] = mapper_getMapCoordinates(mapperObj);

pixelTimes = mapperISI * (0:numel(mapPattern)-1);%This is used in a few places, so allocate/calculate it once.
pixelTimes = pixelTimes(pixelNumbers);

stepFcn(xSig, xCoords(pixelNumbers), 0, pixelTimes);
stepFcn(ySig, yCoords(pixelNumbers), 0, pixelTimes);

%Create ephys pulses, as necessary.
ephysSig1 = signalobject('Name', 'ephysMapSubcycle', 'repeatable', 1, 'sampleRate', sampleRate, 'length', pixelISI);
squarePulseTrain(ephysSig1, ephysPulseAmplitude, ephysPulseOffset, ephysPulseDelay, ephysPulseWidth, ephysPulseISI, ephysN);

%Create the pockels cell pulse (or maybe some other modulator nowadays). This is where the magic happens.
%The amplitude is represented by one signal object.
modulatorSigAmp = signalobject('Name', 'modulatorMapSubcycleAmp', 'repeatable', 0, 'sampleRate', sampleRate);
stepFcn(modulatorSigAmp, amplitudes, 0, pixelTimes);

for i = 1 : length(pixelNumbers)
    %Create shutter pulses, as necessary.
    shutterSigArr(i) = signalobject('Name', ['shutterMapSubcycle' num2str(i)], 'repeatable', 1, 'sampleRate', sampleRate, 'length', pixelISI);
    squarePulseTrain(shutterSigArr(i), 5000, 0, delay(i) - 0.00, width(i) + 0.001, pulseISI(i), numberOfPulses(i));

    %The timing is represented by another signal object.
    modulatorSigMaskArr(i) = signalobject('Name', ['modulatorMapSubcycleMask' num2str(i)], 'repeatable', 1, 'sampleRate', sampleRate, 'length', pixelISI);
    squarePulseTrain(modulatorSigMaskArr(i), 1, 0, delay(i), width(i), pulseISI(i), numberOfPulses(i));
    %The product of the previous two signal objects fully specifies the signal.
end
shutterSig = signalobject('Name', 'shutterMapSubcycle', 'repeatable', 1, 'sampleRate', sampleRate, 'length', pixelISI * length(pixelNumbers));
recursive(shutterSig, 'add', shutterSigArr);
modulatorSigMask = signalobject('Name', 'modulatorMapSubcycleMask', 'repeatable', 1, 'sampleRate', sampleRate, 'length', pixelISI * length(pixelNumbers));
recursive(modulatorSigMask, 'add', modulatorSigMaskArr);
modulatorSig = signalobject('Name', ['modulatorMapSubcycle' pulseNameSuffix], 'repeatable', 0, 'sampleRate', sampleRate);
recursive(modulatorSig, 'multiply', [modulatorSigAmp, modulatorSigMask]);

%Now save the pulses. Delete them when we're done.
for signal = [xSig, ySig, ephysSig1, shutterSig, modulatorSig]
    fprintf(1, '   Writing pulse to disk - ''%s''...\n', get(signal, 'Name'));
    saveCompatible(fullfile(destDir, [get(signal, 'Name') '.signal']), 'signal', '-mat');
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
fprintf(1, '   Creating cycle position 1...\n');
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
        pj_setPulseName(pj, 'ephysMapSubcycle');
    elseif endsWithIgnoreCase(channels{j}, ':xMirror')
        pj_setPulseName(pj, 'xMirrorMapSubcycle');
    elseif endsWithIgnoreCase(channels{j}, ':yMirror')
        pj_setPulseName(pj, 'yMirrorMapSubcycle');
    elseif endsWithIgnoreCase(channels{j}, ':shutter0')
        pj_setPulseName(pj, 'shutterMapSubcycle');
    elseif endsWithIgnoreCase(channels{j}, ':pockelsCell')
        pj_setPulseName(pj, 'modulatorMapSubcycle');
    end
end
pj_currentPosition(pj, 1);%Set the new cycle to the first position.
pj_currentChannel(pj, channels{1});%Set the new cycle to the first channel.

fprintf(1, 'New cycle and pulses complete.\n\n');

return;
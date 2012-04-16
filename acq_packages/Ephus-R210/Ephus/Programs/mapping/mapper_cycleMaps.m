% mapper_cycleMaps - Creates pulses for a series of cycled maps.
%
% SYNTAX
%  mapper_cycleMaps(amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth)
%  mapper_cycleMaps(amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, pulseDest)
%  mapper_cycleMaps(amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, pulseDest, cycleName)
%   amplitudes - The amplitudes for each step.
%   delay - The delay for the shutter/modulator pulse, in seconds.
%           The shutter is forced to be 2ms earlier.
%           May be a vector, of the same length as amplitudes, or a scalar.
%   width - The width for the shutter/modulator pulse, in seconds.
%           The shutter is forced to be 2ms longer.
%           May be a vector, of the same length as amplitudes, or a scalar.
%   pulseISI - The pulse isi, in seconds.
%              This is not equivalent to the pixel isi (which comes directly from the Mapper).
%              May be a vector, of the same length as amplitudes, or a scalar.
%   numberOfPulses - The number of shutter/modulator pulses per pixel, for each map.
%                    May be a vector, of the same length as amplitudes, or a scalar.
%   testPulseAmp - The amplitude of the ephys test pulse.
%   testPulseDelay - The delay of the ephys test pulse, in seconds.
%   testPulseWidth - The width of the test pulse, in seconds.
%   pulseDest - The directory (the pulse set, within the pulse directory) in which to place pulses.
%               The user will be prompted if this is not specified.
%               Ex: 'C:\Data\User1\pulses\CycledMapPulses'
%   cycleName - The name of the cycle to be created.
%               The user will be prompted if this is not specified.
%
% NOTES
%
% Created: Timothy O'Connor 6/1/08
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function mapper_cycleMaps(amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, varargin)

mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
[mapPatternArray, mapperISI, sampleRate] = getLocalBatch(progmanager, mapperObj, 'mapPatternArray', 'isi', 'sampleRate');
if isempty(mapPatternArray)
    fprintf(2, 'No mapPatternArray defined.\n\tThis variable is initialized after the first map execution.\n');
    return;
end

if length(varargin) < 1
    destDir = getDefaultCacheDirectory(progmanager, 'powerCycleMaps');
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
setDefaultCacheValue(progmanager, 'powerCycleMaps', destDir);
[pulseDir, pulseSetName] = fileparts(destDir);

if length(delay) == 1
    delay = ones(size(amplitudes)) * delay;
end
if length(width) == 1
    width = ones(size(amplitudes)) * width;
end
if length(pulseISI) == 1
    pulseISI = ones(size(amplitudes)) * pulseISI;
end
if length(numberOfPulses) == 1
    numberOfPulses = ones(size(amplitudes)) * numberOfPulses;
end

%Create pulses.
fprintf(1, 'Creating pulses in ''%s''...\n', destDir);
for i = 1 : length(amplitudes)
% mapper_feedbackMapping_createNextMap(pixelISI, powerModulationAmplitudes, modulatorDelay, modulatorWidth, modulatorISI, modulatorN, ...
%                                        shutterDelay, shutterWidth, shutterISI, shutterN, ...
%                                        ephysPulseAmplitude, ephysPulseDelay, ephysPulseWidth, ephysPulseISI, ephysN, ...
%                                        sampleRate, destDir, pulseNameSuffix)
    mapper_feedbackMapping_createNextMap(mapperISI, amplitudes(i), delay(i), width(i), pulseISI(i), numberOfPulses(i), ...
                                  delay(i) - 0.002, width(i) + 0.001, pulseISI(i), numberOfPulses(i), ...
                                  testPulseAmp, 0, testPulseDelay, testPulseWidth, 2 * testPulseWidth, 1, ...
                                  sampleRate, destDir, ['_' num2str(i)]);
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
for i = 1 : length(amplitudes)
    fprintf(1, '   Creating position %s...\n', num2str(i));
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
            pj_setPulseName(pj, ['ephysFeedbackMap_' num2str(i)]);
        elseif endsWithIgnoreCase(channels{j}, ':xMirror')
            pj_setPulseName(pj, ['xMirrorFeedbackMap_' num2str(i)]);
        elseif endsWithIgnoreCase(channels{j}, ':yMirror')
            pj_setPulseName(pj, ['yMirrorFeedbackMap_' num2str(i)]);
        elseif endsWithIgnoreCase(channels{j}, ':shutter0')
            pj_setPulseName(pj, ['shutterFeedbackMap_' num2str(i)]);
        elseif endsWithIgnoreCase(channels{j}, ':pockelsCell')
            pj_setPulseName(pj, ['modulatorFeedbackMap_' num2str(i)]);
        end
    end
end
pj_currentPosition(pj, 1);%Set the new cycle to the first position.
pj_currentChannel(pj, channels{1});%Set the new cycle to the first channel.

fprintf(1, 'New cycle and pulses complete.\n\n');

return;
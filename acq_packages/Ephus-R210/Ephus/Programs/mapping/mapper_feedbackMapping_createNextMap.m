% mapper_feedbackMapping_createNextMap - Create pulses to do a cycle-based map, for feedback applications.
%
% SYNTAX
%  mapper_feedbackMapping_createNextMap(pixelISI, powerModulationAmplitudes, modulatorDelay, modulatorWidth, modulatorISI, modulatorN, ...
%                                        shutterDelay, shutterWidth, shutterISI, shutterN, ...
%                                        ephysPulseDelay, ephysPulseOffset, ephysPulseWidth, ephysPulseISI, ephysN, ephysPulseAmplitude, ...
%                                        sampleRate, destDir, pulseNameSuffix)
%    pixelISI - The inter-pixel interval, in seconds.
%    powerModulationAmplitudes - The power for each stimulus amplitude.
%    modulatorDelay - The onset delay before the first modulator pulse, in seconds.
%    modulatorWidth - The width time for modulator pulse, in seconds.
%    modulatorISI - The ISI of the modulator pulse, in seconds.
%    modulatorN - Number of modulator pulses, per pixel.
%    shutterDelay - The onset delay for the shutter pulse, in seconds.
%    shutterWidth - The width of the shutter pulse, in seconds.
%    shutterISI - The ISI of the shutter pulse, in seconds.
%    shutterN - Number of shutter pulses, per pixel.
%    ephysPulseDelay - The onset delay for the ephys pulse, in seconds.
%    ephysPulseWidth - The width of the ephys pulse, in seconds.
%    ephysPulseISI - The ISI of the ephys pulse, in seconds.
%    ephysN - The number of ephys pulses, per pixel.
%    ephysPulseAmplitude - The amplitude of the ephys pulse, in mV or pA.
%    ephysPulseOffset - The offset of the ephys pulse, in mV or pA.
%    ephysPulseOffset - The offset of the ephys pulse, in mV or pA.
%    sampleRate - The default sampleRate for each pulse (which may be altered automatically when it is actually used).
%    destDir - The destination directory for the created pulses.
%    pulseNameSuffix - Suffix appended to each pulse's name (and the associated filename).
%
% NOTES
%  The intended use of this function is to call it from a user function that does data analysis to generate new power modulation values.
%  This will then generate a new set of pulses, which act just as a board clock timed map would. By loading these pulses via the pulseJacker
%  a cycle of maps can be run, where the user function creates new pulses at each iteration. Looping, in this scenario, would be CPU timed
%  and the loop interval would be the inter-map interval. Each "map" is done as a single acquisition over all pixels.
%
% Created: Timothy O'Connor 5/31/08
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function mapper_feedbackMapping_createNextMap(pixelISI, powerModulationAmplitudes, modulatorDelay, modulatorWidth, modulatorISI, modulatorN, ...
                                       shutterDelay, shutterWidth, shutterISI, shutterN, ...
                                       ephysPulseAmplitude, ephysPulseOffset, ephysPulseDelay, ephysPulseWidth, ephysPulseISI, ephysN, ...
                                       sampleRate, destDir, pulseNameSuffix)

%Get the map pattern and pack it into pulses.
mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
% [mapPattern] = getLocalBatch(progmanager, mapperObj, 'mapPatternArray');
mapPattern = mapper_getMapPattern(mapperObj);
pixelTimes = pixelISI * (0:numel(mapPattern)-1);%This is used in a few places, so allocate/calculate it once.

xSig = signalobject('Name', ['xMirrorFeedbackMap' pulseNameSuffix], 'repeatable', 0, 'sampleRate', sampleRate);
ySig = signalobject('Name', ['yMirrorFeedbackMap' pulseNameSuffix], 'repeatable', 0, 'sampleRate', sampleRate);
% %This method, using raw voltages, would require that the mirror channels are unpreprocessed.
% [xMirrorVoltages, yMirrorVoltages] = mapper_getMirrorVoltages(mapperObj);
% literal(xSig, xMirrorVoltages);
% literal(ySig, yMirrorVoltages);
[xCoords, yCoords] = mapper_getMapCoordinates(mapperObj);
stepFcn(xSig, xCoords, 0, pixelTimes);
stepFcn(ySig, yCoords, 0, pixelTimes);

%Create ephys pulses, as necessary.
ephysSig1 = signalobject('Name', ['ephysFeedbackMap' pulseNameSuffix], 'repeatable', 1, 'sampleRate', sampleRate, 'length', pixelISI);
squarePulseTrain(ephysSig1, ephysPulseAmplitude, ephysPulseOffset, ephysPulseDelay, ephysPulseWidth, ephysPulseISI, ephysN);

%Create shutter pulses, as necessary.
shutterSig = signalobject('Name', ['shutterFeedbackMap' pulseNameSuffix], 'repeatable', 1, 'sampleRate', sampleRate, 'length', pixelISI);
% %The shutter may also take a digital pulse, if the hardware supports buffered digital I/O.
% %Analog signals can still be used for digital lines, so there's no need to explicitly create a digital pulse here.
% digitalPulseTrain(shutterSig, 1, 0, pixelDelay, pixelWidth, pixelISI, numel(mapPattern));
squarePulseTrain(shutterSig, 5000, 0, shutterDelay, shutterWidth, shutterISI, shutterN);

%Create the pockels cell pulse (or maybe some other modulator nowadays). This is where the magic happens.
%The amplitude is represented by one signal object.
modulatorSigAmp = signalobject('Name', ['modulatorFeedbackMapAmp' pulseNameSuffix], 'repeatable', 0, 'sampleRate', sampleRate);
stepFcn(modulatorSigAmp, powerModulationAmplitudes, 0, pixelTimes);
%The timing is represented by another signal object.
modulatorSigMask = signalobject('Name', ['modulatorFeedbackMapMask' pulseNameSuffix], 'repeatable', 1, 'sampleRate', sampleRate, 'length', pixelISI);
squarePulseTrain(modulatorSigMask, 1, 0, modulatorDelay, modulatorWidth, modulatorISI, modulatorN);
%The product of the previous two signal objects fully specifies the signal.
modulatorSig = signalobject('Name', ['modulatorFeedbackMap' pulseNameSuffix], 'repeatable', 0, 'sampleRate', sampleRate);
recursive(modulatorSig, 'multiply', [modulatorSigAmp, modulatorSigMask]);

%Now save the pulses. Delete them when we're done.
for signal = [xSig, ySig, ephysSig1, shutterSig, modulatorSig]
    fprintf(1, '   Writing pulse to disk - ''%s''...\n', get(signal, 'Name'));
    saveCompatible(fullfile(destDir, [get(signal, 'Name') '.signal']), 'signal', '-mat');
    delete(signal);
end

return;
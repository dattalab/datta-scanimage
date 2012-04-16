% getPockelsCalibrationFit - Measure a Pockels cell calibration curve and return the coeffecients of a 3rd order polynomial fit.
%
% SYNTAX
%  [coeffs, maxV, minV, offset] = getPockelsCalibrationFit(pockelsCellDevice, photodiodeDevice, triggerOrigin, pockelsCellTriggerDestination, photodiodeTriggerDestination, shutterDevice)
%  [coeffs, maxV, minV, offset] = getPockelsCalibrationFit(pockelsCellDevice, photodiodeDevice, triggerOrigin, pockelsCellTriggerDestination, photodiodeTriggerDestination, shutterDevice, shutterClockSource, shutterClockTask)
%   pockelsCellDevice - The NIMEX device name for the analog output connected to the pockels cell under test.
%   photodiodeDevice - The NIMEX device name for the analog output connected to the photodiode under test.
%   triggerOrigin - The NIMEX device name for the digital line that will send a trigger.
%   pockelsCellTriggerDestination - The NIMEX terminal name for the pockels cell task to accept a trigger.
%   photodiodeTriggerDestination - The NIMEX terminal name for the photodiode task to accept a trigger.
%   shutterDevice - The NIMEX device name for the shutter control.
%   sampleClockDestination - The NIMEX terminal for the sample clock destination. If the clock is internal, do not use this argument.
%   shutterClockTask - A preconfigured NIMEX task to be used as the master sample clock source.
%   coeffs - The coefficients of a 3rd order fit, as per the Matlab `\` operator.
%   maxV - The maximum voltage measured on the photodiode [V].
%   minV - The minimum voltage measured on the photodiode [V].
%   offset - The photodiode's voltage offset (due to ambient light and/or electronics) [V].
%
% NOTES
%
% CHANGES
% JL102307A   modified the code to @nimex
% TO012408E - Add a title to the plot. -- Tim O'Connor 1/24/08
% TO080108E - Allow external sample clocks. Output digital shutter signals, if necessary. -- Tim O'Connor 8/1/08
%
% Created 10/22/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function [coeffs, maxV, minV, offset] = getPockelsCalibrationFit(pockelsCellDevice, photodiodeDevice, triggerOrigin, pockelsCellTriggerDestination, photodiodeTriggerDestination, shutterDevice, varargin)

pockelsCellTask = nimex;
nimex_addAnalogOutput(pockelsCellTask, pockelsCellDevice);
photodiodeTask = nimex;
nimex_addAnalogInput(photodiodeTask, photodiodeDevice);
shutterTask = nimex;
nimex_addAnalogOutput(shutterTask, shutterDevice);

%TO080108E
sampleClockDestination = '';
masterSampleClockTask = [];
if ~isempty(varargin)
    masterSampleClockTask = varargin{1};
    sampleClockDestination = varargin{2};
end

maxModulationVoltage = 2;
modulation_voltage = (0:0.01:maxModulationVoltage-0.01)';

% fprintf(1, 'Test mode, changing control signal to a sin^2 curve\n');
% testModulation_voltage = sin(0 : (pi/2) / 100 : (pi/2) - (pi/2)/100).^2;
% modulation_voltage = testModulation_voltage;

% JL102307A   modified the code to @nimex

nimex_setTaskProperty(pockelsCellTask, 'samplingRate', 10000, 'triggerSource', pockelsCellTriggerDestination, 'sampsPerChanToAcquire', length(modulation_voltage), 'clockSource', sampleClockDestination);%TO080108E
nimex_setTaskProperty(photodiodeTask, 'samplingRate', 10000, 'triggerSource', photodiodeTriggerDestination, 'sampsPerChanToAcquire', length(modulation_voltage), 'clockSource', sampleClockDestination);%TO080108E

%TO080108E
if ~isempty(masterSampleClockTask)
    nimex_startTask(masterSampleClockTask);
end

%Find photodiode offset.
nimex_startTask(photodiodeTask);
nimex_sendTrigger(photodiodeTask, triggerOrigin);
offsetdata = nimex_readAnalogF64(photodiodeTask, length(modulation_voltage));
nimex_stopTask(photodiodeTask);
% figure, plot(offsetdata, 'o:');
offset = mean(offsetdata);

%Output the Pockels cell control signal (a ramp).
nimex_writeAnalogF64(pockelsCellTask, pockelsCellDevice, modulation_voltage, length(modulation_voltage));
%TO080108E - Handle digital shutter lines cleanly.
if isempty(strfind(shutterDevice, 'port'))
    nimex_putSample(shutterTask, shutterDevice, 5);
else
    nimex_putSample(shutterTask, shutterDevice, uint32(255));
end

nimex_startTask(photodiodeTask);
nimex_startTask(pockelsCellTask);

nimex_sendTrigger(photodiodeTask, triggerOrigin);

%Read in the photodiode voltages corresponding to the Pockels cell control signal.
photodiode_voltage = nimex_readAnalogF64(photodiodeTask, length(modulation_voltage));
maxV = max(photodiode_voltage);
[minV, mni] = min(photodiode_voltage);
%TO080108E - Use proper digital signals.
if isempty(strfind(shutterDevice, 'port'))
    nimex_putSample(shutterTask, shutterDevice, 0);
else
    nimex_putSample(shutterTask, shutterDevice, uint32(0));
end
photodiode_voltage = photodiode_voltage - offset;
fprintf(1, '\n%s - Pockels cell calibration -\n ambient light/amplifier offset: %s [V]\n photodiode min: %s [V]\n photodiode max: %s [V]\n\n\n', datestr(now), num2str(offset), ...
    num2str(min(photodiode_voltage)), num2str(max(photodiode_voltage)));


%TO080108E
if ~isempty(masterSampleClockTask)
    nimex_stopTask(masterSampleClockTask);
end

nimex_stopTask(photodiodeTask);
nimex_stopTask(pockelsCellTask);

eom_max = maxV - offset;

%Normalize
photodiode_voltage = photodiode_voltage / eom_max;

%Check that the calibration is valid.
mn = minV - offset;
if length(mni) > 1 && length(mni) < 3
    mni = mni(1);
elseif length(mni) >= 3
    warning('Too many minima');
    mni = mni(1);
end
[mx mxi] = max(photodiode_voltage);
if length(mxi) > 1 && length(mxi) < 3
    mxi = mxi(1);
elseif length(mxi) >= 3
    warning('Too many maxima');
    mxi = mxi(1);
end
if mxi > mni
    photodiode_voltage = photodiode_voltage(mni:mxi);
    modulation_voltage = modulation_voltage(mni:mxi);
elseif mni > mxi
    photodiode_voltage = photodiode_voltage(mxi:mni);
    modulation_voltage = modulation_voltage(mxi:mni);
end

%Calculate a fit of the photodiode voltage to the Pockels cell control signal.
coeffs = [ones(size(photodiode_voltage)) photodiode_voltage photodiode_voltage.^2 photodiode_voltage.^3] \ modulation_voltage;

%Display the fit vs the real measurements.
T = (0:.01:mx)';
Y = [ones(size(T)) T T.^2 T.^3] * coeffs;
indices = find(Y >= min(modulation_voltage));
Y = Y(indices);
T = T(indices);
figure, plot(T, Y,'.-', photodiode_voltage, modulation_voltage, 'o-');
xlabel('Photodiode Intensity (Offset Subtracted, Normalized)');
ylabel('Modulation Voltage');
title('Pockels Cell Calibration');
legend('Fit', 'RawData');

return;
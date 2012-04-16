% photodiode/addCalibrationPoint - Add another datapoint for the current calibration.
%
% SYNTAX
%  addCalibrationPoint(this, powerInMw)
%   this - The object instance.
%   powerInMw - The reading from a power meter.
%
% USAGE
%
% STRUCTURE
%
% NOTES
%
% CHANGES
%  JL10152007A change codes with @nimex - Jinyang Liu 10/15/07
%
% Created 8/2/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function addCalibrationPoint(this, powerInMw)
global photodiodeObjects;

if isempty(photodiodeObjects(this.ptr).calibrationUser)
    error('A user name must be specified for a calibration to be performed.');
end

if photodiodeObjects(this.ptr).boardID == -1 | photodiodeObjects(this.ptr).channelID == -1
    error('A valid boardID and channelID must be specified to perform a calibration.');
end

%JL10152007A change codes with @nimex
aiTask = nimex;
nimex_addAnalogInput(aiTask,['/dev' num2str(photodiodeObjects(this.ptr).boardID) '/ai' num2str(photodiodeObjects(this.ptr).channelID)]);
nimex_setTaskProperty(aiTask, 'samplingRate', 1002, 'sampsPerChanToAcquire', 100);
nimex_startTask(aiTask);
data = nimex_readAnalogF64(aiTask, 100);
pause(0.11);
nimex_stopTask(aiTask);
voltage = mean(data);
delete(aiTask);

% ai = analoginput('nidaq', photodiodeObjects(this.ptr).boardID);
% addchannel(ai, photodiodeObjects(this.ptr).channelID);
% set(ai, 'SampleRate', 1002, 'TriggerType', 'Immediate', 'SamplesPerTrigger', 100);
% start(ai);
% pause(0.11);
% stop(ai);
% voltage = mean(getdata(ai));
% delete(ai);

% voltage = 0.01 * powerInMw;%Test purposes only.
photodiodeObjects(this.ptr).calibrationDate = clock;

index = length(photodiodeObjects(this.ptr).calibrationPowers) + 1;
photodiodeObjects(this.ptr).calibrationPowers(index) = powerInMw;
photodiodeObjects(this.ptr).calibrationVoltages(index) = voltage;

if length(photodiodeObjects(this.ptr).calibrationPowers) > 1
    coeffs = [ones(size(photodiodeObjects(this.ptr).calibrationVoltages')) photodiodeObjects(this.ptr).calibrationVoltages'] \ photodiodeObjects(this.ptr).calibrationPowers';
    if length(coeffs) == 1
        coeffs = [0; coeffs];
    elseif length(coeffs) > 2
        coeffs = coeffs(1:2);
    end
    photodiodeObjects(this.ptr).calibrationOffset = coeffs(1);
    photodiodeObjects(this.ptr).calibrationSlope = coeffs(2);
end

return;
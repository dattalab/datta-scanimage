% mapper_coordinates2Voltages - Convert micron coordinates into galvo voltages.
%
% SYNTAX
%  mapper_coordinates2Voltages(hObject, axis, data)
%    hObject - The mapper program handle.
%    axis - 'X' or 'Y', determines which channel is being preprocessed.te
%    data - The actual data to preprocess.
%
% USAGE
%
% NOTES
%  Refactored from mapper_mirrorChannelPreprocessor.m
%  See TO060308A.
%
% CHANGES
%   VI061308A - Account for possibility of horizontal/vertical mirrors being switched -- Vijay Iyer 6/13/08
%
% CREDITS
% Created 6/3/08 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function preprocessed = mapper_coordinates2Voltages(hObject, axis, data)
% fprintf(1, '%s - mapper_coordinates2Voltages\n%s', datestr(now), getStackTraceString);

if isempty(data)
    error('Can not convert empty data.');
end

axesSwitch = getLocal(progmanager,hObject,'axesSwitch'); %VI061308A

if (strcmpi(axis, 'X')&& ~axesSwitch) || (strcmpi(axis,'Y') && axesSwitch) %VI061308A
    [offset, amplitude, gain, invert] = getLocalBatch(progmanager, hObject, ...
        'temp_xOffset', 'temp_xAmplitude', 'temp_xGain', 'temp_xInvert');
elseif (strcmpi(axis, 'Y') && ~axesSwitch) || (strcmpi(axis, 'X') && axesSwitch) %VI061308A
    [offset, amplitude, gain, invert] = getLocalBatch(progmanager, hObject, ...
        'temp_yOffset', 'temp_yAmplitude', 'temp_yGain', 'temp_yInvert');
else
    error('Invalid axis specified: ''%s''', axis);
end

sign = +1;
if invert
    sign = -1;
end

preprocessed = sign * (data * gain + offset);
% figure; plot(1:length(data), 1000 * data, 'o:', 1:length(preprocessed), preprocessed, '*:'); title(axis);

overVoltage = find(preprocessed > 6);
underVoltage = find(preprocessed < -6);
if ~isempty(overVoltage)
    fprintf(2, 'Warning: mapper_coordinates2Voltages - ''%s'' mirror control signal may be invalid. Voltages were found to be out of range - OVER_VOLTAGE\n%s', axis, getStackTraceString);
    figure;
    plot(1:length(data), data, ':v', 1:length(preprocessed), preprocessed, ':o', overVoltage, preprocessed(overVoltage), 'x');
    title(['Mirror Control OverVoltage (' axis ' axis)']);
    legend('Raw Samples', 'Preprocessed Samples', 'Over-Voltage Samples');
    preprocessed(overVoltage) = 6;
end
if ~isempty(underVoltage)
    fprintf(2, 'Warning: mapper_coordinates2Voltages - ''%s'' mirror control signal may be invalid. Voltages were found to be out of range - UNDER_VOLTAGE\n%s', axis, getStackTraceString);
    figure;
    plot(1:length(data), data, ':v', 1:length(preprocessed), preprocessed, ':o', underVoltage, preprocessed(underVoltage), 'x');
    title(['Mirror Control UnderVoltage (' axis ' axis)']);
    legend('Raw Samples', 'Preprocessed Samples', 'Under-Voltage Samples');
    preprocessed(underVoltage) = -6;
end

N = 1024;
Y = fft(preprocessed, N);
powerSpectrum = Y .* conj(Y) / N;
if any(powerSpectrum(256:514) > .7)
    fprintf(2, 'Warning: mapper_coordinates2Voltages - ''%s'' mirror control signal may be invalid. Frequencies were found to be out of range - OVER_FREQUENCY\n%s', axis, getStackTraceString);
    f = 10000 * (0:N/2) / N;
    figure;
    plot(f, powerSpectrum(1:(N/2)+1), ':o');
    title(['Mirror Control Over Frequency (' axis ' axis)']);
    xlabel('frequency (Hz)')
end

% fprintf(1, 'mapper_coordinates2Voltages %s-axis (before): %s - %s\n', axis, num2str(min(data)), num2str(max(data)));
% fprintf(1, 'mapper_coordinates2Voltages %s-axis (after): %s - %s\n\n', axis, num2str(min(preprocessed)), num2str(max(preprocessed)));

return;
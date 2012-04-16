% mapper_mirrorChannelPreprocessor - Convert micron coordinates into galvo voltages.
%
% SYNTAX
%  mapper_mirrorChannelPreprocessor(hObject, axis, data)
%    hObject - The mapper program handle.
%    axis - 'X' or 'Y', determines which channel is being preprocessed.te
%    data - The actual data to preprocess.
%
% USAGE
%
% NOTES
%  Used mapper/executeMousePattern as a prototype.
%
% CHANGES
%   TO102207A - Port to nimex. -- Tim O'Connor 10/22/07
%   TO060208I - Fail when the data is empty. -- Tim O'Connor 6/2/08
%   TO060308A - Refactor all mirror voltage calculations to remove redunancy. -- Tim O'Connor 6/3/08
%   TO102408A - Mirror data now gets preprocessed (as of TO060308A). -- Tim O'Connor 10/24/08
%   TO031309A - Added a try/catch to look for error conditions, and print useful information. -- Tim O'Connor 3/13/09
% Created 9/13/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function preprocessed = mapper_mirrorChannelPreprocessor(hObject, axis, data)
% fprintf(1, '%s - mapper_mirrorChannelPreprocessor\n', datestr(now));

if isempty(data)
    error('Can not preprocess empty data.');
end

%TO102207A - Port to nimex.
if getLocal(progmanager, hObject, 'map')
    preprocessed = 1000 * data;%LTP021208
    return;
end

%TO102408A - Mirror data now gets preprocessed (as of TO060308A). -- Tim O'Connor 10/24/08
% if getLocal(progmanager, hObject, 'mouse') %LTP021208
%     preprocessed = 1000 * data;
%     return;
% end
try
    preprocessed = mapper_coordinates2Voltages(hObject, axis, 1000 * data);%TO060308A
catch
    preprocessed = [];
%     fprintf(2, 'mapper_mirrorChannelPreprocessor: Encountered an error while calling `mapper_coordinates2Voltages`: \n%s\n', getLastErrorStack);
end

% fprintf(1, 'mapper_mirrorChannelPreprocessor - From [%s - %s] to [%s - %s]\n', num2str(min(data)), num2str(max(data)), num2str(min(preprocessed)), num2str(max(preprocessed)));
return;
% if strcmpi(axis, 'X')
%     [offset, amplitude, gain, invert] = getLocalBatch(progmanager, hObject, ...
%         'temp_xOffset', 'temp_xAmplitude', 'temp_xGain', 'temp_xInvert');
% elseif strcmpi(axis, 'Y')
%     [offset, amplitude, gain, invert] = getLocalBatch(progmanager, hObject, ...
%         'temp_yOffset', 'temp_yAmplitude', 'temp_yGain', 'temp_yInvert');
% else
%     error('Invalid axis specified: ''%s''', axis);
% end
% 
% sign = +1;
% if invert
%     sign = -1;
% end
% 
% preprocessed = sign * (1000 * data * gain + offset);
% % figure; plot(1:length(data), 1000 * data, 'o:', 1:length(preprocessed), preprocessed, '*:'); title(axis);
% 
% overVoltage = find(preprocessed > 6);
% underVoltage = find(preprocessed < -6);
% if ~isempty(overVoltage)
%     fprintf(2, 'Warning: mapper_mirrorChannelPreprocessor - ''%s'' mirror control signal may be invalid. Voltages were found to be out of range - OVER_VOLTAGE\n%s', axis, getStackTraceString);
%     figure;
%     plot(1:length(data), data, ':v', 1:length(preprocessed), preprocessed, ':o', overVoltage, preprocessed(overVoltage), 'x');
%     title(['Mirror Control OverVoltage (' axis ' axis)']);
%     legend('Raw Samples', 'Preprocessed Samples', 'Over-Voltage Samples');
%     preprocessed(overVoltage) = 6;
% end
% if ~isempty(underVoltage)
%     fprintf(2, 'Warning: mapper_mirrorChannelPreprocessor - ''%s'' mirror control signal may be invalid. Voltages were found to be out of range - UNDER_VOLTAGE\n%s', axis, getStackTraceString);
%     figure;
%     plot(1:length(data), data, ':v', 1:length(preprocessed), preprocessed, ':o', underVoltage, preprocessed(underVoltage), 'x');
%     title(['Mirror Control UnderVoltage (' axis ' axis)']);
%     legend('Raw Samples', 'Preprocessed Samples', 'Under-Voltage Samples');
%     preprocessed(underVoltage) = -6;
% end
% 
% N = 1024;
% Y = fft(preprocessed, N);
% powerSpectrum = Y .* conj(Y) / N;
% if any(powerSpectrum(256:514) > .7)
%     fprintf(2, 'Warning: mapper_mirrorChannelPreprocessor - ''s'' mirror control signal may be invalid. Frequencies were found to be out of range - OVER_FREQUENCY\n%s', axis, getStackTraceString);
%     f = 10000 * (0:N/2) / N;
%     figure;
%     plot(f, powerSpectrum(1:(N/2)+1), ':o');
%     title('Mirror Control Over Frequency');
%     xlabel('frequency (Hz)')
% end
% 
% return;
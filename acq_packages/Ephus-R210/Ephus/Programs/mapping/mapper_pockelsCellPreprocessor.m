% mapper_pockelsCellPreprocessor - An @AOMUX preprocessor function for the mapper to control a Pockels cell.
%
% SYNTAX
%  mapper_pockelsCellPreprocessor(hObject, data)
%    hObject - The mapper program handle.
%    data - The actual data to preprocess.
%
% USAGE
%
% NOTES
%  This is only intended as a temporary implementation of a Pockels cell preprocessor. It may,
%  however, grow into a more permanent function, at which time it should be extracted
%  from the mapper.
%
%  The control signal is expected to vary between 0 and 100 (ie. the units are percent).
%
% CHANGES
%  TO031306C: Scaling 0-.100 V, convert that into normalized units. -- Tim O'Connor 3/13/06
%  TO102508H: Handle the 'coeffs' variable's potential non-existence. -- Tim O'Connor 10/25/08
%  TO021510E: Make the Pockels cell optional. -- Tim O'Connor 2/15/10
%
% Created 3/10/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function preprocessed = mapper_pockelsCellPreprocessor(hObject, data)
% fprintf(1, 'mapper_pockelsCellPreprocessor: InitialRange = [%s %s].\n', num2str(min(data)), num2str(max(data)));

try
    %TO102508H - Just checking for empty below is not enough, because this call may fail, so try/catch it. -- Tim O'Connor 10/25/08
    coeffs = getLocal(progmanager, hObject, 'coeffs');
catch
    coeffs = [];
end
if isempty(coeffs)
    preprocessed = zeros(size(data));
    warning('Pockels cell appears to be uncalibrated.');
    return;
end

data = 10 * data;%TO031306C

%Apply the 3rd degree polynomial fit.
try%LTP021208 Added try catch with Tim over the phone 
basis = cat(2, ones(size(data)), data, data.^2, data.^3);
preprocessed = basis * coeffs;
catch
    basis = cat(1, ones(size(data)), data, data.^2, data.^3)';
    preprocessed = basis * coeffs;
end
%Watch out for over/under voltages and NaNs.
indicesOfNaNs = find(preprocessed == NaN);
overVoltage = find(preprocessed > getLocal(progmanager, hObject, 'modulatorMax'));%For UV, no modulation beyond 1V is necessary. %TO021510E - The range is now configurable.
underVoltage = find(preprocessed < getLocal(progmanager, hObject, 'modulatorMin'));%All modulation is positive. %TO021510E - Not anymore...
if ~isempty(overVoltage)
    fprintf(2, 'Warning: mapper_pockelsCellPreprocessor - Pockels cell calibration or control signal may be invalid. Voltages were found to be out of range - OVER_VOLTAGE\n%s', getStackTraceString);
    figure;
    plot(1:length(data), data, ':v', 1:length(preprocessed), preprocessed, ':o', 1:length(overVoltage), preprocessed(overVoltage), 'x');
    title('Pockels Cell OverVoltage');
    legend('Preprocessed data', 'Overvoltage samples');
    preprocessed(overVoltage) = 2;
    fprintf(2, 'To set "fake" pockels cell calibration data, run: setGlobal(progmanager, ''coeffs'', ''mapper'', ''mapper'', [0 0.1 0.1 0.1]'')\n');
end
if ~isempty(underVoltage)
    fprintf(2, 'Warning: mapper_pockelsCellPreprocessor - Pockels cell calibration or control signal may be invalid. Voltages were found to be out of range - UNDER_VOLTAGE\n%s', getStackTraceString);
    figure;
    plot(1:length(data), data, ':v', 1:length(preprocessed), preprocessed, ':o', 1:length(underVoltage), preprocessed(underVoltage), 'x');
    title('Pockels Cell UnderVoltage');
    legend('Preprocessed data', 'Undervoltage samples');
    preprocessed(underVoltage) = 0;
    fprintf(2, 'To set "fake" pockels cell calibration data, run: setGlobal(progmanager, ''coeffs'', ''mapper'', ''mapper'', [0 0.1 0.1 0.1]'')\n');
end
if ~isempty(indicesOfNaNs)
    fprintf(2, 'Warning: mapper_pockelsCellPreprocessor - Pockels cell calibration or control signal may be invalid. Voltages were found to be out of range - NaN\n%s', getStackTraceString);
    figure;
    plot(1:length(data), data, ':v', 1:length(preprocessed), preprocessed, ':o', 1:length(indicesOfNaNs), preprocessed(indicesOfNaNs), 'x');
    title('Pockels Cell NaN');
    legend('Preprocessed data', 'NaN samples');
    preprocessed(indicesOfNaNs) = 0;
    fprintf(2, 'To set "fake" pockels cell calibration data, run: setGlobal(progmanager, ''coeffs'', ''mapper'', ''mapper'', [0 0.1 0.1 0.1]'')\n');
end
% fprintf(1, 'mapper_pockelsCellPreprocessor: FinalRange = [%s %s].\n', num2str(min(data)), num2str(max(data)));
return;
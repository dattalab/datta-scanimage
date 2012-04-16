% plotStabilityCharacterization
%
%  This function will read and plot the data recorded using characterizeStability.m
%
% Created 8/22/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function plotStabilityCharacterization

[f p] = uigetfile(fullfile(pwd, 'stabilityCharacterization.txt'), 'Select a file in which to store data...');
if length(f) == 1 & length(p) == 1
    if f == 0 & p == 0
        return;
    end
end
inputfile = fullfile(p, f);

finfo = dir(inputfile);
fObject = fopen(inputfile, 'r');

wb = waitbarWithCancel(0, sprintf('Loading data from %s', strrep(strrep(inputfile, '\', '\\'), '_', '\_')), 'Tag', 'plotStabilityCharacterization_waitbar');
% wb = waitbar(0, sprintf('Loading data from %s', strrep(strrep(inputfile, '\', '\\'), '_', '\_')), 'Tag', 'plotStabilityCharacterization_waitbar');

atEof = 0;
lineNumber = 0;
headerSizeInLines = 2;
startTimestamp = '';
endTimestamp = '';

while ~atEof
    if isWaitbarCancelled(wb)
        delete(wb);
        return;
    end
    
    line = fgetl(fObject);
    lineNumber = lineNumber + 1;
    if length(line) == 1
        if line == -1
            atEof = 1;
        end
    end
    
    if feof(fObject)
        atEof = 1;
    end
% if lineNumber > 20
%     delete(wb);
%     return;
% end
    if lineNumber > headerSizeInLines
        %Beyond the header
        [serialTimestamp voltageLevel textTimestamp] = strread(line, '%f%f%s', 'delimiter', ',');
        xVals(lineNumber - headerSizeInLines) = serialTimestamp;
        yVals(lineNumber - headerSizeInLines) = voltageLevel;
        if lineNumber - headerSizeInLines == 1
            startTimeStamp = textTimestamp{1};
        end
        endTimeStamp = textTimestamp{1};
        
        %Scale into minutes.
        if lineNumber - headerSizeInLines == 1        
            timeOffset = xVals(1);
        end

        xVals(end) = xVals(end) - timeOffset;
        if lineNumber - headerSizeInLines == 1
            baseTime = datevec(xVals(1));
        end
        xVals(end) = etime(datevec(xVals(end)), baseTime) / 60;
    end

    waitbar(ftell(fObject) / finfo.bytes, wb);
end

fclose(fObject);

fig = figure('Name', 'stabilityCharacterization');
pObject = plot(xVals', yVals', 'o:', 'MarkerSize', 3);
title('Signal Intensity vs. Time');
xlabel('Time [minutes]');
ylabel('Voltage [V]');

meanVal = mean(yVals);
stdVal = std(yVals);
fprintf(1, '\nAnalyzed stability data from %s\n  Acquired %s datapoints from ''%s'' to ''%s''\n  Mean: %s\n  Standard Deviation: %s (%s%% of the mean)\n\n', ...
    inputfile, num2str(length(xVals)), startTimeStamp, endTimeStamp, num2str(meanVal), num2str(stdVal), num2str(100 * stdVal / meanVal));

if ishandle(wb)
    delete(wb);
end

return;
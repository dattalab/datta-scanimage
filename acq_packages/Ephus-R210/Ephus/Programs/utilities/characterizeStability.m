% characterizeStability
%
%  This function will periodically sample a given input channel, and write the timestamp and voltage
%  to a text file. This is useful for monitoring the stability of a signal over a long time period.
%
% Created 8/19/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function characterizeStability

[f p] = uiputfile(fullfile(pwd, 'stabilityCharacterization.txt'), 'Select a file in which to store data...');
if length(f) == 1 & length(p) == 1
    if f == 0 & p == 0
        return;
    end
end
outputfile = fullfile(p, f);
if ~endsWithIgnoreCase(outputfile, '.txt')
    outputfile = [outputfile '.txt'];
end

answers = inputdlg({'Sampling Interval [s]', 'Board ID', 'Channel ID'}, 'Characterize Stability Parameters', 1, {'60', '2', '3'});
if isempty(answers)
    return;
end
interval = str2num(answers{1});
boardID = str2num(answers{2});
channelID = str2num(answers{3});

ai = analoginput('nidaq', boardID);
set(ai, 'Name', 'characterizeStability_analoginput', 'SampleRate', 10000, 'SamplesPerTrigger', 1000);
addchannel(ai, channelID);

t = timer('Name', 'characterizeStability_timer', 'TimerFcn', {@characterizeStability_timerCallback, interval, ai, outputfile}, ...
    'Period', interval, 'Tag', 'characterizeStability_timer', 'TasksToExecute', Inf, 'ExecutionMode', 'fixedDelay');

fprintf('%s - Tracking stability of signal on\n  board: %s\n  channel: %s\nAt %s Hz.\nResults may be found in - ''%s''\n\n***  Type `stop(timerfind)` to end execution of this program.  ***\n\n', ...
    datestr(datevec(now)), num2str(boardID), num2str(channelID), num2str(1 / interval), outputfile);

fObject = fopen(outputfile, 'w');
fprintf(fObject, '%s - characterizeStability.m output file\r\nSerial Timestamp,\tVoltage level [v],\tText Timestamp\r\n', datestr(clock));
fclose(fObject);

start(t);

return;

%--------------------------------------------------------------------------
function characterizeStability_timerCallback(tObject, eventdata, interval, ai, outputfile)

start(ai);

%Get the timestamp.
currentTime = now;

%Take some samples and average them.
voltage = mean(getdata(ai));

stop(ai);

fObject = fopen(outputfile, 'a');
fprintf(fObject, '%s,\t%s,\t%s\r\n', num2str(currentTime), num2str(voltage), datestr(datevec(currentTime)));
fclose(fObject);

% fprintf(1, 'characterizeStability_timerCallback: %s - %s [V]\n', datestr(datevec(now)), num2str(voltage));

return;
% SIGNAL/GETSQUAREPULSETRAINDATA - Create data for a squarePulseTrain type.
%
% SYNTAX
%  data = getSquarePulseTrainData(SIGNAL, time) - Gets (time / SIGNAL.sampleRate) datapoints of SIGNAL. If SIGNAL.length is not long enough
%                                    the appropriate number of points at SIGNAL.offset are returned.
%
% Changed:
%  2/3/05 Tim O'Connor (TO020305d): Added the noPadding variable.
%  Added the squarePulseTrain type, to simply port over the parameters from the original Physiology software. -- Tim O'Connor 5/2/05 TO050205A
%  TO070605C - Leading edges are exactly ISI spaced, not (ISI + width). -- Tim O'Connor 7/6/05
%  TO072105B - Pulse trains were generating one extra pulse, beyond what was speficied. -- Tim O'Connor 7/21/05
%  TO080905C - Removed a superfluous +1, used to account for time 0, which doesn't exist, time starts at sample 1. -- Tim O'Connor 8/9/05
%  TO081005A - When the delay is 0, the pulse technically starts at time 0, which must be bumped into sample 1. -- Tim O'Connor 8/10/05
%  TO081205A - Inserted a -1 to remove the falling edge from final indexing. That is, the transition occurs prior to the falling edge. -- Tim O'Connor 8/12/05
%  TO092805E - Check for (time == 0), return an empty array. -- Tim O'Connor 9/28/05
%  TO033108D - Add support for multiline/multibit digital data. -- Tim O'Connor 3/31/08
%  TO053108A - Handle infinite length pulses properly. -- Tim O'Connor 5/31/08
%  TO060208F - Allow a hard length to be taken into account, and repeat the signal as necessary. -- Tim O'Connor 6/2/08
%
% Created 8/19/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function data = getSquarePulseTrainData(this, time, varargin)
global signalobjects;

%TO092805E
if time == 0
    data = [];
    return;
end

pointer = indexOf(this);

%TO060208F
if signalobjects(pointer).length ~= -1
    if time > signalobjects(pointer).length && ~signalobjects(pointer).repeatable
        error('The requested time duration (%s [s]) exceeds this @signalobject''s length (%s [s]).', num2str(time), num2str(signalobjects(pointer).length));
    else
        fullTime = time;
        time = signalobjects(pointer).length;
    end
end

samples = ceil(time * signalobjects(pointer).sampleRate);

%TO033108D
if strcmpi(signalobjects(pointer).type, 'digitalPulseTrain')
    data = zeros(samples, 1);
else
    data = ones(samples, 1) * signalobjects(pointer).offset;
end

%Rising = delay : isi : delay + (width + isi) * number
% risingEdgesInTime = signalobjects(pointer).squarePulseTrainDelay : signalobjects(pointer).squarePulseTrainWidth + signalobjects(pointer).squarePulseTrainISI : ...
%     signalobjects(pointer).squarePulseTrainDelay + (signalobjects(pointer).squarePulseTrainWidth + signalobjects(pointer).squarePulseTrainISI) * ...
%     (signalobjects(pointer).squarePulseTrainNumber - 1);
%TO070605C - Rising = delay : isi : delay + isi * number
risingEdgesInTime = signalobjects(pointer).squarePulseTrainDelay : signalobjects(pointer).squarePulseTrainISI : ...
    signalobjects(pointer).squarePulseTrainDelay + signalobjects(pointer).squarePulseTrainISI * ...
    (signalobjects(pointer).squarePulseTrainNumber - 1);%TO072105B - The -1 accounts for the first one, which is a given.
if isempty(risingEdgesInTime) && signalobjects(pointer).squarePulseTrainISI == 0
    risingEdgesInTime = signalobjects(pointer).squarePulseTrainDelay;
end
risingEdgesInSamples = risingEdgesInTime * signalobjects(pointer).sampleRate;%The +1 accounts for time 0. - REMOVED TO080905C
risingEdgesInSamples = risingEdgesInSamples(find(risingEdgesInSamples <= length(data)));%Trim any that come in beyond the requested data.
risingEdgesInSamples = ceil(risingEdgesInSamples);
%TO081005A - When the delay is 0, the pulse technically starts at time 0, which must be bumped into sample 1. -- Tim O'Connor 8/10/05
if ~isempty(risingEdgesInSamples)
    if risingEdgesInSamples(1) == 0
        risingEdgesInSamples(1) = 1;
    end
end

%TO053108A
if signalobjects(pointer).squarePulseTrainWidth == Inf
    fallingEdgesInSamples = length(data);
else
    %Falling = width + delay : isi : delay + (width + isi) * number + width
    % fallingEdgesInTime = signalobjects(pointer).squarePulseTrainWidth + signalobjects(pointer).squarePulseTrainDelay : signalobjects(pointer).squarePulseTrainWidth + ...
    %     signalobjects(pointer).squarePulseTrainISI : signalobjects(pointer).squarePulseTrainDelay + (signalobjects(pointer).squarePulseTrainWidth + ...
    %     signalobjects(pointer).squarePulseTrainISI) * (signalobjects(pointer).squarePulseTrainNumber - 1) + signalobjects(pointer).squarePulseTrainWidth;
    %TO070605C - Falling = width + delay : isi : delay + isi * number + width
    fallingEdgesInTime = signalobjects(pointer).squarePulseTrainWidth + signalobjects(pointer).squarePulseTrainDelay : ...
        signalobjects(pointer).squarePulseTrainISI : signalobjects(pointer).squarePulseTrainDelay + signalobjects(pointer).squarePulseTrainWidth + ...
        signalobjects(pointer).squarePulseTrainISI * (signalobjects(pointer).squarePulseTrainNumber - 1);%TO072105B - The -1 accounts for the first one, which is a given.
    if isempty(fallingEdgesInTime) && signalobjects(pointer).squarePulseTrainISI == 0
        fallingEdgesInTime = signalobjects(pointer).squarePulseTrainWidth + signalobjects(pointer).squarePulseTrainDelay;
    end
    fallingEdgesInSamples = fallingEdgesInTime * signalobjects(pointer).sampleRate;%The +1 accounts for time 0. - REMOVED TO080905C
    fallingEdgesInSamples = fallingEdgesInSamples(find(fallingEdgesInSamples <= length(data)));%Trim any that come in beyond the requested data.
    fallingEdgesInSamples = ceil(fallingEdgesInSamples) - 1;%TO081205A Inserted a -1 to remove falling edge from indexing.
    fallingEdgesInSamples(find(fallingEdgesInSamples == 0)) = 1;%TO081205A - The -1 may cause spurious zeros.
end

if length(risingEdgesInSamples) - length(fallingEdgesInSamples) == 1
    %Force a final down transition.
    fallingEdgesInSamples(length(fallingEdgesInSamples) + 1) = length(data);
elseif length(risingEdgesInSamples) > length(fallingEdgesInSamples)
    %When would this case ever occur?
    fallingEdgesInSamples(length(fallingEdgesInSamples) + 1 : length(risingEdgesInSamples)) = length(data);
    warning('Unexpected rising edges found while generating signal data.');
end

%TO033108D
if strcmpi(signalobjects(pointer).type, 'digitalPulseTrain')
    for i = 1 : length(risingEdgesInSamples)
%         fprintf(1, 'risingEdgesInSamples: %s - fallingEdgesInSamples: %s\n', num2str(risingEdgesInSamples(i)), num2str(fallingEdgesInSamples(i)));
        data(risingEdgesInSamples(i) : fallingEdgesInSamples(i)) = 1;
    end
else
    for i = 1 : length(risingEdgesInSamples)
%         fprintf(1, 'risingEdgesInSamples: %s - fallingEdgesInSamples: %s\n', num2str(risingEdgesInSamples(i)), num2str(fallingEdgesInSamples(i)));
        data(risingEdgesInSamples(i) : fallingEdgesInSamples(i)) = signalobjects(pointer).offset + signalobjects(pointer).amplitude;
    end
end

%TO060208F
if signalobjects(pointer).length ~= -1
    if size(data, 1) > size(data, 2)
        data = repmat(data, ceil(fullTime / time), 1);
    else
        data = repmat(data, 1, ceil(fullTime / time));
    end
end

%Force it to go back to baseline, no matter what.
if ~isempty(data)
    data(length(data)) = signalobjects(pointer).offset;
end

return;
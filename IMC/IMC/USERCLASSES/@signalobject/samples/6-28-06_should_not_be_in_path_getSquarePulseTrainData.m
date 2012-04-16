% SIGNAL/GETSQUAREPULSETRAINDATA - Create data for a squarePulseTrain type.
%
% SYNTAX
%  data = getSquarePulseTrainData(SIGNAL, time) - Gets (time / SIGNAL.sampleRate) datapoints of SIGNAL. If SIGNAL.length is not long enough
%                                    the appropriate number of points at SIGNAL.offset are returned.
%
% Changed:
%  2/3/05 Tim O'Connor (TO020305d): Added the noPadding variable.
%  Added the squarePulseTrain type, to simply port over the parameters from the original Physiology software. -- Tim O'Connor 5/2/05 TO050205A
%
% Created 8/19/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function data = getSquarePulseTrainData(this, time, varargin)
global signalobjects;

pointer = indexOf(this);

samples = ceil(time * signalobjects(pointer).sampleRate);

data = ones(samples, 1) * signalobjects(this.ptr).offset;

%Rising = delay : width + isi : delay + (width + isi) * number
risingEdgesInTime = signalobjects(pointer).squarePulseTrainDelay : signalobjects(pointer).squarePulseTrainWidth + signalobjects(pointer).squarePulseTrainISI : ...
    signalobjects(pointer).squarePulseTrainDelay + (signalobjects(pointer).squarePulseTrainWidth + signalobjects(pointer).squarePulseTrainISI) * ...
    (signalobjects(pointer).squarePulseTrainNumber - 1);
risingEdgesInSamples = risingEdgesInTime * signalobjects(pointer).sampleRate + 1;%The +1 accounts for time 0.
risingEdgesInSamples = risingEdgesInSamples(find(risingEdgesInSamples <= length(data)));%Trim any that come in beyond the requested data.
risingEdgesInSamples = ceil(risingEdgesInSamples);

%Falling = width + delay : width + isi : delay + (width + isi) * number + width
fallingEdgesInTime = signalobjects(pointer).squarePulseTrainWidth + signalobjects(pointer).squarePulseTrainDelay : signalobjects(pointer).squarePulseTrainWidth + ...
    signalobjects(pointer).squarePulseTrainISI : signalobjects(pointer).squarePulseTrainDelay + (signalobjects(pointer).squarePulseTrainWidth + ...
    signalobjects(pointer).squarePulseTrainISI) * (signalobjects(pointer).squarePulseTrainNumber - 1) + signalobjects(pointer).squarePulseTrainWidth;
fallingEdgesInSamples = fallingEdgesInTime * signalobjects(pointer).sampleRate + 1;%The +1 accounts for time 0.
fallingEdgesInSamples = fallingEdgesInSamples(find(fallingEdgesInSamples <= length(data)));%Trim any that come in beyond the requested data.
fallingEdgesInSamples = ceil(fallingEdgesInSamples);

if length(risingEdgesInSamples) - length(fallingEdgesInSamples) == 1
    %Force a final down transition.
    fallingEdgesInSamples(length(fallingEdgesInSamples) + 1) = length(data);
elseif length(risingEdgesInSamples) > length(fallingEdgesInSamples)
    %When would this case ever occur?
    fallingEdgesInSamples(length(fallingEdgesInSamples) + 1 : length(risingEdgesInSamples)) = length(data);
    warning('Unexpected rising edges found while generating signal data.');
end

for i = 1 : length(risingEdgesInSamples)
% fprintf(1, '%s - %s\n', num2str(risingEdgesInSamples(i)), num2str(fallingEdgesInSamples(i)));
    data(risingEdgesInSamples(i) : fallingEdgesInSamples(i)) = signalobjects(pointer).offset + signalobjects(pointer).amplitude;
end

%Force it to go back to baseline, no matter what.
if ~isempty(data)
    data(length(data)) = signalobjects(pointer).offset;
end

return;
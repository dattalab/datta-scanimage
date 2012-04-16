% @signalobject/getStepFcnData - Create data for a stepFcn type.
%
% SYNTAX
%  data = getStepFcnData(SIGNAL, time) - Gets (time / SIGNAL.sampleRate) datapoints of SIGNAL. If SIGNAL.length is not long enough
%                                    the appropriate number of points at SIGNAL.offset are returned.
%
% CHANGED
%
% Created 6/11/10 - Tim O'Connor
% Copyright - Northwestern University/Howard Hughes Medical Institute 2010
function data = getStepFcnData(this, time, varargin)
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
        time = signalobjects(pointer).length;
    end
end

samples = ceil(time * signalobjects(pointer).sampleRate);
data = ones(samples, 1) * signalobjects(pointer).offset;

onsetSamples = ceil(signalobjects(pointer).stepFcnOnsetTimes * signalobjects(pointer).sampleRate);
widthsInSamples = ceil(signalobjects(pointer).stepFcnWidths * signalobjects(pointer).sampleRate);

if length(onsetSamples) == 1
    onsetSamples = onsetSamples * ones(size(widthsInSamples));
end
if length(widthsInSamples) == 1
    widthsInSamples = widthsInSamples * ones(size(onsetSamples));
end
if length(signalobjects(pointer).amplitude) == 1
    amplitudes = signalobjects(pointer).amplitude * ones(size(onsetSamples));
else
    amplitudes = signalobjects(pointer).amplitude;
end

for i = 1 : length(onsetSamples)
    data(onsetSamples(i) : min(onsetSamples(i) + widthsInSamples(i), length(data))) = amplitudes(i);
end

%Force it to go back to baseline, no matter what.
if ~isempty(data)
    data(length(data)) = signalobjects(pointer).offset;
end

return;
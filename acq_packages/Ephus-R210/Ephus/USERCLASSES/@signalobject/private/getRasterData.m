% SIGNAL/GETRASTERDATA - Create data for a raster type.
%
% SYNTAX
%  data = getRasterData(SIGNAL, time) - Gets (time / SIGNAL.sampleRate) datapoints of SIGNAL. If SIGNAL.length is not long enough
%                                       the appropriate number of points at SIGNAL.offset are returned.
%
% CHANGES
%
% Created 12/08/09 - Tim O'Connor
% Copyright - Northwestern University/Howard Hughes Medical Institute 2009
function data = getRasterData(this, time, varargin)
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

%Determine some common parameters.
samples = ceil(time * signalobjects(pointer).sampleRate);
samplesPerLine = ceil(signalobjects(pointer).sampleRate / signalobjects(pointer).frequency);
samplesPerFrame = samplesPerLine * signalobjects(pointer).rasterLinesPerFrame;
delaySamples = ceil(signalobjects(pointer).phi * signalobjects(pointer).sampleRate / 1000);
fastAxis = strcmpi(signalobjects(pointer).rasterAxis, 'fast');

%Generate one scan line.
if fastAxis
    line = linspace(signalobjects(pointer).offset, signalobjects(pointer).amplitude, samplesPerLine);
else
    line = linspace(signalobjects(pointer).offset, signalobjects(pointer).amplitude, samplesPerFrame);
end

if (samples < samplesPerLine)
    %Prepend a delay and return the correct number of samples.
    data = cat(1, signalobjects(pointer).rasterPark * ones(1, delaySamples), line);
    data = data(1:samples);
elseif samples <= samplesPerFrame
    %Replicate out the data (if necessary), then prepend a delay, then return the correct number of samples.
    if fastAxis
        data = cat(2, signalobjects(pointer).rasterPark * ones(1, delaySamples), repmat(line, 1, ceil(samples / samplesPerLine)));
    else
        data = cat(2, signalobjects(pointer).rasterPark * ones(1, delaySamples), line);
    end
    data = data(1 : samples);
else
    %Replicate out the data (if necessary), then append an ISI lag, then replicate the data again, then prepend a delay, then return the correct number of samples.
    isiSamples = ceil(signalobjects(pointer).rasterInterFrameInterval * signalobjects(pointer).sampleRate / 1000);
    interFrameSamples = isiSamples - samplesPerFrame;
    if fastAxis
        line = repmat(line, 1, ceil(samples / samplesPerLine));
    end
    data = repmat(cat(2, line, signalobjects(pointer).rasterPark * ones(1, interFrameSamples)), 1, ceil(samples / (samplesPerFrame + interFrameSamples)));
    data = cat(2, signalobjects(pointer).rasterPark * ones(1, delaySamples), data);
    if signalobjects(pointer).rasterNumberOfFrames ~= -1 && signalobjects(pointer).rasterNumberOfFrames < samples / isiSamples
        data(signalobjects(pointer).rasterNumberOfFrames * samplesPerFrame + 1 : end) = signalobjects(pointer).rasterPark;
    end
    data = data(1:samples);
end

return;
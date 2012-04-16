% mapper_startMapSubsetCycle -  Creates pulses for a cycle that stimulates a subset of map pixels, with individual power/timing settings at each pixel, then starts the cycle.
%
% SYNTAX
%  mapper_startMapSubsetCycle(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth)
%  mapper_startMapSubsetCycle(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, pulseDest)
%  mapper_startMapSubsetCycle(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, pulseDest, cycleName)
%   pixelNumbers - An array indicating the indices of the pixels to be included in the cycle.
%                  The locations of these pixels are calculated from the currently selected map pattern along with the other mapper parameters.
%   amplitudes - The amplitudes for each pixel.
%                May be a vector, of the same length as pixelNumbers, or a scalar.
%   delay - The delay for the shutter/modulator pulse, in seconds.
%           The shutter is forced to be 2ms earlier.
%           May be a vector, of the same length as pixelNumbers, or a scalar.
%   width - The width for the shutter/modulator pulse, in seconds.
%           The shutter is forced to be 2ms longer.
%           May be a vector, of the same length as pixelNumbers, or a scalar.
%   pulseISI - The pulse isi, in seconds.
%              This is not equivalent to the pixel isi (which comes directly from the Mapper).
%              May be a vector, of the same length as pixelNumbers, or a scalar.
%   numberOfPulses - The number of shutter/modulator pulses per pixel.
%                    May be a vector, of the same length as pixelNumbers, or a scalar.
%   testPulseAmp - The amplitude of the ephys test pulse.
%   testPulseDelay - The delay of the ephys test pulse, in seconds.
%   testPulseWidth - The width of the test pulse, in seconds.
%   pulseDest - The directory (the pulse set, within the pulse directory) in which to place pulses.
%               The user will be prompted if this is not specified.
%               Ex: 'C:\Data\User1\pulses\MapSubsetCyclePulses'
%   cycleName - The name of the cycle to be created.
%               The user will be prompted if this is not specified.
%
% NOTES
%
% Created: Timothy O'Connor 3/14/09
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2009
function mapper_startMapSubsetCycle(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, varargin)

%Disable the pulseJacker while we make a new cycle.
if isprogram(progmanager, 'pulseJacker')
    pj = getGlobal(progmanager, 'hObject', 'pulseJacker', 'pulseJacker');
    if getLocal(progmanager, pj, 'enable')
        setLocalBatch(progmanager, pj, 'enable', 0);
        pulseJacker('enable_Callback', pj, [], pj);
    end
end

fprintf(1, 'Building cycle of a map subset...\n');
mapper_makeMapSubsetCycle(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, varargin{:});%This is where the real work is done.

mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
[pixelISI] = getLocalBatch(progmanager, mapperObj, 'isi');

fprintf(1, 'Configuring programs to use the new cycle...\n');
traceLength = numel(pixelNumbers) * pixelISI;

if isprogram(progmanager, 'ephys')
    ep = getGlobal(progmanager, 'hObject', 'ephys', 'ephys');
    setLocalBatch(progmanager, ep, 'traceLength', traceLength, 'selfTrigger', 0, 'externalTrigger', 1);
    if ~getLocal(progmanager, ep, 'startButton')
        ephys('externalTrigger_Callback', ep, [], ep);
    end
end
if isprogram(progmanager, 'stimulator')
    stim = getGlobal(progmanager, 'hObject', 'stimulator', 'stimulator');
    setLocalBatch(progmanager, stim, 'traceLength', traceLength, 'selfTrigger', 0, 'externalTrigger', 1);
    if ~getLocal(progmanager, stim, 'startButton')
        stimulator('externalTrigger_Callback', stim, [], stim);
    end
end
if isprogram(progmanager, 'acquirer')
    acq = getGlobal(progmanager, 'hObject', 'acquirer', 'acquirer');
    setLocalBatch(progmanager, acq, 'traceLength', traceLength, 'selfTrigger', 0, 'externalTrigger', 1);
    if ~getLocal(progmanager, acq, 'startButton')
        acquirer('externalTrigger_Callback', acq, [], acq);
    end
end

setLocalBatch(progmanager, pj, 'enable', 1);
pulseJacker('enable_Callback', pj, [], pj);

lm = loopManager;
set(lm, 'interval', traceLength, 'preciseTimeMode', 0, 'iterations', 1);

xsg_setSetID('MSUB');

fprintf(1, 'Storing mapper headers in mapSubsetCycle userdata header...\n');
mapperHeader = getHeaders(progmanager, mapperObj);
setUserDataHeaderValue(progmanager, 'mapSubsetCycle', 'mapper', mapperHeader.mapper.mapper);
header.pixelNumbers = pixelNumbers;
header.amplitudes = amplitudes;
header.delay = delay;
header.width = width;
header.pulseISI = pulseISI;
header.numberOfPulses = numberOfPulses;
header.testPulseAmp = testPulseAmp;
header.testPulseDelay = testPulseDelay;
header.testPulseWidth = testPulseWidth;
setUserDataHeaderValue(progmanager, 'mapSubsetCycle', 'parameters', header);

fprintf(1, 'Map subset cycle ready. Initiating cycle...\n');
start(lm);

return;
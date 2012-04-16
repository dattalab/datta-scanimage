% mapper_startCycleMap - Creates pulses for a series of cycled maps, then starts the cycle.
%
% SYNTAX
%  mapper_startCycleMap(amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth)
%  mapper_startCycleMap(amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, pulseDest)
%  mapper_startCycleMap(amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, pulseDest, cycleName)
%   amplitudes - The amplitudes for each step.
%   delay - The delay for the shutter/modulator pulse, in seconds.
%           The shutter is forced to be 2ms earlier.
%           May be a vector, of the same length as amplitudes, or a scalar.
%   width - The width for the shutter/modulator pulse, in seconds.
%           The shutter is forced to be 2ms longer.
%           May be a vector, of the same length as amplitudes, or a scalar.
%   pulseISI - The pulse isi, in seconds.
%              This is not equivalent to the pixel isi (which comes directly from the Mapper).
%              May be a vector, of the same length as amplitudes, or a scalar.
%   numberOfPulses - The number of shutter/modulator pulses per pixel, for each map.
%                    May be a vector, of the same length as amplitudes, or a scalar.
%   testPulseAmp - The amplitude of the ephys test pulse.
%   testPulseDelay - The delay of the ephys test pulse, in seconds.
%   testPulseWidth - The width of the test pulse, in seconds.
%   loopPadding - The extra time, beyond the map length, to wait in between loop intervals, in seconds.
%   pulseDest - The directory (the pulse set, within the pulse directory) in which to place pulses.
%               The user will be prompted if this is not specified.
%               Ex: 'C:\Data\User1\pulses\CycledMapPulses'
%   cycleName - The name of the cycle to be created.
%               The user will be prompted if this is not specified.
%
% NOTES
%
% CHANGES
%  TO031409B - Added more information to the header data. -- Tim O'Connor 3/14/09
%
% Created: Timothy O'Connor 6/1/08
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function mapper_startCycleMap(amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, loopPadding, varargin)

%Disable the pulseJacker while we make a new cycle.
if isprogram(progmanager, 'pulseJacker')
    pj = getGlobal(progmanager, 'hObject', 'pulseJacker', 'pulseJacker');
    if getLocal(progmanager, pj, 'enable')
        setLocalBatch(progmanager, pj, 'enable', 0);
        pulseJacker('enable_Callback', pj, [], pj);
    end
end

fprintf(1, 'Building cycle of maps...\n');
mapper_cycleMaps(amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, varargin{:});

mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
[pixelISI] = getLocalBatch(progmanager, mapperObj, 'isi');
mapPattern = mapper_getMapPattern(mapperObj);

fprintf(1, 'Configuring programs to use the new cycle...\n');
traceLength = numel(mapPattern) * pixelISI;

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
set(lm, 'interval', traceLength + loopPadding, 'preciseTimeMode', 0, 'iterations', length(amplitudes));

xsg_setSetID('MCYC');

fprintf(1, 'Storing mapper headers in mapCycle userdata header...\n');
mapperHeader = getHeaders(progmanager, mapperObj);
setUserDataHeaderValue(progmanager, 'mapCycle', 'mapper', mapperHeader.mapper.mapper);
%TO031409B
header.amplitudes = amplitudes;
header.delay = delay;
header.width = width;
header.pulseISI = pulseISI;
header.numberOfPulses = numberOfPulses;
header.testPulseAmp = testPulseAmp;
header.testPulseDelay = testPulseDelay;
header.testPulseWidth = testPulseWidth;
header.loopPadding = loopPadding;
setUserDataHeaderValue(progmanager, 'mapCycle', 'parameters', header);

fprintf(1, 'Cycle of maps is ready. Start it using the loopGUI.\n\n');

return;
function ephysAcc_updateAmpsAndSignals(hObject, varargin)

sampleRate = getLocal(progmanager, hObject, 'sampleRate');

amplifiers = getLocal(progmanager, hObject, 'amplifiers');
stimOn = getLocal(progmanager, hObject, 'stimOnArray');
acqOn = getLocal(progmanager, hObject, 'acqOn');
testPulses = getLocal(progmanager, hObject, 'testPulses');

outputChannelNames = {};
inputChannelNames = {};
time = [];
repetitions = Inf;

for i = 1 : length(amplifiers)
	if stimOn(i)
        %Configure the test pulse.
        duration = ephysAcc_getDuration(hObject, i);
        delay = 0.25 * duration;
        frequency = 1 / (2 * duration);
        time(length(time) + 1) = 2 * duration;
        
    end
    
    if acqOn(i)
    end
end
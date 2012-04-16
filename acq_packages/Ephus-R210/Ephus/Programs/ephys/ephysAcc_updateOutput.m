% ephysAcc_updateOutput - Configure the output for the ephysScope.
%
% SYNTAX
%  ephysAcc_updateOutput(hObject)
%  ephysAcc_updateOutput(hObject, ampIndex)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO070605D: Center the trace on the scope, by setting the delay to duration/2 instead of duration/4. -- Tim O'Connor 7/6/05
%  TO070705A: Switch from sweepDelay [s] to sweepRate [Hz]. -- Tim O'Connor 7/7/05
%  TO092605N: Set appropriate time scale for each (independent) scope object, based on the associated pulse. -- Tim O'Connor 9/26/05
%             NOT_YET_COMPLETED - Requires trimming of data to match the timing, and the time domains must be even multiples of one another.
%  TO092805A: Fixed problem with time/division on scope for non-stimulating/non-acquiring channels. -- Tim O'Connor 9/28/05
%  TO100705J: Optimization(s). -- Tim O'Connor 10/7/05
%  TO112205C: Allow per-channel event listeners. Implement all state/lifecycle listeners using the @CALLBACKMANAGER. -- Tim O'Connor 11/22/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO122205B: RepeatOutput must be an integer. -- Tim O'Connor 12/22/05
%  TO080906C: By popular demand, make the scope output run indefinitely. -- Tim O'Connor 8/9/06
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%  TO031010L - Make sure the longest duration is used for the determination of the xUnitsPerDiv. GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
%
% Created 3/31/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephysAcc_updateOutput(hObject, varargin)

amplifiers = getLocal(progmanager, hObject, 'amplifiers');
if isempty(varargin)
    indices = 1 : length(amplifiers);
else
    indices = varargin{1};
end

%TO100705J - Optimization.
[sampleRate, stimOn, acqOn, testPulses, sweepRate] = ...
    getLocalBatch(progmanager, hObject, 'sampleRate', 'stimOnArray', 'acqOnArray', 'testPulses', 'sweepRate');
sweepDelay = 1 / sweepRate;
% sampleRate = getLocal(progmanager, hObject, 'sampleRate');
% stimOn = getLocal(progmanager, hObject, 'stimOnArray');
% acqOn = getLocal(progmanager, hObject, 'acqOnArray');
% testPulses = getLocal(progmanager, hObject, 'testPulses');
% sweepDelay = 1 / getLocal(progmanager, hObject, 'sweepRate');%TO070705A

outputChannelNames = {};
inputChannelNames = {};

sc = getMain(progmanager, hObject, 'scopeObject');
pulseTime = 0;

%TO031010L - Make sure the longest duration is used for the determination of the xUnitsPerDiv. GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
for i = 1 : length(indices)
    if stimOn(i) && acqOn(i)
        pulseTime = max(pulseTime, 2 * ephysAcc_getDuration(hObject, indices(i)));
    end
end

for i = 1 : length(indices)
	if stimOn(i)
        %Configure the test pulse.
        duration = ephysAcc_getDuration(hObject, indices(i));
        amplitude = ephysAcc_getAmplitude(hObject, indices(i));

        %TO070605D: Center the trace on the scope, by setting the delay to duration/2 instead of duration/4. -- Tim O'Connor 7/6/05
        delay = 0.5 * duration;
        set(testPulses(indices(i)), 'SampleRate', sampleRate);

        squarePulse(testPulses(indices(i)), amplitude, 0, delay, duration);
        outputChannelNames{length(outputChannelNames) + 1} = getVComChannelName(amplifiers{i});%TO120205A
    end
    %TO092605N
    if acqOn(i)
        if ephysAcc_getDuration(hObject, i) > 0
            %set(sc, 'xUnitsPerDiv', 2 * ephysAcc_getDuration(hObject, i) / 10);
            set(sc, 'xUnitsPerDiv', pulseTime / 10);%TO031010L GS031010_REMOTE_DEBUG_SESSION
        end
    end
end


setLocal(progmanager, hObject, 'pulseTime', pulseTime);
if sweepDelay < pulseTime
    sweepDelay = pulseTime;
end
% set(aom, 'outputTime', sweepDelay);%TO070705A, TO100705I

repetitions = Inf;%TO080906C

% dm = getLocal(progmanager, hObject, 'daqmanager');%TO100705I
for i = 1 : length(outputChannelNames)
    setTaskProperty(daqjob('scope'), outputChannelNames{i}, 'samplingRate', sampleRate, ...
        'sampleMode', 'DAQmx_Val_ContSamps', 'everyNSamples', sampleRate * pulseTime, 'sampsPerChanToAcquire', sampleRate * pulseTime);
end

return;
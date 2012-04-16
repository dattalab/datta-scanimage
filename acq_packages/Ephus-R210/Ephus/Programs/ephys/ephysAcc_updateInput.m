% ephysAcc_updateInput - Configure the input for the ephysScope.
%
% SYNTAX
%  ephysAcc_updateInput(hObject)
%  ephysAcc_updateInput(hObject, ampIndex)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO070705A: Switch from sweepDelay [s] to sweepRate [Hz]. -- Tim O'Connor 7/7/05
%  TO092805C: Fixed typo ("samples"-->"samplesToPass"). -- Tim O'Connor 9/28/05
%  TO100705J: Optimization(s). -- Tim O'Connor 10/7/05
%  TO112205C: Allow per-channel event listeners. Implement all state/lifecycle listeners using the @CALLBACKMANAGER. -- Tim O'Connor 11/22/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%  TO032406F - Use a start ID to safely ignore superfluous calls to the amplifier state change listener function. -- Tim O'Connor 3/24/06
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% Created 3/31/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephysAcc_updateInput(hObject, varargin)

amplifiers = getLocal(progmanager, hObject, 'amplifiers');
if ~isempty(varargin)
    amplifiers = amplifiers(varargin{1});
end

%TO100705J - Optimization.
[sampleRate, sweepRate, acqOn] = getLocalBatch(progmanager, hObject, 'sampleRate', 'sweepRate', 'acqOnArray');
sweepDelay = 1 / sweepRate;
% sampleRate = getLocal(progmanager, hObject, 'sampleRate');
% sweepDelay = 1 / getLocal(progmanager, hObject, 'sweepRate');%TO070705A
% acqOn = getLocal(progmanager, hObject, 'acqOnArray');

inputChannelNames = {};

pulseTime = 0;
for i = 1 : length(amplifiers)
    if acqOn(i)
        pulseTime = max(pulseTime, 2 * ephysAcc_getDuration(hObject, i));
    end
end
setLocal(progmanager, hObject, 'pulseTime', pulseTime);
if sweepDelay < pulseTime
    sweepDelay = pulseTime;
end

job = daqjob('scope');
for i = 1 : length(amplifiers)
    try
        inputChannelNames = cat(1, inputChannelNames, getInputChannelNames(amplifiers{i}));%TO120205A
    catch
        inputChannelNames = cat(2, inputChannelNames, getInputChannelNames(amplifiers{i}));%TO120205A
    end
    if acqOn(i)
        scaledOutputChannel = get(amplifiers{i}, 'scaledOutputChannel');%TO120205A
        if sum(strcmp(inputChannelNames, scaledOutputChannel)) > 1
            inputChannelNames = {inputChannelNames{find(~strcmp(inputChannelNames, scaledOutputChannel))}};
        end
        %This one should get top priority, since it reduces the amount of data, possibly very significantly.
        bindDataPreprocessor(job, scaledOutputChannel, ...
            {@ephysAcc_trimData, round(sampleRate * pulseTime)}, ['ephysAcc_trimData-' num2str(getParent(hObject, 'figure'))]);
%         inputChannelNames{length(inputChannelNames) + 1} = get(amplifiers{i}, 'scaledOutputChannel');%TO120205A
    end
end

%TO070705A
samples = ceil(sampleRate * sweepDelay);
%samples = pulseTime * sampleRate + sweepDelay * sampleRate;
%if pulseTime + sweepDelay < 0.1
if sweepDelay < 0.1
    warning('ephys: Pulse time may be too short, scope display updates will be delayed, to prevent CPU lockup.');
    if pulseTime == 0
        %This is just a dummy placeholder value. 
        %Make it large, in case an acquisition with it is started, it won't hog the CPU.
        samples = 100000;
    else
        samples = samples * round(0.1 / pulseTime);
    end
end

samplesPerTrigger = samples * 4;%Under nimex, with a continuous acquisition, this is used as a buffer configuration parameter, nothing more.

for i = 1 : length(inputChannelNames)
    %There could be performance optimization here, for example by setting the SampleRate to 200 or something else that's low and keeping the SamplesAcquiredFcnCount low.
    %This relies on telegraphs for any Axopatch 200Bs to be on separate boards from the control/acquisition.
    setTaskProperty(job, inputChannelNames{i}, 'samplingRate', sampleRate, 'sampsPerChanToAcquire', samplesPerTrigger, 'everyNSamples', samples, 'sampleMode', 'DAQmx_Val_ContSamps');
end
for i = 1 : length(amplifiers)
    setTaskProperty(job, getScaledOutputChannelName(amplifiers{i}), 'samplingRate', sampleRate, 'sampsPerChanToAcquire', samplesPerTrigger, 'everyNSamples', samples, 'sampleMode', 'DAQmx_Val_ContSamps');
end

return;

%------------------------------------------------
function data = ephysAcc_trimData(samplesToPass, data)

if isempty(data)
    %Nothing to do...?
    return;
end

%TO092805C: Fixed typo ("samples"-->"samplesToPass"). -- Tim O'Connor 9/28/05
if samplesToPass > length(data)
    warning('ephysAcc_trimData: Expected %s samples, recieved %s.', num2str(samplesToPass), length(data));
    samplesToPass = length(data);
elseif samplesToPass < 1
    warning('ephysAcc_trimData: Expecting an invalid number of samples... Ignoring data.');
    return;
end

data = data(1 : samplesToPass);

return;

% %------------------------------------------------
% function instrumentedStop(hObject, ai, )
% 
% 'instrumentedStop'
% 
% ephysAcc_stop(hObject);
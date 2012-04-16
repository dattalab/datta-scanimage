% mapper_stimulatePoint - Execute one stimulation in a map.
%
% SYNTAX
%  mapper_stimulatePoint(hObject)
%
% USAGE
%  This is called to execute one stimulus.
%
% NOTES
%  See TO020206B (creation of this function).
%
% CHANGES
%  TO030706D: Add userFcn events for the mapper. -- Tim O'Connor 3/7/06
%  TO031206A: Pockels cell control has been moved entirely to the stimulator. -- Tim O'Connor 3/12/06
%  TO031306D: Getting the amplifiers from ephys is slow, get a numeric array instead. -- Tim O'Connor 3/13/06
%  TO033106E: Don't change the acqOn/stimOn settings. -- Tim O'Connor 3/31/06
%  TO111706E: Trigger through the @startmanager, don't use any program's start button (set them all to external trigger). -- Tim O'Connor 11/17/06
%  TO053108B - Allow the mapper to work without the usual 'Big 3' programs. -- Tim O'Connor 5/31/08
%  VI102608A: External trigger for daqjob is forced to be the first on its list -- Vijay Iyer 10/26/08
%
% Created 2/2/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_stimulatePoint(hObject)
% function mapper_stimulatePoint(hObject, xMirrorVoltage, yMirrorVoltage, pockelsTransmission)

%TO053108B - It appears that sampleRate was hardcoded in here, so use the variable instead.
[coeffs pockelsTransmission sampleRate shutterSignal pockelsSignal ephysPulse, pockelsSignal, shutterSignal, sampleRate] = getLocalBatch(progmanager, hObject, ...
    'coeffs', 'pockelsTransmission', 'sampleRate', 'shutterSignal', 'pockelsSignal', 'ephysPulse', 'pockelsSignal', 'shutterSignal', 'sampleRate');

if isprogram(progmanager, 'stimulator')
    stim = getGlobal(progmanager, 'hObject', 'stimulator', 'stimulator');
    stimChannels = getLocal(progmanager, stim, 'channels');
    [stimStimOnArray, channels] = getLocalBatch(progmanager, stim, 'stimOnArray', 'channels');%TO031306D
    for i = 1 : length(channels)
        if strcmpi(channels(i).channelName, 'xMirror')
            stimStimOnArray(i) = 0;
        elseif strcmpi(channels(i).channelName, 'yMirror')
            stimStimOnArray(i) = 0;
        end
    end
    setLocalBatch(progmanager, stim, 'sampleRate', sampleRate, 'selfTrigger', 0, 'externalTrigger', 1, 'stimOnArray', stimStimOnArray);%TO020206A
end

if isprogram(progmanager, 'acquirer')
    acq = getGlobal(progmanager, 'hObject', 'acquirer', 'acquirer');
    %acqChannels = getLocal(progmanager, acq, 'channels');%TO053108B - This seems to not be used.
    setLocalBatch(progmanager, acq, 'sampleRate', sampleRate, 'selfTrigger', 0, 'externalTrigger', 1);
end

if isprogram(progmanager, 'ephys')
    ephysObj = getGlobal(progmanager, 'hObject', 'ephys', 'ephys');
    ephysStimAcqOnArray = getLocal(progmanager, ephys, 'stimOnArray');%TO031306D
    ephysStimAcqOnArray(:) = 1;
    setLocalBatch(progmanager, ephysObj, 'sampleRate', sampleRate, 'selfTrigger', 0, 'externalTrigger', 1);%TO020206A %TO031306D %TO111706E
end

fireEvent(getUserFcnCBM, 'mapper:Stimulate');%TO030706D: Add userFcn events for the mapper. -- Tim O'Connor 3/7/06

%Implement duration. -- Tim O'Connor 1/26/06
%TO020206A - Duration has been abandonded (let individual programs determine it for themselves). -- Tim O'Connor 2/2/06

if isprogram(progmanager, 'acquirer')
    if ~getLocal(progmanager, acq, 'startButton')
        % fprintf(1, 'mapper_stimulatePoint: updating acq external trigger state...\n')
        acquirer('externalTrigger_Callback', acq, [], acq);
    end
end
if isprogram(progmanager, 'stimulator')
    if ~getLocal(progmanager, stim, 'startButton')
        % fprintf(1, 'mapper_stimulatePoint: updating stim external trigger state...\n')
        stimulator('externalTrigger_Callback', stim, [], stim);
    end
end
if isprogram(progmanager, 'ephys')
    %TO111706E
    if ~getLocal(progmanager, ephysObj, 'startButton')
        % fprintf(1, 'mapper_stimulatePoint: updating stim external trigger state...\n')
        ephys('externalTrigger_Callback', ephysObj, [], ephysObj);
    end
end

try      
    %VI102608A -- Force the acquisition @daqjob to use the 'first' external trigger
    if get(daqjob('acquisition'),'triggerDestinationIndex') ~= 1
        fprintf(1, 'Warning - The mapper presently requires that the ''first'' external trigger line be used, so this is being forced');
        trigDests = getTriggerDestinations(daqjob('acquisition'));
        setTriggerDestination(daqjob('acquisition'),trigDests{1});
    end
    %%%%%%%%%%%%%%%%%
    
    job = daqjob('acquisition');
    trigger(job);
catch
    warning('An error occurred while acquiring trace(s): %s', lasterr);
end

return;
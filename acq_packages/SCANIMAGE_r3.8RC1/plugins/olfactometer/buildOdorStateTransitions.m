function buildOdorStateTransitions(eventName, eventData)
global state gh;

state.olfactometer.odorPosition=1;

state.olfactometer.odorStateList;
state.olfactometer.odorTimeList;
state.olfactometer.odorFrameList;

state.olfactometer.triggerWave;
state.olfactometer.valveStatusWave;
state.olfactometer.nFrames;

state.olfactometer.odorStateList;

calculateFrameTimes;
overrideFrames(state.olfactometer.nFrames);

if ~exist('state.olfactometer.oldLastOdor','var')
    state.olfactometer.oldLastOdor= '';
end

%disp('Rebuilding olfactometer state values');
% gotta build stuff from the state.olfactometer struct

% need a list of the enabled ports
% could probably vectorize all of this...

enabledOdors = zeros(1,16);
state.olfactometer.nOdors=0;
for i=1:16
    enabledOdors(i) = state.olfactometer.(['valveEnable_' num2str(i)]);
end

%need to force enabling of the first odor
if ~any(enabledOdors)
    disp('LIKELY ERROR-  NO ENABLED ODORS!  enabling the first valve (blank)')
    state.olfactometer.valveEnable_1 = 1;
    updateGUIByGlobal('state.olfactometer.valveEnable_1');
    enabledOdors(1) = 1;
end

odors=[];
state.olfactometer.nOdors=0;
for i=1:16
    if enabledOdors(i)
        state.olfactometer.nOdors=state.olfactometer.nOdors+1;
        odors = [odors i] ;
    end
end

% make state arrays

msPerFrame = state.acq.linesPerFrame*state.acq.msPerLine;

% pull out frame information

frameLengthsMS = [];
state.olfactometer.nFrames = length(odors) * ...
    sum(state.olfactometer.frameSpecificationField_1 + ...
    state.olfactometer.frameSpecificationField_2+ ...
    state.olfactometer.frameSpecificationField_3+ ...
    state.olfactometer.frameSpecificationField_4);
state.olfactometer.totalMS=msPerFrame*state.olfactometer.nFrames;

for i=1:4
    frameLengthsMS = [frameLengthsMS state.olfactometer.(['frameSpecificationField_' num2str(i)]) * msPerFrame];
end

while (1) % the loop here is to insure that odors don't happen back to back
    if (state.olfactometer.randomize)
        orderOfOdors = randperm(length(odors));
    else
        orderOfOdors = 1:length(odors);
    end
    % build state lists
    state.olfactometer.odorStateList = [];
    state.olfactometer.odorTimeList = [];
    state.olfactometer.odorFrameList = [];
    
    state.olfactometer.odorStateListString = '';
    state.olfactometer.odorTimeListString = '';
    state.olfactometer.odorFrameListString = '';
    
    
    for i=1:length(odors)
            state.olfactometer.odorStateList = [state.olfactometer.odorStateList 0 odors(orderOfOdors(i)) 0 0];
            
            if strcmp(state.olfactometer.odorStateListString, '')
                state.olfactometer.odorStateListString = ['0;' num2str(odors(orderOfOdors(i))) ';0' ';0'];
            else
                state.olfactometer.odorStateListString = [state.olfactometer.odorStateListString ';0;' num2str(odors(orderOfOdors(i))) ';0' ';0'];
            end
        
        state.olfactometer.odorTimeList = [state.olfactometer.odorTimeList frameLengthsMS(1) frameLengthsMS(2) frameLengthsMS(3) frameLengthsMS(4) ];
        if strcmp(state.olfactometer.odorTimeListString, '')
            state.olfactometer.odorTimeListString = [num2str(frameLengthsMS(1)) ';' num2str(frameLengthsMS(2)) ';' num2str(frameLengthsMS(3)) ';' num2str(frameLengthsMS(4)) ];
        else
            state.olfactometer.odorTimeListString = [state.olfactometer.odorTimeListString ';' num2str(frameLengthsMS(1)) ';' num2str(frameLengthsMS(2)) ';' num2str(frameLengthsMS(3)) ';' num2str(frameLengthsMS(4)) ];
        end
        state.olfactometer.odorFrameList = [state.olfactometer.odorFrameList ...
            state.olfactometer.frameSpecificationField_1 ...
            state.olfactometer.frameSpecificationField_2 ...
            state.olfactometer.frameSpecificationField_3 ...
            state.olfactometer.frameSpecificationField_4 ];
        
        if strcmp(state.olfactometer.odorFrameListString, '')
            state.olfactometer.odorFrameListString = [ num2str(state.olfactometer.frameSpecificationField_1) ';' ...
                num2str(state.olfactometer.frameSpecificationField_2) ';' ...
                num2str(state.olfactometer.frameSpecificationField_3) ';' ...
                num2str(state.olfactometer.frameSpecificationField_4) ];
        else
            state.olfactometer.odorFrameListString = [state.olfactometer.odorFrameListString ';' ...
                num2str(state.olfactometer.frameSpecificationField_1) ';' ...
                num2str(state.olfactometer.frameSpecificationField_2) ';' ...
                num2str(state.olfactometer.frameSpecificationField_3) ';' ...
                num2str(state.olfactometer.frameSpecificationField_4) ];
        end
    end
    
    firstOdor = num2str(odors(orderOfOdors(1)));
    lastOdor = num2str(odors(orderOfOdors(end)));

    if strcmp(state.olfactometer.oldLastOdor,'')
        state.olfactometer.oldLastOdor = lastOdor;
        break
    elseif ~strcmp(firstOdor, state.olfactometer.oldLastOdor)
        state.olfactometer.oldLastOdor = lastOdor;
        break
    else
        keyboard
    end
end

%send order to arduino
% valve_string = mat2str(orderOfOdors-1);
% valve_string = strrep(valve_string, '[', '');
% valve_string = strrep(valve_string, ']', '');
% valve_string = strrep(valve_string, ' ', '');
state.olfactometer.arduino_string = arrayfun(@valvenum2hexstr, odors(orderOfOdors));
disp (['to arduino ' state.olfactometer.arduino_string])
fprintf(state.olfactometer.arduino, '%s\n', state.olfactometer.arduino_string);
disp(state.olfactometer.odorStateListString)

%make new pulses
makePulses(frameLengthsMS, odors(orderOfOdors));

%reload pulses
stim_on = getGlobal(progmanager, 'externalTrigger', 'stimulator', 'stimulator');
if stim_on == 1
    setGlobal(progmanager, 'externalTrigger', 'stimulator', 'stimulator', 0)
    stimulator('externalTrigger_Callback', stim_getHandle, [], guidata(stim_getHandle))
    setGlobal(progmanager, 'externalTrigger', 'stimulator', 'stimulator', 1)
    stimulator('externalTrigger_Callback', stim_getHandle, [], guidata(stim_getHandle))
end

acq_on = getGlobal(progmanager, 'externalTrigger', 'acquirer', 'acquirer');
if acq_on == 1
    setGlobal(progmanager, 'externalTrigger', 'acquirer', 'acquirer', 0)
    acquirer('externalTrigger_Callback', acq_getHandle, [], guidata(acq_getHandle))
    setGlobal(progmanager, 'externalTrigger', 'acquirer', 'acquirer', 1)
    acquirer('externalTrigger_Callback', acq_getHandle, [], guidata(acq_getHandle))
end

ephys_on = getGlobal(progmanager, 'externalTrigger', 'ephys', 'ephys');
if ephys_on == 1
    setGlobal(progmanager, 'externalTrigger', 'ephys', 'ephys', 0)
    ephys('externalTrigger_Callback', ephys_getHandle, [], guidata(ephys_getHandle))
    setGlobal(progmanager, 'externalTrigger', 'ephys', 'ephys', 1)
    ephys('externalTrigger_Callback', ephys_getHandle, [], guidata(ephys_getHandle))
end

if length(odors) > 0
    state.olfactometer.nextFrameTrigger = state.olfactometer.odorFrameList(state.olfactometer.odorPosition);
    state.olfactometer.miniCycleState = mod(state.olfactometer.odorPosition,4);
end


updateHeaderString('state.olfactometer')
updateHeaderString('state.olfactometer.odorTimeListString');
updateHeaderString('state.olfactometer.odorStateListString');
updateHeaderString('state.olfactometer.odorFrameListString');

% if any external trigger is engaged in stim, acq, or ephys, update the
% xsg file name, otherwise, make it empty.
acq_on =  getGlobal(progmanager, 'externalTrigger', 'acquirer', 'acquirer');
ephys_on =  getGlobal(progmanager, 'externalTrigger', 'ephys', 'ephys');
stim_on =  getGlobal(progmanager, 'externalTrigger', 'stimulator', 'stimulator');

if (acq_on || ephys_on || stim_on)
    state.xsgFilename = [xsg_getFilename() '.xsg'];
else
    state.xsgFilename = '';
end
updateHeaderString('state.xsgFilename');

if ~strcmp(state.files.baseName,'')
% write header string to txt
f=fopen([state.files.baseName zeroPadNum2Str(state.files.fileCounter) '_hdr.txt'], 'w+');
fprintf(f,'%s',state.headerString);
fprintf(f,'%s',['state.xsgFilename=''' state.xsgFilename '''']);
fclose(f);
end

%keyboard;
end

function makePulses(frameLengthsMS, orderedOdors)
global state

sample_rate = getGlobal(progmanager, 'sampleRate', 'ephys', 'ephys');
trace_length_in_samples = round(sum(frameLengthsMS) * length(orderedOdors) * sample_rate/1000); 
if trace_length_in_samples == 0
    return
end

stim_literal_pulse = zeros(1, trace_length_in_samples);
state_literal_pulse = zeros(1, trace_length_in_samples);

for i=1:length(orderedOdors)
    start = round( ((i-1) * sum(frameLengthsMS)*10) + frameLengthsMS(1)*10);
    stop = round( ((i-1) * sum(frameLengthsMS)*10) + sum(frameLengthsMS(1:2))*10);
    stim_literal_pulse(start:stop) = 10000;
    state_literal_pulse(start:stop) = orderedOdors(i)*1000;
end

stimPulse = signalobject('Name', 'olfactoTrigPulse', 'sampleRate', 10000);
literal(stimPulse, stim_literal_pulse);

statePulse = signalobject('Name', 'olfactoStatePulse', 'sampleRate', 10000);
literal(statePulse, state_literal_pulse);

allPulses = [stimPulse, statePulse];

destdir = 'C:\scanimage_conf\olfactoPulses\olfactoPulses';

for signal = allPulses
    saveCompatible(fullfile(destdir, [get(signal, 'Name') '.signal']), 'signal', '-mat');
end

delete(allPulses)

% set acquierer, ephys, and stim trace lengths
ephys_setTraceLength(ceil(trace_length_in_samples/sample_rate));
acq_setTraceLength(ceil(trace_length_in_samples/sample_rate));
stim_setTraceLength(ceil(trace_length_in_samples/sample_rate));

end
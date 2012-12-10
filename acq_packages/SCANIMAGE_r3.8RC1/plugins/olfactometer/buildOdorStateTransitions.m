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

odors;

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

while (1)
    orderOfOdors = randperm(length(odors));
    
    % build state lists
    state.olfactometer.odorStateList = [];
    state.olfactometer.odorTimeList = [];
    state.olfactometer.odorFrameList = [];
    
    state.olfactometer.odorStateListString = '';
    state.olfactometer.odorTimeListString = '';
    state.olfactometer.odorFrameListString = '';
    
    
    for i=1:length(odors)
        if (state.olfactometer.randomize)
            state.olfactometer.odorStateList = [state.olfactometer.odorStateList 0 odors(orderOfOdors(i)) 0 0];
            
            if strcmp(state.olfactometer.odorStateListString, '')
                state.olfactometer.odorStateListString = ['0;' num2str(odors(orderOfOdors(i))) ';0' ';0'];
            else
                state.olfactometer.odorStateListString = [state.olfactometer.odorStateListString ';0;' num2str(odors(orderOfOdors(i))) ';0' ';0'];
            end
        else
            state.olfactometer.odorStateList = [state.olfactometer.odorStateList 0 odors(i) 0 0];
            if strcmp(state.olfactometer.odorStateListString, '')
                state.olfactometer.odorStateListString = ['0;' num2str(odors(i)) ';0' ';0'];
            else
                state.olfactometer.odorStateListString = [state.olfactometer.odorStateListString ';0;' num2str(odors(i)) ';0' ';0'];
            end
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
    
    if (state.olfactometer.randomize)
        firstOdor = num2str(odors(orderOfOdors(1)));
        lastOdor = num2str(odors(orderOfOdors(end)));
    else
        firstOdor = num2str(odors(1));
        lastOdor = num2str(odors(end));
    end
    
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

if length(odors) > 0
    state.olfactometer.nextFrameTrigger = state.olfactometer.odorFrameList(state.olfactometer.odorPosition);
    state.olfactometer.miniCycleState = mod(state.olfactometer.odorPosition,4);
end


updateHeaderString('state.olfactometer')
updateHeaderString('state.olfactometer.odorTimeListString');
updateHeaderString('state.olfactometer.odorStateListString');
updateHeaderString('state.olfactometer.odorFrameListString');

state.xsgFilename = [xsg_getFilename() '.xsg'];
updateHeaderString('state.xsgFilename');

if ~strcmp(state.files.baseName,'')
% write header string to txt
f=fopen([state.files.baseName zeroPadNum2Str(state.files.fileCounter) '_hdr.txt'], 'w+');
fprintf(f,'%s',state.headerString);
fprintf(f,'%s',['state.xsgFilename=''' state.xsgFilename '''']);
fclose(f);
end

end
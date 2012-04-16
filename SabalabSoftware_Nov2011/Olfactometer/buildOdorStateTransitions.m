function buildOdorStateTransitions(vargin)
global state gh;

state.olfactometer.odorPosition=1;
state.olfactometer.odorStateList;
state.olfactometer.odorTimeList;
state.olfactometer.triggerWave;
state.olfactometer.valveStatusWave;
state.olfactometer.nFrames;

state.olfactometer.odorStateList;

%disp('Rebuilding olfactometer state values');
% gotta build stuff from the state.olfactometer struct

% need a list of the enabled ports
% could probably vectorize all of this...

enabledOdors = zeros(1,16);
state.olfactometer.nOdors=0;
for i=1:16
    enabledOdors(i) = state.olfactometer.(['valveEnable_' num2str(i)]);
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
orderOfOdors = randperm(length(odors));

% make state arrays

msPerFrame = state.acq.linesPerFrame*state.acq.msPerLine;

% pull out frame information

frameLengthsMS = [];
state.olfactometer.nFrames=state.olfactometer.frameSpecificationField_1+ ...
    length(odors) * sum(state.olfactometer.frameSpecificationField_2+ ...
    state.olfactometer.frameSpecificationField_3+ ...
    state.olfactometer.frameSpecificationField_4);
state.olfactometer.totalMS=msPerFrame*state.olfactometer.nFrames;

for i=1:4
    frameLengthsMS = [frameLengthsMS state.olfactometer.(['frameSpecificationField_' num2str(i)]) * msPerFrame];
end

% build state lists
state.olfactometer.odorStateList = [0];
state.olfactometer.odorTimeList = [frameLengthsMS(1)];
state.olfactometer.odorStateListString = '0';
state.olfactometer.odorTimeListString = num2str(frameLengthsMS(1));
state.olfactometer.odorFrameListString = num2str(state.olfactometer.frameSpecificationField_1);

for i=1:length(odors)
    if (state.olfactometer.randomize)
        state.olfactometer.odorStateList = [state.olfactometer.odorStateList 0 odors(orderOfOdors(i)) 0 ];
        state.olfactometer.odorStateListString = [state.olfactometer.odorStateListString ';0;' num2str(odors(orderOfOdors(i))) ';0'];
    else
        state.olfactometer.odorStateList = [state.olfactometer.odorStateList 0 odors(i) 0 ];
        state.olfactometer.odorStateListString = [state.olfactometer.odorStateListString ';0;' num2str(odors(i)) ';0'];
    end
    
    state.olfactometer.odorTimeList = [state.olfactometer.odorTimeList frameLengthsMS(2) frameLengthsMS(3) frameLengthsMS(4) ];
    state.olfactometer.odorTimeListString = [state.olfactometer.odorTimeListString ';' num2str(frameLengthsMS(2)) ';' num2str(frameLengthsMS(3)) ';' num2str(frameLengthsMS(4)) ];
    
    state.olfactometer.odorFrameListString = [state.olfactometer.odorFrameListString ';' ...
        num2str(state.olfactometer.frameSpecificationField_2) ';' ...
        num2str(state.olfactometer.frameSpecificationField_3) ';' ...
        num2str(state.olfactometer.frameSpecificationField_4) ];
    
end

updateheaderString('state.olfactometer.odorTimeListString');
updateheaderString('state.olfactometer.odorStateListString');
updateheaderString('state.olfactometer.odorFrameListString');

end
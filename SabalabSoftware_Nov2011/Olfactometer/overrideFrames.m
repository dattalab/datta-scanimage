function overrideFrames(newFrameNumber)
global state gh;

state.cycle.frames=newFrameNumber;
state.cycle.framesList(state.cycle.currentCyclePosition)=newFrameNumber;
updateGuiByGlobal('state.acq.numberOfFrames');
updateGUIByGlobal('state.cycle.frames');
updateGUIByGlobal('state.cycle.framesList');

state.cycle.recordingDuration=state.olfactometer.totalMS/1000;
state.cycle.recordingDurationList(state.cycle.currentCyclePosition)=state.olfactometer.totalMS/1000;
updateGUIByGlobal('state.cycle.recordingDuration');
updateGUIByGlobal('state.cycle.recordingDurationList');

state.cycle.delay=ceil(state.olfactometer.totalMS/1000)+1;
state.cycle.delayList(state.cycle.currentCyclePosition)=ceil(state.olfactometer.totalMS/1000)+1;
updateGUIByGlobal('state.cycle.delay');
updateGUIByGlobal('state.cycle.delayList');

applyAdvancedCyclePosition;
applyChangesToOutput;
timerCallPackageFunctions('CycleChanged');
end
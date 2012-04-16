function olfactometer_refresh(vargin)
global state;
calculateFrameTimes();
buildOdorStateTransitions();
overrideFrames(state.olfactometer.nFrames);
acq_setTraceLength(state.acq.numberOfFrames / state.acq.frameRate);
end

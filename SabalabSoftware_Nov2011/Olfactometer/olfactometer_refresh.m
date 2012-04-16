function olfactometer_refresh(vargin)
global state;
calculateFrameTimes();
buildOdorStateTransitions();
overrideFrames(state.olfactometer.nFrames);
end

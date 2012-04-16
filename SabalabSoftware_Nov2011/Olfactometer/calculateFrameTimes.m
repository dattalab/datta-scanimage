function calculateFrameTimes()
global state gh;

state.acq.linesPerFrame;
state.acq.msPerLine;

msPerFrame = state.acq.linesPerFrame*state.acq.msPerLine;

for i=1:4
    state.olfactometer.(['frameSpecificationRealTimes_' num2str(i)]) = ...
        [num2str(state.olfactometer.(['frameSpecificationField_' num2str(i)]) * msPerFrame / 1000 ) ' sec'];
    updateGUIByGlobal(['state.olfactometer.frameSpecificationRealTimes_' num2str(i)]);
end



end
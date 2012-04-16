function olfactometerCycleFunction()
global state gh;


calculateFrameTimes;

% build general odor transition logic
buildOdorStateTransitions();

% insure the right amount of frames to be imaged
if (state.cycle.framesList(state.cycle.currentCyclePosition) ~= ...
           state.olfactometer.nFrames)
       overrideFrames(state.olfactometer.nFrames);
end

% insure that the aux outputs are enabled with a blank pulse so that
% the code knows to build enough channels.  fill them with 1's

olfAux = zeros(1,4);
olfAux(state.olfactometer.valveStatusDAValue)=1;
olfAux(state.olfactometer.triggerDAValue)=1;

for i=1:4 % 4 possible aux cycles to be used
    if (olfAux(i))
        state.cycle.(['aux' num2str(i+3)]) = 1;
        state.cycle.(['aux' num2str(i+3) 'List'])(state.cycle.currentCyclePosition) = 1;
        updateGUIByGlobal(['state.cycle.aux' num2str(i+3)]);
    end
end

% putDataGrab has a section for overwriting the aux data
% note that only works when both imaging and phys is on...


end
function overrideFrames(newFrameNumber)
global state gh;

state.acq.numberOfFrames = newFrameNumber;
updateGUIByGlobal('state.acq.numberOfFrames');

end

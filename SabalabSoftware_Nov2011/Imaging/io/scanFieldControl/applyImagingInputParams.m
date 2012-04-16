function applyImagingInputParams
global state
if state.analysisMode
    resetImageProperties;
else
    
   %AJG EDIT force deletion of the grab input...
    evalin('base','delete(grabInput)');
    global grabInput;
    grabInput = analoginput('nidaq',state.init.acquisitionBoardIndex);
	set(grabInput, 'SampleRate', state.acq.inputRate);
	set(grabInput, 'SamplesAcquiredFcn', {'makeFrameByStripes'});
    set(grabInput, 'TriggerType', 'Manual');
    set(grabInput, 'ExternalTriggerDriveLine', 'RTSI0');
    set(grabInput, 'ManualTriggerHwOn', 'Trigger');

    setupInputChannels;
    preallocateMemory;
    resetImageProperties(0);
    resetCounters;
end
updateHeaderString('state.acq.pixelsPerLine');
updateHeaderString('state.acq.fillFraction');

updateImageGUI;
updateClim;

state.internal.fractionStart = (...
    (state.acq.lineDelay-state.acq.mirrorLag)/state.acq.msPerLine*state.internal.samplesPerLine) / state.internal.samplesPerLine;
state.internal.fractionEnd = state.internal.fractionStart + (state.acq.samplesAcquiredPerLine-1) / state.internal.samplesPerLine;
state.internal.fractionPerPixel=(state.internal.fractionEnd - state.internal.fractionStart)/state.acq.pixelsPerLine;



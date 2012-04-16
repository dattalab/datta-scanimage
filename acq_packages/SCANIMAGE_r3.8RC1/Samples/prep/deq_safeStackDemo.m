function deq_safeStackDemo(eventName,eventData)
%% SAFESTACKCALLBACK 
	global state;
	
	persistent numRepeats;
	if isempty(numRepeats)
		numRepeats = 0;
	end
	
	persistent init;
	if isempty(init)
		init = false;
	end
	
	% ensure we're actually collecting a stack
	if state.acq.numberOfZSlices == 1
        return; % do nothing
	else
		% 'zSliceCounter' gets updated before events are generated, but we're interested in the previous value
		zSliceCounter = state.internal.zSliceCounter - 1;
	end
	
	switch eventName
		case 'acquisitionStarting'
			% allocate the necessary memory
			state.acq.referenceSlice = cell(1,state.init.maximumNumberOfInputChannels);
            for channelCounter = 1:state.init.maximumNumberOfInputChannels
                state.acq.referenceSlice{channelCounter} = zeros(state.internal.storedLinesPerFrame,state.acq.pixelsPerLine,'uint16');
			end
			numRepeats = 0;
			
		case 'frameAcquired'
			if zSliceCounter == 0 && ~init
				% this is the first time through, so store the reference
				% slice that all subsequent slices will be compared to.
				for channelCounter = 1:state.init.maximumNumberOfInputChannels
					state.acq.referenceSlice{channelCounter} = state.acq.acquiredData{1}{channelCounter};
				end
				init = true;
			else
				if ~isSliceValid(state.acq.acquiredData{1})
					handleInvalidSlice(numRepeats);
					numRepeats = numRepeats + 1;
					state.hSI.flagListenerAbort();
				else
					numRepeats = 0;
				end
			end
	end
	
end

function isValid = isSliceValid(sliceData)
	% This is where a user would implement logic to determine if the
	% just-collected slice is valid.  For now, we'll just roll the dice.
	
	if rand() < 0.7
		isValid = true;
	else
		disp('Invalid slice!');
		isValid = false;
	end
	
end

function handleInvalidSlice(repeatNumber)
	global state;
	
	MAX_REPEATS = 2;
	
	% we have an invalid slice--repeat the slice
	if repeatNumber < MAX_REPEATS
		setStatusString('Repeating Slice...');
		
		state.internal.frameCounter = 1;
		updateGUIByGlobal('state.internal.frameCounter');
		
		setStatusString('Acquiring...');
		flushAOData();
		
		% move the stage back one step
		motorFinishMove();
		state.motor.absZPosition = state.internal.initialMotorPosition(3) - state.acq.stackCenteredOffset + state.acq.zStepSize * (state.internal.zSliceCounter - 1);
		motorUpdatePositionDisplay();
		try 
			motorStartMove();
		catch ME
			state.motor.absZPosition = state.motor.absZPosition - state.acq.zStepSize; %restore to previous value if move failed to start    
			motorUpdatePositionDisplay();
			ME.rethrow();
		end
		
		motorFinishMove();
		
		notify(state.hSI,'sliceDone'); %VI100410A
		
		try; startGrab; catch; end
			openShutter;
			dioTrigger;
	else
		disp('The number of safe-stack repeats has exceeded the maximum number of attempts.');
		abortCurrent();
	end
end
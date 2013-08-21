function olfactometerFrameFunction(eventName, eventData)
global state;

lastFrame = state.internal.frameCounter +1;
nextFrameTrigger = state.olfactometer.nextFrameTrigger;

state.olfactometer.miniCycleState = mod(state.olfactometer.odorPosition,4);
if ~state.olfactometer.miniCycleState % if we're in an ISI state
    if (lastFrame == (nextFrameTrigger - 1)) 
        % on the last ISI frame now so open the shutter in prep for imaging
        openShutter
    elseif state.shutter.shutterOpen && (nextFrameTrigger - lastFrame > 1) 
         % not on the last frame, and the shutter is open so close
        closeShutter
    end
end

try
nextOdorState = state.olfactometer.odorStateList(state.olfactometer.odorPosition+1);
catch
nextOdorState = 0;
end
if (lastFrame >= nextFrameTrigger)
    disp(['new state (' num2str(nextOdorState) ') entered at frame = ' num2str(lastFrame) '; time = ' num2str(lastFrame/state.acq.frameRate)])
    %incrementOdorByTrigger()
    
    % increment the nextFrameTrigger 
    % (is reset by buildOdorStateTransitions)
    if state.olfactometer.odorPosition <= numel(state.olfactometer.odorStateList)
        state.olfactometer.nextFrameTrigger = ...
            nextFrameTrigger + ...
            state.olfactometer.odorFrameList(state.olfactometer.odorPosition);
    end
    
end
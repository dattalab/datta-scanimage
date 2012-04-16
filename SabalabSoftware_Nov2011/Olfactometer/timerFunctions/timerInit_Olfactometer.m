function timerInit_Olfactometer
    global state gh
	%initOlfactometer('', state.analysisMode)
	% model after initPhys
    % need to read in ini, connect to olfactometer, and build basic state
    % transitions and waves, turn on flow rates, etc.
    
	if ~state.analysisMode
		h=waitbar(0,'Initializing Olfactometer');
	else
		h=waitbar(0,'Initializing Olfactometer in Analysis Mode');
    end	

    %build the gui handles and launch the gui all at once
    gh.olfactometer = guihandles(olfactometer);

	waitbar(.1,h);
	
	openini('olfactometer.ini');
	
	waitbar(.2,h,'Connecting to olfactometer and setting flowrates...');
    
    % connect to olfactometer and set basic flow rates?
    initOlfactometer();
    
    waitbar(1,h);
    
    close(h);

    % build struct of valvePosition guihandles for updating GUI during odor
    % delivery in a cycle
    
    valveChildren = get(gh.olfactometer.valvePanel, 'Children');
    state.olfactometer.valveButtonGUIHandles = [];
    for i=1:length(valveChildren)
        if (strfind(get(valveChildren(i), 'Tag'), 'valveRadioButton')>0)
            state.olfactometer.valveButtonGUIHandles = [state.olfactometer.valveButtonGUIHandles valveChildren(i)];
        end
    end
    state.olfactometer.valveButtonGUIHandles = fliplr(state.olfactometer.valveButtonGUIHandles);
    state.olfactometer.currentValve = 1;
    
    
  % odor valve state variables
 % these are edited/filled by buildOdorStateTransitions
 
  state.olfactometer.odorPosition=1;
  state.olfactometer.odorStateList=[];
  state.olfactometer.odorTimeList=[];
  state.olfactometer.triggerWave=[];
  state.olfactometer.valveStatusWave=[];
  state.olfactometer.nFrames=0;
  state.olfactometer.totalMS=0;
 
end
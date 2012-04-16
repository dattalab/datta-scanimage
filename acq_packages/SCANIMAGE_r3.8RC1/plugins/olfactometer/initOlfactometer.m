function initOlfactometer
    global state gh
    % need to read in ini, connect to olfactometer, and build basic state
    % transitions and waves, turn on flow rates, etc.
    
    h=waitbar(0,'Initializing Olfactometer');

    %build the gui handles and launch the gui all at once
    %gh.olfactometer = guihandles(olfactometer);
    gh=setfield(gh,'olfactometer', guidata(olfactometer));     
	waitbar(.1,h);
	
	%openini('olfactometer.ini');
	initguis('olfactometer.ini');
    
	waitbar(.2,h,'Connecting to olfactometer and setting flowrates...');
    
    % connect to olfactometer and set basic flow rates
    connectToOlfactometer();
    updateMFCRates();
    %initOlfactometerTasks();
    
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
  state.olfactometer.odorFrameList=[];
  state.olfactometer.triggerWave=[];
  state.olfactometer.valveStatusWave=[];
  state.olfactometer.nFrames=0;
  state.olfactometer.totalMS=0;
 
  
end
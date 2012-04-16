function startFocus
	global state
	global focusInput focusOutput pcellFocusOutput
	
	state.internal.status=2;
	state.internal.lastTaskDone=2;
    
	putDataFocus

	start(focusOutput);
	if state.pcell.pcellOn
		start(pcellFocusOutput);
    end
    
	start(focusInput);
%	trigger(focusInput);


 
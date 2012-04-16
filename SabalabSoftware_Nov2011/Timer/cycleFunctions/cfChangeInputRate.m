function cfChangeInputRate(rate)
	global state
	
	state.phys.settings.inputRate=rate;
	updateGuiByGlobal('state.phys.settings.inputRate');
	
	
function setTilerStatusString(st)
	global gh state
	
	state.tiler.statusString=st;
	updateGuiByGlobal('state.tiler.statusString');

function makeNewSawToothMirrorOutput
	global state
	
	state.internal.lengthOfXData = state.acq.actualOutputRate*state.acq.msPerLine/1000;  %AJG changed this so it was floored throughout THIS function.  
                                                                                         % this is for the 2.5ms scan line workaround
	state.internal.lineDelay = state.acq.lineDelay/state.acq.msPerLine;
	state.internal.flybackDecimal = 1-state.acq.fillFraction-state.internal.lineDelay;
	
	state.internal.startOutputColumnInLine=1;
	state.internal.endOutputColumnInLine=round(floor(state.internal.lengthOfXData)*(1-state.internal.flybackDecimal))+1;
	
	state.internal.startOutputFractionInLine=(state.internal.startOutputColumnInLine-1)/floor(state.internal.lengthOfXData);
	state.internal.endOutputFractionInLine=(state.internal.endOutputColumnInLine-1)/floor(state.internal.lengthOfXData);
	
	oneSawTooth=zeros(1, floor(state.internal.lengthOfXData)+1);   
    oneSawTooth(state.internal.startOutputColumnInLine:state.internal.endOutputColumnInLine) = ...
		linspace(-1,1,state.internal.endOutputColumnInLine-state.internal.startOutputColumnInLine+1);
	
% 	avg=round((state.internal.startOutputColumnInLine+state.internal.endOutputColumnInLine)/2);
% 	oneSawTooth(state.internal.startOutputColumnInLine:avg) = -1;
% 	oneSawTooth(avg:state.internal.endOutputColumnInLine) = 1;
	
	
	% exponential flyback
	oneSawTooth(state.internal.endOutputColumnInLine:end) = 2 * exp(-[0:state.acq.tausInFlyback/(length(oneSawTooth)-state.internal.endOutputColumnInLine):state.acq.tausInFlyback])-1;
		
	% oneSawTooth(state.internal.endOutputColumnInLine:end) = ...
	% 	linspace(1,-1,floor(state.internal.lengthOfXData)-state.internal.endOutputColumnInLine+2);
	oneSawTooth=oneSawTooth(1:floor(state.internal.lengthOfXData));

    
    oneSawToothPlusOne = -1*ones(1,floor(state.internal.lengthOfXData)+1);
    oneSawToothPlusOne(1:floor(state.internal.lengthOfXData)) = oneSawTooth;
    
    twoSawTeeth= horzcat(oneSawTooth, oneSawToothPlusOne);
    
    if state.acq.dualLaserMode==1
    	if (floor(state.internal.lengthOfXData) == state.internal.lengthOfXData)
            state.acq.rawSawtoothMirrorOutput=repmat(oneSawTooth, 1, state.acq.linesPerFrame)';
        else
            state.acq.rawSawtoothMirrorOutput=repmat(twoSawTeeth, 1, state.acq.linesPerFrame/2)';
        end
        
		state.acq.rawSawtoothMirrorOutput(state.internal.startOutputColumnInLine ...
			: floor(state.internal.lengthOfXData)*(state.acq.linesPerFrame-1)+state.internal.endOutputColumnInLine, 2) ...
			= linspace(-1,1,floor(state.internal.lengthOfXData)*(state.acq.linesPerFrame-1)+state.internal.endOutputColumnInLine ...
			- state.internal.startOutputColumnInLine + 1)';
		
		state.acq.rawSawtoothMirrorOutput(floor(state.internal.lengthOfXData) * ...
			(state.acq.linesPerFrame-1)+state.internal.endOutputColumnInLine+1:end,2) ...
			= state.acq.rawSawtoothMirrorOutput(floor(state.internal.lengthOfXData) * ...
			(state.acq.linesPerFrame-1)+state.internal.endOutputColumnInLine+1:end,1);    
	else
       	state.acq.rawSawtoothMirrorOutput=repmat(oneSawTooth, 1, 2*state.acq.linesPerFrame)';
		if state.acq.dualLaserMode==2	% alternate by line
			state.acq.rawSawtoothMirrorOutput(state.internal.startOutputColumnInLine ...
				: floor(state.internal.lengthOfXData)*(2*state.acq.linesPerFrame-1)+state.internal.endOutputColumnInLine, 2) ...
				= linspace(-1,1,floor(state.internal.lengthOfXData)*(2*state.acq.linesPerFrame-1)+state.internal.endOutputColumnInLine ...
				- state.internal.startOutputColumnInLine + 1)';
		
			state.acq.rawSawtoothMirrorOutput(floor(state.internal.lengthOfXData) * ...
				(2*state.acq.linesPerFrame-1)+state.internal.endOutputColumnInLine+1:end,2) ...
				= state.acq.rawSawtoothMirrorOutput(floor(state.internal.lengthOfXData) * ...
				(2*state.acq.linesPerFrame-1)+state.internal.endOutputColumnInLine+1:end,1);    
		else
			disp('not implemented')
		end
		

	end

	
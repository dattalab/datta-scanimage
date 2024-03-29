function makeNewPcellPowerOutput
	global state
	
%	state.internal.lineDelay = state.acq.lineDelay/state.acq.msPerLine; % calculate fractional line delay
	
	if state.acq.bidi
		pStart =  1+round(state.internal.lengthOfXData * ...
			((1-state.acq.fillFraction)/2+...
			(state.acq.lineDelay/2+state.acq.mirrorLag-state.pcell.pcellDelay)/state.acq.msPerLine));
		pEnd =  1+round(state.internal.lengthOfXData * ...
			((1-state.acq.fillFraction)/2++state.acq.fillFraction+...
			(state.acq.lineDelay/2+state.acq.mirrorLag-state.pcell.pcellDelay)/state.acq.msPerLine));
	else
		pStart = round(state.internal.lengthOfXData * ...
			(state.acq.lineDelay+state.acq.mirrorLag-state.pcell.pcellDelay)/state.acq.msPerLine);
		pEnd =  round(state.internal.lengthOfXData * ...
			((state.acq.lineDelay+state.acq.mirrorLag-state.pcell.pcellDelay)/state.acq.msPerLine+state.acq.fillFraction));
	end
	
	if state.acq.dualLaserMode==1	% both lasers on at the same time
		state.acq.pcellPowerOutput=zeros(state.internal.lengthOfXData * state.acq.linesPerFrame, 2*state.pcell.numberOfPcells);
	elseif state.acq.dualLaserMode==2
		state.acq.pcellPowerOutput=zeros(2*state.internal.lengthOfXData * state.acq.linesPerFrame, 2*state.pcell.numberOfPcells);
	end
	
	for pcellCounter=1:state.pcell.numberOfPcells
		% the power while imaging
		scanningPowerRaw=getfield(state.pcell, ['pcellScanning' num2str(pcellCounter)]);
		if state.blaster.active && state.blaster.blankImaging
			scanningPower=powerToPcellVoltage(0, pcellCounter);
		else
			scanningPower=powerToPcellVoltage(scanningPowerRaw, pcellCounter);			
		end

		% the power while flying back
		flybackPowerRaw = getfield(state.pcell, ['pcellFlyBack' num2str(pcellCounter)]);		
		if flybackPowerRaw==-1
			flybackPower=scanningPower;
		else
			flybackPower=powerToPcellVoltage(flybackPowerRaw, pcellCounter);
		end
		
		% Fill with the flyback
		pOut = flybackPower*ones(floor(state.internal.lengthOfXData), 1);	
		% Fill scanning portion
		pOut(max(pStart,1):min(pEnd,state.internal.lengthOfXData))=scanningPower;	
		
        pOutPlusOne = zeros(floor(state.internal.lengthOfXData)+1,1);
        pOutPlusOne(1:floor(state.internal.lengthOfXData)) = pOut;
        pOutTwo = vertcat(pOut, pOutPlusOne);
        
		if state.acq.dualLaserMode==1	% both lasers on at the same time
            if state.acq.bidi %bidirectional scan so flip alternate lines
                state.acq.pcellPowerOutput(:, pcellCounter)  = repmat(pOut, [state.acq.linesPerFrame 1]);          
                %state.acq.pcellPowerOutput(:, pcellCounter) = repmat([pOut; flipdim(pOut, 1)], [state.acq.linesPerFrame/2 1]);
            else % unidirectional scan
                if (floor(state.acq.msPerLine) == state.acq.msPerLine) 
                    state.acq.pcellPowerOutput(:, pcellCounter)  = repmat(pOut, [state.acq.linesPerFrame 1]);
                else
                    state.acq.pcellPowerOutput(:, pcellCounter)  = repmat(pOutTwo, [state.acq.linesPerFrame/2 1]);    
                end
                
            end
		elseif state.acq.dualLaserMode==2 % alternate each laser in each scan
			dualPowerRaw = getfield(state.pcell, ['pcellDualLevel' num2str(pcellCounter)]);
			if dualPowerRaw==-1
				dualPower=scanningPower;
			else
				dualPower=powerToPcellVoltage(dualPowerRaw, pcellCounter);
			end
			pOutDual=flybackPower*ones(state.internal.lengthOfXData, 1);	
			pOutDual(max(pStart,1):min(pEnd,state.internal.lengthOfXData))=dualPower;	
			
			if state.acq.bidi	
				if mod(pcellCounter, 2)==1		 
					state.acq.pcellPowerOutput(:, pcellCounter) = repmat([pOut; flipdim(pOutDual, 1)], [state.acq.linesPerFrame 1]);
				else
					state.acq.pcellPowerOutput(:, pcellCounter) = repmat([pOutDual; flipdim(pOut, 1)], [state.acq.linesPerFrame 1]);
				end
			else
				if mod(pcellCounter, 2)==1		 
					state.acq.pcellPowerOutput(:, pcellCounter) = repmat([pOut; pOutDual], [state.acq.linesPerFrame 1]);
				else
					state.acq.pcellPowerOutput(:, pcellCounter) = repmat([pOutDual; pOut], [state.acq.linesPerFrame 1]);
				end
			end
		end

		if (scanningPowerRaw>0) || ((state.acq.dualLaserMode==2) && (dualPowerRaw>0))
			state.acq.pcellPowerOutput(:, pcellCounter + state.pcell.numberOfPcells) = 5 * state.shutter.open;
		else
			state.acq.pcellPowerOutput(:, pcellCounter + state.pcell.numberOfPcells) = 5 * state.shutter.closed;
		end				
	end

function makePulsePattern(number, update, rate)
    global state
	currentUser = state.user;

    if nargin<1
        number=state.pulses.patternNumber;
    end
    if nargin<2
        update=1;
    end
    if nargin<3
		try
			rate=state.phys.settings.outputRate;
		catch
			rate=10000;
		end
	end

    
    % checks for improper pulse configs (length too short for pulses etc)
    
	if (state.pulses.delayList(number) + state.pulses.pulseWidthList(number) ...
        +state.pulses.isiList(number)*(state.pulses.numPulsesList(number)-1))...
            >= state.pulses.durationList(number)
        beep;
        setPhysStatusString('check pulse pattern');
        disp(['makePulsePattern: pulse #' num2str(number) ' duration maybe too short']);
	end
    
	if (state.pulses.numPulsesList(number)>1) && ...
			(state.pulses.pulseWidthList(number)>=state.pulses.isiList(number))
        beep;
        setPhysStatusString('Bad pulse pattern');
		setStatusString('Bad pulse pattern');
        error(['makePulsePattern: pulse #' num2str(number) ' width>=isi']);
    end
	
    % init arrays
    
	numPoints=round(state.pulses.durationList(number)*rate/1000);
    data=state.pulses.offsetList(number)...
         * ones(1, numPoints);
    
   	corners=state.pulses.numPulsesList(number)*max(state.pulses.patternRepeatsList(number),1);
	displayVectorX=zeros(1, corners);
	displayVectorY=zeros(1, corners);

     
    if (state.pulses.pulseWidthList(number)>0 | state.pulses.waveTypeList(number)==5)
        for patternCounter=1:max(state.pulses.patternRepeatsList(number), 1)
            start=state.pulses.delayList(number) + (patternCounter-1)*state.pulses.patternISIList(number);
            
            for counter=1:state.pulses.numPulsesList(number)
                switch state.pulses.waveTypeList(number)  % switch on the wave type...
                    
                    case 1      % square
                        data(min(round(1+start*rate/1000) ...
                            : round((start+state.pulses.pulseWidthList(number))*rate/1000), numPoints)) ...
                            = state.pulses.amplitudeList(number) + state.pulses.offsetList(number);
                    case 2      % sine
                        startPoint=round(1+start*rate/1000);
                        endPoint=round((start+state.pulses.pulseWidthList(number))*rate/1000);
                        
                        t=[0:endPoint-startPoint];
                        amp=state.pulses.amplitudeList(number);
                        scale=1/state.pulses.isiList(number);
                        f=1/(state.pulses.pulseWidthList(number)*scale*rate/1000);
                        data(startPoint:endPoint) ...
                            = amp*sin(2*pi*f*t) + state.pulses.offsetList(number);
                    case 3      % ramp up
                        rampPoints=min(round((start+state.pulses.pulseWidthList(number))*rate/1000), numPoints) - ...
                            min(round(1+start*rate/1000), numPoints)+1;
                        data(min(round(1+start*rate/1000) ...
                            : round((start+state.pulses.pulseWidthList(number))*rate/1000), numPoints)) ...
                            = linspace(0, state.pulses.amplitudeList(number), rampPoints) + state.pulses.offsetList(number);
                    case 4      % ramp down
                        rampPoints=min(round((start+state.pulses.pulseWidthList(number))*rate/1000), numPoints) - ...
                            min(round(1+start*rate/1000), numPoints)+1;
                        data(min(round(1+start*rate/1000) ...
                            : round((start+state.pulses.pulseWidthList(number))*rate/1000), numPoints)) ...
                            = linspace(state.pulses.amplitudeList(number), 0, rampPoints) + state.pulses.offsetList(number);
                        
                    case 5
                        data=state.pulses.customWaveList{number};
                end
                            
                firstPos=((patternCounter-1)*state.pulses.numPulsesList(number)+counter-1)*4+1;
                displayVectorX(firstPos)=start;
				displayVectorX(firstPos+1)=start;
				displayVectorX(firstPos+2)=start+state.pulses.pulseWidthList(number);
				displayVectorX(firstPos+3)=start+state.pulses.pulseWidthList(number);
				displayVectorY(firstPos)=state.pulses.offsetList(number);
				
                %some leftover code for displaying...  i think it has to do
                %with the fact that some of ians old traces started before
                %an expected level.
				if strcmp(currentUser, 'ian') && state.pulses.patternNumber == 15
					displayVectorY(firstPos+1)=state.pulses.amplitudeList(number)*state.cycle.currentCyclePosition + state.pulses.offsetList(number);
					displayVectorY(firstPos+2)=state.pulses.amplitudeList(number)*state.cycle.currentCyclePosition + state.pulses.offsetList(number);
				else
					displayVectorY(firstPos+1)=state.pulses.amplitudeList(number) + state.pulses.offsetList(number);
					displayVectorY(firstPos+2)=state.pulses.amplitudeList(number) + state.pulses.offsetList(number);
				end
				
				displayVectorY(firstPos+3)=state.pulses.offsetList(number);
				
				start=start + state.pulses.isiList(number);
				
            end            
        end	
    end
    
    for counter=str2num(state.pulses.addCompList{number})
        if counter
            makePulsePattern(counter, update);
            addData=getfield(state.pulses, ['pulsePattern' num2str(counter)]);
            len=min(length(addData), length(data));
            data(1:len)=data(1:len)+addData(1:len);
		end
	end
    eval(['state.pulses.pulsePattern' num2str(number) '= data;']);
   
    if ~state.initializing
        if any(number==[state.cycle.da0List(state.cycle.currentCyclePosition)...
                        state.cycle.da1List(state.cycle.currentCyclePosition)])
            state.phys.internal.needNewOutputData=1;
        end        
        if any(number==[state.cycle.aux4List(state.cycle.currentCyclePosition) ...
                        state.cycle.aux5List(state.cycle.currentCyclePosition) ...
                        state.cycle.aux6List(state.cycle.currentCyclePosition) ...
                        state.cycle.aux7List(state.cycle.currentCyclePosition)])
            state.phys.internal.needNewAuxOutputData=1;
        end
    else
        state.phys.internal.needNewOutputData=1;
        state.phys.internal.needNewAuxOutputData=1;
	end
    
	if ~any(displayVectorX==0)
		displayVectorX=[0 displayVectorX];
		displayVectorY=[state.pulses.offsetList(number) displayVectorY];
	end
	
	if ~any(displayVectorX>=state.pulses.durationList(number))
		displayVectorX=[displayVectorX state.pulses.durationList(number)];
		displayVectorY=[displayVectorY state.pulses.offsetList(number)];
	end
	
	eval(['state.pulses.displayVectorX' num2str(number) '= displayVectorX;']);
	eval(['state.pulses.displayVectorY' num2str(number) '= displayVectorY;']);
	
	if (number==state.pulses.patternNumber) && update
        setWave('currentPulsePattern', 'data', data, 'xscale', [0 1000/rate]);
		setWave('currentPulseVectorX', 'data', displayVectorX);
		setWave('currentPulseVectorY', 'data', displayVectorY);
    end

    end
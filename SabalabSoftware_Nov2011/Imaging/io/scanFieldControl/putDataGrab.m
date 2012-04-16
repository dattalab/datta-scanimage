function putDataGrab
global state

global grabOutput pcellGrabOutput
putdata(grabOutput, state.acq.repeatedMirrorData);			% Queues Data to engine for Board 2 (Mirrors)
pcellChannels=0:2*state.pcell.numberOfPcells-1;

if length(state.cycle.physOnList)>=state.cycle.currentCyclePosition & state.cycle.physOnList(state.cycle.currentCyclePosition) % BSMOD 08012005 Changes so that Imaging and Phys can both use the aux board
    %TN 03Aug05
    chanNeeded=[pcellChannels ...
        find(...
        [state.cycle.aux4List(state.cycle.currentCyclePosition) ...
        state.cycle.aux5List(state.cycle.currentCyclePosition) ...
        state.cycle.aux6List(state.cycle.currentCyclePosition) ...
        state.cycle.aux7List(state.cycle.currentCyclePosition)])+3];
    
    delete(get(pcellGrabOutput, 'Channel'));
    
    if isempty(chanNeeded)
        return
    end
    
    chanAdded=addchannel(pcellGrabOutput, chanNeeded);
    set(chanAdded, 'OutputRange', [-10 10], 'UnitsRange', [-10 10]);
    
    nPoints=size(state.acq.pcellRepeatedOutput, 1);
    
    state.phys.daq.auxOutput=zeros(nPoints, length(chanNeeded));
    counter=1;
    for channel=chanNeeded
        if any(channel==pcellChannels)
            state.phys.daq.auxOutput(1:nPoints, counter)=state.acq.pcellRepeatedOutput(:, counter);
            
            %AJG MOD
            % olfactometer overwrite... assign last channels to the
            % trigger and valve state waves
            % these waves are created in oflactometerCycleFunction
        elseif (isfield(state, 'olfactometer'))
            if (state.olfactometer.enable)
                rate = get(pcellGrabOutput, 'SampleRate')/1000;
                points = state.olfactometer.odorTimeList*rate;
                accPoints = zeros(1,length(points));
                accPoints(1)=points(1);
                for j = 2:length(points)
                    accPoints(j)=points(j)+accPoints(j-1);
                end
                if (counter==(state.olfactometer.valveStatusDAValue+4))
                    state.olfactometer.valveStatusWave=zeros(1,nPoints);
                    %disp(['overwriting for valve status da on aux chan ' num2str(counter)])
                    
                    for i=1:length(state.olfactometer.odorStateList)
                        try
                            start = 1+accPoints(i-1);
                            stop = accPoints(i);
                        catch
                            start = 1;
                            stop = accPoints(1);
                        end
                        state.olfactometer.valveStatusWave(start:stop) = ...
                            ones(1,points(i))*state.olfactometer.odorStateList(i);
                        
                    end
                    %figure;plot(state.olfactometer.valveStatusWave);
                    state.phys.daq.auxOutput(1:nPoints, counter)=state.olfactometer.valveStatusWave';
                    
                elseif (counter==(state.olfactometer.triggerDAValue+4))
                    state.olfactometer.triggerWave=zeros(1,nPoints);
                    %disp(['overwriting for trigger da on aux chan ' num2str(counter)])
                    
                    % make trigger wave from timeList
                    for i=1:length(state.olfactometer.odorStateList)-1
                        state.olfactometer.triggerWave(accPoints(i):accPoints(i)+1250) = 5;
                    end
                    state.phys.daq.auxOutput(1:nPoints, counter)=state.olfactometer.triggerWave';
                    %figure;plot(state.olfactometer.triggerWave);
                else
                    patternNum=eval(['state.cycle.aux' num2str(channel) 'List(state.cycle.currentCyclePosition);']);
                    makePulsePattern(patternNum, 0, get(pcellGrabOutput, 'SampleRate'));
                    pattern=eval(['state.pulses.pulsePattern' num2str(patternNum)]);
                    pSize=size(pattern, 2);
                    if nPoints > pSize
                        pattern=[pattern repmat(pattern(end), 1, nPoints-pSize)];
                    elseif pSize>nPoints
                        pattern=pattern(1:nPoints);
                    end
                    state.phys.daq.auxOutput(1:nPoints, counter)=pattern';
                    
                end
            end
        else
            patternNum=eval(['state.cycle.aux' num2str(channel) 'List(state.cycle.currentCyclePosition);']);
            makePulsePattern(patternNum, 0, get(pcellGrabOutput, 'SampleRate'));
            pattern=eval(['state.pulses.pulsePattern' num2str(patternNum)]);
            pSize=size(pattern, 2);
            if nPoints > pSize
                pattern=[pattern repmat(pattern(end), 1, nPoints-pSize)];
            elseif pSize>nPoints
                pattern=pattern(1:nPoints);
            end
            state.phys.daq.auxOutput(1:nPoints, counter)=pattern';
            
        end
        counter=counter+1;
    end
    
    putdata(pcellGrabOutput, state.phys.daq.auxOutput);
else
    if size(get(pcellGrabOutput, 'Channel'),1)~=size(pcellChannels,1)
        delete(get(pcellGrabOutput, 'Channel'));
        addchannel(pcellGrabOutput, pcellChannels);
    end
    putdata(pcellGrabOutput, state.acq.pcellRepeatedOutput);		% Queues Data to engine for board 1 (Pockell Cell)
end

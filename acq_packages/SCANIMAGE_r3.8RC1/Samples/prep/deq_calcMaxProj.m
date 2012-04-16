function deq_calcMaxProj(eventName,eventData,channelDisplayList,channelFileList,liveDisplay)
    global state gh
    %Do ANALYSIS and display images if doing max projections....
    %% CHANGES
    %   VI091009A: No longer specify EraseMode upon update of data. This is determined a priori elsewhere (currently in makeImageFigures())
    %% ************************************************

    if nargin < 5 || isempty(liveDisplay)
        liveDisplay = true; 
        if nargin < 4 || isempty(channelFileList)
           channelFileList = []; 
           if nargin < 3 || isempty(channelDisplayList)
               channelDisplayList = [];  
           end
        end
    end
    
    % ensure we have valid channel lists
    if isempty(channelDisplayList)
        for i = 1:state.init.maximumNumberOfInputChannels
            if state.acq.(['imagingChannel' num2str(i)])
                channelDisplayList = [channelDisplayList i];
            end
        end
    end

    if isempty(channelFileList)
        for i = 1:state.init.maximumNumberOfInputChannels
            if state.acq.(['savingChannel' num2str(i)])
                channelFileList = [channelFileList i];
            end
        end
    end
    
    % make sure we can actually compute a max projection...
    if state.acq.numberOfZSlices == 1 || (~state.acq.averaging && state.acq.numberOfFrames > 1)
        return; % do nothing
    end

    switch eventName
        case 'acquisitionStarting'
            % allocate the necessary memory
            state.acq.maxData = cell(1,state.init.maximumNumberOfInputChannels);
            for channelCounter = 1:state.init.maximumNumberOfInputChannels
                state.acq.maxData{channelCounter} = zeros(state.internal.storedLinesPerFrame,state.acq.pixelsPerLine,'uint16');
            end

        case 'sliceDone'    
            % DEQ20101114 - it looks like keepAllSlicesInMemory isn't begin used?
            %if state.internal.keepAllSlicesInMemory % BSMOD 1/18/2
            %    position = state.internal.zSliceCounter + 1;
            %else
                position = 1;
            %end

            % update the running max projection calculation
            for channelCounter = 1:state.init.maximumNumberOfInputChannels
                if getfield(state.acq,['acquiringChannel' num2str(channelCounter)])	% channel is on
                    if	state.internal.zSliceCounter==0 %DEQ - zSliceCounter gets updated before 'sliceDone' is notified, so it's one greater than the slice it represents...
                        if state.acq.maxMode==0
                            state.acq.maxData{channelCounter} = state.acq.acquiredData{1}{channelCounter}(:,:,position);
                        else
                            state.acq.maxData{channelCounter} = double(state.acq.acquiredData{1}{channelCounter}(:,:,position));
                        end
                    else
                        if state.acq.maxMode==0
                            state.acq.maxData{channelCounter} = max(state.acq.acquiredData{1}{channelCounter}(:,:,position), ...
                                state.acq.maxData{channelCounter});
                        else
                            state.acq.maxData{channelCounter} = ...
                               (double(state.acq.acquiredData{1}{channelCounter}(:,:,state.internal.zSliceCounter)) + ... 
                               (state.internal.zSliceCounter - 1) *state.acq.maxData{channelCounter})/(state.internal.zSliceCounter); 
                            %state.acq.maxData{channelCounter} = ...
                            %    (double(state.acq.acquiredData{channelCounter}(:,:,state.internal.zSliceCounter + 1)) + ...
                            %    state.internal.zSliceCounter*state.acq.maxData{channelCounter})/(state.internal.zSliceCounter + 1);
                            %  BSMOD 1/18/2 eliminated reliance on position for above 2 lines
                        end
                    end
                end
                
                % update the display image
                if liveDisplay
                    set(state.internal.maximagehandle(channelCounter), 'CData', uint16(state.acq.maxData{channelCounter}));
                end
            end

        case 'acquisitionDone'
            % update the display images
            if ~liveDisplay
                for channelCounter = channelDisplayList
                    set(state.internal.maximagehandle(channelCounter), 'CData', uint16(state.acq.maxData{channelCounter}));
                end
            end

            % save to files
            writeMaxData(channelFileList);
    end
end

function writeMaxData(channelList)
    % saves the max projection data into a 16 bit tiff files.  Each channel is saved sequentially in
    % the same file
    global state

    if ~state.acq.averaging && state.acq.numberOfFrames > 1		% if it is not possible to do a max
        return													% then return
    end

    if nargin < 1
        channelList = [];
        for i = 1:state.init.maximumNumberOfInputChannels
            if state.acq.(['savingChannel' num2str(i)])
                channelList = [channelList i];
            end
        end
    end

    first = 1;
    for channelCounter = channelList
		if state.acq.maxMode==1
			state.acq.maxData{channelCounter}=uint16(state.acq.maxData{channelCounter});
		end
		if first
			fileName = [state.files.fullFileName 'max.tif'];
			imwrite(state.acq.maxData{channelCounter}, fileName,  'WriteMode', 'overwrite', ...
				'Compression', 'none', 'Description', state.headerString);	
			first = 0;
		else
			imwrite(state.acq.maxData{channelCounter}, fileName,  'WriteMode', 'append', ...
				'Compression', 'none', 'Description', state.headerString);	
		end
	end	
end

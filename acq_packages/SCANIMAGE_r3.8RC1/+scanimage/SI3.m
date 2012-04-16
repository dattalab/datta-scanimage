classdef SI3 < most.Model
    %Class encapsulating (newer) ScanImage 3.x state/behavior
    
    %% ABSTRACT PROPERTY REALIZATION (most.Model)
    properties (Hidden, SetAccess=protected)
        mdlPropAttributes = zlclInitPropMetadata(); %A structure effecting Map from property names to structures whose fields are Tags, with associated values, specifying attributes of each property
        
        %OPTIONAL (Can leave empty)
        mdlHeaderExcludeProps; %String cell array of props to forcibly exclude from header
    end
    
    %% USER PROPERTIES
    
    properties (SetObservable)
		
		% menu  props
        roiUseMIPForMRI = true; % If true, Max Image Projections will be stored as the Most Recent Image (in the EOA cache).
        roiShowMarkerNumbers = true; % If true, ROI/Position IDs will be displayed on the RDF and PDF.
		roiGotoOnAdd = true; % If true, ROI scan parameters are automatically updated to match each new ROI added using roiAddXXX() methods
        roiSnapOnAdd = false; % If true, and roiGotoOnAdd=true as well, a Snapshot image is automatically collected at each new ROI added using roiAddXXX() methods.
		roiGotoOnSelect = true; % If true, ROI scan parameters are automatically updated to match any ROI selected in the table.
		roiSnapOnSelect = false; % If true, and roiGotoOnAdd=true as well, a Snapshot image is automatically collected for any ROI selected in the table.
        roiShowAbsoluteCoords = false; % If true, Positions will be displayed using absolute coordinates.
        roiWarnOnMove = true; % If true, any ROI-goto operation involving a motor-move will prompt the user for confirmation.
        
        % RDF toolbar props
        roiDisplayedChannel = '1'; % Specifies which channel to use for ROIs; one of {'1' '2' '3' '4' 'merge'}
        roiDisplayDepth=inf;
        
        % Tolerances
        roiPositionToleranceX;% = state.motor.posnResolution;
        roiPositionToleranceY;% = state.motor.posnResolution;
        roiPositionToleranceZ;% = state.motor.posnResolution;
        roiPositionToleranceZZ;% = state.motor.posnResolutionZ;
	end
    
    
    %% SUPERUSER PROPERTIES
    
    properties (Hidden,SetAccess=private)
        
        % Overridable function handles
        % NOTE: these are intended to be directly accessed, ignoring good OOP practice in favor of performance, i.e. feval(state.hSI.hMakeStripe)
        hMakeStripe = @makeStripe;
        hMakeFrameByStripes = @makeFrameByStripes;
        hEndAcquisition = @endAcquisition;
        hMakeMirrorDataOutput = @makeMirrorDataOutput;
        
        % USER-ADDED OVERRIDABLE FUNCTION HANDLES
        %    NOTE: Any added overridable functions/handles should be added to overridableFcns list
        
    end
    
    properties (Constant)
        overridableFcns = {'makeStripe' 'makeFrameByStripes' 'endAcquisition' 'makeMirrorDataOutput'};        
    end
    
    
    %% DEVELOPER PROPERTIES
    
    properties (Access=private)
        %User/Override Function Handling
        listenerAbortFlag = false; % A flag indicating that a notify()-ed event generated an "error" condition.
    end
    
    
    properties (Hidden, SetAccess=protected, SetObservable, GetObservable)
        
        %ROI ColumnArrayTable bound props
        roiIDs = {};
        roiPositionIDs = [];
		roiTypes = {};		
        roiZoomFactors = [];
        roiRotations = [];
        roiShifts = {};
        roiScanAngleMultipliers = {};
        
        %roiAspectRatios = [1 nan]; %TODO!
        
    end
    
    properties (Hidden, SetObservable, GetObservable)
        
        % Position Handling
        positionDataStructure;
		activePositionID = 0;
        shownPositionID;
		shownPositionString = '';
        selectedPositionID;
        
        % ROI Handling
        roiDataStructure;
        activeROIID;
        shownROI = -1;
        selectedROIID;
		roiLastLine = [];
        
		currentRSPStruct; % a struct containing the current RSPs
        
		% ROI GUI params
        roiBreadcrumbString = 'ROOT =>';
        roiAngleToMicronsFactor=1; % an unrealistic, but safe, default value...
        
		roiLastAcqCache;
        
        roiName='';
        roiPath='';
		roiLoading = false;
        
		% ColumnArrayTable bound props
		positionIDs = {};
		xVals = [];
		yVals = [];
		zVals = [];
		zzVals = [];
        
        doSuppressTableUpdates = false; % if true, the ROI uitable will not be automatically updated
    end
    
    properties (Hidden, SetObservable)
		roiAutoUpdateConfig = true;
		
        %Line Scan Handling
        lineScanEnable = false;
        scanAngleMultiplierSlowCache = [];
        
        roiIsShownROIOutOfSync = false; % if true, indicates that the current motor position doesn't match that of the shown ROI
        roiActiveUpdatePending = false; % if true, indicates that the active ROI has been changed, but the view has not yet been updated.
        %roiSuppressLinescanSideEffects = false; % if true, indicates that enabling/disabling LS mode should have no side effects.
        
        isSubUnityZoomAllowed = false;
		
		currentBaseZoom = 1;
        
        motorStepSizeX = 1;
        motorStepSizeY = 1;
        motorStepSizeZ = 1;
        motorStepSizeZZ = 1;
        %motorStepSizeZCache = 1; % allows caching of z-step value when secondary-z motor is enabled/disabled.
    end
    
    properties (Hidden, SetAccess=protected)
        hROIDisplayFig;
        hROIDisplayAx;
        hROIDisplayIm;
        
        hROIAcqIm;
    end
        
    
    properties (Hidden, Dependent)
		roiBaseConfigStruct;
    end
    
    properties (Hidden, Constant)
        usrBoundProperties = {'roiAngleToMicronsFactor' 'roiUseMIPForMRI' 'roiShowMarkerNumbers' ...
                                'roiGotoOnAdd' 'roiSnapOnAdd' 'roiGotoOnSelect' 'roiSnapOnSelect' 'roiShowAbsoluteCoords' ...
								'roiBaseConfigStruct' 'roiWarnOnMove' 'roiDisplayedChannel' 'roiDisplayDepth' ...
                                'roiPositionToleranceX' 'roiPositionToleranceY' 'roiPositionToleranceZ' 'roiPositionToleranceZZ' ...
                             };

		scanParameterNames = {'zoomFactor' 'scanShiftFast' 'scanShiftSlow' 'scanRotation' 'scanAngleMultiplierFast' 'scanAngleMultiplierSlow'};

        markerColors = containers.Map({'point' 'line' 'square' 'rect' 'selected' 'active'}, ...
                                            {[1 0 1] [1 0 1] [1 0 1] [1 0 1] [1 1 0] [0 1 0]});
			
        ROI_ROOT_ID = -1;
		ROI_BASE_ID = 0;
    end
    
    
    %% CLASS EVENTS
    events
        
        %% COMMONLY USED EVENTS
        %A list of the 'top-ten' events, most likely to be useful to general users
        
        acquisitionStarting; % Fires when a GRAB acqusition or LOOP acquisition is being started.
        acquisitionStarted; % Fires when a GRAB acqusition or LOOP repeat has been started
        acquisitionDone; %Fires when a GRAB acquisition, or single iteration of LOOP acquisition, has completed
        sliceDone; %Fires when single slice of a multi-slice GRAB/LOOP acquisition has completed
		
        focusStart; % Fires when a FOCUS acquisition has been started.
        focusDone; %Fires when FOCUS acquisition is completed
        
        stripeAcquired; %Fires when acqusition of stripe has occurred
        frameAcquired; %Fires when acquisition of frame has been completed
        
        startTriggerReceived; %Fires when start trigger is received (only for GRAB/LOOP acquisitions)
        nextTriggerReceived; %Fires when a 'next' trigger is received
        
        %USR-file only events
        appOpen; %Fires when ScanImage starts
        appClose; %Fires when ScanImage closes
        
        %% USER-ADDED EVENTS
        %Add any events required by your application here
        %At appropriate point in application code, you must add the line:
        %   notify(state.userFcns.hEventManager,'<EVENT_NAME>');
        %   (Ensure the 'state' variable is in scope, by entering 'global state' in same function, if not there already)
        
        
        
        %% OTHER EVENTS
        %Other events, added by developers, e.g. for specific 'plugins', are entered here
        
        abortAcquisitionStart; %Fires at start of an abort acquisition operation (for GRAB/LOOP)
        abortAcquisitionEnd; %Event at end of an abort acquisition operation (for GRAB/LOOP)
        
        
        %TODO: Add following events, using regular notify (see DriftComp branch)
        %         executeFocusStart; %Event invoked at start of acquisition function execute<Focus/Grab/Loop>Callback()
        %         executeGrabStart;
        %         executeLoopStart
        %
        
        %TODO: Add following events,  using 'smart' notify (see DriftComp branch, si_notify())
        %         startGrabStart;
        %         startFocusStart;
        
    end
    
    
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = SI3()
                     
            %Initialize Class Data store
            obj.ensureClassDataFile(struct('userFcnsLastPath', most.idioms.startPath(), 'usrOnlyFcnsLastPath', most.idioms.startPath(), ...
                                            'overrideFcnsLastPath',most.idioms.startPath(), 'cycleLastPath',most.idioms.startPath(), ...
                                            'cycleCFGLastPath',most.idioms.startPath(), 'roiLastPath',most.idioms.startPath()));
            
			% Register any listeners
			addlistener(obj,'acquisitionDone',@obj.roiEOA_Listener);
			addlistener(obj,'focusDone',@obj.roiEOA_Listener);
            addlistener(obj,'appOpen',@obj.ziniInitializeFigures);
			addlistener(obj,'appOpen',@(src,event) obj.roiSetBaseConfig(true));
            addlistener(obj,'appOpen',@obj.roiUpdateRootRSPs);
            
			% InItialize the ROI data-struct, adding the ROOT and BASE ROIs
			obj.roiDataStructure = containers.Map('KeyType','int32','ValueType','any');
            
			rootROIStruct = struct('type','square','positionID',0,'children',[]);
            obj.roiDataStructure(obj.ROI_ROOT_ID) = rootROIStruct;
			
			baseROIStruct = struct('type','square','parentROIID',obj.ROI_ROOT_ID,'positionID',0);
			obj.roiDataStructure(obj.ROI_BASE_ID) = baseROIStruct;
			obj.roiAddChildToParent(obj.ROI_ROOT_ID, obj.ROI_BASE_ID);
			
			% Initialize the Position data-struct, adding a root all-NaN position
			obj.positionDataStructure = containers.Map('KeyType','int32','ValueType','any');
			obj.roiAddPosition(struct('motorX',nan,'motorY',nan,'motorZ',nan,'motorZZ',nan),0); % create a 'root' all-NaN PDO
            
            %Miscellaneous initializations
            obj.notify('dummyEvent'); %Ensure persistent var gets initialized
        end
    end
    
    
    methods (Access=public)%protected
        
        function ziniInitializeFigures(obj,~,~)           
            global state;

			obj.hROIDisplayFig = obj.hController{1}.hGUIData.roiDisplayGUI.figure1;
            obj.hROIDisplayAx = obj.hController{1}.hGUIData.roiDisplayGUI.axROIDisplay;
			axSize = [diff(get(obj.hROIDisplayAx,'XLim')) diff(get(obj.hROIDisplayAx,'YLim'))];
            obj.hROIDisplayIm = image('Parent', obj.hROIDisplayAx,'CData',zeros(axSize(2),axSize(1)));
            
            set(obj.hROIDisplayFig,'Visible','on');
            figure(obj.hROIDisplayFig);
            blankData = zeros(state.internal.storedLinesPerFrame, state.acq.pixelsPerLine);
            set(obj.hROIDisplayIm,'CData',blankData);
 			set(obj.hROIDisplayIm,'XData',[1 axSize(1)],'YData', [1 axSize(2)]);
            set(obj.hROIDisplayFig,'Colormap',eval(state.internal.figureColormap1));
            set(obj.hROIDisplayFig,'Visible','off');
            
            obj.roiUpdateROITable();
            obj.roiUpdatePositionTable();
            obj.roiUpdateView();
        end
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% PROPERTY ACCESS
    
    methods 
        
        %% GET HETHODS
	
		function val = get.currentRSPStruct(obj)	
			if ~obj.mdlInitialized
				return;
			end
			
			global state;
			
			val = struct();
			for i = 1:length(obj.scanParameterNames)
				val.(obj.scanParameterNames{i}) = state.acq.(obj.scanParameterNames{i}); 
			end
		end
		
		function val = get.roiBaseConfigStruct(obj)
			val = [];
			
			global state gh;
			if isempty(state) || isempty(gh)
				% must be startup--global structs don't exist yet...
				return;
			end
			
			roiStruct = obj.roiDataStructure(obj.ROI_BASE_ID);
			fieldsToRemove = {'MRI' 'hMarker' 'hMarkerLabel'};
			for i = 1:length(fieldsToRemove)
				if isfield(roiStruct,fieldsToRemove{i})
					roiStruct = rmfield(roiStruct,fieldsToRemove{i});
				end
			end
			val = roiStruct;
		end
        
		
        %% SET METHODS   
        
		function set.activePositionID(obj,val)
			
			if ~obj.mdlInitialized
				return;
			end
			
			global state;
			
            if isempty(val)
                val = 0;
            end
            
			% The cache of last added/gone-to line ROI should be cleared if motor position changes
            if val ~= obj.activePositionID
                obj.roiLastLine = [];
            end
            
			% boilerplate set code
            val = obj.validatePropArg('activePositionID',val);
			obj.activePositionID = val;
		end
		
        function set.activeROIID(obj,val)
    
			if ~obj.mdlInitialized
				return;
			end
            
            % before we update the value, reset the marker color of the currently selected ROI
            if ~isempty(obj.activeROIID)
                if ~isempty(obj.selectedROIID) && obj.activeROIID == obj.selectedROIID
                    % do nothing
                else
                    if obj.roiDataStructure.isKey(obj.activeROIID)
                        obj.roiSetMarkerColor(obj.activeROIID); % sets color to default
                    end
                end
            end
            
            if ~isempty(val) && (isempty(obj.activeROIID) || val ~= obj.activeROIID)
                obj.roiActiveUpdatePending = true;
            end
            
            % boilerplate set code
            val = obj.validatePropArg('activeROIID',val);
			obj.activeROIID = val;

            % highlight the active ROI ID marker in green
            if ~isempty(val)
                obj.roiSetMarkerColor(val,obj.markerColors('active'));
            end
            
            % update the asterisk in the ROI table
			if ~obj.doSuppressTableUpdates
				obj.roiUpdateROITable();
			end
		end
		
        function set.shownROI(obj,val)

            if ~obj.mdlInitialized
                return;
            end
            
            global state;
				
            if isempty(val)
				% fall back to show the ROOT ROI, if nothing else
                val = obj.ROI_ROOT_ID;
			else
				% Prevent points and lines from being shown
                if obj.roiDataStructure.isKey(val)
                    newROIStruct = obj.roiDataStructure(val);
                    if (isfield(newROIStruct,'type') && (strcmpi(newROIStruct.type,'point') || strcmpi(newROIStruct.type,'line')))
                        return;
                    end
				else
					obj.zprvDisp('Invalid ROI ID.');
					return;
				end
            end
  
            % "pre-set" logic:
            if ~obj.doSuppressTableUpdates
                obj.roiSetMarkersVisibility('off');
			end
            
			if val ~= obj.shownROI
				didChange = true;
			else
				didChange = false;
			end
			
            % boilerplate "set" logic:
            val = obj.validatePropArg('shownROI',val);
			obj.shownROI = val;
            
			obj.roiUpdateShownROI(didChange);
        end
        
        function set.isSubUnityZoomAllowed(obj,val)
			val = obj.validatePropArg('isSubUnityZoomAllowed',val);
			obj.isSubUnityZoomAllowed = val;
			
			global state gh;
            
            if isempty(state) || isempty(gh)
				% must be startup--global structs don't exist yet...
                return;
            end
                
            % update dependant properties
            if ~obj.isSubUnityZoomAllowed %~get(gh.userPreferenceGUI.cbIsSubUnityZoomAllowed,'Value')
                if state.acq.zoomFactor < 1
                    setZoomValue(1);
                end

                if state.acq.minZoomFactor < 1
                    state.acq.minZoomFactor = 1;
                    updateGUIByGlobal('state.acq.minZoomFactor');
                end
            else
               state.acq.minZoomFactor = 0.1; 
               updateGUIByGlobal('state.acq.minZoomFactor');
            end
		end
		
% 		function set.lineScanEnable(obj,val)
% 			global state gh;
% 			if isempty(state) || isempty(gh)
% 				% must be startup--global structs don't exist yet...
% 				return;
%             end
%             
%             if strcmp(get(gh.mainControls.focusButton, 'Visible'), 'off')
% 			    beep;
% 			    obj.zprvError('LS disabled.','Linescan is disabled during acquisition; must be focusing');
% 			    return;
%             end
%             
%             
%             % boilerplate set code
%             val = obj.validatePropArg('lineScanEnable',val);
% 			obj.lineScanEnable = val;
%             
%             if obj.roiSuppressLinescanSideEffects
%                 return;
%             end
% 			
% 			try
% 			    isFocus = false;
% 			    if ~strcmpi(get(gh.mainControls.focusButton, 'String'), 'FOCUS')
% 			        isFocus = true;
% 					abortCurrent(0); %VI120108A
% 			    end    
% 			    
% 				if val
%                     % cache the existing SAMSLow
%                     obj.scanAngleMultiplierSlowCache = state.acq.scanAngleMultiplierSlow;
%                     
%                     % set SAMSlow = 0
%                     state.acq.scanAngleMultiplierSlow = 0;
%                     updateGUIByGlobal('state.acq.scanAngleMultiplierSlow');
%                     
%                     set(gh.powerBox.stFramesOrLines, 'String', 'Lines:'); %VI020609A
%                 else
%                     % if SAMSlow is zero, restored the cached value. Otherwise, user just edited SAMSlow, so respect the new value.
%                     if state.acq.scanAngleMultiplierSlow == 0
%                         state.acq.scanAngleMultiplierSlow = obj.scanAngleMultiplierSlowCache; 
%                         updateGUIByGlobal('state.acq.scanAngleMultiplierSlow');
%                     end
%                     
%                     set(gh.powerBox.stFramesOrLines, 'String', 'Frames:'); %VI020609A
% 				end
% 			    applyConfigurationSettings();
%                 state.internal.updatedZoomOrRot = true;
% 
% 				
% 			    % TODO: check BIDI
% 				% checkConfigSettings;
% 				
% 				if isFocus
% 					stopGrab;
% 					stopFocus;
% 				
% 					setupDAQDevices_ConfigSpecific;
% 					resetCounters;
% 					updateHeaderString('state.acq.pixelsPerLine');
% 					updateHeaderString('state.acq.fillFraction');
% 					startPMTOffsets;
% 					
% 			        executeFocusCallback(gh.mainControls.focusButton);
%                 else
%                     if obj.mdlInitialized % don't snap during startup...
%                         snapShot();
%                     end
% 				end
% 			catch
% 			    rethrow(lasterror);
% 			end
% 		end
		
		function set.roiBaseConfigStruct(obj,val)
			global state gh;
			if isempty(state) || isempty(gh)
				% must be startup--global structs don't exist yet...
				return;
            end
			
			obj.roiDataStructure(obj.ROI_BASE_ID) = val;
        end
		
        function set.roiDisplayedChannel(obj,val)
            global state;
            
            if ~obj.mdlInitialized
                return;
            end
            
            if isnumeric(val)
                val = num2str(val);
            end
            
            if ~isempty(val) && ~strcmp(val,'merge') && str2double(val) > max(find(state.acq.imagingChannel))
                obj.zprvError('Invalid channel.', 'ScanImage is not currently acquiring the specified channel.');
                return;
            elseif strcmp(val,'merge')
                if ~state.acq.channelMerge
                    obj.zprvError('Invalid channel.', 'ScanImage is not currently acquiring merged data (this can be turned on in Channel controls).');
                    return;
                elseif ~isfield(obj.roiLastAcqCache,'MRI') || length(obj.roiLastAcqCache.MRI) < 5
                    obj.zprvError('No acquired data.', 'No data has been acquired since channel-merge has been enabled.');
                    return;
                end
            end
            % boilerplate set code
            val = obj.validatePropArg('roiDisplayedChannel',val);
			obj.roiDisplayedChannel = val;
            
            obj.roiUpdateView();
        end
        
        function set.roiDisplayDepth(obj,val)
            % boilerplate set code
            val = obj.validatePropArg('roiDisplayDepth',val);
			obj.roiDisplayDepth = val;
            
            % update the views
            obj.roiUpdateROITable();
            obj.roiUpdateView();
        end
        
		function set.roiGotoOnAdd(obj,val)
			% boilerplate set code
            val = obj.validatePropArg('roiGotoOnAdd',val);
			obj.roiGotoOnAdd = val;
		end
			
		function set.roiGotoOnSelect(obj,val)
			% boilerplate set code
            val = obj.validatePropArg('roiGotoOnSelect',val);
			obj.roiGotoOnSelect = val;
        end
		
        function set.roiIsShownROIOutOfSync(obj,val)
            % boilerplate set code
            val = obj.validatePropArg('roiIsShownROIOutOfSync',val);
			obj.roiIsShownROIOutOfSync = val;
            
            if obj.roiIsShownROIOutOfSync
                % Visually indicate that the shown ROI is out of sync by highlighting its RDF display in red...
                
            else
                
            end
        end
        
		function set.roiSnapOnAdd(obj,val)
			% boilerplate set code
            val = obj.validatePropArg('roiSnapOnAdd',val);
			obj.roiSnapOnAdd = val;
		end
		
		function set.roiSnapOnSelect(obj,val)
			% boilerplate set code
            val = obj.validatePropArg('roiSnapOnSelect',val);
			obj.roiSnapOnSelect = val;
        end
        
        function set.selectedROIID(obj,val)
			% Sets the currently-selected ROI.
			
            global state gh;
			if isempty(state) || isempty(gh)
				% must be startup--global structs don't exist yet...
				return;
            end
            
            % before we update the value, reset the marker color of the currently selected ROI
            if ~isempty(obj.selectedROIID)
				if ~isempty(obj.activeROIID) && isscalar(obj.selectedROIID) && obj.selectedROIID == obj.activeROIID
					obj.roiSetMarkerColor(obj.selectedROIID,obj.markerColors('active'));
				else
					obj.roiSetMarkerColor(obj.selectedROIID);
				end
            end
            
            % boilerplate set code
            val = obj.validatePropArg('selectedROIID',val);
			obj.selectedROIID = val;

            if ~isempty(val)
				% highlight the selected ROI marker in yellow
				obj.roiSetMarkerColor(val,obj.markerColors('selected'));
					
				if obj.roiGotoOnSelect
					obj.roiGotoROI(obj.selectedROIID);

					% only take a snapshot if 'goto-on-select' is enabled
					if obj.roiSnapOnSelect
						snapShot();
						while state.internal.snapping
							pause(0.1);
						end
					end
				end
			end
        end
       
        
        function set.roiPositionToleranceX(obj,val)
            val = obj.zprpRoiClampPositionTolerance(val,'X');
            
            val = obj.validatePropArg('roiPositionToleranceX',val);
			obj.roiPositionToleranceX = val;
        end
        
        function set.roiPositionToleranceY(obj,val)
            val = obj.zprpRoiClampPositionTolerance(val,'Y');
            
            val = obj.validatePropArg('roiPositionToleranceY',val);
			obj.roiPositionToleranceY = val;
        end
        
        function set.roiPositionToleranceZ(obj,val)
            val = obj.zprpRoiClampPositionTolerance(val,'Z');
            
            val = obj.validatePropArg('roiPositionToleranceZ',val);
			obj.roiPositionToleranceZ = val;
        end
        
        function set.roiPositionToleranceZZ(obj,val)
            val = obj.zprpRoiClampPositionTolerance(val,'ZZ');
            
            val = obj.validatePropArg('roiPositionToleranceZZ',val);
			obj.roiPositionToleranceZZ = val;
        end
        
        function set.roiShowAbsoluteCoords(obj,val)
            val = obj.validatePropArg('roiShowAbsoluteCoords',val);
			obj.roiShowAbsoluteCoords = val;
            
            obj.roiUpdatePositionTable();
        end
        
		function set.roiShowMarkerNumbers(obj,val)
			val = obj.validatePropArg('roiShowMarkerNumbers',val);
			obj.roiShowMarkerNumbers = val;
            
            if val
                visibleState = 'on';
            else 
                visibleState = 'off';
            end
            
            rois = obj.roiDataStructure.keys();
            for i = 1:length(rois)
                roiStruct = obj.roiDataStructure(rois{i});
                
                if isfield(roiStruct,'hMarkerLabel')
                    set(roiStruct.hMarkerLabel,'Visible',visibleState);
                end
            end
		end


    end
    
    %Property-access helpers
    methods (Hidden)
        function val = zprpRoiClampPositionTolerance(obj,val,dimension)
            % Enforces position tolerance/resolution constraints.
            
            global state;            
                        
            if isempty(val) || (state.motor.motorOn && val < state.motor.(['resolution' dimension]))
                val = state.motor.(['resolution' dimension]);
            end

        end
    end
    
    %% USER METHODS
    methods 
		
		function cycAddIteration(obj,rowArray)
            % Adds a new iteration row to the end of the cycle table.
            %
            % rowArray: A cell array representing the new row.
            %
            
            global state;
            
            if nargin < 2 || isempty(rowArray)
                rowArray = state.cycle.cycleTableColumnDefaults; 
            end
            
            columnNames = state.cycle.cycleTableColumns;
            if length(rowArray) ~= length(columnNames)
                obj.zprvDisp('Invalid row data.');
                return;
            end
            
            if isempty(fieldnames(state.cycle.cycleTableStruct))
                iterationIndex = 1;
            else
                iterationIndex = length(state.cycle.cycleTableStruct) + 1;
            end
            
            for i = 1:length(rowArray)
                state.cycle.cycleTableStruct(iterationIndex).(columnNames{i}) = rowArray{i};
            end
            
            state.cycle.cycleConfigPaths{iterationIndex} = '';
            if isempty(state.cycle.cycleLength)
                state.cycle.cycleLength = 1;
            else
                state.cycle.cycleLength = state.cycle.cycleLength + 1;
            end
            updateGUIByGlobal('state.cycle.cycleLength'); % TODO: move this to PropControl
            
            if ~obj.doSuppressTableUpdates
                obj.hController{1}.cycTableUpdateView();
            end
		end
		
		function cycRemoveIteration(obj,iterationIndex)
            % Removes the specified iteration (row) from the cycle table.
            %
            % iterationIndex: an integer specifying the row to be removed.
            % If empty, the last row will be removed.
            %
            
            global state;
            
            if nargin < 2 || isempty(iterationIndex)
                iterationIndex = length(state.cycle.cycleTableStruct); 
            end
            
            state.cycle.cycleTableStruct(iterationIndex) = [];
            state.cycle.cycleConfigPaths(iterationIndex) = [];
            state.cycle.cycleLength = state.cycle.cycleLength - 1;
            updateGUIByGlobal('state.cycle.cycleLength'); %TODO: move this to PropControl
            
            if ~obj.doSuppressTableUpdates
                obj.hController{1}.cycTableUpdateView();
            end
        end
		
        function roiID = roiAddCurrent(obj)
            % Adds a new ROI using the current RSPs.
            %
            % roiID: the ID of the newly created ROI.
            
			% calling roiAddNew() without args captures the current config state
            roiID = obj.roiAddNew();
        end
        
        function roiID = roiAddRect(obj,doForceSquare)
            % Adds a new Rectanglular ROI.
            %
            % doForceSquare: a boolean that, if true, indicates to constrain graphical selection to a square. 
            %
            % roiID: the ID of the newly created ROI.
            
            global state
            
            roiID = [];
            done = 0;
            
			% ensure we have EOA data
			if isempty(obj.roiLastAcqCache)
				obj.zprvError('Cannot create ROI','Unable to create ROI: No acquired data.');
				return;
			end
			
            if nargin < 2 || isempty(doForceSquare)
                 doForceSquare = false;
            end
					
            % Determine target figure
            hAx = si_selectImageFigure();
            if isempty(hAx)
                return;
            end
            
            % Extract ROI coordinates from target figure 
            pos=getRectFromAxes(hAx, 'Cursor', 'crosshair', 'nomovegui', 1, 'forcesquare', doForceSquare,'LineColor',[0.5 0.5 0.5],'LineWidth',2); %VI071310A %VI021809B
            if pos(3) == 0 || pos(4) == 0
                return;
            end
                
			sizeImage = [diff(get(hAx,'XLim')) diff(get(hAx,'YLim'))];

			% Determine scan parameters corresponding to selected ROI coordinates
            if hAx == obj.hROIDisplayAx
                shownROIStruct = obj.roiDataStructure(obj.shownROI);
                originalZoomFactor = shownROIStruct.RSPs.zoomFactor;
                originalShiftFast = shownROIStruct.RSPs.scanShiftFast;
                originalShiftSlow = shownROIStruct.RSPs.scanShiftSlow;
                originalSAMFast = shownROIStruct.RSPs.scanAngleMultiplierFast;
                originalSAMSlow = shownROIStruct.RSPs.scanAngleMultiplierSlow;
                
                % shift the position proportionally to the SAM 
                offset = [sizeImage(1)*(1-originalSAMFast) - pos(3), sizeImage(2)*(1-originalSAMSlow) - pos(4)];
            else
                % transform pixel coords, accounting for Scan Angle Multiplier ~= 1
                pos(1) = pos(1) + (1-obj.roiLastAcqCache.RSPs.scanAngleMultiplierFast)*state.acq.pixelsPerLine/2;
                pos(2) = pos(2) + (1-obj.roiLastAcqCache.RSPs.scanAngleMultiplierSlow)*state.acq.linesPerFrame/2;
                pos(3) = pos(3)*obj.roiLastAcqCache.RSPs.scanAngleMultiplierFast;
                pos(4) = pos(4)*obj.roiLastAcqCache.RSPs.scanAngleMultiplierSlow;
               
                originalZoomFactor = obj.roiLastAcqCache.RSPs.zoomFactor;
                originalShiftFast = obj.roiLastAcqCache.RSPs.scanShiftFast;
                originalShiftSlow = obj.roiLastAcqCache.RSPs.scanShiftSlow;
                originalSAMFast = obj.roiLastAcqCache.RSPs.scanAngleMultiplierFast;
                originalSAMSlow = obj.roiLastAcqCache.RSPs.scanAngleMultiplierSlow;
                
                % shift the position proportionally to the SAM
                offset = [state.acq.pixelsPerLine*(1-originalSAMFast) - pos(3), state.acq.linesPerFrame*(1-originalSAMSlow) - pos(4)];
                
                % make sure it makes sense to add a new ROI, given the current scan configuration
                currentType = obj.computeROIType(originalSAMFast,originalSAMSlow);
                if strcmp(currentType,'line') || strcmp(currentType,'point')
                    obj.zprvError('Cannot create ROI', 'Unable to add ROI under current scan configuration.');
                    roiID = [];
                    return;
                end
            end

            if pos(1) + pos(3) > sizeImage(1) || pos(2) + pos(4) > sizeImage(2)
                obj.zprvError('Invalid ROI','The drawn ROI exceeds the bounds of the current acquisition.');
                return;
            end
            
            offset(offset < 0) = 0;
            centerX = (pos(1) + 0.5 * pos(3)) - offset(1)/2;
            centerY = (pos(2) + 0.5 * pos(4)) - offset(2)/2;
            scale = min(sizeImage(1:2) ./ pos(3:4));

            s.RSPs.zoomFactor = round(10 * originalZoomFactor * scale)/10; %Don't round! (as was done in original SI3)
            
            if pos(3)/sizeImage(1) == pos(4)/sizeImage(2)
                s.RSPs.scanAngleMultiplierFast = 1;
                s.RSPs.scanAngleMultiplierSlow = 1;
            elseif pos(3)/sizeImage(1) > pos(4)/sizeImage(2)
                s.RSPs.scanAngleMultiplierFast = 1;
                s.RSPs.scanAngleMultiplierSlow = (pos(4)/sizeImage(2))/(pos(3)/sizeImage(1));
            elseif pos(4)/sizeImage(2) > pos(3)/sizeImage(1)
                s.RSPs.scanAngleMultiplierFast = (pos(3)/sizeImage(1))/(pos(4)/sizeImage(2));
                s.RSPs.scanAngleMultiplierSlow = 1;
            else
                disp('wtf'); 
            end

            s.RSPs.scanShiftFast = originalShiftFast + ((state.init.scanAngularRangeReferenceFast * originalSAMFast)/originalZoomFactor) * (centerX/sizeImage(1) - 0.5);
            s.RSPs.scanShiftSlow = originalShiftSlow + ((state.init.scanAngularRangeReferenceSlow * originalSAMSlow)/originalZoomFactor) * (centerY/sizeImage(2) - 0.5);
            
            %Add to ROI Spec Table
            roiID = obj.roiAddNew(s,[],hAx);
        end
        
        function roiID = roiAddSquare(obj)
            % Adds a new Square ROI.
            
             roiID = obj.roiAddRect(true);
        end
        
		function roiIDs = roiAddPoints(obj,numPoints)
			% Opens a dialog to add one or more 'point' ROIs.
			
            if nargin < 2 || isempty(numPoints)
                numPoints = inf;
            end
            
			global state;
			
			roiIDs = [];
			
			% ensure we have EOA data
			if isempty(obj.roiLastAcqCache)
				obj.zprvError('Cannot create ROI', 'Unable to create ROI: No acquired data.');
				return;
			end
			
			% make sure it makes sense to add a new ROI, given the current scan configuration
			currentType = obj.computeROIType(state.acq.scanAngleMultiplierFast,state.acq.scanAngleMultiplierSlow);
			if strcmp(currentType,'point')
				obj.zprvError('Cannot create ROI', 'Unable to add ROI under current scan configuration.');
				return;
			end
			
			%Determine target figure
            hAx = si_selectImageFigure();
            if isempty(hAx)
                return;
            end
			
			%Extract ROI coordinates from target figure
			[x, y]= getPointsFromAxes(hAx, 'Cursor', 'crosshair', 'nomovegui', 1,'numberOfPoints',numPoints,'LineStyle','none','MarkerEdgeColor',[0.5 0.5 0.5],'MarkerSize',8,'EraseMode','normal');
			if isempty(x) || isempty(y)
				return;
            end
            
            % convert from pixel to angular coordinates
            angularPointCoords = obj.zprvRoiConvertPixels2Angle([x y],hAx,true);
			
			if isempty(angularPointCoords)
				return;
			end
			
			% Add the new Point ROIs...
            roiIDs = zeros(1,size(angularPointCoords,1));
			gotoOnAddCache = obj.roiGotoOnAdd;
			obj.roiGotoOnAdd = false;
            obj.doSuppressTableUpdates = true;
            hWaitbar = waitbar(0,'Adding Point ROIs');
			for i=1:size(angularPointCoords,1)
                if i == size(angularPointCoords,1)
                    obj.roiGotoOnAdd = gotoOnAddCache;
                    obj.doSuppressTableUpdates = false; % don't update the view until the last point
                end
				roiIDs(i) = obj.roiAddPoint(angularPointCoords(i,:),hAx);
				waitbar(i/size(angularPointCoords,1),hWaitbar);
			end
			close(hWaitbar);
            
			obj.doSuppressTableUpdates = false;
            obj.roiUpdateROITable();
            obj.roiUpdatePositionTable();
        end
        
		function roiID = roiAddPoint(obj,posn,hAx)
			% Adds a single 'point' ROI at the given position.
            %
			% posn: the position (given in angular coordinates) of the new Point
            % hAx: a handle to the Axes object that the point was "drawn" on.
            %
            % roiID: the ID of the newly created ROI.
           
            % if called without args, prompt user for graphical selection
            if nargin < 2 || isempty(posn)
                roiID = obj.roiAddPoints(1);
                return;
            end
            
            global state;
            roiID = [];
			
			% ensure we have EOA data
			if isempty(obj.roiLastAcqCache)
				obj.zprvError('Cannot create ROI', 'Unable to create ROI: No acquired data.')
				return;
			end
            
            if nargin < 3 || isempty(hAx)
                % if no Axes handle given, assume channel-1 display
                hAx = state.internal.axis(1);
            end
            
			% construct the ROI structure
			s = struct();
			s.RSPs.scanAngleMultiplierFast = 0;
			s.RSPs.scanAngleMultiplierSlow = 0;
			s.RSPs.scanShiftFast = posn(1);
			s.RSPs.scanShiftSlow = posn(2);
			s.RSPs.scanRotation = 0;

			roiID = obj.roiAddNew(s,[],hAx);
			if roiID < 1
				return;
            end
        end
        
		function roiIDs = roiAddGrid(obj,gridSize,gridShift,isGridShiftInMicrons,scanAngleMultiplier,zoomFactor,rotation,angleToMicronsFactor)
			% Adds a grid of ROIs, which can be points, lines, or rectangles/square
			%
			% gridSize: a 2-vector specifying the MxN size of the grid.
			% gridShift: <Default=[0 0]> a 2-vector specifying the x,y offset to be added to the grid. TODO: MxN next to x,y feels bad
			% isGridShiftInMicrons: <Default=false> a boolean that, if true, specifies that the gridShift units are in microns.
            % scanAngleMultiplier: <Default=[0 0]> a 2-vector specifying scanAngleMultiplierFast/Slow for ROIs to add
            % zoomFactor: <Default=1> zoom factor for ROIs to add
            % rotation: <Default=0> rotation, in degrees, for ROIs to add
			% angleToMicronsFactor: an integer specifying the angle->micron conversion factor for the current rig.
            %
			% roiIDs: a vector of created ROI IDs.
			
			roiIDs = [];
			
			global state;
            
            if nargin < 8 || isempty(angleToMicronsFactor)
                angleToMicronsFactor = obj.roiAngleToMicronsFactor;
            end
                
            if nargin < 7 || isempty(rotation)
                rotation = 0;
            end
            
            if nargin < 6 || isempty(zoomFactor)
                zoomFactor = 1;
            end
            
            if nargin < 5 || isempty(scanAngleMultiplier)
                scanAngleMultiplier = [0 0];
            end
			
			if nargin < 4 || isempty(isGridShiftInMicrons)
				isGridShiftInMicrons = false;
			end
			
			if nargin < 3 || isempty(gridShift)
				gridShift = [0 0];
			end
			
			if nargin < 2
				obj.hController{1}.macroGrid();
				return;
			end
            
			padX = state.acq.pixelsPerLine/(gridSize(2));
			padY = state.acq.linesPerFrame/(gridSize(1));
			
			if isGridShiftInMicrons
				angleMultiplier = [state.acq.scanAngleMultiplierFast*state.init.scanAngularRangeReferenceFast ...
									state.acq.scanAngleMultiplierSlow*state.init.scanAngularRangeReferenceSlow ];
				gridShift = ((gridShift./angleToMicronsFactor)./angleMultiplier).*[state.acq.pixelsPerLine state.acq.linesPerFrame];
			end

            roiType = obj.computeROIType(scanAngleMultiplier(1),scanAngleMultiplier(2));
            
            % all ROIs that are part of a 'grid' get assigned to an all-NaN PDO. 
			% Temporarily make this PDO the 'active', so that all created ROIs 
			% get assigned to it. (And create this PDO, if necessary.)
            nanPositionID = obj.roiAddPosition(struct('motorX',nan,'motorY',nan,'motorZ',nan,'motorZZ',nan));           
            allNanROIID = obj.roiAddNew(struct('positionID',nanPositionID));

            % temporarily disable 'roiXXXOnAdd'
            gotoOnAddCache = obj.roiGotoOnAdd;
            snapOnAddCache = obj.roiSnapOnAdd;
            obj.roiGotoOnAdd = false;
            obj.roiSnapOnAdd = false;
            
			roiIDs = zeros(1,gridSize(1)*gridSize(2));
            obj.doSuppressTableUpdates = true;
            hWaitbar = waitbar(0,'Adding ROIs on grid...');            
            for j = 1:gridSize(1)
                for i = 1:gridSize(2)
                                 
					%Determine grid point in angular coordinates for fast/slow axes
					fsPixels= [i*padX - padX/2 + gridShift(1), j*padY - padY/2 + gridShift(2)];
					fsAngular = obj.zprvRoiConvertPixels2Angle(fsPixels);

					s.RSPs.scanShiftFast = fsAngular(1);
					s.RSPs.scanShiftSlow = fsAngular(2);                            
					s.RSPs.scanAngleMultiplierFast = scanAngleMultiplier(1);
					s.RSPs.scanAngleMultiplierSlow = scanAngleMultiplier(2);
					s.RSPs.zoomFactor = zoomFactor;
					s.RSPs.scanRotation = rotation;
					
					s.parentROIID = allNanROIID;
					s.type = roiType;
					
					roiIDs((j-1)*gridSize(2) + i) = obj.roiAddNew(s);
                    
                    waitbar(((j-1)*gridSize(2) + i)/(gridSize(1)*gridSize(2)),hWaitbar);
                end
            end                                    
            close(hWaitbar);
            
            % restore the state
            obj.doSuppressTableUpdates = false;
%             obj.activePositionID = activePositionIDCache;
            obj.roiGotoOnAdd = gotoOnAddCache;
            obj.roiSnapOnAdd = snapOnAddCache;            

            obj.roiUpdateROITable();
            obj.roiUpdatePositionTable();
        end
        
        function roiAddCenterPoint(obj)
			% Adds a single 'point' ROI centered in the acquisition window.
			
            s = struct();
			s.scanAngleMultiplierFast = 0;
			s.scanAngleMultiplierSlow = 0;
			s.scanShiftFast = 0;
			s.scanShiftSlow = 0;
			s.scanRotation = 0;
			
			%Add to ROI Spec Table
			roiID = obj.roiAddNew(s);
			
			if roiID < 1
				return;
            end
		end
        
		
        function roiID = roiAddLine(obj)
            % Adds a new Line ROI.
            
            global state gh;
            
			done = 0;
            roiID = [];
			
			% ensure we have EOA data
			if isempty(obj.roiLastAcqCache)
				obj.zprvError('Cannot add ROI', 'Unable to create ROI: No acquired data.');
				return;
			end
			
			% make sure it makes sense to add a new ROI, given the current scan configuration
			currentType = obj.computeROIType(state.acq.scanAngleMultiplierFast,state.acq.scanAngleMultiplierSlow);
			if strcmp(currentType,'line')
                obj.zprvError('Cannot add ROI', 'Unable to add ROI under current scan configuration.');
                return;
			elseif strcmp(currentType,'point')
				obj.zprvError('Cannot add ROI', 'Unable to add ROI under current scan configuration.');
				return;
			end
			
            %Determine target figure            
			hAx = si_selectImageFigure();
			if isempty(hAx)
				return;
			end

			sizeImage = [diff(get(hAx,'XLim')) diff(get(hAx,'YLim'))];
			
            %Extract ROI coordinates from target figure 
            [x, y]= getPointsFromAxes(hAx, 'Cursor', 'crosshair', 'nomovegui', 1,'numberOfPoints',2,'LineColor',[0.5 0.5 0.5],'LineWidth',2,'Marker','x','MarkerEdgeColor',[0.5 0.5 0.5],'MarkerSize',8,'EraseMode','normal');
            if isempty(x) || isempty(y) || length(x) ~= 2 || length(y) ~= 2
                return
            end

            if hAx == obj.hROIDisplayAx
                shownROIStruct = obj.roiDataStructure(obj.shownROI);
                scanRotationCurrent = shownROIStruct.RSPs.scanRotation;
                zoomFactorCurrent = shownROIStruct.RSPs.zoomFactor;
                samFastCurrent = shownROIStruct.RSPs.scanAngleMultiplierFast;
                samSlowCurrent = shownROIStruct.RSPs.scanAngleMultiplierSlow;
                scanShiftFastCurrent = shownROIStruct.RSPs.scanShiftFast;
                scanShiftSlowCurrent = shownROIStruct.RSPs.scanShiftSlow;
            else
                % transform pixel coords, accounting for Scan Angle Multiplier ~= 1
                dx = abs(x(2)-x(1));
                dy = abs(y(2)-y(1));
                x(1) = x(1) + (1-obj.roiLastAcqCache.RSPs.scanAngleMultiplierFast)*state.acq.pixelsPerLine/2;
                y(1) = y(1) + (1-obj.roiLastAcqCache.RSPs.scanAngleMultiplierSlow)*state.acq.linesPerFrame/2;
                x(2) = x(1) + dx*obj.roiLastAcqCache.RSPs.scanAngleMultiplierFast;    
                y(2) = y(1) + dy*obj.roiLastAcqCache.RSPs.scanAngleMultiplierSlow;
                
                scanRotationCurrent = obj.roiLastAcqCache.RSPs.scanRotation;
                zoomFactorCurrent = obj.roiLastAcqCache.RSPs.zoomFactor;
                samFastCurrent = obj.roiLastAcqCache.RSPs.scanAngleMultiplierFast;
                samSlowCurrent = obj.roiLastAcqCache.RSPs.scanAngleMultiplierSlow;
                scanShiftFastCurrent = obj.roiLastAcqCache.RSPs.scanShiftFast;
                scanShiftSlowCurrent = obj.roiLastAcqCache.RSPs.scanShiftSlow;
            end
            
			xNormalized = x./sizeImage(1) - 0.5;
			yNormalized = y./sizeImage(2) - 0.5;

			s = struct();
            
			% normalize and calculate scan rotation (in degrees)
			dx = xNormalized(2) - xNormalized(1);
			dy = yNormalized(2) - yNormalized(1);
			delta = sqrt(power(dx,2) + power(dy,2));
			scanRotation = scanRotationCurrent - asind(dy/delta);
			if abs(atan2(dy,dx)) > pi/2
				scanRotation = -scanRotation;
			end
			s.RSPs.scanRotation = scanRotation;
			
			% calculate scan angle multiplier	
			s.RSPs.zoomFactor = round((zoomFactorCurrent/delta)*10)/10;
			
			s.RSPs.scanAngleMultiplierFast = samFastCurrent;
			s.RSPs.scanAngleMultiplierSlow = 0;

			% determine scan shift (determined by the mid-point of the line)
			midPointNormalized = [((x(1) + x(2))/2)/sizeImage(1) - 0.5, ((y(1) + y(2))/2)/sizeImage(2) - 0.5];
			s.RSPs.scanShiftFast = scanShiftFastCurrent + (midPointNormalized(1)/zoomFactorCurrent)*(samFastCurrent*state.init.scanAngularRangeReferenceFast);
			s.RSPs.scanShiftSlow = scanShiftSlowCurrent + (midPointNormalized(2)/zoomFactorCurrent)*(samSlowCurrent*state.init.scanAngularRangeReferenceSlow);
			
            s.type = 'line';
            
			%Add to ROI Spec Table
			roiID = obj.roiAddNew(s,[],hAx);
		end
		
		
		function positionID = roiAddPosition(obj,position,positionID)
            % Adds a new Position (PDO).
            %
            % position: 3 or 4 vector specifying *absolute* position, or a positionStruct with fields motorX/Y/Z/ZZ
            % positionID: Integer identifying position. 
            
			global state;
            
            if nargin < 3 || isempty(positionID)
                % determine the new Position ID.
                existingKeys = obj.positionDataStructure.keys();
                if isempty(existingKeys)
                    positionID = 1;
                else
                    positionID = max([existingKeys{:}]) + 1;
                end
            end
            
            if nargin < 2 || isempty(position)
               
                if ~state.motor.motorOn
                    obj.zprvError('No motor.','No motor is currently configured; adding positions is disabled.');
                    return;
                end
                
                %Update the motor position 
                motorGetPosition();
                                
                position = [state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition];
                
                if state.motor.motorZEnable
                    position(end+1) = state.motor.absZZPosition;
                else
                    position(end+1) = NaN;
                end
                
                doUpdateActivePosition = true;
            else
                doUpdateActivePosition = false;
            end
                
            if ~isstruct(position)
                if state.motor.motorZEnable && length(position) == 3
                    position(4) = NaN;
                end
                
                % make sure the given position doesn't already exist...
                [isDefined, positionIDExisting] = obj.isPositionDefined(position);
				if isDefined
					positionID = positionIDExisting;
                    obj.zprvError('Position exists.',['Position already exists: #' num2str(positionID)]);
                    return;
				end

                % populate all fields with current values
                positionStruct = struct('motorX',position(1),'motorY',position(2),'motorZ',position(3));
                if state.motor.motorZEnable
                    positionStruct.motorZZ = position(4);
                else
                    positionStruct.motorZZ = NaN;
				end
            else
                positionStruct = position;
                if isempty(positionID)
                    error('Invalid Position ID');
                end
            end

            suffixes = {'X' 'Y' 'Z' 'ZZ'};
            isAllNan = true;
            for i = 1:length(suffixes)
                if ~isnan(positionStruct.(['motor' suffixes{i}]))
                    isAllNan = false;
                    break;
                end
            end
            
            % if there's no motor, only allow all-NaN Positions
            if (~isfield(state,'motor') || ~state.motor.motorOn) && ~isAllNan
                obj.zprvError('No motor','Unable to add Position: no motor.');
                return;
            end
            
			obj.positionDataStructure(positionID) = positionStruct;
			
			% update the current position
            if doUpdateActivePosition
                obj.activePositionID = positionID;
            end

            if ~obj.doSuppressTableUpdates
                obj.roiUpdatePositionTable(); 
            end
        end
        
        function wasPositionApplied = roiGotoPosition(obj,posnID)
            % Moves the motor to the given Position ID.
            %
            % posnID: the PDO to go to.  If empty, the currently selected Position will be used.
            %
            % wasPositionApplied: a boolean that, if true, indicates that the motor position was successfully applied.
            
            wasPositionApplied = false;
            
            global state;
            if ~state.motor.motorOn
                obj.zprvError('No motor','No motor is currently configured; motor moves are disabled.');
                return;
            end
            
            if nargin < 2 || isempty(posnID)
                if isempty(obj.selectedPositionID)
                    obj.zprvDisp('No Position selected.');
                    return; % should never get here
                end
                posnID = obj.selectedPositionID;
            else
                if posnID ~= obj.selectedPositionID
                   % ideally, in this case we could programmatically select the given posnID in the table, but in lieu of that, 
                   % just set 'selectedPositonID' to empty.
                   obj.selectedPositionID = [];
                end
            end

            motorPositionGoto(posnID);
            
            wasPositionApplied = true;
        end
        
        function roiGotoLastLine(obj,doGotoParent)
            % Applies the 'last line' ROI.
            %
            % doGotoParent: a boolean that, if true, indicates to go the the *parent* of the last line.
            
			if nargin < 2 || isempty(doGotoParent)
                doGotoParent = false;
            end
			
			if isempty(obj.roiLastLine)
				if doGotoParent
					obj.zprvDisp('No ''last line'' defined.');
					return;
				end
				
				% if a line doesn't exist, create one...
				roiID = obj.roiAddLine();
				if obj.roiGotoOnAdd
					% the line has already been gone to...
					return;
				end
			else
				roiID = obj.roiLastLine;
			end
            
            if doGotoParent
                lastLineStruct = obj.roiDataStructure(obj.roiLastLine);
                if isfield(lastLineStruct,'parentROIID')
                    obj.roiGotoROI(lastLineStruct.parentROIID);
                end
            else
                obj.roiGotoROI(roiID);
            end
            
        end        

       
        function wasROIApplied = roiGotoROI(obj,roiID,doSuppressMotorMove,doSuppressMoveWarning)
            % Applies the selected ROI: applies all ROI scan parameters and goes to the associated motor position.
            %
            % roiID: the ROI to be applied.
            % doSuppressMotorMove: a boolean that, if true, indicates that any motor-position should not be applied.
			% doSuppressMoveWarning: a boolean that, if true, indicates to ignore 'roiWarnOnMove'. (useful for cycle-mode)
            %
            % wasROIApplied: a boolean that, if true, indicates that then ROI was successfully applied.
            
			wasROIApplied = false;
			
            if obj.roiLoading
				return;
            end
            
            if nargin < 4 || isempty(doSuppressMoveWarning)
                doSuppressMoveWarning = false;
            end
            
            if nargin < 3 || isempty(doSuppressMotorMove)
                doSuppressMotorMove = false; 
            end
			
            if nargin < 2 || isempty(roiID)
                if isempty(obj.selectedROIID) || length(obj.selectedROIID) > 1
                    obj.zprvDisp('Invalid ROI.');
                    return;
                end
                roiID = obj.selectedROIID;
            end
            
            global state;

            roiType = '';
			
            % 			if obj.lineScanEnable
            % 				obj.roiSuppressLinescanSideEffects = true;
            % 				obj.lineScanEnable = false;
            % 				obj.roiSuppressLinescanSideEffects = false;
            % 			end
            
            try
                if ~obj.roiDataStructure.isKey(roiID)
                   obj.zprvDisp('Invalid ROI ID.');
                   return;
                end
                
				roiStruct = obj.roiDataStructure(roiID);
                rspStruct = roiStruct.RSPs;
                    
                roiType = roiStruct.type;
                
				% Apply RSPs
                if ~isinf(rspStruct.zoomFactor)
					setZoomValue(rspStruct.zoomFactor,true);
                end
                
                scanParams = {'scanShiftFast' 'scanShiftSlow' 'scanRotation' 'scanAngleMultiplierFast' 'scanAngleMultiplierSlow'};
                changedParams = {};

                
                for i = 1:length(scanParams)
                    paramName = scanParams{i};
                    
                    if state.acq.(scanParams{i}) ~= rspStruct.(paramName)
                        changedParams{end+1} = paramName;
                    end                       
                                        
                    state.acq.(scanParams{i}) = rspStruct.(paramName);
                    updateGUIByGlobal(['state.acq.' paramName]);                                                    
                end
                
                %VI121311: should we call updateRSPs() here?
 
                %Execute appropriate INI callbacks (not invoked automatically by updateGUIByGlobal)
                if any(ismember({'scanAngleMultiplierFast' 'scanAngleMultiplierSlow'},changedParams))
                    resetImageProperties();
                elseif ismember('scanAngleMultiplierSlow',changedParams)
                    updateScanAngleMultiplierSlow();
                end                
                                
                % Apply the motor position
                if state.motor.motorOn && ~doSuppressMotorMove
        
                    position = [];
                    if isfield(roiStruct,'positionID') && roiID ~= obj.ROI_ROOT_ID
                        position = roiStruct.positionID;
                    elseif roiID ~= obj.ROI_ROOT_ID
                        ancestorStruct = obj.roiDataStructure(obj.roiGetOldestAncestor(roiID));
                        if isfield(ancestorStruct,'positionID')
                            position = ancestorStruct.positionID;
                        end
                    end

                    % make the move if necessary, otherwise just update the active ROI.
                    if ~isempty(position) && position ~= obj.ROI_BASE_ID && (isempty(obj.activePositionID) || position ~= obj.activePositionID)
                        if obj.roiWarnOnMove && ~(doSuppressMoveWarning || state.cycle.cycling)
                            % prompt the user for confirmation
                            choice = questdlg('This GOTO operation involves a motor-move; would you like to proceed?', ...
                                'GOTO warning', ...
                                'Yes','No','Don''t warn me again','Yes');
                            switch choice
                                case 'No'
                                    return;
                                case 'Don''t warn me again'
                                    obj.roiWarnOnMove = false;
                            end
                        end
                        motorPositionGoto(position);
                    else
                        obj.roiUpdateActiveROI();
                    end
                else
                    obj.activeROIID = roiID;
                end
                
			catch ME
				ME.throwAsCaller();
            end
            
            % if this is a line, cache the ID
            if strcmpi(roiType,'line')
                obj.roiLastLine = roiID;
            end
            
            obj.roiIsShownROIOutOfSync = false;
			wasROIApplied = true;
        end
        
        function roiEOA_Listener(obj,~,~)
            % Updates the internal 'End Of Acqusition' (EOA) cache.

			if si_isAcquiring()
				return;
			end
			
            global state;
            
            % clear any existing cached data
            obj.roiLastAcqCache = struct();
        
            % Read motor position, cache as 'last acquired' motor position
            if ~state.motor.motorOn
                obj.roiLastAcqCache.position = [nan nan nan];
            else
                obj.roiLastAcqCache.position = motorGetPosition();
            end
        
            % Cache the RSPs that were used as 'last acquired' RSPs
			for i = 1:length(obj.scanParameterNames)
				obj.roiLastAcqCache.RSPs.(obj.scanParameterNames{i}) = state.acq.(obj.scanParameterNames{i});
			end
            
            % prepare the max projections, if necessary
            if obj.roiUseMIPForMRI && state.acq.numberOfZSlices > 1
                calculateMaxProjections();
            end
            
            % Cache the last acquired data – all channels.
            obj.roiLastAcqCache.MRI = cell(1,state.acq.numberOfChannelsImage);
            for i = 1:state.acq.numberOfChannelsImage
                if obj.roiUseMIPForMRI && state.acq.numberOfZSlices > 1 && state.acq.maxImage(i)
                    obj.roiLastAcqCache.MRI{i} = get(state.internal.maximagehandle(i),'CData');%state.acq.maxData(i);
                else
					obj.roiLastAcqCache.MRI{i} = get(state.internal.imagehandle(i),'CData');%state.acq.acquiredData{1}(i);
                end
            end
            
            % Cache the merged data
            if state.acq.channelMerge
                obj.roiLastAcqCache.MRI{5} = state.acq.acquiredDataMerged;
            end
            
            % If the current RSPs (and maybe Position) match an existing RDO, then:
			[isDefined, definedROI, definedPosition] = obj.isCurrentROIDefined();
			
            if isDefined && ~isempty(definedROI) && definedROI ~= obj.ROI_BASE_ID
				% Update stored MRI for that RDO to this recently acquired data
				roiStruct = obj.roiDataStructure(definedROI);
				roiStruct.MRI = obj.roiLastAcqCache.MRI;
				obj.roiDataStructure(definedROI) = roiStruct;
				
                % if this is a top-level ROI, display it--otherwise, display the parent...
                if roiStruct.parentROIID == obj.ROI_ROOT_ID
					obj.shownROI = definedROI;
				else
					obj.shownROI = roiStruct.parentROIID;
                end
				
                % cache the matched ROI
                obj.roiLastAcqCache.definedROI = definedROI;
                
				obj.roiUpdateView();
            else
                obj.roiLastAcqCache.definedROI = [];
                
                if ~isempty(definedPosition)
                    % we matched a position, but the RSPs didn't match; get this PDO's top-level RDO (if one exists).

                    topLevelROIIDExisting = obj.roiGetTopLevelROIID(definedPosition);
                    if ~isempty(topLevelROIIDExisting)
                        % if the effective zoom of the last-acquired data is "more informational" than that of the top-level ROI,
                        % create a new top-level ROI (using the last-acq data) and re-link the existing ROI in the tree.
                        topLevelROIStruct = obj.roiDataStructure(topLevelROIIDExisting);
                        effectiveZoomCached = obj.roiLastAcqCache.RSPs.zoomFactor/(obj.roiLastAcqCache.RSPs.scanAngleMultiplierFast*obj.roiLastAcqCache.RSPs.scanAngleMultiplierSlow);
                        effectiveZoomExisting = topLevelROIStruct.RSPs.zoomFactor/(topLevelROIStruct.RSPs.scanAngleMultiplierFast*topLevelROIStruct.RSPs.scanAngleMultiplierSlow);

                        if effectiveZoomCached < effectiveZoomExisting
                            topLevelROIIDNew = obj.roiAddNewFromAcqCache('positionID',definedPosition);

                            % re-link the existing top-level ROI
                            obj.roiRemoveChildFromParent(topLevelROIIDExisting);
                            obj.roiAddChildToParent(topLevelROIIDNew,topLevelROIIDExisting)

                            topLevelROIID = topLevelROIIDNew;
                        else
                            topLevelROIID = topLevelROIIDExisting;
                        end
                        
                        % SHOW the top-level ROI
                        obj.shownROI = topLevelROIID;
                    end
                end
            end
        end
        
    end
    
    
    %% DEVELOPER METHODS
    
    %Superclass overrides
    methods    
        function tf = notify(obj,eventName,eventData)
            %Event notification method that appends supplied scimData struct to the event's eventData struct, supplied to the event listener(s)

            persistent hEventData
            
            if isempty(hEventData)
                hEventData = scanimage.EventData();
            end
            
            if nargin < 3
                hEventData.scimData = [];
            else
                hEventData.scimData = eventData;
            end
            
            notify@handle(obj,eventName,hEventData);
            
            if obj.listenerAbortFlag
                tf = false;
                obj.listenerAbortFlag = false;
            else
                tf = true;
            end
        end        
    end    
    
    methods  (Hidden)    
        
        function zprvMacroError(obj,errString,varargin)
           if ~isempty(errString)
              setStatusString('Invalid Entry!');
              ME = MException('',errString,varargin{:});
              ME.throwAsCaller();
           end            
        end
        
        function fsAngular = zprvRoiConvertPixels2Angle(obj,fsPixels,hAx,doUseCachedRSPs)
            % Converts pixel coordinates obtained within a particular ROI (at current shift, multiplier, and zoom) into angle coordinates
            %
            % fsPixels: an Mx2 array of pixel coordinates.
            % hAx: an optional argument specifying the axes.
			% doUseCachedRSPS: an optional boolean argument that, if true, specifies to use the scan parameters cached at last acquisition.
            %
            % fsAngular: the computed angular coordinates
            %
			
			fsAngular = [];
            
            global state

            % Pack scalar values into 1x2 vectors.
            scanShift = [state.acq.scanShiftFast state.acq.scanShiftSlow];
            scanAngularRangeReference = [state.init.scanAngularRangeReferenceFast state.init.scanAngularRangeReferenceSlow];
            scanAngleMultiplier = [state.acq.scanAngleMultiplierFast state.acq.scanAngleMultiplierSlow];
            zoomFactor = state.acq.zoomFactor;
            
			if nargin < 3 || isempty(hAx)
				sizeImage = [state.acq.pixelsPerLine  state.internal.storedLinesPerFrame];
            else
                if nargin < 4 || isempty(doUseCachedRSPs)
                    doUseCachedRSPs = false;
                end
                
				sizeImage = [diff(get(hAx,'XLim')) diff(get(hAx,'YLim'))];
                
                if hAx == obj.hROIDisplayAx
                    % if the coords came from the RDF, use the shown ROI's params
                    shownROIStruct = obj.roiDataStructure(obj.shownROI);
                    scanShift = [shownROIStruct.RSPs.scanShiftFast shownROIStruct.RSPs.scanShiftSlow];
                    scanAngleMultiplier = [shownROIStruct.RSPs.scanAngleMultiplierFast shownROIStruct.RSPs.scanAngleMultiplierSlow];
                    zoomFactor = shownROIStruct.RSPs.zoomFactor;
                elseif doUseCachedRSPs
                    scanShift = [obj.roiLastAcqCache.RSPs.scanShiftFast obj.roiLastAcqCache.RSPs.scanShiftSlow];
                    scanAngleMultiplier = [obj.roiLastAcqCache.RSPs.scanAngleMultiplierFast obj.roiLastAcqCache.RSPs.scanAngleMultiplierSlow];
                    zoomFactor = obj.roiLastAcqCache.RSPs.zoomFactor;
                end
			end

            m = size(fsPixels,1);
            fsAngular = zeros(m,2);
            for i = 1:m
                fsNormalized = fsPixels(i,:)./sizeImage - 0.5;
                fsAngular(i,:) = scanShift + fsNormalized .* (scanAngularRangeReference .* scanAngleMultiplier)./zoomFactor;
            end
        end

        function [isDefined, definedPosition] = isCurrentPositionDefined(obj)
            % Determines if the current motor position matches any of the defined Position IDs.
            % NOTE: Assumes motor position has already/recently been read            
            %
            % isDefined: a boolean that, if true, indicates that the current motor position is defined.
            % definedPosition: the ID of the defined Position, if one exists.
            
            global state;
            
            if ~state.motor.motorOn
                isDefined = true;
                definedPosition = 0;
                return;
            end
            
            currentPos = [state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition];
            if state.motor.motorZEnable
                currentPos(end+1) = state.motor.absZZPosition;
            end
            [isDefined, definedPosition] = obj.isPositionDefined(currentPos);
		end
        
		function [isDefined, definedROI, definedPosition] = isCurrentROIDefined(obj)
			% Determines if the current RSPs (and possibly position) match an existing ROI (or PDO).
			%
            % isDefined: a boolean that, if true, indicates an existing ROI matches the current RSPs.
            % definedROI: the integer ID of the existing ROI (if one exists).
            % definedPosition: the integer ID of the existing Position (if one exists).
            
			isDefined = false;
			definedROI = [];
			definedPosition = [];
			
			% first determine if this position is defined
			[isPositionDefined, definedPosition] = obj.isCurrentPositionDefined();
			if ~isPositionDefined
				return;
			end
			
			topLevelROI = obj.positionID2roiID(definedPosition);
			if isempty(topLevelROI)
				return;
			end
            
			% start at the top-level ROI and walk down, looking for a matching ROI
			[isDefined, definedROI] = obj.roiDoCurrentRSPsMatchExistingROI(topLevelROI);
		end
		
		function [doesMatch, matchingROI] = roiDoCurrentRSPsMatchExistingROI(obj,existingROIID)
			% Determines if the current scan-parameters match the given ROI (or, if not, any of its descendants).
            %
            % existingROIID: the integer ID of the ROI to be checked against. 
            %
            % doesMatch: a boolean that, if true, indicates that the RSPs match the given ROI.
			% matchingROI: the integer ID of the matching ROI (if one exists).
            
			global state;
			
			doesMatch = false;
			matchingROI = [];
			
            if nargin < 2 || isempty(existingROIID) || ~obj.roiDataStructure.isKey(existingROIID) || ~isfield(obj.roiDataStructure(existingROIID),'RSPs')
				return;
            end
        
			roiStruct = obj.roiDataStructure(existingROIID);
			rspStructExisting = roiStruct.RSPs;
            
            % construct a struct out of the current RSPs
            rspStructCurrent = struct();
            for i = 1:length(obj.scanParameterNames)
                rspStructCurrent.(obj.scanParameterNames{i}) = state.acq.(obj.scanParameterNames{i});
            end
           
            doAllRSPsMatch = obj.roiIsEqualRSPs(rspStructExisting,rspStructCurrent);
			
			if doAllRSPsMatch
				doesMatch = true;
				matchingROI = existingROIID;
			elseif isfield(roiStruct,'children')
				% if we don't have a match, check this ROI's children
				children = roiStruct.children;
				for i = 1:length(children)
					[doesMatch, matchingROI] = obj.roiDoCurrentRSPsMatchExistingROI(children(i));
					if doesMatch
						return;
					end
				end
			end
		end
		
        function [isDefined, definedPosition] = isPositionDefined(obj, posnVector)
			% Determines if the given motor position matches any of the defined Position IDs.
            
			global state;
			
			isDefined = false;
			definedPosition = [];
			
            if nargin < 2 || isempty(posnVector)
				if isempty(obj.activePositionID)
					return;
				end
				
                % if empty, use the active position
                if isempty(obj.activePositionID)
                    error('Specify a Position.');
                end
                activePositionStruct = obj.positionDataStructure(obj.activePositionID);
                posnVector = [activePositionStruct.motorX activePositionStruct.motorY activePositionStruct.motorZ];
                if isfield(activePositionStruct,'motorZZ')
                    posnVector(4) = activePositionStruct.motorZZ;
                end
            end

			% iterate over all Position entries
            keys = state.hSI.positionDataStructure.keys();
            keys(1) = []; % remove the root entry
            for i = 1:length(keys)
                currentStruct = obj.positionDataStructure(keys{i});
                currentVector = [currentStruct.motorX currentStruct.motorY currentStruct.motorZ];
                if isfield(currentStruct,'motorZZ')
                    currentVector(4) = currentStruct.motorZZ;
                end
                
                if obj.roiIsEqualPosition(posnVector,currentVector)
                    isDefined = true;
                    definedPosition = keys{i};
                    return;
                end
            end
        end
        
        function roiID = positionID2roiID(obj,posnID)
           % Returns the top-level ROI ID posessing the given Position ID (if one exists).
           %
           % posnID: an integer specifying a valid PDO.
           
           roiID = [];
           
           keys = obj.roiDataStructure.keys();
           for i = 1:length(keys)
               if isfield(obj.roiDataStructure(keys{i}),'parentROIID') && obj.roiDataStructure(keys{i}).parentROIID == obj.ROI_ROOT_ID ... 
                   && isfield(obj.roiDataStructure(keys{i}),'positionID') && obj.roiDataStructure(keys{i}).positionID == posnID
                   roiID = keys{i};
                   return;
               end
           end
        end
        
        function roiID = roiAddNew(obj,roiStruct,roiID,hAx,doSuppressAutoActions)
            % Adds a new ROI.
            %
            % roiStruct: Structure containing one or more of the fields: {'zoomFactor' 'scanShiftFast' 'scanShiftSlow' 'scanRotation' 'scanAngularRangeFast' 'scanAngularRangeSlow'}
            % roiID: an optional ID to use for this ROI (useful when loading from a file).
            % hAx: a valid handle to the Axes on which this ROI was 'drawn'
            % doSuppressAutoActions: a boolean that, if true, indicates to ignore 'roiGotoOnAdd' and 'roiSnapOnAdd'
            
            global state
           
            if nargin < 2 || isempty(roiStruct)
				% no arguments means user clicked 'CUR': fill the empty roiStruct with current scan values
                roiStruct = struct();
                isCUR = true;
            else
                if isfield(roiStruct,'RSPs')
                    isCUR = false;
                else
                    isCUR = true;
                end
            end

            if nargin < 3 || isempty(roiID)
                roiID = []; 
            end
            
            if nargin < 4 || isempty(hAx)
                hAx = [];
            else
                if hAx == obj.hROIDisplayAx && (isempty(obj.shownROI) || obj.shownROI < 1)
                    obj.zprvError('Cannot add ROI','Unable to add ROI: no shown ROI.');
                    return;
                end
			end
			
			if nargin < 5 || isempty(doSuppressAutoActions)
				doSuppressAutoActions = false;
            end
            
            childROIID = []; 
            % determine the target parent
            if ~isfield(roiStruct,'parentROIID')
                if isfield(roiStruct,'positionID')
                    roiStruct.parentROIID = obj.roiGetTopLevelROIID();
                    if isempty(roiStruct.parentROIID)
                        roiStruct.parentROIID = obj.ROI_ROOT_ID;
                    end
                else
                    if nargin < 4
                        hAx = [];
                    end

                    [parentROIID, childROIID] = obj.roiGetTargetParent(hAx);
                    if isempty(parentROIID)
                        return;
                    else
                        roiStruct.parentROIID = parentROIID; 
                    end
                end
            end
            
            % Update roiType
            if ~isfield(roiStruct,'type') 
                if ~isfield(roiStruct,'RSPs') || ~isfield(roiStruct.RSPs,'scanAngleMultiplierFast') || ~isfield(roiStruct,'RSPs') || ~isfield(roiStruct.RSPs,'scanAngleMultiplierSlow')
                    roiStruct.type = obj.computeROIType(state.acq.scanAngleMultiplierFast,state.acq.scanAngleMultiplierSlow); 
                else
                    roiStruct.type = obj.computeROIType(roiStruct.RSPs.scanAngleMultiplierFast,roiStruct.RSPs.scanAngleMultiplierSlow); 
                end
            end
            
            % if this is a Line, cache this ROI as the 'last line'
            if strcmpi(roiStruct.type,'line')
                obj.roiLastLine = roiID;
            end
			
            % Fill in any fields unspecified in roiStruct
            roiFields = obj.scanParameterNames;
			if strcmp(roiStruct.type,'point')
				roiFields = setdiff(roiFields, 'zoomFactor');
                roiStruct.RSPs.zoomFactor = 1;
			end
            for i=1:length(roiFields)
                if (~isfield(roiStruct,'RSPs') || ~isfield(roiStruct.RSPs,roiFields{i}))
					if isfield(obj.roiLastAcqCache,'RSPs') && isfield(obj.roiLastAcqCache.RSPs,roiFields{i})
						roiStruct.RSPs.(roiFields{i}) = obj.roiLastAcqCache.RSPs.(roiFields{i});
					else
						roiStruct.RSPs.(roiFields{i}) = state.acq.(roiFields{i});
					end
                end
            end

            % Determine the new roiID value:
            if isempty(roiID)
                existingIDs = obj.roiDataStructure.keys();
                existingIDs([existingIDs{:}] < 1) = [];
                if isempty(existingIDs)
                    roiID = 1;
                else
                    roiID = max([existingIDs{:}]) + 1;
                end
            end
            
            % CUR ROIs need some extra attention...
            if isCUR
                if roiStruct.parentROIID == obj.ROI_ROOT_ID
                    roiStruct.positionID = obj.activePositionID;
                end
                
                roiStruct.MRI = obj.roiLastAcqCache.MRI;
                
                % update the EOA cache to reflect the addition of this ROI
                obj.roiLastAcqCache.definedROI = roiID;
            end
			
			% insert our struct into the master map
			obj.roiDataStructure(roiID) = roiStruct;

            % update the parent's list of children
            obj.roiAddChildToParent(roiStruct.parentROIID, roiID);
            
            % re-link existing ROI, if necessary
            if ~isempty(childROIID)
                obj.roiAddChildToParent(roiID,childROIID); 
            end
            
			obj.doSuppressTableUpdates = true;
            % update the displayed ROI
            obj.shownROI = roiStruct.parentROIID;
            
            % Draw the shape (but only if this ROI's parent is currently displayed)
            if roiStruct.parentROIID == obj.shownROI
                obj.roiDrawMarker(roiID);
            end
			
			if obj.roiGotoOnAdd && ~doSuppressAutoActions && ~obj.roiLoading
				obj.roiGotoROI(roiID);
				
				% only take a snapshot if 'goto-on-add' is enabled
				if obj.roiSnapOnAdd
					snapShot();
					while state.internal.snapping
						pause(0.1);
					end
				end
			end
			
			obj.doSuppressTableUpdates = false;
			obj.roiUpdateROITable();
            obj.roiUpdateView();
		end
		
		function roiID = roiAddNewFromAcqCache(obj,varargin)
			% Adds a new ROI using the RSPs cached from the last acquisition.
			%
            % varargin: an optional list of key/val pairs specifying additional struct fields to add.
            %
			
            if nargin > 1
                propMap = obj.extractPropValArgMap(varargin,{'parentROIID','positionID'}); 
                propKeys = propMap.keys;
            else
                propKeys = [];
            end
            
            roiStruct = struct('type','square','RSPs',obj.roiLastAcqCache.RSPs,'MRI',{obj.roiLastAcqCache.MRI(:)'}); % DEQ20110811 - not sure about this goofy array indexing...but it works
			
            % assign all optional args
            for i = 1:length(propKeys)
                roiStruct.(propKeys{i}) = propMap(propKeys{i});
            end
            
			% if we have a position ID, but no parent ID, force this new ROI to be top-level
			if isfield(roiStruct,'positionID') && ~isfield(roiStruct,'parentROIID')
				roiStruct.parentROIID = obj.ROI_ROOT_ID;
			end
			
			roiID = obj.roiAddNew(roiStruct,[],[],true);
        end
        
        function roiAddChildToParent(obj, parentROIID, childROIID)
            % Assigns a parent/child hierarchy between the two given ROIs.
            %
            % parentROIID: a valid ROI ID representing the parent.
            % childROIID: a valid ROI ID representing the child to be added.
            %
            
            % update the parent's 'children' field, adding the new child ID
            if isfield(obj.roiDataStructure(parentROIID),'children')
                children = obj.roiDataStructure(parentROIID).children;
            else
                children =[];
            end
            parentROIStruct = obj.roiDataStructure(parentROIID);
            parentROIStruct.children = [children childROIID];
            obj.roiDataStructure(parentROIID) = parentROIStruct;
            
            % update the child's parent field
            childROIStruct = obj.roiDataStructure(childROIID);
            childROIStruct.parentROIID = parentROIID;
            
            % if the child has a position reference, but is not a direct
            % child of ROOT, clear the position reference.
            if isfield(childROIStruct, 'positionID') && parentROIID ~= obj.ROI_ROOT_ID
                childROIStruct = rmfield(childROIStruct,'positionID');
            end
            
            obj.roiDataStructure(childROIID) = childROIStruct;
        end
        
		function roiRemoveChildFromParent(obj, childROIID)
			% Deletes the parent/child hierarchy for the given ROI
			% 
			% parentROIID: a valid ROI ID representing the parent.
			% childROIID: a valid ROI ID representing the child to be removed.
            
            existingChildROIStruct = obj.roiDataStructure(childROIID);
			existingParentROIID = existingChildROIStruct.parentROIID;
            existingChildROIStruct.parentROIID = []; % NOTE: this is now a dangling ROI--the user is responsible for re-linking.
			obj.roiDataStructure(childROIID) = existingChildROIStruct;
            
			parentROIStruct = obj.roiDataStructure(existingParentROIID);
			parentROIStruct.children(parentROIStruct.children == childROIID) = [];
			obj.roiDataStructure(existingParentROIID) = parentROIStruct;
        end
		
        function roiID = roiFindMatchingROIAtPosition(obj, posnID, rspStruct)
            % Returns the ROI ID matching the given RSPs at the given position.
            %
            % posnID: the position ID to search at
            % rspStruct: an RDO struct
            %
            % roiID: a valid ROI ID matching 'rspStruct', (empty if no matching ROI exists).
            
            roiID = [];
            
            topLevelROIID = obj.roiGetTopLevelROIID(posnID);
            if isempty(topLevelROIID)
                return;
            end
            
            % starting at 'topLevelROIID', walk down all branches of the tree, looking for the first matching node.
            roiID = obj.roiFindMatchingRSPs(topLevelROIID,rspStruct);
        end
        
        function roiID = roiFindMatchingRSPs(obj, startingROIID, rspStruct)
            
            roiID = [];
            
            startingROIStruct = obj.roiDataStructure(startingROIID);
            if isfield(startingROIStruct,'children')
                children = startingROIStruct.children(startingROIStruct.children > obj.ROI_BASE_ID);
            else
                children = []; % causes exuecution to fall through if RSP test fails
			end
			
			candidates = [startingROIID children];
			
            % go through all of the top-level ROI's children, returning
            % the first one to match 'rspStruct'
            for i = 1:length(candidates)
                if obj.roiIsEqualRSPs(rspStruct,obj.roiDataStructure(candidates(i)).RSPs)
                    roiID = candidates(i);
                    return;
                elseif isempty(candidates)
                    return;
				elseif candidates(i) ~= startingROIID
                    roiID = obj.roiFindMatchingRSPs(candidates(i),rspStruct);
                end
            end
        end
        
        function childrenROIIDs = roiGetDisplayedChildren(obj)
            % Returns a list of descendants of the currently shown ROI, given the current display depth.
            %
            % childrenROIIDs: a list of descendant ROI IDs down to the current display depth.
            
            % construct a list of children, dependant on the current ROI Display Depth.
            childrenROIIDs = [];
            currentLevelIDs = obj.shownROI;
            % iterate to the specified display depth
            for i = 1:min(999,obj.roiDisplayDepth + 1) % DEQ20110830: I think it's safe to assume no hierarchy will be deeper than 999 levels...
                nextLevelIDs = [];
                for j = 1:length(currentLevelIDs)
                    % add the current child to the master list of children
                    childrenROIIDs = [childrenROIIDs currentLevelIDs(j)];
                    
                    % construct a list of the next level of IDs
                    currentChildStruct = obj.roiDataStructure(currentLevelIDs(j));
                    if ~isfield(currentChildStruct,'children') || isempty(currentChildStruct.children)
                        continue;
                    end
                    nextLevelIDs = [nextLevelIDs currentChildStruct.children];
                end
                currentLevelIDs = nextLevelIDs;
                if isempty(nextLevelIDs)
                    break;
                end
            end
            childrenROIIDs(childrenROIIDs == obj.shownROI) = [];
            childrenROIIDs(childrenROIIDs == obj.ROI_ROOT_ID) = [];
        end
        
        function [ancestorROIID  ancestorList] = roiGetOldestAncestor(obj, descendantROIID)
            % Walks up a branch of the ROI tree, returning the oldest ancestor of the given descendant ROI.
            
			ancestorROIID = [];
            ancestorList = [];
            
			if ~obj.roiDataStructure.isKey(descendantROIID)
				return;
			end
			
            descendantROIStruct = obj.roiDataStructure(descendantROIID);
            
            if ~isfield(descendantROIStruct,'parentROIID')
                ancestorROIID = obj.ROI_ROOT_ID;
                return;
            elseif descendantROIStruct.parentROIID == obj.ROI_ROOT_ID
                ancestorROIID = descendantROIID;
                return;
            end
            
            nextParentROIID = descendantROIStruct.parentROIID;
            parentROIID = nextParentROIID;
            
            while nextParentROIID > obj.ROI_BASE_ID
                parentROIID = nextParentROIID;
                ancestorList = fliplr([fliplr(ancestorList) parentROIID]);
                parentROIStruct = obj.roiDataStructure(parentROIID);
                nextParentROIID = parentROIStruct.parentROIID;
            end
            
            ancestorROIID = parentROIID;
        end
       
        function positionID = roiGetPositionFromROIID(obj,roiID)
            % Returns the position associated with a given ROI.
            %
            % roiID: the RDO to return the position of.
            %
            % positionID: the ID of the associated PDO.
            
            if nargin < 2
                error('Specify an ROI.');
            elseif isempty(roiID)
                positionID = [];
                return;
            end
            
            if roiID == obj.ROI_ROOT_ID
                positionID = 0;
                return;
            end
            
            roiStruct = obj.roiDataStructure(roiID);
            if roiStruct.parentROIID == obj.ROI_ROOT_ID && isfield(roiStruct,'positionID')
                positionID = roiStruct.positionID; 
            else
                ancestorStruct = obj.roiDataStructure(obj.roiGetOldestAncestor(roiID));
                positionID = ancestorStruct.positionID;
            end
        end
    
        function isEqual = roiIsEqualPosition(obj,posnA,posnB,doEnforceNans)
            % Returns true if the given positions match (within the defined tolerances).
            %
            % posnA, posnB: valid position vectors.
            % doEnforceNans: a boolean that, if false, indicates to treat Z-axis NaN values as "don't care".
            %
            % isEqual: a boolean that, if true, indicates that the positions match.

            if nargin < 4 || isempty(doEnforceNans)
                doEnforceNans = true;
            end
            
            if nargin < 3 || isempty(posnB) || nargin < 2 || isempty(posnA)
                error('Specify two valid Position IDs.');
            end    

            global state;

            % pad the vectors to a length of 4
            posnA = [posnA nan(1,4-length(posnA))];
            posnB = [posnB nan(1,4-length(posnA))];

            tolerances = [obj.roiPositionToleranceX obj.roiPositionToleranceY obj.roiPositionToleranceZ];
			positionSuffixes = {'X' 'Y' 'Z'};
            if state.motor.motorZEnable
                positionSuffixes{end+1} = 'ZZ';
				tolerances = [tolerances obj.roiPositionToleranceZZ];
            end
            
            valid = false(1,length(positionSuffixes));
            
            % iterate over all dimensions
            for j = 1:length(positionSuffixes)

                % if doEnforceNans is false, treat Z-axis NaNs as "don't care"
                if ~doEnforceNans && (j == 3 || j == 4) && (isnan(posnA(j)) || isnan(posnB(j)))
                    valid(j) = true;
                    continue;
                end
                
                if posnA(j) - tolerances(j) <= posnB(j) && posnB(j) <= posnA(j) + tolerances(j)
                    valid(j) = true;
                else
                    isEqual = false;
                    return;
                end
            end

            if all(valid)
                isEqual = true;
            end
        end
        
        function isEqual = roiIsEqualRSPs(obj,rspStructA,rspStructB)
            % Tests the two given RSPs structs for equality.
            %
            % rspStructA: a valid ROI RSP structure.
            % rspStructB: a valid ROI RSP structure.
            %
            % isEqual: a boolean that, if true, indicates the two RSP structs have matching field values.
            
            isEqual = false;
            
            if nargin < 3 || isempty(rspStructA) || isempty(rspStructB)
                obj.zprvError('','Please specify two valid RSP structs.');
                return;
            end
       
            if length(fieldnames(rspStructA)) ~= length(obj.scanParameterNames) || length(fieldnames(rspStructB)) ~= length(obj.scanParameterNames)
                obj.zprvError('','Invalid RSP structure.');
                return;
            end
            
            % iterate through all fields, testing for equality.
            for i = 1:length(obj.scanParameterNames)
                fieldName = obj.scanParameterNames{i};
                if ~isfield(rspStructB,fieldName) || rspStructA.(fieldName) ~= rspStructB.(fieldName)
                    return;
                end
            end
            
            isEqual = true;
        end
        
        function isValid = roiIsValidPosition(obj,posnID)
             if obj.positionDataStructure.isKey(posnID)
                 isValid = true;
             else 
                 isValid = false;
             end
        end
        
        function isValid = roiIsValidROI(obj,roiID)
             if obj.roiDataStructure.isKey(roiID)
                 isValid = true;
             else 
                 isValid = false;
             end
        end
        
        function roiClearAll(obj)
            % Removes all defined ROIs.
            
            rootROIStruct = obj.roiDataStructure(obj.ROI_ROOT_ID);
            
            hWaitbar = waitbar(0,'Clearing ROIs...');
            
            % remove all top-level ROIs (roiRemoveROI() will take care of deleting any children)
            topLevelROIIDs = rootROIStruct.children;
			topLevelROIIDs(topLevelROIIDs == obj.ROI_BASE_ID) = []; % don't delete the Base ROI
            numROIs = length(topLevelROIIDs);
            obj.doSuppressTableUpdates = true;
            for i = 1:numROIs
                waitbar(i/numROIs,hWaitbar);
				obj.roiRemoveROI(topLevelROIIDs(i));
            end
            close(hWaitbar);
            
			obj.shownROI = obj.ROI_ROOT_ID;
            obj.doSuppressTableUpdates = false;

            obj.hController{1}.disableROIControlButtons();
            obj.hController{1}.updateTableViews({'roi' 'cycle'});
		end
		
		function roiClearShown(obj)
			% Clears all children of the currently displayed ROI.
			
			if isempty(obj.shownROI)
				return;
			end
			
			displayedROIStruct = obj.roiDataStructure(obj.shownROI);	
			if ~isfield(displayedROIStruct,'children') || isempty(displayedROIStruct.children)
				return;
			end
			children = displayedROIStruct.children(displayedROIStruct.children ~= obj.ROI_BASE_ID);
			
			obj.doSuppressTableUpdates = true;
            hWaitbar = waitbar(0,'Clearing ROIs...');
			for i = 1:length(children)
				waitbar(i/length(children),hWaitbar);
				obj.roiRemoveROI(children(i));
			end
			close(hWaitbar);
            obj.doSuppressTableUpdates = false;
			obj.roiUpdateROITable();
		end
        
        function roiClearAllPositions(obj)
            % Removes all defined Positions (and, as a result, all ROIs).
            
            positions = obj.positionDataStructure.keys();
			positions([positions{:}] == 0) = [];
            numPositions = length(positions);
            
            obj.doSuppressTableUpdates = true;
            hWaitbar = waitbar(0,'Clearing Positions...');
            for i = 1:numPositions
                waitbar(i/numPositions,hWaitbar);
                obj.roiRemovePosition(positions{i}); 
            end
            close(hWaitbar);
            obj.doSuppressTableUpdates = false;
            
            obj.hController{1}.disableROIControlButtons();
            obj.hController{1}.updateTableViews();
		end
        
		function roiDrawMarker(obj,roiID)
			% Draws an ROI marker for the given roiID.  
			% If a marker already exists for the ID, it is deleted and redrawn using the current scan parameters.
			
			global state;
            
            roiStruct = obj.roiDataStructure(roiID);
			roiType = roiStruct.type;
				
			if ~isfield(roiStruct,'RSPs')
				return;
			end
			
            %TODO: Rotation! use drawPolygon()
            
            % delete any existing marker
            if isfield(roiStruct, 'hMarker') && ~isempty(roiStruct.hMarker)
               delete(roiStruct.hMarker);
               roiStruct.hMarker = [];
            end
            if isfield(roiStruct, 'hMarkerLabel') && ~isempty(roiStruct.hMarkerLabel)
               delete(roiStruct.hMarkerLabel);
               roiStruct.hMarkerLabel = [];
            end
            
            [posX1 posY1 posX2 posY2] = obj.roiCalculateNormalizedCoords(roiStruct);
			
			% compensate for the size of the roiDisplayGUI (or, more specifically, the size of the axes)
			xLim = get(obj.hROIDisplayAx,'XLim');
			yLim = get(obj.hROIDisplayAx,'YLim');
			sizeImage = [diff(xLim) diff(yLim)];
			posX1 = (posX1 + 0.5) * sizeImage(1);
			posY1 = (posY1 + 0.5) * sizeImage(2);
			if strcmpi(roiType,'line')
				posX2 = (posX2 + 0.5) * sizeImage(1);
				posY2 = (posY2 + 0.5) * sizeImage(2);
			else
				posX2 = posX2 * sizeImage(1);
				posY2 = posY2 * sizeImage(2);
			end
			
            % allow 'active' or 'selected' designations to supercede default color
            if ~isempty(obj.selectedROIID) && obj.selectedROIID == roiID
                markerType = 'selected';
            elseif ~isempty(obj.activeROIID) && obj.activeROIID == roiID
                markerType = 'active';
            else
                markerType = roiType;
            end
            
            EDGE_PADDING = 10;
            
			switch roiType
				case 'point'
                    % if we're near the right edge, switch the label to the left
                    flip = false;
                    if posX1 + EDGE_PADDING > sizeImage(2)
                        markerPosX = posX1 - 12;
                        flip = true;
                    else
                        markerPosX = posX1 + 7;
                    end
                    
                    % if we're near the bottom edge, switch the label to the top
                    if posY1 + EDGE_PADDING > sizeImage(1) || flip
                        markerPosY = posY1 - 7;
                        if ~flip
                            markerPosX = posX1 - 12;
                        end
                    else
                        markerPosY = posY1 + 7;
                    end
					
					shapeFun = @rectangle;
					shapeArgs = {'Parent',obj.hROIDisplayAx,'Position',[posX1 posY1 posX2 posY2],'EdgeColor',obj.markerColors(markerType),'LineWidth',1,'Curvature',[1 1]};
					
                case 'line'
                    % if we're near the right edge, switch the label to the left
                    flip = false;
                    if posX2 + EDGE_PADDING > sizeImage(2)
                        markerPosX = posX1 - 10;
                        flip = true;
                    else
                        markerPosX = posX2 + 4;
                    end
                    
                    % if we're near the bottom edge, switch the label to the top
                    if posY2 + EDGE_PADDING > sizeImage(1) || flip
                        markerPosY = posY1 - 7;
                        if ~flip
                            markerPosX = posX1 - 10;
                        end
                    else
                        markerPosY = posY2 + 2;
                    end
                    
					shapeFun = @line;
					shapeArgs = {'Parent',obj.hROIDisplayAx,'XData',[posX1 posX2],'YData',[posY1 posY2],'Color',obj.markerColors(markerType)};
					
				case {'square' 'rect'}
                    
                    % if we're near the right edge, switch the label to the left
                    flip = false;
                    if posX1 + posX2 + EDGE_PADDING > sizeImage(2)
                        markerPosX = posX1 - EDGE_PADDING;
                        flip = true;
                    else
                        markerPosX = posX1 + posX2 + 4;
                    end
                    
                    % if we're near the bottom edge, switch the label to the top
                    if posY1 + posY2 + EDGE_PADDING > sizeImage(1) || flip
                        markerPosY = posY1 - 7;
                        
                        if ~flip
                            markerPosX = posX1 - EDGE_PADDING;
                        end
                    else
                        markerPosY = posY1 + posY2 + 4;
                    end
					
					shapeFun = @rectangle;
					shapeArgs = {'Parent',obj.hROIDisplayAx,'Position',[posX1 posY1 posX2 posY2],'EdgeColor',obj.markerColors(markerType)};
			end

			% determine marker parameters
			if obj.roiShowMarkerNumbers
				isIDVisible = 'on';
			else
				isIDVisible = 'off';
            end
			
			% draw the shape...
			hMarker = feval(shapeFun,shapeArgs{:});

			% create the marker label
			hMarkerLabel = text('Parent',obj.hROIDisplayAx,'Position',[markerPosX markerPosY],'String',['#' num2str(roiID)],'FontSize',8,'Color',obj.markerColors(markerType),'Visible',isIDVisible);
            if ~obj.roiShowMarkerNumbers
               set(hMarkerLabel,'Visible','off'); 
            end
            
			% pack the marker data into the struct
			roiStruct.hMarker = hMarker;
			roiStruct.hMarkerLabel = hMarkerLabel;
		    obj.roiDataStructure(roiID) = roiStruct;
        end
        
        function roiMacroCopyToCycle(obj,roiIDs,doClearCycleTable)
			% Copies the given ROIs to cycle table iterations. 
			%
			% roiIDs: a vector of ROI IDs to copy.  If empty, all children of the currently displayed ROI will be copied.
			% doClearCycleTable: a boolean that, if true, indicates to clear the cycle table before copying.
			
			if nargin < 3 || isempty(doClearCycleTable)
				% prompt the user
				choice = questdlg('There is existing cycle data; would you like to overwrite it, or append the new data?', ...
									'Existing Cycle Data', ...
									'Overwrite','Append','Overwrite');
				if strcmp(choice,'Overwrite')
					doClearCycleTable = true;
				else
					doClearCycleTable = false;
				end
			end
			
			if nargin < 2 || isempty(roiIDs)
				if ~obj.roiDataStructure.isKey(obj.shownROI)
					return;
				end
				
				displayedROIStruct = obj.roiDataStructure(obj.shownROI);
				if isfield(displayedROIStruct,'children')
					roiIDs = displayedROIStruct.children;
				else
					return;
				end
			end
			
			global state;
			state.cycle.cycleOn = 1;
			updateGUIByGlobal('state.cycle.cycleOn');
 			toggleCycleGUI([],[],[],'on');
			
			if doClearCycleTable
				obj.hController{1}.cycClearTable();
			end

			obj.roiCopyROIsToCycle(roiIDs);
		end
		
		function roiCopyROIsToCycle(obj,roiIDs)
			% Inserts cycle iterations for the given ROIs.
			
			global state;
			
			MOTOR_ACTION_COL_IDX = 3;
			ROI_COL_IDX = 4;               
			
			cycRow = state.cycle.cycleTableColumnDefaults;
			cycRow{MOTOR_ACTION_COL_IDX} = 'ROI #';
            obj.doSuppressTableUpdates = true;
			hWaitbar = waitbar(0,'Inserting cycle iterations...');
			for i = 1:length(roiIDs)
				cycRow{ROI_COL_IDX} = roiIDs(i);
				obj.cycAddIteration(cycRow);
				waitbar(i/length(roiIDs),hWaitbar);
			end
			close(hWaitbar);
            obj.doSuppressTableUpdates = false;
			obj.hController{1}.updateTableViews('cycle');
        end
		
        function roiMacroGrid(obj)
			
            % ensure we have EOA data
            if isempty(obj.roiLastAcqCache)
				obj.zprvError('Cannot create ROIs','Unable to create ROI: No acquired data.');
				return;
            end
            
            name='Grid Macro';
			prompt={'Size (MxN):', ...
					'Grid Offset:', ...
					'Grid Offset Units (''degrees'' or ''microns''):', ...
					'Auto Populate Cycle Table:', ...
					'Auto Clear Cycle Table:', ...
                    'Scan Angle Multiplier [fast slow]:', ...
                    'Scan Zoom Factor:', ...
                    'Scan Rotation:', ...
                    'Angle to Microns Factor:'
                    };
			numlines=1;
			defaultanswer={'[3 3]','[0 0]','degrees','0','1','[0 0]','1','0',num2str(obj.roiAngleToMicronsFactor)};
			answers=inputdlg(prompt,name,numlines,defaultanswer);
			
			if isempty(answers)
				return;
            end
            
            try
                gridSize = str2num(answers{1});
                validateattributes(gridSize,{'numeric'},{'integer' 'positive'},'roiAddGrid','gridSize');
                assert(numel(gridSize)==2,'GridSize must be array of two elements');                
                
                gridOffset = str2num(answers{2});
                validateattributes(gridOffset,{'numeric'},{'finite'},'roiAddGrid','gridOffset');
                assert(numel(gridOffset) == 2,'GridOffset must be array of two elements');
                
                if strcmpi(answers{3},'microns')
                    isMicrons = true;
                else
                    isMicrons = false;
                end
                
                doCopyToCycle = str2double(answers{4});
                doOverwriteCycle = str2double(answers{5});
                
                scanAngleMultiplier = str2num(answers{6});
                validateattributes(scanAngleMultiplier,{'numeric'},{'nonnegative','<=',1.0},'roiAddGrid','scanAngleMultiplier');
                assert(numel(scanAngleMultiplier)==2,'scanAngleMultiplier must be array of two elements');
                
                zoomFactor = str2num(answers{7});
                validateattributes(zoomFactor,{'numeric'},{'scalar','positive','finite'},'roiAddGrid','zoomFactor');
                
                scanRotation = str2num(answers{8});
                validateattributes(scanRotation,{'numeric'},{'scalar','<=',45,'>=',-45},'roiAddGrid','scanRotation');
                
                angleToMicronsFactor = str2num(answers{9});
                validateattributes(angleToMicronsFactor,{'numeric'},{'scalar','positive','finite'},'roiAddGrid','angleToMicronsFactor');
            catch ME
                most.idioms.reportError(ME);
                return;                
            end
			
			roiIDs = obj.roiAddGrid(gridSize,gridOffset,isMicrons,scanAngleMultiplier,zoomFactor,scanRotation,angleToMicronsFactor);
			if doCopyToCycle
				obj.roiMacroCopyToCycle(roiIDs,doOverwriteCycle);
			end
        end
        
        function roiMacroMosaic(obj)
            global state;
            
            % ensure we have EOA data
			if isempty(obj.roiLastAcqCache)
				obj.zprvError('Cannot create ROIs', 'Unable to create ROI: No acquired data.');
				return;
            end
            
            TILES_WARN_THRESHOLD = 50;
            
            persistent modeCache numValCache overlapCache zoomCache samCache angleToMicronsCache startCenteredCache autoPopulateCache autoClearCache;
            
            if isempty(modeCache)
                modeCache = 'Tiles';
            end
            if isempty(numValCache)
                numValCache = '[3 3]';
            end
            if isempty(overlapCache)
                overlapCache = '[0 0]';
            end
            if isempty(zoomCache)
                zoomCache = num2str(state.acq.zoomFactor);
            end
            if isempty(samCache)
                samCache = ['[' num2str(state.acq.scanAngleMultiplierFast) ' ' num2str(state.acq.scanAngleMultiplierSlow) ']'];
            end
            if isempty(angleToMicronsCache)
                angleToMicronsCache = num2str(obj.roiAngleToMicronsFactor);
            end
            if isempty(startCenteredCache)
                startCenteredCache = '0';
            end
            if isempty(autoPopulateCache)
                autoPopulateCache = '1';
            end
            if isempty(autoClearCache)
                autoClearCache = '1';
            end
            
            name='Mosaic Macro';
            prompt={'Specify ''Tiles'' or ''Span'':',...
                    '# Tiles or Span (microns)', ...
                    'Overlap (microns):', ...
                    'Zoom Factor:', ...
                    'Scan Angle MultiplierFast/Slow:', ...
                    'Angle to Microns Factor:', ...
                    'Start Posn Centered:', ...
                    'Auto Populate Cycle Table:' ...
					'Auto Clear Cycle Table:'
                    };
            
            numlines=1;
            defaultanswer={modeCache,numValCache,overlapCache,zoomCache,samCache,angleToMicronsCache,startCenteredCache,autoPopulateCache,autoClearCache};
            answers=inputdlg(prompt,name,numlines,defaultanswer);
            
            if isempty(answers)
                return;
            end
            
            if any(cellfun(@isempty,answers))
                obj.zprvError('','Please specify all parameters.');
                return;
            end
            
            mode = answers{1};
            if ~(strcmpi(mode,'span') || strcmpi(mode,'tiles'))
                obj.zprvMacroError('Invalid mode: please specify ''Span'' or ''Tiles''.');
            end
            
            sizeParam = znstForceXYVar(str2num(answers{2}),'Mosaic Extent (Span or Tiles)');
            overlap = znstForceXYVar(str2num(answers{3}),'Overlap');
            sam = znstForceXYVar(str2num(answers{5}),'Scan Angle Multiplier'); 
            angleToMicronsFactor = str2double(answers{6});
            
            zoomFactor = str2double(answers{4});
            if isnan(zoomFactor) || zoomFactor < 0 || isinf(zoomFactor)                
                obj.zprvMacroError('Invalid zoomFactor: please specify a scalar positive finite value');
            end            
            
            fov = [(angleToMicronsFactor*(sam(1)*state.init.scanAngularRangeReferenceFast))/zoomFactor, ...
                    (angleToMicronsFactor*(sam(2)*state.init.scanAngularRangeReferenceSlow))/zoomFactor];
            tileShift = fov - overlap;
            
            if strcmpi(mode,'tiles')
                sizeParam = round(sizeParam);
                
                if prod(sizeParam) > TILES_WARN_THRESHOLD
                    choice = questdlg('You have specified a very large number of tiles--did you mean to specify ''Span''?', ...
                        'Warning', ...
                        'Yes','No','No');

                    if strcmp(choice,'Yes')
                        mode = 'span';
                    end
                end
            elseif strcmpi(mode,'span')
                 if sizeParam(1) < fov(1) || sizeParam(2) < fov(2)
                     choice = questdlg('The specified Span is less than the specified FOV--did you mean to specify ''Tiles''?', ...
                         'Warning', ...
                         'Yes','No','No');
                     
                     if strcmp(choice,'Yes')
                         mode = 'tiles';
                     end
                 end
            end
            
            if sam(1) < 0 || sam(1) > 1
                obj.zprvError('','Invalid Parameter');
                return;
            end
            if sam(2) < 0 || sam(2) > 1
                obj.zprvError('','Invalid Parameter');
                return;
			end
            
            isStartCentered = str2double(answers{7});
            doAutoPopulateCycleTable = str2double(answers{8});
           	doOverwriteCycle = str2double(answers{9});

            if strcmpi(mode,'span')
                span = sizeParam;
                
                numTiles = ceil(span./tileShift);
                
                coverage = numTiles.*tileShift + overlap;
            elseif strcmpi(mode,'tiles')
                numTiles = sizeParam;
                
                span = numTiles.*tileShift + overlap;  % should this be (... - overlap)?
                
                coverage = span;
            end
            
            if isStartCentered
                centeredOffset = ceil(span./2);
            else
                centeredOffset = [0 0];
            end

            initialOffset = (span - coverage)./2 - centeredOffset;

            initialPosition = [state.motor.absXPosition + initialOffset(1), state.motor.absYPosition + initialOffset(2), state.motor.absZPosition];
            hStep = [tileShift(1) 0 0];
            vStep = [0 tileShift(2) 0];
           
			roiIDs = zeros(prod(numTiles));
            obj.doSuppressTableUpdates = true;
            if isempty(obj.shownROI)
                obj.shownROI = obj.ROI_ROOT_ID;
            end
            hWaitbar = waitbar(0,'Creating ROIs...');
            for j = 1:numTiles(2)
                for i = 1:numTiles(1)
                    k = ((j-1)*numTiles(1) + i);
                    waitbar(k/prod(numTiles),hWaitbar);
                    
                    posn = initialPosition + ((i-1) * hStep) + ((j-1) * vStep);
                   
                    if state.motor.motorZEnable
                        posn(4) = state.motor.absZZPosition;
                    else
                        posn(4) = NaN;
                    end
                    
                    roiStruct = struct();
                    roiStruct.type = 'square';
                    roiStruct.parentROIID = obj.ROI_ROOT_ID;
                    roiStruct.positionID = obj.roiAddPosition(posn);
                    roiStruct.RSPs.zoomFactor = zoomFactor;
                    roiStruct.RSPs.scanAngleMultiplierFast = sam(1);
                    roiStruct.RSPs.scanAngleMultiplierSlow = sam(2);
                    roiStruct.RSPs.scanShiftFast = 0;
                    roiStruct.RSPs.scanShiftSlow = 0;
                    roiStruct.RSPs.scanRotation = 0;
                    
                    roiIDs((j-1)*numTiles(1) + i) = obj.roiAddNew(roiStruct,[],[],true);
                end
            end
            close(hWaitbar);
            
			if doAutoPopulateCycleTable
				obj.roiMacroCopyToCycle(roiIDs,doOverwriteCycle);
			end
			
            viewsToUpdate = {'roi','position'};
            if doAutoPopulateCycleTable
                viewsToUpdate{end+1} = 'cycle'; 
            end
            obj.shownROI = obj.ROI_ROOT_ID;
            obj.doSuppressTableUpdates = false;
            obj.hController{1}.updateTableViews(viewsToUpdate); %TODO: fix this
            
            function val = znstForceXYVar(val,varName)
                if any(isnan(val)) || numel(val) > 2
                    obj.zprvMacroError('Invalid value supplied for ''%s'' -- must be a scalar or 2 element vector',varName);
                end
                
                if isscalar(val)
                    val = [val val];
                end
            end            
           
            % cache the entered values
            cachedVarNames = {'modeCache' 'numValCache' 'overlapCache' 'zoomCache' 'samCache' 'angleToMicronsCache' 'startCenteredCache' 'autoPopulateCache' 'autoClearCache'};
           	for i = 1:length(cachedVarNames)
                eval([cachedVarNames{i} ' = answers{i};']);
            end
        end
        
		function roiMotorRead_Listener(obj)
            % Handles necessary post-read logic.  Checks if the new motor position has defined position/ROI IDs.

            if ~obj.mdlInitialized
                return;
            end
            
            % determine if we're at a defined position
            [isDefined, obj.activePositionID] = obj.isCurrentPositionDefined();
			
			obj.doSuppressTableUpdates = true;
			obj.roiUpdateActiveROI();
            
			% update the shown ROI
            if isDefined            
                if ~isempty(obj.shownROI)
                    shownPosition = obj.roiGetPositionFromROIID(obj.shownROI);
                    
                    % if the shown ROI's PDO already matches this position, do nothing
                    if shownPosition ~= obj.activePositionID
                        % see if position/RSP combo matches an existing ROI
                        existingROIID = obj.roiFindMatchingROIAtPosition(obj.activePositionID,obj.currentRSPStruct);
                        if ~isempty(existingROIID)
                            existingROIStruct = obj.roiDataStructure(existingROIID);
                            obj.shownROI = existingROIStruct.parentROIID;
                            obj.roiIsShownROIOutOfSync = false;
                        else
                            % show the top-level ROI for this position
                            topLevelROIID = obj.roiGetTopLevelROIID(obj.activePositionID);
                            if ~isempty(topLevelROIID)
                                obj.shownROI = topLevelROIID;
                                obj.roiIsShownROIOutOfSync = false;
                            else
                                obj.roiIsShownROIOutOfSync = true;
                            end
                        end
                    else
                       % we have a Shown ROI, and a matching position...
                       obj.roiIsShownROIOutOfSync = false;
                    end
                end
            elseif ~isempty(obj.shownROI) && obj.shownROI ~= obj.ROI_ROOT_ID
                % we have a Shown ROI, and an undefined position...flag that it's out of sync
                obj.roiIsShownROIOutOfSync = true;
            end
			
			obj.doSuppressTableUpdates = false;
			obj.roiUpdateROITable();
            obj.roiUpdatePositionTable();
		end
		
        function [x1 y1 x2 y2] = roiCalculateNormalizedCoords(obj,roiStruct)
           % Calculates the normalized coordinates necessary to draw an ROI on the ROI Display Figure.
           %
           % roiType: a string specifying the type of ROI, one of: {'point' 'line' 'square' 'rectangle'}
           % rspStruct: a struct containing the ROI's scan parameters
           
           global state;
           
		   if ~isfield(roiStruct,'RSPs')
			   error('Invalid ROI struct.');
		   end
		   
           rspStruct = roiStruct.RSPs; 
           rspStructDisplayed = [];
           if ~isempty(obj.shownROI) && isfield(obj.roiDataStructure(obj.shownROI), 'RSPs')
                rspStructDisplayed = obj.roiDataStructure(obj.shownROI).RSPs;
           end
           
           % zoomFactor is the one field we allow to be empty
			if isfield(rspStruct,'zoomFactor')
				zoomFactor = rspStruct.zoomFactor;
			else
				zoomFactor = 1;
			end
			scanShiftFast = rspStruct.scanShiftFast;
			scanShiftSlow = rspStruct.scanShiftSlow;
			scanAngleMultiplierFast = rspStruct.scanAngleMultiplierFast;
			scanAngleMultiplierSlow = rspStruct.scanAngleMultiplierSlow;
            
            % we can't just use 'scanAngleMultiplierXXX' for drawing purposes, since it might be zero...
			switch roiStruct.type
				case 'point'
					angleMultiplierFast = state.init.scanAngularRangeReferenceFast;
					angleMultiplierSlow = state.init.scanAngularRangeReferenceSlow;
					zoomFactor = 1;
				case 'line'
					angleMultiplierFast = scanAngleMultiplierFast*state.init.scanAngularRangeReferenceFast;
					angleMultiplierSlow = state.init.scanAngularRangeReferenceSlow;
				case {'square' 'rect'}
					angleMultiplierFast = scanAngleMultiplierFast*state.init.scanAngularRangeReferenceFast;
					angleMultiplierSlow = scanAngleMultiplierSlow*state.init.scanAngularRangeReferenceSlow;
                otherwise
                    obj.zprvError('',['Unknown ROI type: ' roiStruct.type]);
                    return;
			end
			
            % scale using the currently displayed ROI's params
            if ~isempty(rspStructDisplayed)
                shiftFastNormalized = ((scanShiftFast - rspStructDisplayed.scanShiftFast)/angleMultiplierFast)*rspStructDisplayed.zoomFactor;
                shiftSlowNormalized = ((scanShiftSlow - rspStructDisplayed.scanShiftSlow)/angleMultiplierSlow)*rspStructDisplayed.zoomFactor;
                zoomFactorNormalized = (1/zoomFactor)*rspStructDisplayed.zoomFactor;
            else
                shiftFastNormalized = scanShiftFast/angleMultiplierFast;
                shiftSlowNormalized = scanShiftSlow/angleMultiplierSlow;
                zoomFactorNormalized = 1;
            end
            
            switch roiStruct.type
                case 'point'
                    x1 = shiftFastNormalized;
                    y1 = shiftSlowNormalized;
                    x2 = 0.01;
                    y2 = 0.01;
                    
                case 'line'
                    x1 = (zoomFactorNormalized/2)*-cosd(rspStruct.scanRotation) + shiftFastNormalized;
                    y1 = (zoomFactorNormalized/2)*-sind(-rspStruct.scanRotation) + shiftSlowNormalized;
                    x2 = (zoomFactorNormalized/2)*cosd(rspStruct.scanRotation) + shiftFastNormalized;
                    y2 = (zoomFactorNormalized/2)*sind(-rspStruct.scanRotation) + shiftSlowNormalized;
                    
                case 'square'
                    x1 = shiftFastNormalized - zoomFactorNormalized/2;
                    y1 = shiftSlowNormalized - zoomFactorNormalized/2;
                    x2 = zoomFactorNormalized;
                    y2 = zoomFactorNormalized;
                case 'rect'
                    x1 = shiftFastNormalized*scanAngleMultiplierFast - (zoomFactorNormalized*scanAngleMultiplierFast)/2;
                    y1 = shiftSlowNormalized*scanAngleMultiplierSlow - (zoomFactorNormalized*scanAngleMultiplierSlow)/2;
                    
                    if scanAngleMultiplierFast > scanAngleMultiplierSlow
                        x2 = zoomFactorNormalized;
                        y2 = zoomFactorNormalized*scanAngleMultiplierSlow;
                    elseif scanAngleMultiplierSlow > scanAngleMultiplierFast
                        x2 = zoomFactorNormalized*scanAngleMultiplierFast;
                        y2 = zoomFactorNormalized;
                    end
            end
        end
		
        function [parentROIID, childROIID] = roiGetTargetParent(obj,hAxes)
            % Returns the ROI ID of the parent to use for a to-be-created ROI.
            %
            % hAxes: a handle to the Axes in which the user 'drew' the new ROI.
            %
            % parentROIID = the ROI ID of the parent under which to create the new ROI.
            % childROIID = the ROI ID of an RDO to be linked as a child of the new ROI (if re-linking an existing ROI is necessary).
            %
            % %TODO: this function does a lot more than just get a parent...
            % should the function name be changed to reflect this?
            %
            
            global state;
            
            if nargin < 2 || isempty(hAxes)
                % if user didn't specify hAxes (for instance, when adding a CUR ROI), use the first acq figure.
                hAxes = state.internal.axis(1);
                isCUR = true;
            else
                isCUR = false;
            end
            
            childROIID = [];
            parentROIID = [];
            parentParentROIID = [];
            
            if hAxes == obj.hROIDisplayAx
                % User drew in the RDF; use the currently shown ROI as parent (or ROOT, if nothing is shown).
                
                if isempty(obj.shownROI)
                    parentROIID = obj.ROI_ROOT_ID;
                else
                    parentROIID = obj.shownROI;
                end
                
                if obj.roiGotoOnAdd
                    % update the motor position to match that of the shown ROI.
                    topLevelROIID = obj.roiGetOldestAncestor(parentROIID);
                    shownPositionID = obj.roiDataStructure(topLevelROIID).positionID;
                    if ~isempty(shownPositionID) && shownPositionID > 0
                        obj.roiGotoPosition(shownPositionID);
                    end
                end
                
            elseif ismember(hAxes, state.internal.axis)
                % User drew in one of the acquisition figures...
                
                % ensure we have EOA data
                if isempty(obj.roiLastAcqCache)
                    obj.zprvError('Cannot create ROIs','Unable to create ROI: No acquired data.');
                    return;
                end
                
                % ensure that the current motor position matches the cached EOA motor position
                cachedPosition = obj.roiLastAcqCache.position;
                infixes = {'X' 'Y' 'Z' 'ZZ'};
                isEqual = true;
                for i = 1:length(cachedPosition)
                    motorPos = state.motor.(['abs' infixes{i} 'Position']);
                    if (~isnan(cachedPosition(i)) && ~isnan(motorPos)) && cachedPosition(i) ~= motorPos % TODO: is this boolean logic correct?
                        isEqual = false;
                        break;
                    end
                end
                if ~isEqual
                    obj.zprvError('Motor has moved.','Unable to create ROI: The motor has moved since the last acquisition.');
                    return;
                end
                
                % if adding a CUR, ensure that the cached EOA data matches the current RSPs
                if isCUR
                    currentRSPs = struct();
                    for i = 1:length(obj.scanParameterNames)
                        currentRSPs.(obj.scanParameterNames{i}) = state.acq.(obj.scanParameterNames{i});
                    end
                    if ~obj.roiIsEqualRSPs(obj.roiLastAcqCache.RSPs,currentRSPs)
                        obj.zprvError('Cannot create ROIs','Unable to create ROI: Current scan parameters do not match cached scan parameters.');
                        return;
                    end
                end

                % if the EOA cache matched an existing ROI, use that as parent
                if ~isempty(obj.roiLastAcqCache.definedROI)
                    if isCUR
                        obj.zprvError('Cannot create ROI',['Unable to create ROI: ROI with current scan parameters already exists (ROI # ' num2str(obj.roiLastAcqCache.definedROI) ').']);
                        return;
                    end
                    
                    parentROIID = obj.roiLastAcqCache.definedROI;
                    return;
                else
                    % no defined ROI: forcibly create a top-level ROI from the cached data
                    
                    % first, determine the positionID and parentParentROIID to use.
                    [isDefined, positionID] = obj.isCurrentPositionDefined();
                    
                    if isCUR
                        if ~isDefined
                            positionID = obj.roiAddPosition();
                        end
                        
                        topLevelROIID = obj.roiGetTopLevelROIID(positionID);
                        effectiveZoomCUR = obj.roiLastAcqCache.RSPs.zoomFactor/(obj.roiLastAcqCache.RSPs.scanAngleMultiplierFast*obj.roiLastAcqCache.RSPs.scanAngleMultiplierSlow);
                        
                        if ~isempty(topLevelROIID)
                            topLevelROIStruct = obj.roiDataStructure(topLevelROIID);
                            effectiveZoomExisting = topLevelROIStruct.RSPs.zoomFactor/(topLevelROIStruct.RSPs.scanAngleMultiplierFast*topLevelROIStruct.RSPs.scanAngleMultiplierSlow);
                            
                            if effectiveZoomCUR < effectiveZoomExisting
                                % make the new CUR ROI top-level, and re-link the existing ROI
                                parentROIID = obj.ROI_ROOT_ID;
                                obj.roiRemoveChildFromParent(topLevelROIID);
                                childROIID = topLevelROIID;
                            elseif effectiveZoomCUR > effectiveZoomExisting
                                parentROIID = topLevelROIID;
                            end
                        else
                            if effectiveZoomCUR <= 1.0
                                parentROIID = obj.ROI_ROOT_ID;
                            else
                                % create a top-level ROI (with ROOT RSPs) to be used as the parent
                                parentROIStruct = struct('type','square','parentROIID',obj.ROI_ROOT_ID,'positionID',positionID,'RSPs',obj.roiDataStructure(obj.ROI_ROOT_ID).RSPs);
                                parentROIID = obj.roiAddNew(parentROIStruct,[],[],true);
                            end
                        end
                        
                        return;
                    else
                        if isDefined
                            parentParentROIID = obj.roiGetTopLevelROIID(positionID);
                        else
                            positionID = obj.roiAddPosition();
                        end

                        if isempty(parentParentROIID)
                            % if RSPs don't match ROOT RSPs, create an additional ROI that is top-level
                            if obj.roiIsEqualRSPs(obj.roiLastAcqCache.RSPs,obj.roiDataStructure(obj.ROI_ROOT_ID).RSPs);
                                % if creating a CUR ROI, just use ROOT as the parent
                                if isCUR
                                    parentROIID = obj.ROI_ROOT_ID;
                                    return;
                                end
                                parentParentROIID = obj.ROI_ROOT_ID;
                            else
                                % create a top-level ROI (with ROOT RSPs) to be used as the parent of the parent
                                parentParentROIStruct = struct('type','square','parentROIID',obj.ROI_ROOT_ID,'positionID',positionID,'RSPs',obj.roiDataStructure(obj.ROI_ROOT_ID).RSPs);
                                parentParentROIID = obj.roiAddNew(parentParentROIStruct,[],[],true);
                            end
                        end
						
						% create the top-level parent ROI
                        parentROIID = obj.roiAddNewFromAcqCache('positionID',positionID,'parentROIID',parentParentROIID);
                        obj.roiLastAcqCache.definedROI = parentROIID;
                    end
                end
            else
                % Shouldn't ever get here...
                error('Invalid Axes handle.');
            end
        end
        
        function roiID = roiGetTopLevelROIID(obj,posnID)
            % Returns the top-level ROI ID for the given motor position (if one exists).
            %
			% posnID: a valid Position ID for which to find a top-level ROI.  If empty, the currently selected Position will be used.
			
            roiID = [];
            
			if nargin < 2 || isempty(posnID)
				if isempty(obj.selectedPositionID)
					return;
				end
				posnID = obj.selectedPositionID;
            end
            
            rootROIStruct = obj.roiDataStructure(obj.ROI_ROOT_ID);
            topLevelROIIDs = rootROIStruct.children(rootROIStruct.children ~= obj.ROI_BASE_ID);
            for i = 1:length(topLevelROIIDs)
                childStruct = obj.roiDataStructure(topLevelROIIDs(i));
                if childStruct.positionID == posnID
                    roiID = topLevelROIIDs(i);
                    return;
                end
            end
        end
        
        function roiUpdatePositionTable(obj)
            
			global state;
			
			if isempty(state)
				return;
			end
			
            if obj.doSuppressTableUpdates
                return;
            end
            
            positions = obj.positionDataStructure.keys();
            
            positionIDs = {};
            xVals = repmat(NaN,1,length(positions));
            yVals = repmat(NaN,1,length(positions));
            zVals = repmat(NaN,1,length(positions));
            zzVals = repmat(NaN,1,length(positions));

            for i = 1:length(positions)
                positionStruct = obj.positionDataStructure(positions{i});

                if isempty(positionStruct) || isnumeric(positionStruct)
                    continue;
				end
				
                positionIDs{i} = num2str(positions{i});
		
                if positions{i} == obj.activePositionID
                    positionIDs{i} = [positionIDs{i} ' *'];
                end
                
				% if displaying relative coords, apply the offset
				if ~obj.roiShowAbsoluteCoords   
                    if ~state.motor.motorOn
                        relOrigin = [nan nan nan];
                    else
                        relOrigin = motorGetRelativeOrigin(); 
                    end
                    xVals(i) = positionStruct.motorX - relOrigin(1);
                    yVals(i) = positionStruct.motorY - relOrigin(2);
                    zVals(i) = positionStruct.motorZ - relOrigin(3);
                    
                    if state.motor.motorZEnable
                        zzVals(i) = positionStruct.motorZZ - relOrigin(4);
                    end
                                        
				else
					xVals(i) = positionStruct.motorX;
					yVals(i) = positionStruct.motorY;
					zVals(i) = positionStruct.motorZ;
					zzVals(i) = positionStruct.motorZZ;
				end
				
			end
			
            % update the ColumnArrayTable-bound props
            boundProps = {'positionIDs' 'xVals' 'yVals' 'zVals' 'zzVals'};
            
            numProps = length(boundProps);            
            for i = 1:numProps    
                propName = boundProps{i};
                obj.(propName) = eval(propName);
            end   
        end
                
        function roiUpdateROITable(obj)
            % Updates the data displayed in the ROI uitable, given the currently displayed ROI.
			%
			% doShowWaitbar: a boolean value that, if true, specifies to show a progress bar while updating the table (default=true).
          
            if obj.doSuppressTableUpdates || ~obj.mdlInitialized
                return;
            end
            
            if obj.roiDataStructure.isKey(obj.shownROI)
                displayedROIStruct = obj.roiDataStructure(obj.shownROI);
            else
                displayedROIStruct = [];
            end
            
            roiIDs = {};
            roiPositionIDs = [];
            roiTypes = {};
            roiZoomFactors = [];
            roiRotations = [];
            roiShifts = {};
            roiScanAngleMultipliers = {};
            
            childrenROIIDs = obj.roiGetDisplayedChildren();
            
            for i = 1:length(childrenROIIDs)
                childROIStruct = obj.roiDataStructure(childrenROIIDs(i));

                if ~isfield(childROIStruct,'RSPs')
                    continue;
                end

                if childrenROIIDs(i) == obj.ROI_BASE_ID
                    roiIDs{i} = 'base';
                else
                    roiIDs{i} = num2str(childrenROIIDs(i));
                end

                if childrenROIIDs(i) == obj.activeROIID
                    roiIDs{i} = [roiIDs{i} ' *'];
                end

                roiTypes{i} = childROIStruct.type;

                % if this is a top-level ROI (i.e. parent is ROOT), use its positionID, otherwise walk up the tree and
                % determine the positionID of the top-level ROI.
                if childROIStruct.parentROIID == obj.ROI_ROOT_ID && isfield(childROIStruct,'positionID')
                    roiPositionIDs(i) = childROIStruct.positionID;
                else
                    ancestorID = obj.roiGetOldestAncestor(childrenROIIDs(i));
                    ancestorROIStruct = obj.roiDataStructure(ancestorID);
                    if isfield(ancestorROIStruct,'positionID')
                        roiPositionIDs(i) = ancestorROIStruct.positionID;
                    end
                end
    
                roiZoomFactors(i) = childROIStruct.RSPs.zoomFactor;
                roiShifts{i} = ['[' sprintf('%.2f',childROIStruct.RSPs.scanShiftFast) ' ' sprintf('%.2f',childROIStruct.RSPs.scanShiftSlow) ']'];
                roiRotations(i) = childROIStruct.RSPs.scanRotation;
                roiScanAngleMultipliers{i} = ['[' sprintf('%.2f',childROIStruct.RSPs.scanAngleMultiplierFast) ' ' ...
                                                sprintf('%.2f',childROIStruct.RSPs.scanAngleMultiplierSlow) ']'];
            end
            
            % update the ColumnArrayTable-bound props
            boundProps = {'roiIDs' 'roiTypes' 'roiPositionIDs' 'roiZoomFactors' 'roiShifts' 'roiRotations' 'roiScanAngleMultipliers'};
            numProps = length(boundProps);
            for i = 1:numProps
                propName = boundProps{i};
                obj.(propName) = eval(propName);
            end
            
            % update the breadcrumbs
            breadcrumbString = 'ROOT';
            if obj.shownROI > obj.ROI_BASE_ID 
                [~, breadcrumbList] = obj.roiGetOldestAncestor(obj.shownROI);
                for i = 1:length(breadcrumbList)
                    breadcrumbString = [breadcrumbString ' => ' num2str(breadcrumbList(i))];
                end
                breadcrumbString = [breadcrumbString ' => ' num2str(obj.shownROI)];
            else
               breadcrumbString = [breadcrumbString ' => '];
            end
            obj.roiBreadcrumbString = breadcrumbString;
            
            if obj.roiActiveUpdatePending
                obj.roiActiveUpdatePending = false;
                obj.selectedROIID = [];
            end
        end
        
        function roiSetMarkersVisibility(obj,isVisible)
            % Sets all ROI markers belonging to the currently-displayed ROI to the specified state.
            %
            % isVisible: a boolean value specifiying if the markers are to be visible, OR one of {'on' 'off'}
            
            if nargin < 2 || isempty(isVisible)
               obj.zprvError('','You must specify a state.');
               return;
            end
            
            if isempty(obj.shownROI)
                return;
            end
            
            if ischar(isVisible)
                if ~ismember(isVisible,{'on' 'off'})
                    obj.zprvError('','Invalid state');
                    return;
                end
            elseif isVisible
                isVisible = 'on';
            else
                isVisible = 'off';
            end
            
            % if turning markers off, just turn off everything
            if strcmp(isVisible,'off')
                children = cell2mat(obj.roiDataStructure.keys());
                children(children < 1) = [];
            else
                % get all children of the currently-displayed ROI
                
                if ~obj.roiDataStructure.isKey(obj.shownROI)
                    return;
                end
                currentlyDisplayedROIStruct = obj.roiDataStructure(obj.shownROI);
                if ~isfield(currentlyDisplayedROIStruct,'children')
                    return;
                end
                children = currentlyDisplayedROIStruct.children;
            end
            
            % set all childrens' 'visible' property to the specified state.
            for i = 1:length(children)
                childROIStruct = obj.roiDataStructure(children(i));
                if isfield(childROIStruct,'hMarker')
                    set(childROIStruct.hMarker, 'Visible', isVisible);
                end
                if isfield(childROIStruct,'hMarkerLabel')
                    set(childROIStruct.hMarkerLabel, 'Visible', isVisible);
                end
            end
        end

        function roiUpdateActiveROI(obj)
            % Checks updated RSPs and updates activeROIID appropriately.

            [isDefined, posnID] = obj.isPositionDefined();
            
            if isDefined
                % build an RSP struct with the current RSPs
                rspStruct = obj.currentRSPStruct;
                
                % find an ROI matching the current position and RSPs
                roiID = obj.roiFindMatchingROIAtPosition(posnID,rspStruct);
            else
                roiID = [];
            end
            
            obj.activeROIID = roiID;
        end
        
        function roiUpdateRootRSPs(obj,~,~)
            % Caches the RSPs for the 'ROOT' ROI at program startup.
           
            global state;
            
            rootROIStruct = obj.roiDataStructure(obj.ROI_ROOT_ID);
            rootROIStruct.RSPs = struct();
            for i = 1:length(obj.scanParameterNames)
                fieldName = obj.scanParameterNames{i};
                rootROIStruct.RSPs.(fieldName) = state.acq.(fieldName);
            end
            
            obj.roiDataStructure(obj.ROI_ROOT_ID) = rootROIStruct;
            
%             obj.shownROI = obj.ROI_ROOT_ID;
        end

        function roiRSP_Listener(obj)
            % Handles necessary logic after a change to any ROI Scan Parameter (RSP).
                      
            obj.roiUpdateActiveROI();
            
            %             % if LS is on, force it off without changing any RSPs
            %             if obj.lineScanEnable
            %                 obj.roiSuppressLinescanSideEffects = true;
            %                 obj.lineScanEnable = false;
            %                 obj.roiSuppressLinescanSideEffects = false;
            %             end
		end
        
		function roiUpdateShownPosition(obj)
			% Updates the shown position string in the RDF.
			
			global state;
			
			shownROIPosition = obj.roiGetPositionFromROIID(obj.shownROI);
			
			% determine if the shown Position matches the active Position
            if isempty(shownROIPosition) || (~isempty(obj.activePositionID) && shownROIPosition == obj.activePositionID)
                obj.roiIsShownROIOutOfSync = false;
            else
                obj.roiIsShownROIOutOfSync = true;
            end
			
			% format a string for the current position
            if ~isempty(shownROIPosition)
                obj.shownPositionID = shownROIPosition;
                posnStruct = obj.positionDataStructure(shownROIPosition);
                absPosn = [posnStruct.motorX posnStruct.motorY posnStruct.motorZ];
                if state.motor.motorZEnable
                    absPosn = [absPosn posnStruct.motorZZ];
				end
				relOrigin = motorGetRelativeOrigin();
                positionString = ['[' sprintf('%.2f %.2f %.2f',absPosn(1)-relOrigin(1),absPosn(2)-relOrigin(2),absPosn(3)-relOrigin(3))];
                if state.motor.motorZEnable
                   positionString = [positionString sprintf(' %.2f',absPosn(4)-relOrigin(4))]; 
                end
            else
                obj.shownPositionID = 0;
                positionString = '[NaN NaN NaN';
                if state.motor.motorZEnable
                    positionString = [positionString ' NaN'];
                end
            end
            positionString = [positionString ']'];            
            obj.shownPositionString = positionString;
		end
		
		function roiUpdateShownROI(obj,doUpdateSelectedROI)
			
            global state;
            
            if nargin < 2 || isempty(doUpdateSelectedROI)
				doUpdateSelectedROI = true;
            end
			
            if state.motor.motorOn
                obj.roiUpdateShownPosition();
            end
                
            % post-set logic:
            if obj.doSuppressTableUpdates
                return;
            end
            
			if doUpdateSelectedROI
				obj.selectedROIID = [];
			end
            
            % update the ROI uitable
            obj.roiUpdateROITable();
            
            % update the view
            obj.roiUpdateView();
		end
		
		function roiUpdateView(obj)
			global state;

			% first, clear the display figure
			obj.roiSetMarkersVisibility('off');
 			set(obj.hROIDisplayIm,'CData',zeros(state.internal.storedLinesPerFrame, state.acq.pixelsPerLine));
			
			if isempty(obj.shownROI) || ~obj.roiDataStructure.isKey(obj.shownROI)
				return;
            end
			
            if strcmp(obj.roiDisplayedChannel,'merge')
                targetChannel = 5; % the merge-data is stored in the fifth index of the MRI cache
                colormap('default');
                targetColormap = colormap();
            else
                targetChannel = str2double(obj.roiDisplayedChannel);
                targetColormap = eval(eval(['state.internal.figureColormap' num2str(targetChannel)]));
            end
			
            % init cdata
            for i = 1:3
                cdata(:,:,i) = zeros(state.internal.storedLinesPerFrame, state.acq.pixelsPerLine);
            end
     
			displayedROIStruct = obj.roiDataStructure(obj.shownROI);
			
            % if the acquisition is non-square, draw an Adobe-esque checkered background
            % TODO: this should be fixed for case where pixelsPerLine ~= linesPerFrame...
            if isfield(displayedROIStruct,'RSPs') && displayedROIStruct.RSPs.scanAngleMultiplierFast ~= displayedROIStruct.RSPs.scanAngleMultiplierSlow
                isSquare = false;
                
                bgColor = 0.7;
                fgColor = 0.9;
                checker = [repmat(bgColor,8) repmat(fgColor,8); repmat(fgColor,8) repmat(bgColor,8)];
                cdata(:,:,1) = repmat(checker,state.internal.storedLinesPerFrame/16, state.acq.pixelsPerLine/16);
                cdata(:,:,2) = cdata(:,:,1);
                cdata(:,:,3) = cdata(:,:,2);
            else
                isSquare = true;
            end 
            
			if isfield(displayedROIStruct,'MRI')
				if targetChannel <= length(displayedROIStruct.MRI) && ~isempty(displayedROIStruct.MRI{targetChannel})
					mriData = displayedROIStruct.MRI{targetChannel};
                    
                    if targetChannel == 5
                        mriData = double(mriData);
                    end
				else
					mriData = [];
                end
                
                if ~isSquare
                    % resize the 'square' acq data to its proper size
                    mNew = floor(size(mriData,1)*displayedROIStruct.RSPs.scanAngleMultiplierSlow);
                    nNew = floor(size(mriData,2)*displayedROIStruct.RSPs.scanAngleMultiplierFast);
                    [m,n,~] = size(mriData);
                    [X,Y] = meshgrid( (0:n-1)/(n-1), (0:m-1)/(m-1) );
                    [XI,YI] = meshgrid( (0:nNew-1)/(nNew-1) , (0:mNew-1)/(mNew-1) );
                    mriDataResized = zeros(mNew,nNew,size(mriData,3));
                    for i = 1:size(mriData,3) % TODO: maybe a cleaner way to do this?
                        mriDataResized(:,:,i) = max(interp2(X,Y,mriData(:,:,i),XI,YI,'cubic',0),0.0); % max() clamps any values < 0.0
                    end
                    
                    % compute the l/r/u/d offsets
                    uBound = floor((m - mNew)/2) + 1;
                    dBound = min(uBound + mNew - 1,state.internal.storedLinesPerFrame);
                    lBound = floor((n - nNew)/2) + 1;
                    rBound = min(lBound + nNew - 1,state.acq.pixelsPerLine);
                    
                    mriData = mriDataResized;
				else
					uBound = 1;
					dBound = state.internal.storedLinesPerFrame;
					lBound = 1;
					rBound = state.acq.pixelsPerLine;
				end
                
				if targetChannel < 5
					mriData = round(mriData./(2^state.acq.inputBitDepth/length(targetColormap))); % scale the data to fit the resolution of the colormap
					mriData = ind2rgb(mriData,targetColormap);
				else
					% looking at merge-data, which is already indexed (no need to call ind2rgb())
					mriData = mriData./max(max(max(mriData)));
				end
				cdata(uBound:dBound,lBound:rBound,:) = mriData;
				
                % draw the CData into the figure
                if targetChannel < 5
                    set(obj.hROIDisplayFig,'Colormap',targetColormap);
                    set(obj.hROIDisplayAx,'CLim',get(state.internal.axis(targetChannel),'CLim'));
                    set(obj.hROIDisplayIm,'CDataMapping','scaled');
				else
                    set(obj.hROIDisplayAx,'CLim',[0 1]);
                end
                
                set(obj.hROIDisplayIm,'CData',cdata);
                axSize = [diff(get(obj.hROIDisplayAx,'XLim')) diff(get(obj.hROIDisplayAx,'YLim'))];
                set(obj.hROIDisplayIm,'XData',[1 axSize(1)],'YData', [1 axSize(2)]);
            end
		
            children = obj.roiGetDisplayedChildren();
            children(children == obj.ROI_BASE_ID) = [];
            
			if isfield(displayedROIStruct, 'children')
				for i = 1:length(children)
					obj.roiDrawMarker(children(i));
				end
			end
		end
		
		function roiRemoveROI(obj,roiID)
			% Removes an ROI from the list.
			%
			% 'roiID': A valid ROI to be removed.
            
			if nargin < 2 || isempty(roiID)
				obj.zprvError('','Please specify a valid ROI.');
				return;
			end
			
			if roiID == obj.ROI_BASE_ID
				obj.zprvError('','The Base ROI cannot be deleted.');
				return;
			end
			
            roiStruct = obj.roiDataStructure(roiID);
            
			% if this ROI has children, remove them as well...    
            if isfield(roiStruct,'children') && ~isempty(roiStruct.children)
                children = roiStruct.children;
                for j = 1:length(children)
                    obj.roiRemoveROI(children(j));
                end
                
                % deleting the children modified the parent, so refresh the struct
                roiStruct = obj.roiDataStructure(roiID);
            end
            
            % delete the markers
			if isfield(roiStruct,'hMarker') && ishandle(roiStruct.hMarker)
				delete(roiStruct.hMarker);
			end
			if isfield(roiStruct,'hMarkerLabel') && ishandle(roiStruct.hMarkerLabel)
				delete(roiStruct.hMarkerLabel);
			end
            
            % update the parent's list of children
			obj.roiRemoveChildFromParent(roiID);
            
            obj.roiDataStructure.remove(roiID);
            
			% remove any reference in the EOA cache
			if isfield(obj.roiLastAcqCache,'definedROI') && isequal(obj.roiLastAcqCache.definedROI,roiID)
				obj.roiLastAcqCache.definedROI = [];
            end
            
            if roiID == obj.shownROI
                obj.shownROI = [];
			end
			
            if roiID == obj.activeROIID
                obj.activeROIID = [];
            end
            
            if ~obj.doSuppressTableUpdates
                obj.roiUpdateROITable();
            end
            
            % remove any cycle-iterations referencing this ROI
            iterationIndices = obj.hController{1}.roiID2cycIterationIdx(roiID);
            for i = 1:length(iterationIndices)
                gridShift = length(iterationIndices(iterationIndices < iterationIndices(i)));
                obj.cycRemoveIteration(iterationIndices(i) - gridShift);
            end
        end
		
        function roiRemovePosition(obj,posnID)
            % Removes a Position from the list.
			%
			% 'posnID': A valid Position to be removed.
            
            if nargin < 2 || isempty(posnID)
				obj.zprvError('','Please specify a valid Position.');
				return;
			end
            
			if posnID == 0
				obj.zprvError('','The Root Position cannot be deleted.');
				return;
			end
			
            % delete the position
            if obj.positionDataStructure.isKey(posnID)
                obj.positionDataStructure.remove(posnID);
            end
            
            if posnID == obj.activePositionID
                obj.activePositionID = [];
            end
            
            % remove any associated ROIs
            rootROIStruct = obj.roiDataStructure(obj.ROI_ROOT_ID);
            rootChildren = rootROIStruct.children;
            for j = 1:length(rootChildren)
               childROIStruct = obj.roiDataStructure(rootChildren(j));
               if childROIStruct.positionID == posnID
                   obj.roiRemoveROI(rootChildren(j));
               end
            end

            if ~obj.doSuppressTableUpdates
                obj.roiUpdatePositionTable();
            end
        end
        
        
        function roiRenumberPositions(obj)
			% Renumbers Positions to be consecutive (starting with '1').
			
            positionIDs = obj.positionDataStructure.keys();
			for i = 1:length(positionIDs)
                if i == positionIDs{i}
                    continue;
                end
                
                obj.positionDataStructure(i) = obj.positionDataStructure(positionIDs{i});
                obj.positionDataStructure.remove(positionIDs{i});

                % update any ROIs referencing this Position
                doUpdateROITable = false;
                rootROIStruct = obj.roiDataStructure(obj.ROI_ROOT_ID);
                if isfield(rootROIStruct,'children') && ~isempty(rootROIStruct.children)
                    topLevelROIs = rootROIStruct.children;
                    for j = 1:length(topLevelROIs)
                        roiStruct = obj.roiDataStructure(topLevelROIs(j));
                        if roiStruct.positionID == positionIDs{i}
                             roiStruct.positionID = i;
                             obj.roiDataStructure(topLevelROIs(j)) = roiStruct;
                             doUpdateROITable = true;
                        end
                    end
                end
                
                if obj.activePositionID == positionIDs{i}
                    obj.activePositionID = i;
                end
            end
            
            % Update the data displayed in the Position/ROI table(s).
            obj.roiUpdatePositionTable();
            
            if doUpdateROITable
                obj.roiUpdateROITable();
            end
        end
        
        
		function roiRenumberROIs(obj)
			% Renumbers ROI IDs to be consecutive (starting with '1').
			
            global state;
            
            roiIDs = obj.roiDataStructure.keys();
            roiIDs(1) = []; % skip the root entry
			for i = 1:length(roiIDs)
                if i == roiIDs{i}
                    continue;
                end
                
                obj.roiDataStructure(i) = obj.roiDataStructure(roiIDs{i});
                obj.roiDataStructure.remove(roiIDs{i});
				
                % update the marker ID
                roiStruct = obj.roiDataStructure(i);
                set(roiStruct.hMarkerLabel,'String',['#' num2str(i)]);
                
                % update any childrens' 'parent' field
                if isfield(roiStruct,'children')
                    children = roiStruct.children;
                    for j = 1:length(children)
                        childROIStruct = obj.roiDataStructure(children(j));
                        childROIStruct.parentROIID = i;
                        obj.roiDataStructure(children(j)) = childROIStruct;
                    end
                end
                
                % udpate this ROI's parent's 'children' field
                parentROIStruct = obj.roiDataStructure(roiStruct.parentROIID);
                parentROIStruct.children(parentROIStruct.children == roiIDs{i}) = [];
                parentROIStruct.children = [parentROIStruct.children i];
                obj.roiDataStructure(roiStruct.parentROIID) = parentROIStruct;
								
                % update any cycle-iterations referencing this ROI
                cycIndices = obj.hController{1}.roiID2cycIterationIdx(roiIDs{i});
                for j = 1:length(cycIndices)
                    state.cycle.cycleTableStruct(cycIndices(j)).motorActionID = i; 
                end
                
            end
            
            % Update the data displayed in the ROI table.
            obj.hController{1}.updateTableViews({'roi' 'cycle'});
        end

        function roiLoad(obj)
            % Loads ROI/Position data from the selected .roi file.
            %
            % TODO: this shares a lot of logic with loadCurrentCycle()...should these be refactored/merged?
                
            try
                %Prompt user to select file
                startPath = obj.getLastPath('roiLastPath');
                [fname, pname]=uigetfile({'*.roi'},'Choose ROI File...',startPath);
                if isnumeric(fname)
                    return
                else
                    [~,filenameNoExtension,~] = fileparts(fname);

                    if ~strcmp(pname,startPath)
                        obj.setLastPath('roiLastPath',pname);
                    end
                end
            catch ME
                ME.throwAsCaller();
            end

            % handle a 'cancel' click
            if isnumeric(fname) && fname == 0 && isnumeric(pname) && pname == 0
                return;
			end

			obj.roiLoading = true;
			
            try 
                [fID, message] = fopen(fullfile(pname,fname));
            catch ME
                error('Unable to open file.');
            end
            if fID < 0
                error('Unable to open file: %s.',message);
            end
            
            obj.roiPath = pname;
            [~,obj.roiName,~] = fileparts(fname);
            
            % clear any existing data...
            obj.roiClearAll();

            obj.doSuppressTableUpdates = true;
            
            % initialize some regular expressions we'll need:
            headerExp = '^(\D*)$'; % matches the secton 'header' (i.e. 'ROI' or 'Position')
            rowExp = '^(\d+)\t((.+)\t(.+)\t)+'; % matches a row beginning with an integer ID
            rspExp = '^\t(RSPs)\t((.+)\t(.+)\t)+'; % matches an RSP row
            keyValExp = '([^\t]+)\t([^\t]+)\t'; % captures all key/val pairs in a row
            
            currentLine = fgetl(fID);
            while ischar(currentLine)
                tokens = regexp(currentLine,headerExp,'tokens','once');
                if ~isempty(tokens) % we have a section delimiter...
                    prefix = tokens{1};
                else % we have a row entry or an RSP entry
                    tokens = regexp(currentLine,rowExp,'tokens','once');
                    if ~isempty(tokens)
                        rowID = str2double(tokens{1});
                        rowStruct = struct();
                        isRSP = false;
                    else
                        tokens = regexp(currentLine,rspExp,'tokens','once');
                        if ~isempty(tokens)
                            isRSP = true;
                            rowStruct.RSPs = struct();
						else
							currentLine = fgetl(fID);
							continue;
                        end
                    end
                        
                    keyValLine = tokens{2};
                    matches = regexp(keyValLine,keyValExp,'match');
                    for match = matches
                        keyVal = regexp(match{:},'(.+)\t(.+)\t','tokens');
                        key = keyVal{1}{1};
                        val = keyVal{1}{2};	

                        if strcmpi(val,'nan')
                            val = NaN;
                        elseif ~isnan(str2double(val))
                            val = str2double(val); % numeric value
                        else
                            % string value, do nothing
                        end
                        
                        if isRSP
                            rowStruct.RSPs.(key) = val;
                        else
                            rowStruct.(key) = val;
                        end
                    end

                    % TODO: unify roiAddNew() and roiAddPosition() so that signatures match--thus avoiding this test?
                    if strcmpi(prefix,'roi') && isRSP
                        obj.roiAddNew(rowStruct,rowID); 
                    elseif strcmpi(prefix,'position')
                        obj.roiAddPosition(rowStruct,rowID);
                    end
                end
                currentLine = fgetl(fID);
            end

            fclose(fID);
            
            obj.shownROI = obj.ROI_ROOT_ID;
            
			obj.roiLoading = false;
			
            obj.doSuppressTableUpdates = false;
            obj.roiUpdateROITable();
            obj.roiUpdatePositionTable();
        end
        
        function roiSave(obj)
            % Saves all defined ROI and Position entries.
            
            if isempty(obj.roiName) || isempty(obj.roiPath)
                obj.roiSaveAs();
                return;
            end

            % open the file
            try
                [fID, message] = fopen(fullfile(obj.roiPath,[obj.roiName '.roi']), 'wt');
            catch ME
                error('Unable to open file.');
            end
            if fID < 0
               error('Unable to open file: %s.',message); 
			end

            % Write the ROI data
            prefixes = {'ROI' 'Position'};
            for i = 1:length(prefixes)
                prefix = prefixes{i};
                
                fprintf(fID,'%s\n',prefix);
                
                dataStructure = obj.([lower(prefix) 'DataStructure']);
                ids = dataStructure.keys();
                ids([ids{:}] < 1) = []; % remove the ROOT entry
                
                for j = 1:length(ids)
                    fprintf(fID,'%d\t',ids{j});
                    
                    rowStruct = dataStructure(ids{j});
                    paramNames = setdiff(fieldnames(rowStruct),{'RSPs' 'children' 'hMarker' 'hMarkerLabel'}); % 'children' will be reconstructed, pointless to save marker handles...
                    
                    % write all params
                    for k = 1:length(paramNames)
                        paramName = paramNames{k};
                        if isfield(rowStruct,paramName) && ~isempty(rowStruct.(paramName))
                            obj.fprintfSmart(fID,paramName,rowStruct.(paramName));
                        end
                    end
                    
                    % now write any RSPS
                    if isfield(rowStruct,'RSPs')
                        fprintf(fID,'\n\tRSPs\t');
                        rspNames = fieldnames(rowStruct.RSPs);
                        for k = 1:length(rspNames)
                            obj.fprintfSmart(fID,rspNames{k},rowStruct.RSPs.(rspNames{k})); 
                        end
                    end

                    fprintf(fID,'\n');
                end
                fprintf(fID,'\n');
            end
            fclose(fID); 
        end
        
        function roiSaveAs(obj)
            startPath = obj.getLastPath('roiLastPath');
            [fname, pname]=uiputfile({'*.roi'},'Choose ROI File...',startPath);
            if isnumeric(fname)
                return;
            end
            
            [~,fname,ext] = fileparts(fname);
            if isempty(ext) || ~strcmpi(ext,'.roi')
                fprintf(2,'WARNING: Invalid file extension found. Cannot open ROI file.\n');
                return;
            end
            
            obj.roiName =fname;
            obj.roiPath=pname;
            obj.roiSave();
		end
		
		function roiLoadBaseConfig(obj)
			% Calls through to roiGotoROI() to load the base configuration.
			
			obj.roiGotoROI(obj.ROI_BASE_ID,true);
		end
		
		function roiSetBaseConfig(obj,isInit)
			% Sets the 'Base' ROI.
			%
			% isInit: a boolean value that, if true, specifies that this function is being called during ScanImage initialization.
			%
			
			global state;
			
			if nargin < 2 || isempty(isInit)
				isInit = false;
			end
			
			baseROIStruct = obj.roiDataStructure(obj.ROI_BASE_ID);
			
			if isInit && isfield(baseROIStruct,'RSPs')
				% if the 'RSP' field exists, it means we've already loaded a base-config from a USR file.
				return;
			end
			
			% Cache all current scan parameters
			for i = 1:length(obj.scanParameterNames)
				baseROIStruct.RSPs.(obj.scanParameterNames{i}) = state.acq.(obj.scanParameterNames{i});
			end
			
			obj.roiDataStructure(obj.ROI_BASE_ID) = baseROIStruct;
			
			obj.roiUpdateROITable();
            
            %Hack invoking GUI side effects -- ideally should have a property update bound to SI3Controller
            updateScanAngleMultiplierSlow();
        end
        
        function roiSetMarkerColor(obj, roiID, color)
            % Sets/resets the color of the specified ROI marker.
            %
            % roiStruct: the ID of the ROI to be updated.
            % color: a 3-vector representing the new color to be applied.
            
            if nargin < 2 || isempty(roiID)
                return;
			end
            
			if ~obj.roiDataStructure.isKey(roiID)
				return;
			end
			roiStruct = obj.roiDataStructure(roiID);
            
            if nargin < 3 || isempty(color)
                color = obj.markerColors(roiStruct.type);
			end
            
			% make sure the marker handle is still valid
			if ~isfield(roiStruct,'hMarker') || ~isfield(roiStruct,'hMarkerLabel') ...
						|| ~ishandle(roiStruct.hMarker) || ~ishandle(roiStruct.hMarkerLabel)
				return;
			end
			
            % update the markers
            set(roiStruct.hMarkerLabel,'Color',color);            
            if strcmp(roiStruct.type,'line')
                set(roiStruct.hMarker,'Color',color);
            else
                set(roiStruct.hMarker,'EdgeColor',color);
            end
        end
        
        function roiShiftPosition(obj,axes)
            % 
            
            global state;
            
            if ~state.motor.motorOn
                return;
            end
            
            if nargin < 2 || isempty(axes)
                error('Specify the axes.');
            end
            
            if isempty(obj.selectedPositionID) || ~obj.positionDataStructure.isKey(obj.selectedPositionID)
                error('Select a Position.');
            end
            
            selectedPositionStruct = obj.positionDataStructure(obj.selectedPositionID);
            
            % update current motor position, and then compute the delta against the selected position 
            motorGetPosition();
                                    
            dx = state.motor.absXPosition - selectedPositionStruct.motorX;
            dy = state.motor.absYPosition - selectedPositionStruct.motorY;
            if strcmpi(axes,'xyz')
                 dz = state.motor.absZPosition - selectedPositionStruct.motorZ; 
                 if state.motor.motorZEnable
                     dzz = state.motor.absZZPosition - selectedPositionStruct.motorZZ; 
                 else
                     dzz = 0;
                 end
            else
                dz = 0;
                dzz = 0;
            end
            
            % iterate through all Position entries, adding the offset
            positionIDs = obj.positionDataStructure.keys();
            for i = 1:length(positionIDs)
                positionStruct = obj.positionDataStructure(positionIDs{i});
                positionStruct.motorX = positionStruct.motorX + dx;
                positionStruct.motorY = positionStruct.motorY + dy;
                if strcmpi(axes,'xyz')
                    positionStruct.motorZ = positionStruct.motorZ + dz;
                    if state.motor.motorZEnable
                        positionStruct.motorZZ = positionStruct.motorZZ + dzz; 
                    end
                end
                obj.positionDataStructure(positionIDs{i}) = positionStruct;
            end
            obj.roiUpdatePositionTable();
        end
        
        function roiType = computeROIType(~,scanAngularRangeFast,scanAngularRangeSlow)
           
            if scanAngularRangeFast == 0 && scanAngularRangeSlow == 0
                roiType = 'point';
            elseif scanAngularRangeSlow == 0
                roiType = 'line';
            elseif scanAngularRangeFast == scanAngularRangeSlow
                roiType = 'square';
            else
                roiType = 'rect';
            end
        end
        
        function vals = getOverridableFcns(obj)
            % Returns a cell array of all currently overridable ScanImage functions.
            vals = obj.overridableFcns;
        end
        
        function tf = isFcnOverridden(obj,overriddenFcn)
            if isequal(obj.(['h' upper(overriddenFcn(1)) overriddenFcn(2:end)]),eval(['@' overriddenFcn]))
                tf = false;
            else
                tf = true;
            end
        end
        
        function registerOverrideFcn(obj,overriddenFcn,hOverrideFcn)
            % Adds a user-defined override function to the global list of overrides.
            
            if nargin < 3 || isempty(overriddenFcn) || isempty(hOverrideFcn)
                error('Please specify all arguments.');
            end
            
            % Verify that that the function handle refers to a valid and overridable function.
            assert(strcmp(class(hOverrideFcn),'function_handle'),'Invalid function handle.');
            assert(ismember(overriddenFcn,obj.getOverridableFcns()),[overriddenFcn ' is not overridable.']);
            
            % Point to the new function handle
            obj.(['h' upper(overriddenFcn(1)) overriddenFcn(2:end)]) = hOverrideFcn;
        end
        
        function unregisterOverrideFcn(obj,overriddenFcn)
            
            if nargin < 2 || isempty(overriddenFcn)
                error('You must provide a function name to be unregistered.');
            end
            
            % Point our function handle to the original ScanImage function
            obj.(['h' upper(overriddenFcn(1)) overriddenFcn(2:end)]) = eval(['@' overriddenFcn]);
        end
        
        function flagListenerAbort(obj)
            obj.listenerAbortFlag = true;
            pause(0.2);
        end
        
        function path = getLastPath(obj,path)
            path = obj.getClassDataVar(path);
        end
        
        function setLastPath(obj,varName,val)
            obj.setClassDataVar(varName,val);
        end

		function viewAll_Callback(obj,hObject,eventdata,handles)
			[obj.roiCategoriesView(:)] = deal(logical(get(hObject,'Value')));
		end
		
		function autoSelectAll_Callback(obj,hObject,eventdata,handles)
			[obj.roiCategoriesAutoSelect(:)] = deal(logical(get(hObject,'Value')));
        end
		
        function loadUSRProperties(obj,filename)
            % Loads all USR-bound property values.
            %
            % filename: The USR file being opened.
            %
            
            if nargin < 2 || isempty(filename)
                error('Specify a filename.');
            end
            
            % open file and read in by line ignoring comments
            fid=fopen(filename, 'r');
            if fid==-1
                obj.zprvError('Invalid file',['Error: Unable to open file: ' filename ]);
                return;
            end
            
            fileCell = textscan(fid, '%s', 'commentstyle', 'matlab', 'delimiter', '\n');
            fileCell = fileCell{1};
            
            % skip forward to the 'structure SI3' line...
            i = 1;
            while ~strcmp(fileCell{i},'structure SI3')
                i = i + 1;
                if i > length(fileCell)
                    return;
                end
            end
            i = i + 1;
            
            % concatenate all SI3 lines
            assignmentString = '';
            while ~strcmp(fileCell{i},'endstructure')
                assignmentString = sprintf('%s%s\n', assignmentString, fileCell{i});
                i = i + 1;
            end
            
            fclose(fid);
            
            most.util.assignments2StructOrObj(assignmentString, obj);
			
			obj.roiUpdateROITable();
        end
        
        function saveUSRProperties(obj,fid)
            % Saves all USR-bound properties (listed in 'usrBoundProperties'), 
            % appending them to the end of the USR file represented by 'fid'.
            %
            % fid: A handle to the USR file being saved.
            %
            
            if nargin < 2 || isempty(fid)
                error('Invalid fid.');
            end
            
            % write a string containing prop/val assignments for all USR-bound properties.
            fprintf(fid, 'structure SI3\n');
            fprintf(fid, most.util.structOrObj2Assignments(obj,'obj',obj.usrBoundProperties));
            fprintf(fid, 'endstructure\n');
            
            % (don't close 'fid'--it's still in use...)
        end
 
    end
    
    methods (Access=private)
        
        function isChild = isROIChild(obj,existingROIStruct, newROIStruct)
            % Determines if the given ROI can be considered a child of the specified existing ROI.
            % NOTE: this doesn't take into account motorPosition, as that should already be enforced by the time this logic is called.
            %
            % roiStruct: the roiStruct representing the ROI to be added.
            
            isChild = false;
            
            assert(isfield(existingROIStruct,'RSPs') && isfield(newROIStruct,'RSPs'), '''roiStruct'' is invalid.');
            
            if ~strcmp(existingROIStruct.type,'square') && ~strcmp(existingROIStruct.type,'rect')
                return;
            end
            
            % get the normalized coords
            [x1New y1New x2New y2New] = obj.roiCalculateNormalizedCoords(newROIStruct);
            [x1Existing y1Existing x2Existing y2Existing] = obj.roiCalculateNormalizedCoords(existingROIStruct);
            x2Existing = x1Existing + x2Existing;
            y2Existing = y1Existing + y2Existing;
            
            switch newROIStruct.type
                case 'point'
                    if x1Existing < x1New && x1New < x2Existing ...
                            && y1Existing < y1New && y1New < y2Existing
                       isChild = true; 
                    end
                    
                case 'line'
                    if x1Existing < x1New && x1New < x2Existing ...
                        && x1Existing < x2New && x2New < x2Existing ...
                        && y1Existing < y1New && y1New < y2Existing ...
                        && y1Existing < y2New && y2New < y2Existing
                        isChild = true;
                    end
                    
                case {'square' 'rect'}
                    x2New = x1New + x2New;
                    y2New = y1New + y2New;
                    if x1Existing < x1New && x1New < x2Existing ...
                        && x1Existing < x2New && x2New < x2Existing ...
                        && y1Existing < y1New && y1New < y2Existing ...
                        && y1Existing < y2New && y2New < y2Existing
                        isChild = true;
                    end
            end
        end
		
    end
    
    methods(Static,Access=private)
       
        function fprintfSmart(fID,paramName,val)
            
            if isnumeric(val)
                formatString = '%s\t%d\t';
            elseif ischar(val)
                formatString = '%s\t%s\t';
            elseif islogical(val)
                formatString = '%s\t%s\t';
                if val
                    val = 'true';
                else
                    val = 'false';
                end
            else
                return;
            end
            
            fprintf(fID,formatString,paramName,val);
        end
        
        function zprvError(statusString,messageString,doGenerateException)
            % Prints an error message to the SI3 status string, and optionally generates a Matlab error.
            %
            % statusString: the message to print to the SI3 status string.
            % messageString: the message to print to the Matlab command line.
            % doGenerateError: a boolean that, if true, will cause the function to generate a matlab exception.
            
            if nargin < 3 || isempty(doGenerateException)
                doGenerateException = false; 
            end
            
            if nargin < 2
                messageString = ''; 
            end
            
            textColor = [1 0 0];
            
            if isempty(statusString)
                statusString = 'ERROR';
            end
            setStatusString(statusString,textColor);
            
            if isempty(messageString)
                errorString = statusString;
            else
                errorString = messageString;
            end
            
            ME = MException('SI3:ERROR',errorString);
            
            if doGenerateException
                ME.throwAsCaller();
            else
                most.idioms.reportError(ME);
            end
        end
        
        function zprvDisp(messageString)
            % Prints a debugging message to the matlab console.
            %
            % messageString: the string to print.
            
            global state;
            
            state.hSI.zprvError('',messageString,false);
        end

    end
   
    %% DEVELOPER EVENTS
    
    events
        dummyEvent;
    end
    
    
end


function s = zlclInitPropMetadata()

s.activePositionID = struct('Classes','numeric');
s.shownPositionID = struct('Classes','numeric');
s.shownPositionString = struct('Classes','string');
s.activeROIID = struct('Classes','numeric');
s.shownROI = struct('Classes','numeric');
s.lineScanEnable = struct('Classes','binaryflex');
s.roiIsShownROIOutOfSync = struct('Classes','binaryflex');

s.roiName = struct('Classes','string');
s.roiAngleToMicronsFactor = struct('Classes','numeric');
s.roiDisplayDepth = struct('Classes','numeric');
s.roiDisplayedChannel = struct('Classes','string');

s.motorStepSizeX = struct('Classes','numeric');
s.motorStepSizeY = struct('Classes','numeric');
s.motorStepSizeZ = struct('Classes','numeric');
s.motorStepSizeZZ = struct('Classes','numeric');

s.roiIDs = struct('Classes','string');
s.roiPositionIDs = struct('Classes','numeric');
s.roiTypes = struct('Classes','string');
s.roiZoomFactors = struct('Classes','numeric');
s.roiRotations = struct('Classes','numeric');
s.roiShifts = struct('Classes','string');
s.roiScanAngleMultipliers = struct('Classes','string');
s.roiGotoOnAdd = struct('Classes','binaryflex');
s.roiSnapOnAdd = struct('Classes','binaryflex');

s.roiPositionToleranceX = struct('Classes','numeric');
s.roiPositionToleranceY = struct('Classes','numeric');
s.roiPositionToleranceZ = struct('Classes','numeric');
s.roiPositionToleranceZZ = struct('Classes','numeric');

% binary ROI menu settings
s.roiUseMIPForMRI = struct('Classes','binaryflex');
s.roiShowMarkerNumbers = struct('Classes','binaryflex');
s.roiGotoOnAdd = struct('Classes','binaryflex');
s.roiSnapOnAdd = struct('Classes','binaryflex');
s.roiGotoOnSelect = struct('Classes','binaryflex');
s.roiSnapOnSelect = struct('Classes','binaryflex');
s.roiWarnOnMove = struct('Classes','binaryflex');

end

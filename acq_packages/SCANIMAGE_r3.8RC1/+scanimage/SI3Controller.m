classdef SI3Controller < most.Controller
    %SCANIMAGE3CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% ABSTRACT PROPERTY REALIZATIONS (most.Controller)
    properties (SetAccess=protected)
        propBindings = lclInitPropBindings();
    end
    
    
    %% USER PROPERTIES
    
    
    %% DEVELOPER PROPERTIES
    
    properties (Hidden, SetAccess=protected)

        %PropControl Handles
		hROITable;
		hPositionTable;
        
        % TODO: Ideally, the cycle table should be revised to utilize ColumnArrayTable
        hCycleTable;
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods

        function obj = SI3Controller(hModel)
            
            obj = obj@most.Controller(hModel,{'cycleGUI' 'mainControls' 'motorControls' 'positionGUI' 'roiDisplayGUI' 'roiGUI' 'userPreferenceGUI'});
                        
            %Initialize PropControls
			obj.hROITable = getfield(guidata(obj.hGUIs.roiGUI), 'pcROITable');
			obj.hPositionTable = getfield(guidata(obj.hGUIs.positionGUI), 'pcPositionTable');

            obj.hCycleTable = obj.hGUIData.cycleGUI.tblCycle;
            
            % register CloseRequestFcns for any 'tethered' Controller GUIs
            tetheredGUIs = {'cycleGUI' 'roiGUI' 'roiDisplayGUI' 'positionGUI'};
            for i = 1:length(tetheredGUIs)
                set(obj.hGUIData.(tetheredGUIs{i}).figure1,'CloseRequestFcn',@(src,evnt)hideGUI(tetheredGUIs{i}));
            end
            
            addlistener(obj.hModel,'roiIDs','PostSet',@obj.roiTable_Listener);
            addlistener(obj.hModel,'positionIDs','PostSet',@obj.posnTable_Listener);
        end
        
    end
    
    %% DEVELOPER METHODS
    
    methods (Hidden)
 		
		function cycClearTable(obj)
			% Clears the contents of the cycle table.
			
			global state;
			
			state.cycle.cycleTableStruct = struct();
			state.cycle.cycleConfigPaths = {};
			state.cycle.cycleLength = 0;
			obj.cycTableUpdateView();
		end
        
        function cycTableUpdateView(obj)
            % Updates the cycle uitable to reflect the current model state.
            
            global state;
            
			if isempty(fieldnames(state.cycle.cycleTableStruct))
				tableData = {};
			else
				tableData = cell(length(state.cycle.cycleTableStruct),length(state.cycle.cycleTableColumns));
			end
			
            for i = 1:size(tableData,1)
                cycStruct = state.cycle.cycleTableStruct(i);
                for j = 1:length(state.cycle.cycleTableColumns)
                    columnName = state.cycle.cycleTableColumns{j};
                    
                    if isfield(cycStruct,columnName)
                        tableData{i,j} = cycStruct.(columnName);
                    else
                        tableData{i,j} = state.cycle.cycleTableColumnDefaults{j};
                    end
                end
            end
            
             set(obj.hGUIData.cycleGUI.tblCycle,'Data',tableData);
        end
        
        function motorStep_Callback(obj,axis,direction)
            global state;
            
            if strcmp(direction,'dec')
                signModifier = -1; 
            else
                signModifier = 1;
            end

            eval(['state.motor.abs' upper(axis) 'Position = state.motor.abs' upper(axis) 'Position + signModifier*obj.hModel.motorStepSize' upper(axis) ';']);
			motorSetPositionAbsolute([],'verify');
            most.idioms.pauseTight(state.motor.stepDelay); %VI051911A
			motorUpdatePositionDisplay(); 
        end
        
        function motorZero_Callback(obj)
            global state;
            
            state.motor.absXPosition = 0;
			state.motor.absYPosition = 0;
			state.motor.absZPosition = 0;
            if state.motor.motorZEnable
                state.motor.absZZPosition = 0;
            end
			
			motorSetPositionAbsolute([],'verify');
            most.idioms.pauseTight(state.motor.stepDelay); %VI051911A
			motorUpdatePositionDisplay();
        end
        
        function id = posnIdx2posnID(obj,idx)
            % Converts a row index to the corresponding Position ID.
            
			id = cell(1,length(idx));
			
            tableData = get(obj.hPositionTable.hTable,'Data');
			for i = 1:length(idx)
				id{i} = str2double(tableData(idx(i),1));
			end
        end
        
        function roiAdd(obj,type)
            if nargin < 2 || isempty('type')
                type = 'current';
			end
            
            % DEQ20110706 - it seems that there is a bug that causes the
            % RDF's colormap to get screwed up if it isn't visible at the 
            % time the first marker is drawn.  This is a bandaid.
            if strcmp(get(obj.hGUIData.roiDisplayGUI.figure1,'Visible'),'off')
                set(obj.hGUIData.roiGUI.tbROIDisplay,'Value',1);
                seeGUI('gh.roiDisplayGUI.figure1'); 
            end
			
            if strcmp(type,'centerpoint')
                obj.hModel.roiAddPoint([0 0]);
            elseif ~ismember(type,{'position' 'current' 'point' 'points' 'line' 'square' 'rect'})
                obj.hModel.zprvError('Invalid type.',['''' type ''' is not a valid ROI type.']);
                return;
			end
			
            eval(['obj.hModel.roiAdd' upper(type(1)) lower(type(2:end)) ';']);
        end
        
        function id = roiIdx2roiID(obj,idx)
            % Converts a row index to the corresponding ROI ID.
	
			id = cell(1,length(idx));
			
            tableData = get(obj.hROITable.hTable,'Data');
			for i = 1:length(idx)
				if ~isempty(tableData{idx(i),1})
					id{i} = str2double(tableData{idx(i),1}(1));
				else
					id{i} = [];
				end
			end
        end
        
        function iterationIndices = roiID2cycIterationIdx(obj,roiID)
            % Returns all cycle iteration indices that reference the given ROI.
            
            global state;
            
            iterationIndices = [];
            
            for rowIdx = 1:length(state.cycle.cycleTableStruct)
                if strcmp(state.cycle.cycleTableStruct(rowIdx).motorAction,'ROI #') ...
                        && state.cycle.cycleTableStruct(rowIdx).motorActionID == roiID
                    iterationIndices(end+1) = rowIdx; 
                end
            end
		end

        function roiShow_Callback(obj)
			if isempty(obj.hModel.selectedROIID)
				obj.hModel.zprvError('','Unspecified ROI.');
				return;
			elseif length(obj.hModel.selectedROIID) > 1
				obj.hModel.zprvError('','Invalid ROI.');
				return;
			end

			roiID = obj.hModel.selectedROIID;
            
            obj.hModel.shownROI = roiID;
            
            % disable the ROI control buttons (only if 'shownROI' has changed)
            if obj.hModel.shownROI == roiID
                obj.disableROIControlButtons();
            end
        end
        
        function posnTable_Listener(obj,src,evntdata)
            % PostSet listener for the Position uitable
            
            % 'PostSet' callbacks happen before Controller updates the
            % GUI, so this is a good time to resize the table (if necessary)...
            tableSize = obj.hPositionTable.getTableSize();
            if length(evntdata.AffectedObject.positionIDs) > tableSize(1) || length(evntdata.AffectedObject.positionIDs) < tableSize(1) 
                obj.hPositionTable.resize(length(evntdata.AffectedObject.positionIDs));
            end
        end
        
        function roiTable_Listener(obj,src,evntdata)
            % PostSet listener for the ROI uitable
            
            % 'PostSet' callbacks happen before Controller updates the
            % GUI, so this is a good time to resize the table (if necessary)...
            tableSize = obj.hROITable.getTableSize();
            if length(evntdata.AffectedObject.roiIDs) > tableSize(1) || length(evntdata.AffectedObject.roiIDs) < tableSize(1)
                obj.hROITable.resize(length(evntdata.AffectedObject.roiIDs));
            end
        end
        
        function roiFlagShownROIOutOfSync(obj,~,~)
            global gh;
            
            tooltipString = 'The currently displayed ROI.';
            warnString = ' (NOTE: The current motor position does not match that of the currently displayed ROI.)';
            
            if obj.hModel.roiIsShownROIOutOfSync
                set(gh.roiDisplayGUI.stCurrentROI,'ForegroundColor',[1 0 0]);
                set(gh.roiDisplayGUI.etShownROI,'ForegroundColor',[1 0 0]);
                set(gh.roiDisplayGUI.stCurrentROI,'TooltipString',[tooltipString warnString]);
                set(gh.roiDisplayGUI.etShownROI,'TooltipString',[tooltipString warnString]);
            else
                set(gh.roiDisplayGUI.stCurrentROI,'ForegroundColor',[0 0 0]);
                set(gh.roiDisplayGUI.etShownROI,'ForegroundColor',[0 0 0]);
                set(gh.roiDisplayGUI.stCurrentROI,'TooltipString',tooltipString);
                set(gh.roiDisplayGUI.etShownROI,'TooltipString',tooltipString);
            end
        end
        
		function roiGotoOnAdd_Helper(obj,val,handles)
			global gh;
			if val
				set(handles.mnuSnapOnAdd,'Enable','on');
				set(gh.mainControls.cbSnapOnAdd,'Enable','on');
			else
				set(handles.mnuSnapOnAdd,'Enable','off');
				set(gh.mainControls.cbSnapOnAdd,'Enable','off');
			end
		end
		
		function roiGotoOnSelect_Helper(obj,val,handles)
			if val || strcmpi(val,'on')
				set(handles.mnuSnapOnSelect,'Enable','on');
				set(handles.cbSnapOnSelect,'Enable','on');
			else
				set(handles.mnuSnapOnSelect,'Enable','off');
				set(handles.cbSnapOnSelect,'Enable','off');
			end
		end
		
        function roiDisplayZoom(obj,direction)
            hZoom = zoom(obj.hModel.hROIDisplayFig);
            set(hZoom,'Direction',direction,'Enable','on');
        end
        
        function updateTableViews(obj,tablesToUpdate)
            % Updates the ROI, Cycle, and Position uitable views;
            %
            % tablesToUpdate: a cell array of tables to update. One of: {'roi','position','cycle'}
            % If empty, all views will be updated.
            %
            
            if nargin < 2 || isempty(tablesToUpdate)
                tablesToUpdate = {'roi','position','cycle'};
            end
            
            if ismember('roi',tablesToUpdate)
                obj.hModel.roiUpdateROITable();
            end
            if ismember('position',tablesToUpdate)
               obj.hModel.roiUpdatePositionTable();
            end
            if ismember('cycle',tablesToUpdate)
               obj.cycTableUpdateView();
            end
		end
        
        function removePosition_Callback(obj)
           
            indices = selectedTableCells('position');
            rows = unique(indices(:,1));
            positions = obj.posnIdx2posnID(rows);
			obj.hModel.doSuppressTableUpdates = true;
            for i = 1:length(positions)
                obj.hModel.roiRemovePosition(positions{i});
            end
            obj.hModel.doSuppressTableUpdates = false;
            obj.updateTableViews();
        end
        
        function removeROI_Callback(obj,roiIDs)
            
            if nargin < 2 || isempty(roiIDs)
                indices = selectedTableCells('roi');
                rows = unique(indices(:,1));
                roiIDs = obj.roiIdx2roiID(rows);
            end
            
            obj.hModel.doSuppressTableUpdates = true;
            for i = 1:length(roiIDs)
                roiID = roiIDs{i};
                
                if roiID == obj.hModel.selectedROIID
                    obj.hModel.selectedROIID = [];
                end
                obj.hModel.roiRemoveROI(roiID);
            end
            obj.hModel.doSuppressTableUpdates = false;
            obj.updateTableViews();
        end
        
        function toggleUseSecondaryZ(obj)
            % We maintain two z-step values (one for the motor, and one for the secondary z motor)--this function updates the displayed value when secondary-z is enabled/disabled.
            
            global state gh;
            
            % we have two overlapping textfields--show the proper one.
            if state.motor.motorZEnable
                set(gh.motorControls.etStepSizeZZ,'Visible','on');
                set(gh.motorControls.etStepSizeZ,'Visible','off');
            else
                set(gh.motorControls.etStepSizeZ,'Visible','on');
                set(gh.motorControls.etStepSizeZZ,'Visible','off');
            end
        end
        
        function updateSelectedPosition(obj, posnID)
			if isempty(posnID) || isempty(obj.hModel.selectedPositionID) || posnID ~= obj.hModel.selectedPositionID
				obj.hModel.selectedPositionID = posnID;
			end
            
			if isempty(posnID)
				return;
			end
			
            % determine the top-level ROI associated with this position
            roiID = obj.hModel.roiGetTopLevelROIID();

			% if an ROI exists, show it.
			if ~isempty(roiID)
				obj.hModel.shownROI = roiID;
			end
        end
        
        function updateSelectedROI(obj, roiID)
			if isempty(roiID) || isempty(obj.hModel.selectedROIID) || (isscalar(obj.hModel.selectedROIID) && isscalar(roiID) && roiID ~= obj.hModel.selectedROIID)
				obj.hModel.selectedROIID = roiID;
			end
        end
        
        function roiUpdateDisplayDepth(obj,~,~)
            % Sets the toolbar buttons on the RDF to the appropriate state.
            
            switch obj.hModel.roiDisplayDepth
                case 1
                    toggledButton = 'tbDepthOne';
                case 2
                    toggledButton = 'tbDepthTwo';
                    
                case inf
                    toggledButton = 'tbDepthInf';
                    
                otherwise
                    toggledButton = '';
            end
            
            % make sure the appropriate buttons are 'on' or 'off'
            buttonNames = {'tbDepthOne' 'tbDepthTwo' 'tbDepthInf'};
            if ~isempty(toggledButton)
                set(obj.hGUIData.roiDisplayGUI.(toggledButton),'State','on');
                buttonNames(strcmp(buttonNames,toggledButton)) = [];
            end
            for i = 1:length(buttonNames)
                set(obj.hGUIData.roiDisplayGUI.(buttonNames{i}),'State','off');
            end
        end
        
        function roiUpdateDisplayedChannel(obj,~,~)
            
            switch obj.hModel.roiDisplayedChannel
                case '1'
                    toggledButton = 'tbOne';
                    
                case '2'
                    toggledButton = 'tbTwo';
                    
                case '3'
                    toggledButton = 'tbThree';
                    
                case '4'
                    toggledButton = 'tbFour';
                    
                case 'merge'
                    toggledButton = 'tbMerge';
            end
            
            % make sure the appropriate buttons are 'on' or 'off'
            buttonNames = {'tbOne' 'tbTwo' 'tbThree' 'tbFour' 'tbMerge'};
            if ~isempty(toggledButton)
                set(obj.hGUIData.roiDisplayGUI.(toggledButton),'State','on');
                buttonNames(strcmp(buttonNames,toggledButton)) = [];
            end
            for i = 1:length(buttonNames)
                set(obj.hGUIData.roiDisplayGUI.(buttonNames{i}),'State','off');
            end
        end
        
        function roiUpOneLevel_Callback(obj,isSelect)
            % Forces the ROI display to go up one level in the ROI hierarchy.
            %
            % isSelect: A boolean value that, if true, indicates that the function is being triggered by a selection.
            
            global state;
            
            if isempty(obj.hModel.shownROI)
                return;
            end
           
            if nargin < 2 || isempty(isSelect)
                isSelect = false;
            end
            
            % get the parent of the current Displayed ROI
            roiStruct = obj.hModel.roiDataStructure(obj.hModel.shownROI);
            if ~isfield(roiStruct,'parentROIID')
                return;
            end
            parentROIID = roiStruct.parentROIID;
            
            % update the displayed ROI
            obj.hModel.shownROI = parentROIID;
            
            if isSelect && obj.hModel.roiGotoOnSelect
                obj.hModel.roiGotoROI(parentROIID);

                % only take a snapshot if 'goto-on-select' is enabled
                if isSelect && obj.hModel.roiSnapOnSelect
                    snapShot();
                    while state.internal.snapping
                        pause(0.1);
                    end
                end
            end
        end
        
        function disableROIControlButtons(obj)
            set(obj.hGUIData.roiGUI.pbShow,'Enable','off');
            set(obj.hGUIData.roiGUI.pbRemove,'Enable','off');
        end
        
        function enableROIControlButtons(obj)
            set(obj.hGUIData.roiGUI.pbShow,'Enable','on');
            set(obj.hGUIData.roiGUI.pbRemove,'Enable','on');
        end
        
        function enablePositionControlButtons(obj)
            set(obj.hGUIData.roiGUI.pbShow,'Enable','off');
            set(obj.hGUIData.roiGUI.pbRemove,'Enable','on');
		end
	end
    
end

function s = lclInitPropBindings()

% ROI GUI menu options
s.roiUseMIPForMRI = struct('GuiIDs',{{'roiGUI','mnuUseMIPForMRI'}});
s.roiShowMarkerNumbers = struct('GuiIDs',{{'roiGUI','mnuShowIDs', 'roiDisplayGUI','tbDisplayNumbers'}});
s.roiGotoOnAdd = struct('GuiIDs',{{'mainControls','cbGotoOnAdd', 'roiGUI','mnuGotoOnAdd'}});
s.roiSnapOnAdd = struct('GuiIDs',{{'mainControls','cbSnapOnAdd', 'roiGUI','mnuSnapOnAdd'}});
s.roiGotoOnSelect = struct('GuiIDs',{{'roiGUI','cbGotoOnSelect', 'roiGUI','mnuGotoOnSelect'}});
s.roiSnapOnSelect = struct('GuiIDs',{{'roiGUI','cbSnapOnSelect', 'roiGUI','mnuSnapOnSelect'}});
s.roiWarnOnMove = struct('GuiIDs',{{'roiGUI','mnuWarnOnMove'}});

% ROI Display GUI controls
s.shownROI = struct('GuiIDs',{{'roiDisplayGUI','etShownROI'}});
s.roiDisplayedChannel = struct('Callback','roiUpdateTargetChannel');

% ROI uitable props (column array table bound)
s.roiIDs = struct('GuiIDs',{{'roiGUI','pcROITable'}},'PropControlData',struct('columnIdx',1,'format','cellstr'));
s.roiPositionIDs = struct('GuiIDs',{{'roiGUI','pcROITable'}},'PropControlData',struct('columnIdx',2,'format','numeric'));
s.roiTypes = struct('GuiIDs',{{'roiGUI','pcROITable'}},'PropControlData',struct('columnIdx',3,'format','cellstr'));
s.roiZoomFactors = struct('GuiIDs',{{'roiGUI','pcROITable'}},'PropControlData',struct('columnIdx',4,'format','numeric'));
s.roiRotations = struct('GuiIDs',{{'roiGUI','pcROITable'}},'PropControlData',struct('columnIdx',5,'format','numeric'));
s.roiShifts = struct('GuiIDs',{{'roiGUI','pcROITable'}},'PropControlData',struct('columnIdx',6,'format','cellstr'));
s.roiScanAngleMultipliers = struct('GuiIDs',{{'roiGUI','pcROITable'}},'PropControlData',struct('columnIdx',7,'format','cellstr'));

% Position uitable props (column array table bound)
s.positionIDs = struct('GuiIDs',{{'positionGUI','pcPositionTable'}},'PropControlData',struct('columnIdx',1,'format','cellstr'));
s.xVals = struct('GuiIDs',{{'positionGUI','pcPositionTable'}},'PropControlData',struct('columnIdx',2,'format','numeric'),'ViewPrecision','%.2f');
s.yVals = struct('GuiIDs',{{'positionGUI','pcPositionTable'}},'PropControlData',struct('columnIdx',3,'format','numeric'),'ViewPrecision','%.2f');
s.zVals = struct('GuiIDs',{{'positionGUI','pcPositionTable'}},'PropControlData',struct('columnIdx',4,'format','numeric'),'ViewPrecision','%.2f');
s.zzVals = struct('GuiIDs',{{'positionGUI','pcPositionTable'}},'PropControlData',struct('columnIdx',5,'format','numeric'),'ViewPrecision','%.2f');

% misc ROI GUI 
s.roiName = struct('GuiIDs',{{'roiGUI','etROIName','positionGUI','etROIName'}});
s.roiBreadcrumbString = struct('GuiIDs',{{'roiGUI','stBreadcrumbs'}});
s.roiAngleToMicronsFactor = struct('GuiIDs',{{'roiGUI','etAngleToMicrons'}});
s.roiDisplayDepth = struct('GuiIDs',{{'roiGUI','etDisplayDepth','roiDisplayGUI','etDisplayDepth'}},'Callback','roiUpdateDisplayDepth');
s.roiDisplayedChannel = struct('Callback','roiUpdateDisplayedChannel');

s.roiPositionToleranceX = struct('GuiIDs',{{'roiGUI','etToleranceX','positionGUI','etToleranceX'}});
s.roiPositionToleranceY = struct('GuiIDs',{{'roiGUI','etToleranceY','positionGUI','etToleranceY'}});
s.roiPositionToleranceZ = struct('GuiIDs',{{'roiGUI','etToleranceZ','positionGUI','etToleranceZ'}});
s.roiPositionToleranceZZ = struct('GuiIDs',{{'roiGUI','etToleranceZZ','positionGUI','etToleranceZZ'}});

% Motor GUI props
s.motorStepSizeX = struct('GuiIDs',{{'motorControls','etStepSizeX'}});
s.motorStepSizeY = struct('GuiIDs',{{'motorControls','etStepSizeY'}});
s.motorStepSizeZ = struct('GuiIDs',{{'motorControls','etStepSizeZ'}});
s.motorStepSizeZZ = struct('GuiIDs',{{'motorControls','etStepSizeZZ'}});

% misc
s.activePositionID = struct('GuiIDs',{{'motorControls','etPosnID'}});
s.shownPositionID = struct('GuiIDs',{{'roiDisplayGUI','etPosnID'}});
s.shownPositionString = struct('GuiIDs',{{'roiDisplayGUI','etPositionString'}});
s.activeROIID = struct('GuiIDs',{{'mainControls','etCurrentROIID'}});
s.isSubUnityZoomAllowed = struct('GuiIDs',{{'userPreferenceGUI','cbIsSubUnityZoomAllowed'}});
s.roiIsShownROIOutOfSync = struct('Callback','roiFlagShownROIOutOfSync');
end

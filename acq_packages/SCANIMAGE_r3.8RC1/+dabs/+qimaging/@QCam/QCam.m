classdef QCam < Programming.Interfaces.VClassic
    % QCAM Class encapsulating functionality of a single camera device under the QCam API
    %
    % The goal of this class is to provide a thin wrapper around QImaging's C API, 
    % in the form of a Matlab class. 
    %
    % All QCam_DoSomething() methods have been wrapped by corresponding Matlab
    % doSomething() methods.  Methods arguments are the same, with two exceptions:
    %   1) methods that take a camera handle and/or Settings structure--these
    %   arguments are automatically passed.  
    %   2) grabFrame() and queueFrames() -- these methods have been implemented
    %   via MEX functions and take different arguments.  See the documentation
    %   for these methods for more details.
    %
    % All 'qprmPropertyName' state parameters have been mapped to internal 
    % 'propertyName' properties (with the exception of qprm(S32/64)PropertyName 
    % properties, which have been mapped to 'propertyName(S32/64)'.  
    %
    % All 'qinfPropertyName' info parameters have been mapped to internal
    % 'infPropertyName' properties.
    
    %% CONSTRUCTOR-INITIALIZED PROPERTIES
    properties (SetAccess=private)
        cameraHandle; % Handle returned by API identifying camera
        cameraSettings; % Structure used to hold camera state parameters
    end
    
    %% ABSTRACT PROPERTY REALIZATION
    properties(GetAccess=protected,Constant)
        setErrorStrategy = 'restoreCached'; % tell VClass to cache the current value before calling a Set function, and fall back to this cached value if an error occurs.
    end
        
    
    %% DEVICE PROPERTIES (ADDED BY CLASS)
    properties
        
    end
    
    %% DEVICE PROPERTIES
    %   'Pseudo-dependent' properties    
    %   The device properties for QCam API include both the 'Camera Information Parameters' and the 'Camera State Parameters' enumerated in the API documentation
    
    %Camera Information Parameters -- these are get-only
    properties (GetObservable,SetObservable)               
        infBitDepth; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infCameraType; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infCcd; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infCcdHeight; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infCcdWidth; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infCcdType; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infCooled; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infExposureRes; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infFirmwareBuild; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infFirmwareVersion; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infHardwareVersion; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infImageHeight; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infImageWidth; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infImageSize; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infIntensifierModel; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infIsModelB; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infNormGaindBRes; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infNormGainSigFigs; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infNormITGaindBRes; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infNormITGainSigFigs; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infSerialNumber; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infStreamVersion; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infTriggerDelayRes; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infUniqueId; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infRegulatedCooling; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infRegulatedCoolingLock; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infFanControl; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infHighSensitivityMode; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infblackoutMode; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infPostProcessImageSize; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infAsymmetricalBinning; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infColorWheelSupported; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infEMGain; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infOpenDelay; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        infCloseDelay; % This property wraps an 'info parameter' of the same name.  See QImaging documentation.
        %infDualChannel; % given by the documentation, but not defined in the header
    end
    
    %Camera State Parameters
    properties (GetObservable,SetObservable) 
        binning; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        cameraMode; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        coolerActive; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        colorWheel; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        horizontalBinning; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        imageFormat; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        intensifierGain; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        normalizedGain; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        normIntensGaindB; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        offset; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        readoutSpeed; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        roiHeight; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        roiWidth; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        roiX; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        roiY; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        absoluteOffsetS32; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        normalizedGaindBS32; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        shutterState; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        syncb; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        triggerDelay; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        triggerType; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        verticalBinning; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        exposure; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        exposure64; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        exposureBlue; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        exposureBlue64; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        exposureRed; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        exposureRed64; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        normIntensGain64; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        doPostProcessing; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        postProcessGainRed; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        postProcessGainGreen; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        postProcessGainBlue; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        postProcessBayerAlgorithm; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        postProcessImageFormat; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        regulatedCoolingTempS32; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        fan; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        blackoutMode; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        highSensitivityMode; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        EMGain; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        closeDelay; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        openDelay; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        CCDClearingMode; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
        overSample; % This property wraps a 'state parameter' of the same name.  See QImaging documentation.
    end
    
    
    %% PRIVATE/PROTECTED PROPERTIES
    
    % Properties to be explicitly initialized on object construction
    properties (Access=public, Hidden) %TODO: CHANGE THIS BACK TO PROTECTED
        methodNargoutMap; % Map keyed by driver function names, containing number of output arguments for each function, not including 'status'
        responseCodeMap; % Maps response code strings to their numeric value
        propertyAliasMap; % Maps property names used by QCam class to names used by QCam API.
        propertyValidValuesMap; % Maps property names to the values given by either a 'range table' or a 'sparse table'
        enumMap; % Maps the name of an enum structure to an array mapping string/val pairs NOTE: this map uses one-based indexing, while the API uses zero-based indexing.
        
        isConstructed=false; % A flag used to indicate that the object has been successfully constructed.
        commitFlag = false; % a flag used to indicate that there are property changes that have not yet been sent to the camera
        preflightValidatedFlag = true; % a flag used to indicate that the current settings structure has been validated by preFlightSettings()
    end
    
    properties (GetAccess=private,Hidden, Constant)
        driverPrettyName = 'QCam API';
        driverHeaderFilename = 'QCamApi_2_0_8_MOD';
        driverLib = 'QCamDriver';
        driverPath = 'c:\windows\system32';
        driverDataFilename = 'DriverData.mat';
        
        dataFileFields = {'methodNargoutMap' 'responseCodeMap'};
        
        displayProperties = sort({'infSerialNumber' 'infCameraType' 'infBitDepth' 'infCcdType' 'infCcdWidth' 'infCcdHeight' 'binning' });
    end
    
    
    %% CONSTRUCTOR/DESTRUCTOR      
    
    methods
        function obj = QCam(cameraSerialNumber)
            % Constructs a Devices.QImaging.QCam class instance, encapsulating a QImaging device.

            import Devices.QImaging.*;
            
            % Load the QImaging  DLL, if needed
            % TODO: At moment, we cache header file as part of class, but rely on DLL to be installed in particular path. Is this right approach?
            if ~libisloaded(obj.driverLib)
                disp([obj.driverPrettyName ': Initializing...']);
                warning('off','MATLAB:loadlibrary:parsewarnings');
                %loadlibrary(obj.driverLib,@QCamDriver_2_0_8); %TODO: can't get this to work with obj.driverHeaderFilename 
                loadlibrary(fullfile(obj.driverPath, [obj.driverLib '.dll']),@QCamDriver_2_0_8);
                warning('on','MATLAB:loadlibrary:parsewarnings');
            end
            
            % Update the driver data file, if needed
            dataFullFileName = fullfile(obj.classPrivatePath,obj.driverDataFilename);
            if ~exist(dataFullFileName,'file')
                obj.driverDataUpdate(); %This loads header file and data, and loads the library as well
            else
                % Load properties from file
                fileProps = obj.dataFileFields;
                foundFileProps = who('-file',dataFullFileName);
                if ~isempty(setdiff(fileProps,foundFileProps)) %Some properties weren't found
                    obj.driverDataUpdate();
                else
                    % A silly two-step
                    structVar = load(dataFullFileName, fileProps{:});
                    for i=1:length(fileProps)
                        obj.(fileProps{i}) = structVar.(fileProps{i});
                    end
                end
            end
            
            % Initialize the driver
            obj.loadDriver();
            
            % Determine # of cameras & obtain handle to this particular camera
            [cameraList,numCameras] = obj.listCameras();
            
            if numCameras == 0
                error('There does not appear to be a camera attached to the system.');
            end
            
            if ~nargin && numCameras > 1
                error(['A camera serial number must be specified when there is more than one camera (' num2str(obj.numCameras) ' cameras detected).']);
            end
            
            if numCameras > 1
                % TODO: handle the case of multiple cameras
            else
                obj.openCamera(cameraList.cameraId);
            end
            
            disp('About to initialize model property values...');
            obj.initializeModelPropValues(); %Initialize properties which depend on particular camera model
            obj.initializeDefaultPropValues(); %Initialize properties to a default startup state -- including several properties with SetXXX() call, but no corresponding GetXXX() function.
            
            obj.customDisplayPropertyList = obj.displayProperties;
            
            %Signal construction completion
            obj.isConstructed = true;
        end
        
        function delete(obj)
            
            %Handle array case
            if length(obj) > 1
                for i=1:length(obj)
                    delete(obj(i));
                end
                return;
            end
            
            if ~isempty(obj.cameraHandle)
                 obj.closeCamera();
            end
                        
        end
        
    end
    
    %% PROPERTY ACCESS METHODS
    
    methods (Access=protected)
       
        function pdepPropHandleGet(obj,src,evnt)
            propName = src.Name;
            
            % make sure we are in a consistent state with the hardware
            if obj.isConstructed && obj.commitFlag
                if ~obj.preflightValidatedFlag
                    obj.preflightSettings();
                    obj.preflightValidatedFlag = true;
                end
            end

            switch propName(1:3)
                case {'inf'}
                    obj.pdepPropGroupedGet(@obj.getInfParameter,src,evnt);
                otherwise
                    obj.pdepPropGroupedGet(@obj.getStateParameter,src,evnt);
            end
            
            % ensure we return numbers as doubles
            if isnumeric(obj.(propName)) 
                obj.pdepPropLockMap(propName) = true;
                obj.(propName) = double(obj.(propName));
                obj.pdepPropLockMap(propName) = false;
            end
        end
        
        function pdepPropHandleSet(obj,src,evnt)
            propName = src.Name;
            
            switch propName(1:3)
                case {'inf'} %Set-access not allowed for info parameters
                    if obj.isConstructed
                        obj.pdepPropSetDisallow(src,evnt);
                    end
                otherwise
                    obj.pdepPropGroupedSet(@obj.setStateParameter,src,evnt);
                    obj.commitFlag = true;
                    obj.preflightValidatedFlag = false;
            end
            
        end
        
    end
    
    %% GROUPED PDEP GET METHODS
    methods (Hidden)
        
       function val = getInfParameter(obj,propName)
           % Returns the value for the given info parameter
           
            val = obj.(propName);
            
            enumName = ['QCam_qc' propName(4:end)];
            if obj.enumMap.isKey(enumName)
                enumCell = obj.enumMap(enumName);
               val = enumCell{val + 1}; 
            end
       end
        
       function val = getStateParameter(obj,propName)
           % Returns the value for the given state parameter
           
           % make sure we're using the API name
           if ~strcmp(propName(1:4),'qprm')
               propName = obj.propertyAliasMap(propName);
           end
           
           % handle the S32 and 64 cases
           if strcmp(propName(end-1:end),'64')
               propName = [propName(1:4) '64' propName(5:end-2)];
           elseif strcmp(propName(end-2:end),'S32')
               propName = [propName(1:4) 'S32' propName(5:end-3)];
           end
           
           val = obj.getParam(propName);
       end
       
       function setStateParameter(obj,propName,val)
           % Sets the given state parameter to the given value.
           
           % make sure we're using the API name
           if ~strcmp(propName(1:4),'qprm')
               propName = obj.propertyAliasMap(propName);
           end
           
           obj.setParam(propName,val);
       end
    end
    
    
    %% ABSTRACT METHOD REALIZATIONS / FUNCTION OVERRIDES
    
    methods
        function display(obj)
            obj.VClassDisplay();
        end
    end
    
    
    %% PUBLIC METHODS
    
    % API WRAPPER METHODS
    methods (Access=public)
        
        function abort(obj)
            % See QCam API documentation for function details.
            
           obj.driverCall('QCam_Abort',obj.cameraHandle);
        end
        
        function closeCamera(obj)
            % See QCam API documentation for function details.
            
           obj.driverCall('QCam_CloseCamera',obj.cameraHandle); 
        end
        
        function val = getCameraModelString(obj)
            % See QCam API documentation for function details.
            
           val = obj.driverCall('QCam_GetCameraModelString',obj.cameraHandle,char(zeros(1,256),256)); 
        end
        
        function val = getInfo(obj,propName)
            % See QCam API documentation for function details.
            
            val = obj.driverCall('QCam_GetInfo',obj.cameraHandle,['q' propName],0); 
        end
        
        function val = getParam(obj,propName)
            % See QCam API documentation for function details.
            % NOTES: 1) this method wraps 'QCam_GetParam()','QCam_GetParam64()',
            %           and 'QCam_GetParamS32()' 
            %        2) assumes that propName is using the API property name
            %           (not our internal alias).

            % determine which API GetXXX() function to call
            callFnc = obj.formatFunctionName('QCam_GetParam',propName);
           
            [~,val] = obj.driverCall(callFnc,obj.cameraSettings,propName,0);
        end
        
        function val = getParamMax(obj,propName)
            % See QCam API documentation for function details.
            % NOTES: 1) this method wraps 'QCam_GetParamMax()','QCam_GetParam64Max()',
            %           and 'QCam_GetParamS32Max()' 
            %        2) assumes that propName is using the API property name
            %           (not our internal alias).
            
            % determine which API GetXXXMax() function to call
            callFnc = obj.formatFunctionName('QCam_GetParamMax',propName);
           
            [~, val] = obj.driverCall(callFnc,obj.cameraSettings,propName,0);
        end
        
        function val = getParamMin(obj,propName)
            % See QCam API documentation for function details.
            % NOTES: 1) this method wraps 'QCam_GetParamMin()','QCam_GetParam64Min()',
            %           and 'QCam_GetParamS32Min()' 
            %        2) assumes that propName is using the API property name
            %           (not our internal alias).
            
            % determine which API GetXXXMin() function to call
            callFnc = obj.formatFunctionName('QCam_GetParamMin',propName);

            [~, val] = obj.driverCall(callFnc,obj.cameraSettings,propName,0);
        end
        
        function val = getParamSparseTable(obj,propName)
            % See QCam API documentation for function details.
            % NOTES: 1) this method wraps 'QCam_GetParamSparseTable()','QCam_GetParamSparseTable64()',
            %           and 'QCam_GetParamSparseTableS32()' 
            %        2) assumes that propName is using the API property name
            %           (not our internal alias).
            
            % determine which API GetParamSparseTableXXX() function to call
            callFnc = obj.formatFunctionName('QCam_GetParamSparseTable',propName);
            
            table = [1:32];
            sparseTable = libpointer('uint32Ptr',table);
            
            [~,sparseTable,size] = obj.driverCall(callFnc,obj.cameraSettings,propName,sparseTable,32);
            val = sparseTable(1:size);
        end
        
        function val = getSerialString(obj)
            % See QCam API documentation for function details.
            
            val = obj.driverCall('QCam_GetSerialString',char(zeros(1,32)),32);
        end
        
        function tf = isRangeTable(obj,propName)
            % See QCam API documentation for function details.
            % NOTES: 1) this method wraps 'QCam_IsRangeTable()','QCam_IsRangeTable64()',
            %           and 'QCam_IsRangeTableS32()'
            %        2) assumes that propName is using the API property name
            %           (not our internal alias).
            
            
            % determine which API IsRangeTableXXX() function to call
            callFnc = obj.formatFunctionName('QCam_IsRangeTable',propName);
            
            err = obj.driverCallRaw(callFnc,obj.cameraSettings,propName);
            
            if strcmp('qerrSuccess',err)
                tf = true;
            else
                tf = false;
            end
        end
        
        function tf = isSparseTable(obj,propName)
            % See QCam API documentation for function details.
            % NOTES: 1) this method wraps 'QCam_IsSparseTable()','QCam_IsSparseTable64()',
            %           and 'QCam_IsSparseTableS32()'
            %        2) assumes that propName is using the API property name
            %           (not our internal alias).
            
            % determine which API QCam_SetParamXXX() function to call
            callFnc = obj.formatFunctionName('QCam_IsSparseTable',propName);

            err = obj.driverCallRaw(callFnc,obj.cameraSettings,propName);
            
            if strcmp('qerrSuccess',err)
                tf = true;
            else
                tf = false;
            end
        end        
        
        function val = libVersion(obj)
            % See QCam API documentation for function details.
            
            [x y z] = obj.driverCall('QCam_LibVersion',0,0,0); 
            val = [num2str(x) '.' num2str(y) '.' num2str(z)];
        end
        
        function varargout = listCameras(obj)
            % See QCam API documentation for function details.
            
            cameraList = libpointer('QCam_CamListItem');
            cameraList.Value.m_reserved = zeros(10,1,'uint32');  %Deal with array nested in structure
            [cameraList, numCameras] = obj.driverCall('QCam_ListCameras',cameraList,1);
            varargout = {cameraList numCameras};
        end
        
        function loadDriver(obj)
            % See QCam API documentation for function details.
            
            obj.driverCallFiltered('QCam_LoadDriver','qerrDriverAlreadyLoaded');
        end
        
        function openCamera(obj,cameraID)
            % See QCam API documentation for function details.
            
            obj.cameraHandle = obj.driverCall('QCam_OpenCamera',cameraID,0);
        end
        
        function tf = preflightSettings(obj)
            % See QCam API documentation for function details.
            
            obj.driverCall('QCam_PreflightSettings',obj.cameraHandle,obj.cameraSettings);
        end
        
        function val = readDefaultSettings(obj)
            % See QCam API documentation for function details.

            defaultSettings = libpointer('QCam_Settings');
            defaultSettings.Value.m_private_data = zeros(64,1,'uint32');
            
            obj.driverCall('QCam_ReadDefaultSettings',obj.cameraHandle,defaultSettings);
            
            val = defaultSettings;
        end
        
        function val = readSettingsFromCamera(obj)
            % See QCam API documentation for function details.

            currentSettings = libpointer('QCam_Settings');
            currentSettings.Value.m_private_data = zeros(64,1,'uint32');
            
            obj.driverCall('QCam_ReadSettingsFromCam',obj.cameraHandle,currentSettings);
            
            val = currentSettings;
        end
        
        function releaseDriver(obj)
            % See QCam API documentation for function details.
            
            obj.driverCall('QCam_ReleaseDriver',obj.cameraHandle,obj.cameraSettings);
        end
        
        function sendSettingsToCamera(obj)
            % See QCam API documentation for function details.
            
            obj.driverCall('QCam_SendSettingsToCam',obj.cameraHandle,obj.cameraSettings);
            
            obj.commitFlag = false;
        end
        
        function setParam(obj,propName,value)
            % See QCam API documentation for function details.
            % NOTES: 1) this method wraps 'QCam_SetParam()','QCam_SetParam64()',
            %           and 'QCam_SetParamS32()'
            %        2) assumes that propName is using the API property name
            %           (not our internal alias).
            
            % determine which API QCam_SetParamXXX() function to call
            callFnc = obj.formatFunctionName('QCam_SetParam',propName);
           
            % if it exists, enforce any sparse/range table constraints
            if obj.propertyValidValuesMap.isKey(propName)
                tableData = obj.propertyValidValuesMap(propName);
                if ~isempty(tableData)
                    if length(tableData) == 2
                        assert(tableData(1) <= value && value <= tableData(2),'Error setting data: the given value is not within the valid range.');
                    else
                        assert(ismember(value,tableData),['Error setting data: the given value is not valid. Must be one of: ' mat2str(tableData)]);
                    end
                end
            end
            
            obj.driverCall(callFnc,obj.cameraSettings,propName,value);
        end
        
        function setStreaming(obj,value)
            % See QCam API documentation for function details.
            
            if (obj.commitFlag)
                disp('There are pending property updates--sending settings to camera now...');
                obj.sendSettingsToCamera();
            end
            
            obj.driverCall('QCam_SetStreaming',obj.cameraHandle,value);
        end
        
        function translateSetting(obj,settings)
            % TODO: IMPLEMENT THIS...NOT REALLY SURE HOW THIS IS USED
        end
        
        function trigger(obj)
            % See QCam API documentation for function details.
            
            if (obj.commitFlag)
                disp('There are pending property updates--sending settings to camera now...');
                obj.sendSettingsToCamera();
            end
            
            obj.driverCall('QCam_Trigger',obj.cameraHandle);
        end
    end
    
    
    
    %% PRIVATE/PROTECTED METHODS
    methods (Access=private)
        
        function varargout = driverCall(obj,funcName,varargin)
            % Method to wrap calls to QCam API functions. 
            % funcName: name of QCam API function to call
            % varargin: an optional list of input arguments
            
            %Determine # of output arguments
            varargout = cell(nargout,1);
            
            %Call the driver function
            if nargout
                [status varargout{:}] = calllib(obj.driverLib,funcName,varargin{:});
            else
                status = calllib(obj.driverLib,funcName,varargin{:});
            end
            
            %Throw error if status code represent an error
            obj.validateStatus(status,funcName);
        end
       
        function varargout = driverCallFiltered(obj,funcName,ignoredCodes,varargin)
            % A variant of driverCall() used to ignore certain device responses.
            % see driverCall() documentation.
            
            %Determine # of output arguments
            varargout = cell(nargout,1);
            
            %Call the DAQmx driver function
            [status varargout{:}] = calllib(obj.driverLib,funcName,varargin{:});
            
            %Throw error if status code represent an error
            obj.validateStatus(status,funcName,ignoredCodes);
        end
        
        function [status varargout] = driverCallRaw(obj,funcName,varargin)
            % A variant of driverCall() used to ignore certain device responses.
            % see driverCall() documentation.
            
            %Determine # of output arguments
            varargout = cell(nargout-1,1);
            
            %Call the DAQmx driver function
            [status varargout{:}] = calllib(obj.driverLib,funcName,varargin{:});
        end
        
        function driverDataUpdate(obj)
            % A utility method that loads (and caches) data from the device driver.
            
            obj.responseCodeMap = containers.Map({'dummy'},{1}); % Maps response code strings to their numeric value
            obj.propertyAliasMap = containers.Map({'dummy'},{'dummy'}); % Maps property names used by QCam class to names used by QCam API.
            obj.enumMap = containers.Map({'dummy'},{{'dummy1' 'dummy2'}}); % Maps enum names to enum string/value pairs
            
            try
                prototypes = libfunctions(obj.driverLib, '-full');
                
                %Determine methodNargoutMap
                tokens = regexp(prototypes,'(QCam_Err|\[(.*)])\s*(\w*)','tokens','once'); %Captures the output arguments of each function
                tokens = cat(1,tokens{:}); %Converts from nested cell array to Nx2 cell array
                outArgs = tokens(:,1);
                funcNames = tokens(:,2);
                outArgs = regexp(outArgs,'QCam_Err(.*)','tokens','once'); % A cell array of cell arrays, each containing 2 elements: the first containing the void* argument and the second the comma-delimited list of remaining arguments
                numOutArgs = cellfun(@(x)length(strfind(x{1},',')),outArgs);
                
                obj.methodNargoutMap = containers.Map(funcNames',num2cell(numOutArgs'));    
                
                % Scan the header file and store all device response code string/value pairs
                fID = fopen(fullfile(obj.classPath,[obj.driverHeaderFilename '.h']), 'r');
                
                while (~feof(fID))
                    currentLine = textscan(fID,'%s', 1,'delimiter','\n','whitespace','');
                    
                    responseCodeMatch = regexp(currentLine{:},'^\s+qerr');
                    enumMatch = regexp(currentLine{:},'^typedef enum');
                    
                    if (~isempty(responseCodeMatch) && ~isempty(responseCodeMatch{1}))
                        parts = regexp(currentLine{:},'\s+(\w+)\s+=\s+(\d+|0x\w+)','tokens');
                        parts = parts{1}{:};
                        codeName = parts{1};
                        codeValue = parts{2};
                        
                        hexIdx = regexp(codeValue, '0x', 'once');
                        if (hexIdx == 1)
                            codeValue = hex2dec(codeValue(3:end));
                        else
                            codeValue = str2num(codeValue);
                        end
                        
                        obj.responseCodeMap(codeName) = codeValue;    
                    elseif (~isempty(enumMatch) && ~isempty(enumMatch{1}))
                        % the following code is contingent on the assumption that the header's enum declarations conform to the following format:
                        %
                        % typedef enum
                        % {
                        %    ...
                        % }
                        % QCam_<NAME>
                        %
                        isEnum = true;
                        isLastLine = false;
                        currentEnumCell = cell(1);
                        while isEnum
                           currentLine = textscan(fID,'%s', 1,'delimiter','\n','whitespace','');
                           currentLine = currentLine{:};
                           
                           % skip the first line and opening brace
                           if strcmp(currentLine,'typedef enum') ||strcmp(currentLine,'{')
                               continue;
                           end
                           
                           % skip closing brace and prep to read enum name
                           if strcmp(currentLine,'}')
                               isLastLine = true;
                               continue;
                           end
                           
                           % read the enum name and prep to break the loop
                           if isLastLine
                               enumName = currentLine{:};
                               isEnum = false;
                               continue;
                           end
                           
                           % process the line
                           parts = regexp(currentLine,'\s+(\w+)\s+=\s+(\d+)','tokens');

                           if isempty(parts{:})
                               continue;
                           end
                           
                           parts = parts{1};
                           
                           if strcmp(parts{1}{1}(1:4),'qprm') % handle parameter enums seperately
                               parts = regexp(currentLine{:},'^\s+qprm(S32|64)*(\w+)','tokens');
                               parts = parts{:};
                               
                               if ~isempty(parts{1})
                                   pName = [lower(parts{2}(1)) parts{2}(2:end) parts{1}];
                               elseif strcmp(parts{2}(2),upper(parts{2}(2)))          % if the second character is upper case...
                                   pName = parts{2};                               % ...keep the first character upper case...
                               else
                                   pName = [lower(parts{2}(1)) parts{2}(2:end)];   % ...otherwise, make the first character lower case.
                               end
                               
                               if strcmp(pName(1),'_')    % skip props that begin with an underscore
                                   continue;
                               end
                               
                               obj.propertyAliasMap(pName) = ['qprm' parts{:}];
                           else
                               currentEnumCell{str2double(parts{1}(2)) + 1} = parts{1}{1}; % store the indexed value (converting to 1-based indexing)
                           end
                        end
                        
                        % store vals
                        obj.enumMap(enumName(1:end-1)) = currentEnumCell;
                    end
                    
                end
                fid = fclose(fID);
                obj.responseCodeMap.remove('dummy');
                obj.propertyAliasMap.remove('dummy');
                
                %Save variables to file
                tempStruct = struct();
                for i=1:length(obj.dataFileFields)
                    tempStruct.(obj.dataFileFields{i}) = obj.(obj.dataFileFields{i});
                end
                save(fullfile(obj.classPath,obj.driverDataFilename),'-struct','tempStruct',obj.dataFileFields{:});
                
            catch ME
                obj.VError('','DriverDataParseError','Error occurred while parsing driver data header file: \n%s',ME.message);
            end
        end
        
        function val = formatFunctionName(obj,template,propName)
            % Correctly formats a default function name (such as 'QCam_SetParam') 
            % to one of the 32/64 bit variants
            
            if length(propName) < 7 || strcmp(propName(5:7),'S32')
                suffix = 'S32';
            elseif length(propName) < 6 || strcmp(propName(5:6),'64')
                suffix = '64';
            else
                suffix = '';
            end
            
            % the Min/Max functions don't match the pattern nicely...
            if strcmp('QCam_GetParamMin',template)
                val = ['QCam_GetParam' suffix 'Min'];
            elseif strcmp('QCam_GetParamMax',template)
                val = ['QCam_GetParam' suffix 'Max'];
            else
                val = [template suffix];
            end
        end
        
        function initializeDefaultPropValues(obj)
            
        end
        
        function initializeModelPropValues(obj)
            
            obj.propertyValidValuesMap = containers.Map({'dummy'},{[1:10]});
            
            % populate the state parameter structure
            obj.cameraSettings = libpointer('QCam_Settings');
            obj.cameraSettings.Value.m_private_data = zeros(64,1,'uint32'); 
            obj.driverCall('QCam_ReadDefaultSettings',obj.cameraHandle,obj.cameraSettings);
            
            % loop through this class's pdep properties
            mc = metaclass(obj);
            for prop=[mc.Properties{:}]
                if prop.GetObservable || prop.SetObservable
                    propNotSupported = false;
                    % initialize the property value (local) to its default value (from hardware)
                    if strcmp('inf',prop.Name(1:3)) % handle 'info parameters'
                        
                        [status val] = obj.driverCallRaw('QCam_GetInfo',obj.cameraHandle,['q' prop.Name],0);
                        if strcmp(status,'qerrNotSupported')
                            obj.pdepPropLockMap(prop.Name) = true;
                            obj.(prop.Name) = [];
                            obj.pdepPropLockMap(prop.Name) = false;
                        else
                            obj.validateStatus(status,'QCam_GetInfo');
                            obj.pdepPropLockMap(prop.Name) = true;
                            obj.(prop.Name) = val;
                            obj.pdepPropLockMap(prop.Name) = false;
                        end
                        
                    else % handle 'state parameters' by instigating a pdep get
                        if obj.propertyAliasMap.isKey(prop.Name)
                            propName = obj.propertyAliasMap(prop.Name);
                        else
                            warning(['Unknown property: ' prop.Name]);
                            continue;
                        end
                        
                        callFnc = obj.formatFunctionName('QCam_GetParam',propName);
                        [status,~,val] = obj.driverCallRaw(callFnc,obj.cameraSettings,propName,0);
                        if strcmp(status,'qerrNotSupported')
                            obj.pdepPropLockMap(prop.Name) = true;
                            obj.(prop.Name) = [];
                            obj.pdepPropLockMap(prop.Name) = false;
                            propNotSupported = true;
                        else
                            obj.pdepPropLockMap(prop.Name) = true;
                            obj.(prop.Name) = val;
                            obj.pdepPropLockMap(prop.Name) = false;
                        end              
                        
                        % determine if this property has an associated 'range table' or 'sparse table
                        try 
                            if ~propNotSupported && obj.isRangeTable(propName)
                                obj.propertyValidValuesMap(propName) = [obj.getParamMin(propName) obj.getParamMax(propName)];
                            elseif ~propNotSupported && obj.isSparseTable(propName)
                                sparseTable = obj.getParamSparseTable(propName);
                                obj.propertyValidValuesMap(propName) = sparseTable;
                            end
                        catch ME
                            if ~isempty(strfind(ME.message,'qerrNotSupported'))
                                fprintf(1,'WARNING: QImaging API reported that property ''%s'' has a range table or sparse table, but none was found\n',propName);
                            else 
                                ME.rethrow();
                            end
                        end
                    end
                    
                end
            end
            obj.propertyValidValuesMap.remove('dummy'); 
            
        end

        function validateStatus(obj,status,funcName,filteredCodes)
            % Checks the response code returned by driverCall() to verify
            % a successful driver call.
            % status: the response code returned by driverCall()
            % funcName: the function name called by driverCall()
            % filteredCodes: an optional list of response codes to ignore
            
            if nargin < 4
                filteredCodes = {};
            end
            
            if ~iscell(filteredCodes)
                filteredCodes = {filteredCodes};
            end
            
            if ~strcmp(status,'qerrSuccess') && ~ismember(status,filteredCodes)                
                ME = MException('QCam:FailedCall',['QCam error (' status ') in call to ' funcName]);
                ME.throwAsCaller();
            end
        end
        
    end
    
end


classdef LSM < dabs.thorlabs.private.ThorDevice
    %LSM Class encapsulating Laser Scanning Microscopy Devices offered by Thorlabs
    
    
    %% NOTES
    %
    %   TODO: (VI062511) Add framePeriodEstimate dependent property which estimates frame period at current settings
    %   TODO: Improve naming of 'running' & 'isAcquiring' property/method pair
    %   TODO: Currently setLoggingProperty() allows changes to loggingHeaderString & loggingFileName during live acquisition (though not recommended). However, this is problematic for loggingHeaderString -- a change to just that property would start the current file over wt
    %   TODO: Use some parsing scheme to create and fill-in values for class-added properties listing out options for triggerMode (e.g. 'triggerModes'), and other enumerated properties.
    
    %   TODO: Move accessDeviceCheckoutList to ThorDevice (centralized store of Dabs.Devices)
    
    %% ABSTRACT PROPERTY REALIZATIONS (dabs.thorlabs.private.ThorDevice)
    properties (Constant, Hidden)
        deviceTypeDescriptorSDK = 'Camera'; %Descriptor used by SDK for device type in function calls, e.g. 'Device', 'Camera', etc.
        prop2ParamMap=zlclInitProp2ParamMap(); %Map of class property names to API-defined parameters names
    end
    
    
    %% ABSTRACT PROPERTY REALIZATIONS (most.APIWrapper)
    
    %Following MUST be supplied with non-empty values for each concrete subclass
    properties (Constant, Hidden)
        apiPrettyName='Thorlabs LSM';  %A unique descriptive string of the API being wrapped
        apiCompactName='ThorlabsLSM'; %A unique, compact string of the API being wrapped (must not contain spaces)       
       
        %Properties which can be indexed by version
        apiDLLNames = 'ThorConfocal'; %Either a single name of the DLL filename (sans the '.dll' extension), or a Map of such names keyed by values in 'apiSupportedVersionNames'
        %apiHeaderFilenames = { 'LSM_SDK_MOD.h' 'LSM_SDK_MOD.h' 'LSM_SDK_MOD.h' 'LSM_SDK.h' 'LSM_SDK.h' 'LSM_SDK.h' 'LSM_SDK.h' 'LSM_SDK.h'}; %Either a single name of the header filename (with the '.h' extension - OR a .m or .p extension), or a Map of such names keyed by values in 'apiSupportedVersionNames'
        apiHeaderFilenames = 'ThorConfocal_proto.m';
        
    end    
   
    
    %% DEVICE PROPERTIES (PSEUDO-DEPENDENT)
    
    %PDEP properties corresponding directly to 'params' defined by API
    properties (SetObservable, GetObservable)
        triggerMode; %One of {'SW_SINGLE_FRAME', 'SW_MULTI_FRAME', 'SW_FREE_RUN_MODE', 'HW_SINGLE_FRAME', 'HW_MULTI_FRAME_TRIGGER_FIRST'}
        triggerTimeout=inf; %Time, in seconds, within which external start trigger is expected to arrive
        triggerFrameClockWithExtTrigger=true; %<Logical>If true, frame clock signal is generated when external (hardware) triggering is enabled. This adds some latency... 
        multiFrameCount; %Number of frames to acquire when using triggerMode='SW_MULTI_FRAME' or 'HW_MULTI_FRAME_TRIGGER_FIRST'
        
        pixelsPerDim; %Number of pixels (in both X & Y dimensions)
        fieldSize; %Value from 1-255 setting the field-size
        
        scanMode; %One of {'TWO_WAY_SCAN', 'FORWARD_SCAN', 'BACKWARD_SCAN'}
        bidiPhaseAlignment; %Value from -127-128 allowing bidi scan adjustment ('TWO_WAY_SCAN' mode)
        aspectRatioY; 
        areaMode;        
        offsetY;
        
        averagingMode; %One of {'AVG_NONE', 'AVG_CUMULATIVE'};
        averagingNumFrames; %Number of frames to average, when averagingMode = 'AVG_CUMULATIVE'
        
        channelsActive; %Array identifying which channels are active, e.g. 1, [1 2], etc.
        inputChannelRange1; %One of the valid input ranges (e.g. 'INPUT_RANGE_20_MV')
        inputChannelRange2; %One of the valid input ranges (e.g. 'INPUT_RANGE_20_MV')
        inputChannelRange3; %One of the valid input ranges (e.g. 'INPUT_RANGE_20_MV')
        inputChannelRange4; %One of the valid input ranges (e.g. 'INPUT_RANGE_20_MV')

        clockSource=1; %<1=Internal, 2=External> Specifies clock source for synchronizing to laser pulse train rate
        clockRate=80e6; %Specify clock rate correpsonding to laser pulse train
        
        flybackTimeLines;
    end

    %PDEP properties created by this class
    properties (GetObservable,SetObservable)        
        frameCount;          % async thread MEX frame count
        framesAvailable;     % async thread MEX frames availalbe (circular buffer queue current size)
        
        circBufferSize=4;  % size of the circular buffer in frames
        
        loggingFileName=''; %Full filename of logging file
        loggingAveragingFactor=1; %Number of frames to average before writing to disk (decimating data stream)
        %         loggingFilePath;
        %         loggingFileName='lsm_data';
        %         loggingFileType='tif';  %One of {'tif' 'bin'} %TODO: Actually use this -- or eliminate it!
    end
    
    properties (GetObservable,SetObservable, Hidden)
        %Property must be hidden to avoid nested header string
        loggingHeaderString=''; %String containing header information to store as metadata in logging TIF file
    end
    
    %Hidden PDEP properties created by this class
    properties (GetObservable,SetObservable,Hidden)
        droppedFramesTotal;  % async thread MEX dropped frames (single frame buffer)
        droppedLogFramesTotal;  % loggng thread MEX dropped frames        
    end      
    
    
    %% PUBLIC PROPERTIES
    properties        
        loggingEnable=false; %Flag specifying whether to log during acquisitions

        frameAcquiredEventFcn; %Function handle
    end    

        
    
    properties (SetAccess=protected)        
        framesAcquired;
        running = false;        
    end      
    
    %Constructor-initialized
    properties (SetAccess=protected)
        hPMTModule; %PMT module which /must/ be loaded for successful scanner operation
        numChannels; %Number of input channels available for this scanner device
    end
    
    %% PRIVATE/PROTECTED PROPERTIES    
        
    properties (Hidden)
        verbose = false;        
        loggingOpenModeString='wbn';   % the mode string passed to fopen when opening the log file        
    end
    
    properties (SetAccess=protected, Hidden, Dependent)
        numChannelsActive; %Number of channels currently active        
        loggingFullFileName;  % the complete path and file name of the file to write to, including extension
    end      

    properties (SetAccess=protected,Hidden) 
        callMEXOnParamChange = false;
    end

    
    properties (SetAccess=protected,Hidden)
       paramChangeFlag=false; %Logical indicating if a property has been changed since last startAcquisition() 
       
       loggingStreamUpdateFlag=false;
       loggingEnableMEX=false; %Internal flag used to actively start/stop logging at MEX file level
    end
    
    properties (Constant, Hidden)        
        framePeriodOverhead = 6.06e-3; %Time, in ms, that is added to each frame period as overhead -- mostly due to the Y scanner flyback time       
    end

    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = LSM(varargin)            
                        
            %Invoke superclass constructor
            obj = obj@dabs.thorlabs.private.ThorDevice(varargin{:});

            %Construct/identify (required) associated PMT object
            obj.hPMTModule = dabs.thorlabs.PMT();
            
            %Determine number of channels
            channelsActiveInfo = obj.paramInfoMap('channelsActive');
            obj.numChannels = log(channelsActiveInfo.paramMax + 1)/log(2);                        
            
            %Invoke superclass initializer
            obj.initialize();
            
            %Initialize MEX interface
            obj.configureFrameAcquiredEvent('initialize');
            obj.configureFrameAcquiredEvent('configBuffers');
            
            %Initialize flags
            obj.callMEXOnParamChange = true;
            obj.paramChangeFlag = true;
        end
        
        function delete(obj)
               
                if(obj.running)
                    obj.stop();
                end
                                
                %obj.apiCall('TeardownCamera');                                
                obj.configureFrameAcquiredEvent('destroy'); %vvv: This destroys /all/ scanners -- we should make a call that deletes only this scanner
                
                delete(obj.hPMTModule); 
  
%                unloadlibrary('ThorConfocal');
            
        end
    end
    
    
    %% PROPERTY ACCESSS
    methods
        function val = get.numChannelsActive(obj)
            val = numel(obj.pdepGetDirect('channelsActive'));
        end
        
        %         function fName = get.loggingFullFileName(obj)
        %             fName = fullfile(obj.loggingFilePath, obj.loggingFileName);
        %             [~,~,ext] = fileparts(fName);
        %             if isempty(ext)
        %                 fName = [fName '.' obj.loggingFileType];
        %             end
        %         end
        
        function fName = get.loggingFullFileName(obj)
            [p,f,e] = fileparts(obj.loggingFileName);
            
            if isempty(p)
                p = pwd();
            end
            
            if isempty(e)
                e = '.tif';
            end
               
            fName = fullfile(p,[f e]);
        end
        
                
        %NOTE: Following are now PDEP properties, but these can be restored to test/compare execution time as pure dependent property, vs pdep property. 
        %      Tests found get-access time of fieldSize as 5.9ms with PDEP and 4.8ms with pure dependent (12/14/2010)
        %
        %         function val = get.fieldSize(obj)
        %             val = obj.apiCall('GetParam',obj.paramCodeMap('fieldSize'),0);
        %
        %         end
        %
        %         function set.fieldSize(obj,val)
        %
        %             obj.apiCall('SetParam',obj.paramCodeMap('fieldSize'),val);
        %
        %             if(obj.running && obj.callMEXOnParamChange)
        %                 obj.configureFrameAcquiredEvent('setup');
        %                 obj.configureFrameAcquiredEvent('start');
        %             end
        %         end
        %
        
        
        function set.channelsActive(obj,val)
            %            if(obj.running)
            %                error('LSM: cannot change channels while device is running');
            %            end
           obj.pdepSetAssert(val,isnumeric(val) && (isvector(val) || isempty(val)) && all(ismember(val,1:obj.numChannels)),'Invalid value entered for ''channelsActive''');
           obj.channelsActive = val;
        end
        
        %         function set.circBufferSize(obj,val)
        %             obj.circBufferSize = val;
        %             if(obj.callMEXOnParamChange)
        %                 obj.configureFrameAcquiredEvent('configBuffers');
        %             end
        %         end
        
        function set.loggingEnable(obj,val)
            obj.loggingEnable = logical(val);
            if(obj.running) 
                obj.loggingEnableMEX = obj.loggingEnable; 
            end
        end
        
        function set.loggingEnableMEX(obj,val)            
            
            obj.loggingEnableMEX = val;
            obj.configureFrameAcquiredEvent('configLogFile');            
        end
        
%         function set.loggingHeaderString(obj,val)
%             assert(most.idioms.isstring(val),'The value of loggingHeaderString must be a string');            
%             assert(~obj.running || obj.loggingStreamUpdateFlag, 'Value of loggingHeaderString must be set via updateLoggingStream() while logging is active');
%            
%             obj.loggingHeaderString = val;    
%         end
        
    
        function set.frameAcquiredEventFcn(obj,val)
            obj.frameAcquiredEventFcn = val;
            if(obj.callMEXOnParamChange)
                obj.configureFrameAcquiredEvent('configCallback');
            end
        end

    end
    
    %PDep Property Handling
    methods (Hidden, Access=protected)
        function pdepPropHandleGet(obj,src,evnt)
            propName = src.Name;
            
            switch propName
                
                %Properties with string-encoded values  
                case {'triggerMode' 'scanMode' 'averagingMode' 'areaMode'}
                    obj.pdepPropGroupedGet(@obj.getParameterEncoded,src,evnt);
                    
                case {'inputChannelRange1' 'inputChannelRange2'}
                    obj.pdepPropGroupedGet(@obj.getInputChannelRange,src,evnt);
                
                %Properties with a maximum-value encoded as Inf by this class
                case {'triggerTimeout'}
                    obj.pdepPropGroupedGet(@obj.getParameterMaxInf,src,evnt);
                    
                %Properties that are maintained in MEX function
                case {'framesAvailable' 'frameCount' 'droppedFramesTotal' 'droppedLogFramesTotal'}
                    obj.pdepPropGroupedGet(@obj.getMEXProperty, src, evnt);
                    
                %Properties to get directly
                case {'circBufferSize' 'loggingFileName' 'loggingHeaderString' 'loggingAveragingFactor'}
                    %Do nothing -- simple pass-through
                   
                case {'channelsActive' 'multiFrameCount'}
                    obj.pdepPropIndividualGet(src, evnt);
                                       
                otherwise
                    obj.pdepPropGroupedGet(@obj.getParameterSimple,src,evnt);
            end
        end
        
        function pdepPropHandleSet(obj,src,evnt)
            propName = src.Name;
                                    
            disallowWhileRunning = {'triggerMode' 'multiFrameCount' 'circBufferSize' 'loggingAveragingFactor'};
            needsConfigBuffers = {'pixelsPerDim' 'channelsActive' 'circBufferSize' 'loggingAveragingFactor'}; %These properties require that MEX-maintained buffers be reconfigured
            alwaysAllow  = {'loggingFileName' 'loggingHeaderString'};
            
            if obj.running && ~ismember(propName, alwaysAllow)
                if ismember(propName, disallowWhileRunning)
                    error('Cannot set ''%s'' while acquisition is running', propName);
                elseif ismember(propName, needsConfigBuffers) && obj.loggingEnableMEX
                    error('Cannot set ''%s'' while acquisition is running and logging to disk', propName);
                elseif ~strcmpi(obj.pdepGetDirect('triggerMode'),'SW_FREE_RUN_MODE') 
                    error('Cannot set ''%s'' when running in single-frame or multi-frame triggerMode', propName);
                end
            end

            switch propName
                case {'triggerMode' 'scanMode' 'averagingMode' 'inputChannelRange1' 'inputChannelRange2' 'areaMode'}
                    obj.pdepPropGroupedSet(@obj.setParameterEncoded,src,evnt);                    
                                      
                case {'channelsActive' 'multiFrameCount' }
                    obj.pdepPropIndividualSet(src,evnt);                          
                    
                case {'triggerTimeout'}
                    obj.pdepPropGroupedSet(@obj.setParameterMaxInf,src,evnt);
                    
                case {'frameCount' 'framesAvailable' 'droppedFramesTotal' 'droppedLogFramesTotal'}
                    obj.pdepPropSetDisallow(src,evnt);
                    return;
                    
                case {'circBufferSize' 'loggingAveragingFactor'}
                    %Do nothing -- pass-through
                    
                case { 'loggingHeaderString' 'loggingFileName' }
                    %Properties related to logging configuration -- NOT Thor API 'parameters'
                    obj.pdepPropGroupedSet(@obj.setLoggingProperty,src,evnt);
                    return;
                    
                otherwise
                    obj.pdepPropGroupedSet(@obj.setParameterSimple,src,evnt);
            end
            
            %Signal that a parameter has changed
            obj.paramChangeFlag = true;
            
            %Handle further MEX file operations on property change            
                            
            if obj.callMEXOnParamChange
                if ismember(propName, needsConfigBuffers)
                    if obj.running 
                        obj.configureFrameAcquiredEvent('stop'); %Must stop acquisition before 
                        obj.configureFrameAcquiredEvent('configBuffers');

                        obj.configureFrameAcquiredEvent('setup');
                        obj.configureFrameAcquiredEvent('start');                        
                    else
                        obj.configureFrameAcquiredEvent('configBuffers');
                    end
                else
                    if obj.running
                        obj.configureFrameAcquiredEvent('setup');
                        obj.configureFrameAcquiredEvent('start');                        
                    end
                end                                                   
            end                       

        end
    end
    
    methods (Hidden)
        
        function val = getMEXProperty(obj,propName)
               val = obj.configureFrameAcquiredEvent('get',propName);            
        end
        
        function val = getMultiFrameCount(obj)            
            val = obj.getParameterSimple('multiFrameCount');
            
            if val == obj.zprpGetMaxMultiFrameCount()
                val = inf;
            end
            
        end
                
        function val = getInputChannelRange(obj,propName)
            rawVal = obj.getParameterSimple(propName);
            
            %Convert raw (numeric) value to corresponding string
            enumValMapMap = obj.accessAPIDataVar('enumValMapMap');
            enumValMap = enumValMapMap('InputRange');
            
            val = enumValMap(rawVal);  %Converts to string corresponding to value                     
            
        end
        
        function val = getChannelsActive(obj)
            %Unpack the scalar into a vector
            scalarVal = obj.apiCall('GetParam', obj.paramCodeMap('channelsActive'),0);            
            val = find(fliplr(dec2bin(scalarVal,obj.numChannels))==49);
        end

        function setChannelsActive(obj,val)             
            %Pack vector value into a scalar
            obj.apiCall('SetParam', obj.paramCodeMap('channelsActive'), sum(val));                        
        end

        function setLoggingProperty(obj,propName,val)
            assert(most.idioms.isstring(val),'The value of ''%s'' must be a string',propName);            
            %assert(~obj.running || obj.loggingStreamUpdateFlag, 'Value of ''%s'' must be set via updateLoggingStream() while logging is active',propName);
            
             %Allow changes to occur directly while running, except if called from updateLoggingStream()
             % When not running or when called from updateLoggingStream() --> defer call to MEX file
            if obj.running && ~obj.loggingStreamUpdateFlag
                obj.configureFrameAcquiredEvent('configLogFile');
            end   
        end    
        
        function setMultiFrameCount(obj,val)
            propName = 'multiFrameCount';
            maxVal =  obj.zprpGetMaxMultiFrameCount();
            if val >= maxVal
                obj.setParameterSimple(propName,maxVal);
            else
                obj.setParameterSimple(propName,val);

            end            
        end
        
        
        %         function setLoggingProperty(obj,propName,~) %(obj,propName,val)
        %             %Re-configure the log file
        %             if obj.callMEXOnParamChange
        %                 assert(~obj.running || obj.loggingStreamUpdateFlag, 'Value of property ''%s'' must be set via updateLoggingStream() while logging is active', propName);
        %
        %                 if ~obj.loggingStreamUpdateFlag %If calling from updateLoggingStream(), defer call to MEX file
        %                     obj.configureFrameAcquiredEvent('configLogFile');
        %                 end
        %             end
        %         end
    
        
        function maxVal = zprpGetMaxMultiFrameCount(obj)
            
            %Following is logic indicated by Thorlabs developers
            backlineCount = 48; 
            
            switch obj.scanMode
                case 'TWO_WAY_SCAN'
                    numLines = backlineCount + obj.pixelsPerDim/2;
                otherwise 
                    numLines = backlineCount + obj.pixelsPerDim;
            end
            
            maxVal = floor(intmax('int32')/numLines);

        end            
        
    end
        
    
    %% PUBLIC METHODS
    
    methods
        
        function arm(obj)
            %Macro method used to arm an acquisition. 
            %Calls preflightAcquisition() & setAcquisition() API functions, prepares log file, resets acquisition flags, etc.
            
            if(obj.running)
                obj.stop();
            end

            if(obj.paramChangeFlag)
                err = obj.configureFrameAcquiredEvent('preflight');
                if(~err)
                    msg = uint16(ones(1, 64));
                    [status, msg] = obj.apiCallRaw('GetLastErrorMsg', msg, 64);
                    
                    error('Error occurred during call to PreflightAcquisition: %s', msg);
                end
                obj.paramChangeFlag = false;
            end
                                    
            obj.framesAcquired = 0;            

            obj.loggingEnableMEX = obj.loggingEnable;  % this calls to configLogFile -- property values of loggingHeaderString and loggingFileName are enforced
            
            obj.running = true;
            
            obj.configureFrameAcquiredEvent('newacq');                                 
            obj.configureFrameAcquiredEvent('setup');
            
        end
        
        %         function armLogging(obj)
        %             %Method to arm logging, which may be done before or after arming/starting an acquisition
        %             %Arming logging /after/ start of acquisition can allow headerString to be fully
        %
        %         end
        
        
        function data = getData(obj,numFrames)
%            disp('LSM.getdata: calling configureFrameAcquiredEvent');
            
            if nargin < 2 || isinf(numFrames)
                data = obj.configureFrameAcquiredEvent('getdata');
            else
                data = obj.configureFrameAcquiredEvent('getdata',numFrames);
            end
            
            if(~isempty(data))
                sz = size(data);                
                if(numel(sz) > 3)
                    fprintf(2,'Incrementing by more than 1! Size of data: %s\n',mat2str(sz));
                    obj.framesAcquired = obj.framesAcquired + sz(4);
                else
                    obj.framesAcquired = obj.framesAcquired + 1;
                end
            end
        end
        
        function start(obj)
            %Starts scanner and armed acquisition 
            
            obj.hPMTModule.scanEnable = 1; %Actually starts the scanner
            obj.configureFrameAcquiredEvent('start'); %Starts acquisition thread and LSM acquisition
        end
        

        function stop(obj)
            %Stop scanning/acquisition/logging immediately -- any queued frames not logged are lost.             
            obj.stopOrFinish('stop')
        end
        
        function finish(obj)
            %Stop scanning/acquisition immediately. Waits for any queued frames to be logged and then stops logging.
            obj.stopOrFinish('finish');            
        end
        
        function parkAtCenter(obj)
            
            assert(~obj.running,'Cannot park scanner while it is already running');
            
            obj.scanMode = 'SCAN_MODE_CENTER';
            obj.triggerMode = 'SW_FREE_RUN_MODE';
            obj.arm();

            %Start LSM, without starting scanner (PMT property)
            obj.configureFrameAcquiredEvent('start'); %Starts acquisition thread and LSM acquisition

        end
        
        function pause(obj)
            %Stop scanning/acquisition, but allow it to be subsequently resumed
            %Resumed acquisitions continue logging data to same file
            
            obj.configureFrameAcquiredEvent('pause');
            obj.hPMTModule.scanEnable = 0;            
        end
        
        function resume(obj)
            %Resumes scanning/acquisition that was previously paused
            %Resumed acquisitions continue logging data to same file
            
            obj.configureFrameAcquiredEvent('finishLogging');
            obj.start();
        end
        
        function tf = isAcquiring(obj)
           tf = obj.configureFrameAcquiredEvent('isAcquiring');            
        end
        
        function flushData(obj)
            obj.configureFrameAcquiredEvent('flush');
        end
                  
        function updateLoggingStream(obj,loggingFileName,loggingHeaderString,nextFileFrameCount)
            %Method allowing loggingFileName and, optionally, loggingHeaderString, to be updated during a running acquisition
            
            try
                obj.loggingStreamUpdateFlag = true;                                
                
                obj.loggingFileName = loggingFileName;
                if nargin >= 3                
                    obj.loggingHeaderString = loggingHeaderString;
                end                
                
                if nargin >= 4
                    obj.configureFrameAcquiredEvent('configLogFile',nextFileFrameCount);
                else
                    obj.configureFrameAcquiredEvent('configLogFile');
                end
                
                obj.loggingStreamUpdateFlag = false;
                
            catch ME
                obj.loggingStreamUpdateFlag = false;
                ME.rethrow();
            end
        end
        
        %
        %         function abortAcquisition(obj)
        %             %Macro method used to abort an ongoing acquisition
        %
        %
        %         end
      
        %         % used for single frame mode, this starts an acquisition without
        %         % resetting params, etc.  start() must have been called prior to
        %         % calling this function, or else it does not
        %         function nextFrame(obj)
        %             if(~obj.running)
        %                 error('LSM: call start() before calling nextFrame()');
        %             end
        %
        %             obj.configureFrameAcquiredEvent('start');
        %         end
        
        %         function start(obj)
        %             if(obj.running)
        %                 obj.stop();
        %             end
        %
        %             % force sync of input channel ranges
        %             obj.apiCall('SetParam',obj.paramCodeMap('inputChannelRange1'),obj.inputChannelRange1);
        %             obj.apiCall('SetParam',obj.paramCodeMap('inputChannelRange2'), obj.inputChannelRange2);
        %
        %             if(obj.paramChangeFlag)
        %                 err = obj.configureFrameAcquiredEvent('preflight');
        %                 disp(['LSM.start() preflight returned ' num2str(err)]);
        %                 if(~err)
        %                     msg = char(ones(1, 64));
        %                     [status, msg] = obj.apiCallRaw('GetLastErrorMsg', msg, 64);
        %                     disp(['Error msg=' msg]);
        %                     return
        %                 end
        %                 obj.paramChangeFlag = false;
        %             end
        %
        %             obj.framesAcquired = 0;
        %             obj.droppedFrames = 0;
        %             obj.hPMTModule.scanEnable = 1;
        %             obj.loggingEnableMEX = obj.loggingEnable;  % ensure call to configLogFile
        %
        %             obj.running = true;
        %
        %             obj.configureFrameAcquiredEvent('newacq');
        %
        %             obj.configureFrameAcquiredEvent('setup');
        %             obj.configureFrameAcquiredEvent('start');
        %         end
        %
        %
        
    end
    
    %% PRIVATE/PROTECTED METHODS
    
    
    methods (Hidden)
          
        function preflightAcquisition(obj)
            %Direct method to arm acquisition with current settings and resets DAQ board
            %obj.configureFrameAcquiredEvent('configBuffers');
            obj.configureFrameAcquiredEvent('preflight');
        end
        
        function setupAcquisition(obj)
            %Direct method to arm acquisition with current settings without resetting DAQ board
            %Unlike preflightAcquisition(), setupAcquisition() can be called in midst of ongoing acquisition
            
            obj.configureFrameAcquiredEvent('setup');
        end
        
        function startAcquisition(obj)
            %Starts pre-configured acquisition
            
            obj.configureFrameAcquiredEvent('startDirect');
        end
        
        function postflightAcquisition(obj)
            %Stops ongoing acquisition, releasing resources
            obj.configureFrameAcquiredEvent('postflight');
        end
        
        function status = statusAcquisition(obj)
            %Returns the status of the acquisition
            
            status = obj.apiCall('StatusAcquisition', 0);
            %TODO: Decode status
        end
        
        function [status, lastCompletedFrameIndex] = statusAcquisitionEx(obj)
            %Returns status of acquisition and frame count maintained by scanner driver
            %   lastCompletedFrameIndex: Index of the last known frame to be available for collection
            
            [status, lastCompletedFrameIndex] = obj.apiCall('StatusAcquisitionEx', 0, 0);
            %TODO: Decode status
        end                             
        
    end
    
    methods (Access=protected)
        
        function stopOrFinish(obj,cmdString)
            %   cmdString: One of {'stop' 'finish'}
            
            obj.hPMTModule.scanEnable = 0;
            obj.configureFrameAcquiredEvent(cmdString);
            
            if obj.running
                obj.configureFrameAcquiredEvent('postflight');
                
                obj.running = false;
                obj.loggingEnableMEX = false; % this will close the file, but not affect the loggingEnable at the next start
            end
        end
    end
    
    
    
end

%% HELPERS


function prop2ParamMap = zlclInitProp2ParamMap()

prop2ParamMap = containers.Map('KeyType','char','ValueType','char');

prop2ParamMap('triggerMode') = 'PARAM_TRIGGER_MODE';
prop2ParamMap('multiFrameCount') = 'PARAM_MULTI_FRAME_COUNT';
prop2ParamMap('cameraType') = 'PARAM_CAMERA_TYPE';
prop2ParamMap('pixelsPerDim') = 'PARAM_LSM_PIXEL_X';
prop2ParamMap('fieldSize') = 'PARAM_LSM_FIELD_SIZE';
prop2ParamMap('channelsActive') = 'PARAM_LSM_CHANNEL';
prop2ParamMap('bidiPhaseAlignment') = 'PARAM_LSM_ALIGNMENT';
prop2ParamMap('inputChannelRange1') = 'PARAM_LSM_INPUTRANGE1';
prop2ParamMap('inputChannelRange2') = 'PARAM_LSM_INPUTRANGE2';
prop2ParamMap('inputChannelRange3') = 'PARAM_LSM_INPUTRANGE3';
prop2ParamMap('inputChannelRange4') = 'PARAM_LSM_INPUTRANGE4';
prop2ParamMap('scanMode') = 'PARAM_LSM_SCANMODE';
prop2ParamMap('averagingMode') = 'PARAM_LSM_AVERAGEMODE';
prop2ParamMap('averagingNumFrames') = 'PARAM_LSM_AVERAGENUM';
prop2ParamMap('clockSource') = 'PARAM_LSM_CLOCKSOURCE';
prop2ParamMap('clockRate') = 'PARAM_LSM_EXTERNALCLOCKRATE';
prop2ParamMap('triggerTimeout') = 'PARAM_TRIGGER_TIMEOUT_SEC';
prop2ParamMap('triggerFrameClockWithExtTrigger') = 'PARAM_ENABLE_FRAME_TRIGGER_WITH_HW_TRIG';
prop2ParamMap('areaMode') = 'PARAM_LSM_AREAMODE';
prop2ParamMap('offsetY') = 'PARAM_LSM_OFFSET_Y';
prop2ParamMap('aspectRatioY') = 'PARAM_LSM_Y_AMPLITUDE_SCALER';
prop2ParamMap('flybackTimeLines') = 'PARAM_LSM_FLYBACK_CYCLE';

end

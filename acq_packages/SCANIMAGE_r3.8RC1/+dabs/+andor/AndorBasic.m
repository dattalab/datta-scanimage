classdef AndorBasic < handle
    %ANDORBASIC Class encapsulating basic functionality of a camera device from Andor Technology
       
    properties (SetAccess=private)
        cameraIndex=[]; %Integer value, specified by user on construction, identifying camera
        cameraHandle; %Map of integer values, provided by driver, identifying camera
        availXPixels; %Number of horizontal pixels available to camera
        availYPixels; %Number of vertical pixels available to camera
        currXPixels; %Number of horizontal pixels with currently configured Readout mode
        currYPixels; %Number of vertical pixels with currently configured Readout mode        
        exposureTime; %Actual exposure time value, in seconds.
        targetTemperature; %Cool camera to this Centigrade (Andor SetTemperature) 
        %Read-only parameters reflecting Camera properties
        serialNumber; %Readout of camera's serial number
        hasInternalShutter; %Logical value indicating, if true, that camera has an internal shutter
        readoutTime; %Time, in seconds, that camera requires to readout data with currently configured acquisition settings
        keepCleanTime; %Time, in seconds
        EMGainRange; %Permissible gain range of camera, get from camera
        currentEMCCDGain; %read from ccd what the EMGain is currently set to
        currentTemperature; %returned from GetTemperature
        temperatureRange; %allowed target temperature range (returned from GetTemperatureRange)
        temperatureStatus; %[sensorTemp targetTemp ambientTemp coolerVolts] (Andor GetTemperatureStatus)
        cameraStatus % camera ready for new acquisition (or not) (returned from GetStatus)
        NumberVerticalSpeeds; %TODO 
        
    end
    
    properties
        acquisitionMode='single scan'; %One of {'single scan', 'accumulate', 'kinetics', 'fast kinetics', 'run till abort'}. Acquisition mode to be used on the next StartAcquisition.
        triggerMode='internal'; %One of {'internal', 'external', 'external start', 'external exposure', 'external fvb em', 'software'}. Trigger mode that the camera will operate in.
        readMode='image'; %One of {'full vertical binning', 'multi-track', 'random-track', 'single-track', 'image'}. Reflects the readout mode to be used on the subsequent acquisitions.
        fastExtTrigger=false; %Logical value indicating whether fast trigger mode is enabled. When fast external triggering is enabled, the system will NOT wait until a “Keep Clean” cycle has been completed before accepting the next trigger. This setting will only have an effect if the trigger mode has been set to External;
        exposureTimeCommand=.01; %Exposure time, in seconds, to use on next acquisition. Actual exposureTime will not be less than this value. The exposureTime, accumulateCycleTime, and kineticCycleTime properties report the actual values, once all the acquisition properties have been set (e.g. readMode, exposureTimeCommand, kineticCycleCommand).        
        targetTemperatureCommand; %desired ccd temperature in Centigrades
        EMCCDGainCommand; %Current gain settingof camera 
        
    end
   
    %     properties (SetAccess=private,Dependent)
    %         acquisitionTimings;
    %     end
        
    properties (SetAccess=private, Hidden)
        totalNumPixels; %Total number of pixels
    end
    
    properties (Access=private,Hidden, Constant)
        driverPrettyName = 'Andor Technology SDK';
        driverHeaderFile = 'ATMCD32D.H';
        driverLib = 'ATMCD32D';
        driverPath = 'c:\program files\Andor Solis\Drivers';
        driverDataFileName = 'DriverData.mat';
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = AndorBasic(cameraIndex, varargin)
            
            import Devices.Andor.*
            
            %Handle array case
            if nargin == 0
                return;
            elseif length(cameraIndex) > 1
                %obj(length(cameraIndex)) = AndorBasic();
                
                for i=length(cameraIndex):-1:1
                    obj(i) = AndorBasic(cameraIndex(i),varargin{:});
                end
                return;
            end
            
            
            %Load the Andor  DLL, if needed
            if ~libisloaded(obj.driverLib)
                disp([obj.driverPrettyName ': Initializing...']);
                warning('off','MATLAB:loadlibrary:parsewarnings');
                loadlibrary(fullfile(obj.driverPath, [obj.driverLib '.dll']),fullfile(obj.driverPath,obj.driverHeaderFile));
                warning('on','MATLAB:loadlibrary:parsewarnings');
            end
            
            %Initialize the Andor SDK
            %TODO: Test if this is really needed
            %calllib(obj.driverLib, 'Initialize', obj.driverPath); %This can be called repeatedly, without any problem
            
            %Determine # of cameras
            [status, numCameras] = calllib(obj.driverLib,'GetAvailableCameras',0);
            obj.validateCall(status,'GetAvailableCameras');               
            
            %Handle input arguments
            if ~nargin && numCameras > 1
                error(['An index must be specified when there is more than one camera (' num2str(obj.numCameras) ' cameras detected).']);
            elseif nargin
                obj.cameraIndex = cameraIndex;            
            else
                obj.cameraIndex = 0; 
            end
            
            %Obtain handle to camera
            [status, obj.cameraHandle] = calllib(obj.driverLib,'GetCameraHandle', obj.cameraIndex, 0);
            obj.validateCall(status,'GetCameraHandle');
            
            %Set newly constructed camera as current one
            obj.makeCurrent();
            
            %Initialize the Andor SDK
            calllib(obj.driverLib, 'Initialize', obj.driverPath); %This can be called repeatedly, without any problem

            
            %Store some of the newly constructed camera's properties
            [status,xpixels,ypixels] = calllib(obj.driverLib,'GetDetector',0,0);
            obj.validateCall(status,'GetDetector');
            [obj.availXPixels, obj.availYPixels] = deal(xpixels,ypixels);
            obj.totalNumPixels = obj.availXPixels * obj.availYPixels;
            
            %Put camera into default modes
            propsToInitialize = {'acquisitionMode' 'triggerMode' 'readMode' 'fastExtTrigger' 'exposureTimeCommand'};
            for i=1:length(propsToInitialize)
                obj.(propsToInitialize{i})= obj.(propsToInitialize{i});
            end
            obj.setImage(1,1,1,obj.availXPixels,1,obj.availYPixels); %Initializes the camera to use no binning and the entire sensor
            
            %Set optional property/value pairs, as specified
            if mod(length(varargin),2)
                error('Optional arguments must be specified as property/value pairs');
            else
                propNames = varargin(1:2:end);
                propVals = varargin(2:2:end);
                for i=1:length(varargin)/2
                    obj.(propNames{i}) = propVals{i};
                end
            end
                
        end
        
        function delete(obj) 
            
            if length(obj) > 1
                for i=1:length(obj)
                    delete(obj(i));
                end
                return;
            end
            
            if ~isempty(obj.cameraIndex) && isvalid(obj)                
                obj.makeCurrent();
                status = calllib(obj.driverLib, 'CoolerOFF');
                [status,currentTemperature] = calllib(obj.driverLib,'GetTemperature',0);
                while currentTemperature < 0
                    pause(1)
                    [status,currentTemperature] = calllib(obj.driverLib,'GetTemperature',0);
                end
                %Shut down system
                obj.shutDown();
            end
        end
        
        function abortAcquisition(obj)
            obj.makeCurrent();
            status = calllib(obj.driverLib,'AbortAcquisition');
            disp(status)
            obj.validateCall(status,'AbortAcquisition');            
        end
            
    end
    
    %% PROPERTY ACCESS
    methods 
        function set.cameraIndex(obj,val)
           if ~isnumeric(val) || ~isscalar(val)
               error('''cameraIndex'' must be a scalar integer value identifying single camera index');
           end  
           obj.cameraIndex = val;
        end
        
        function set.acquisitionMode(obj,val)            
            try 
                switch lower(val)
                    case 'single scan'
                        modeNum = 1;
                    case 'accumulate'
                        modeNum = 2;
                    case 'kinetics'
                        modeNum = 3;
                    case 'fast kinetics'
                        modeNum = 4;
                    case 'run till abort'
                        modeNum = 5;
                    otherwise
                        error('Specified mode not recognized.');
                end
                
                obj.makeCurrent();
                
                status = calllib(obj.driverLib,'SetAcquisitionMode',modeNum);
                obj.validateCall(status,'SetAcquisitionMode');
                
                obj.acquisitionMode = lower(val);
            catch ME
                obj.acquisitionMode = 'Unknown';
                ME.rethrow();                
            end
        end
        
        function set.triggerMode(obj,val)
            
            try
                switch lower(val)
                    case 'internal'
                        modeNum = 0;
                    case 'external'
                        modeNum = 1;
                    case 'external start'
                        modeNum = 6;
                    case 'external exposure'
                        modeNum = 7;
                    case 'external fvb em'
                        modeNum = 9;
                    case 'software'
                        modeNum = 10;
                    otherwise
                        error('Specified mode not recognized.');
                end
                
                obj.makeCurrent();
                
                status = calllib(obj.driverLib,'SetTriggerMode',modeNum);
                obj.validateCall(status,'SetTriggerMode');
                
                obj.triggerMode = lower(val);
            catch ME
                obj.triggerMode = 'Unknown';
                ME.rethrow();
            end
        end
        
        function set.readMode(obj,val)
            
            try
                switch lower(val)
                    case 'full vertical binning'
                        modeNum = 0;
                    case 'multi-track'
                        modeNum = 1;
                    case 'random-track'
                        modeNum = 2;
                    case 'single-track'
                        modeNum = 3;
                    case 'image'
                        modeNum = 4;
                    otherwise
                        error('Specified mode not recognized.');
                end
                
                obj.makeCurrent();
                
                status = calllib(obj.driverLib,'SetReadMode',modeNum);
                obj.validateCall(status,'SetReadMode');
                
                obj.readMode = lower(val);
            catch ME
                obj.readMode = 'Unknown';
                ME.rethrow();
            end
        end
        
        function set.fastExtTrigger(obj,val)
            
            try                
                obj.makeCurrent();
                
                status = calllib(obj.driverLib,'SetFastExtTrigger',val);
                obj.validateCall(status,'SetFastExtTrigger');
                
                obj.fastExtTrigger = val;
            catch ME
                obj.fastExtTrigger = [];
                ME.rethrow();                
            end
        end
        
        function set.exposureTimeCommand(obj,val)
            try
                obj.makeCurrent();
                
                status = calllib(obj.driverLib,'SetExposureTime',val);
                obj.validateCall(status,'SetExposureTime');
                
                obj.exposureTimeCommand = val;
            catch ME
                obj.exposureTimeCommand = [];
                ME.rethrow();
            end
        end
        
        function val = get.exposureTime(obj)
            obj.makeCurrent();
            [status,exposureTime,accumulate,kinetic] = calllib(obj.driverLib,'GetAcquisitionTimings',0,0,0); %#ok<NASGU,PROP>
            obj.validateCall(status,'GetAcquisitionTimings');
            val = exposureTime;            %#ok<PROP>
        end

        function val = get.temperatureRange(obj)
            obj.makeCurrent();
            [status, minTemp, maxTemp] = calllib(obj.driverLib,'GetTemperatureRange',0,0);
            obj.validateCall(status,'GetTemperatureRange');
            val = [minTemp maxTemp];
        end
        
        function coolerON(obj)
            obj.makeCurrent();
            status = calllib(obj.driverLib, 'CoolerON');
            obj.validateCall(status,'CoolerON');
        end

        function coolerOFF(obj)
            obj.makeCurrent();
            status = calllib(obj.driverLib, 'CoolerOFF');
            obj.validateCall(status,'CoolerOFF');
        end
        
        function set.targetTemperatureCommand(obj,val)
            try %TODO is this try catch statement ok? (copied from exposuretime)
                obj.makeCurrent();
                status = calllib(obj.driverLib,'SetTemperature',val); 
                obj.validateCall(status,'SetTemperature');
                obj.targetTemperature = val; 
            catch ME 
                obj.targetTemperatureCommand = [];
                ME.rethrow();
            end
        end

        function val = get.currentTemperature(obj)
            obj.makeCurrent();
            [status,currentTemperature] = calllib(obj.driverLib,'GetTemperature',0);
            val = [currentTemperature status];
        end

       function val = get.EMGainRange(obj) 
           obj.makeCurrent();
           [status, minEMGain, maxEMGain] = calllib(obj.driverLib, 'GetEMGainRange',0,0);
           obj.validateCall(status,'GetEMCCDGain');
           val = [minEMGain maxEMGain]; %TODO use these to get range for user to chose from
       end
       
       function set.EMCCDGainCommand(obj,val) %Error check? (if out of range throws error 20066)
               obj.makeCurrent();
               status = calllib(obj.driverLib,'SetEMCCDGain',val);
               obj.validateCall(status,'SetEMCCDGain');
               %obj.EMCCDGain = val;
       end
       
        function val = get.currentEMCCDGain(obj)
            obj.makeCurrent();
            [status, gain] = calllib(obj.driverLib, 'GetEMCCDGain',0);
            obj.validateCall(status,'GetEMCCDGain');
            val = gain;
        end
        
        function val = get.temperatureStatus(obj)
            %This is a RESERVED method, does that matter? should I not use it?
            obj.makeCurrent();
            [status, sensorTemp, targetTemp, ambientTemp, coolerVolts] = calllib(obj.driverLib,'GetTemperatureStatus',0,0,0,0);
            obj.validateCall(status,'GetTemperatureStatus');
            %disp(status) %renders 20002 = drv success
            val = [sensorTemp targetTemp ambientTemp coolerVolts];
        end
        
        function val = get.cameraStatus(obj)
            obj.makeCurrent()
            [status, cameraStatus] = calllib(obj.driverLib,'GetStatus',0);
            obj.validateCall(status,'GetStatus');
            val = cameraStatus;
        end
            
        function val = get.hasInternalShutter(obj)
           obj.makeCurrent();
           [status, hasShutter] = calllib(obj.driverLib, 'IsInternalMechanicalShutter',0);
           obj.validateCall(status,'IsInternalMechanicalShutter');
           
           val = hasShutter;            
        end
        
        function val = get.readoutTime(obj)
            obj.makeCurrent();
            
            [status, readoutTime] = calllib(obj.driverLib, 'GetReadOutTime',0);
            obj.validateCall(status,'GetReadOutTime');
            
            val = readoutTime;            
        end
        
        function val = get.keepCleanTime(obj)
            obj.makeCurrent();
            
            [status, keepCleanTime] = calllib(obj.driverLib, 'GetKeepCleanTime',0);
            obj.validateCall(status,'GetKeepCleanTime');
            
            val = keepCleanTime;
        end
        
        
        function val = get.serialNumber(obj)
            obj.makeCurrent();
            
            [status, serialNumber] = calllib(obj.driverLib, 'GetCameraSerialNumber',0);
            obj.validateCall(status,'GetCameraSerialNumber');
            
            val = serialNumber;
        end
        
        %         function val = get.cameraHandle(obj)
        %            persistent cameraHandleStore
        %
        %            if isempty(cameraHandleStore)
        %
        %            end
        %         end
    end
    
    %% PUBLIC METHODS
    methods
        
        function startAcquisition(obj)
            %This function starts an acquisition. The status of the acquisition can be monitored via GetStatus().
            % function startAcquisition(obj)
            
            obj.makeCurrent();
            
            status = calllib(obj.driverLib,'StartAcquisition');
            obj.validateCall(status,'StartAcquisition');            
        end
        
        function setImage(obj,hbin, vbin, hstart, hend, vstart, vend)
           %This function will set the horizontal and vertical binning to be used when taking a full resolution image. 
           % function setImage(obj,hbin, vbin, hstart, hend, vstart, vend)
           %            hbin: number of pixels to bin horizontally.
           %            vbin: number of pixels to bin vertically.
           %            hstart: Start column (inclusive).
           %            hend: End column (inclusive).
           %            vstart: Start row (inclusive).
           %            vend: End row (inclusive).
           
           obj.makeCurrent();
           
           status = calllib(obj.driverLib,'SetImage',hbin, vbin, hstart, hend, vstart, vend);
           obj.validateCall(status,'SetImage');
           
           obj.currXPixels = hend - hstart + 1;
           obj.currYPixels = vend - vstart + 1;
        end
        
        function acqData = getAcquiredData(obj, numPixels)
            % This function will return the data from the last acquisition. The data are returned as long integers (32-bit signed integers).
            % function getAcquiredData(obj, numPixels)
            %   numPixels: (OPTIONAL) Number of pixels to extract from acquisition buffer. If empty/omitted, the total number of pixels for currently configured readout mode will be used.
            
            obj.makeCurrent();
            
            if nargin < 2
                numPixels = obj.currXPixels * obj.currYPixels;
            end
            
            %Allocate memory for output data
            acqData = zeros(obj.currXPixels*obj.currYPixels,1,'int32');

            %Call through
            [status, acqData] = calllib(obj.driverLib,'GetAcquiredData',acqData,numPixels);
            obj.validateCall(status,'GetAcquiredData');

        end
        
        function acqData = getAcquiredData16(obj, numPixels)
            % 16-bit version of the getAcquiredData function.
            % function getAcquiredData(obj, numPixels)
            %   numPixels: (OPTIONAL) Number of pixels to extract from acquisition buffer. If empty/omitted, the total number of pixels for currently configured readout mode will be used.
            
            obj.makeCurrent();
                        
            if nargin < 2
                numPixels = obj.currXPixels * obj.currYPixels;
            end
            
            %Allocate memory for output data
            acqData = zeros(obj.currXPixels*obj.currYPixels,1,'int16');
            
            %Call through
            [status,acqData] = calllib(obj.driverLib,'GetAcquiredData16',acqData,numPixels);
            obj.validateCall(status,'GetAcquiredData16');
        end
        
        function timedOut = waitForAcquisitionTimeOut(obj, timeout)
            %WaitForAcquisitionTimeOut() can be called after an acquisition is started using
            %startAcquisition() to put the Matlab thread to sleep until an Acquisition Event occurs.
            %Acquisition Events include 
                %1) acquistion completed/aborted, 
                %2) scan during acquistion complete, and 
                %3) temperature has stabilized or drifted
            %function waitForAcquisitionTimeOut(timeout)
            % timeout: Time, in milliseconds, to wait before awaking the Matlab thread
            % timedOut: Logical indicating, if true, that timeout was reach before an event occurred.

            try
                status = calllib(obj.driverLib,'WaitForAcquisitionTimeOut',timeout);
                obj.validateCall(status,'WaitForAcquisitionTimeout');
                timedOut = false;                
            catch 
                timedOut = true;
            end
                
        end
        
        function openInternalShutter(obj)
           status = calllib(obj.driverLib, 'SetShutterEx', 1, 1,  0, 0, 0);
           obj.validateCall(status,'SetShutterEx');
        end
        
        function closeInternalShutter(obj)
           status = calllib(obj.driverLib, 'SetShutterEx', 1, 0,  0, 0, 0);
           obj.validateCall(status,'SetShutterEx');
        end
            
    end
    

    %% PRIVATE METHODS    
    methods (Access=private)
        
        function shutDown(obj)
            %This function will close the AndorMCD system down.
            obj.makeCurrent();
            status = calllib(obj.driverLib,'ShutDown');
            obj.validateCall(status,'ShutDown');
        end
           
        function validateCall(obj,status,funcName)
            if status ~= 20002
                ME = MException('Andor:FailedCall',['Andor error (' num2str(status) ') in call to ' funcName]);
                ME.throwAsCaller();
            end
        end
        
        function makeCurrent(obj)
            %             [status, cameraHandle] = calllib(obj.driverLib,'GetCameraHandle', obj.cameraIndex, 0);
            %             obj.validateCall(status,'GetCameraHandle');
            %
            status = calllib(obj.driverLib,'SetCurrentCamera', obj.cameraHandle);
            obj.validateCall(status,'SetCurrentCamera');            
        end
        
        
    end
    
%     methods (Static, Access=private)
%         
%         function get
%         
%         
%     end
    

    
end


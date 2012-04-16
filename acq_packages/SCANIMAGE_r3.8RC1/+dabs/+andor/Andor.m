classdef AndorCamera < dynamicprops
    %ANDORCAMERA Class encapsulating functionality of a single camera device under the Andor SDK
    
    properties
        
        
                
    end
    
        
    properties (Access=private,Hidden, Constant)
        driverPrettyName = 'Andor Technology SDK';
        driverHeaderFile = 'ATMCD32D.H';
        driverLib = 'ATMCD32D';
        driverPath = 'c:\program files\Andor iXon\Drivers';
        driverDataFileName = 'DriverData.mat';
    end
    
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = AndorBasic(cameraIndex)
            
            import Devices.Andor.*            
            
            %Load the Andor  DLL, if needed
            if ~libisloaded(obj.driverLib)
                disp([obj.driverPrettyName ': Initializing...']);
                warning('off','MATLAB:loadlibrary:parsewarnings');
                loadlibrary(fullfile(obj.driverPath, [obj.driverLib '.dll']),fullfile(obj.driverPath,obj.driverHeaderFile));
                warning('on','MATLAB:loadlibrary:parsewarnings');
            end
            
            %Initialize the Andor SDK
            %TODO: Test if this is really needed
            calllib(obj.driverLib, 'Initialize', obj.driverPath); %This can be called repeatedly, without any problem
            
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
       

            
            
            
        end
    end
    
    %% PROPERTY ACCESS
    
    
    %% PUBLIC METHODS
    
    %% PRIVATE/PROTECTED METHODS
    
    methods (Access=private,Static)
        
        function varargout = invokeDriver(funcName,varargin)                      
            [status, numCameras] = calllib(Devices.Andor.AndorCamera.driverLib,'GetAvailableCameras',0);
            Devices.Andor.AndorCamera.validateCall(status,'GetAvailableCameras');                 
        end
        
        function validateStatus(status,funcName)
            if status ~= 20002
                ME = MException('Andor:FailedCall',['Andor error (' num2str(status) ') in call to ' funcName]);
                ME.throwAsCaller();
            end
        end                        
    end
    
    
    
end


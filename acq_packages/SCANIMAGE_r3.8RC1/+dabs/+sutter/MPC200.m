classdef MPC200 < dabs.interfaces.LinearStageControllerBasic
    %MPC200 Class encapsulating MPC-200 device from Sutter Instruments
        
    %TODO(5AM): Consider implementing velocity in unit-ed fashion, ideally leaving possibility of being stage-type dependent       
    
    %% ABSTRACT PROPERTY REALIZATIONS (Devices.Interfaces.LinearStageControllerBasic) 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Following are copied/pasted from superclass definition, but with subclass-specific values set/initialized
    %TMW: This is reasonable, as the subclass does need to define/add information here. However, would be nice if documentation string from superclass could be reused, if appropriate (most common case!).
    properties (SetAccess=protected, Hidden)
        devicePositionUnits; %Units, in meters, in which the device's position values (as reported by its hardware interface) are given
        deviceVelocityUnits=nan; %Units, in meters/sec, in which the device's velocity values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        deviceAccelerationUnits=nan; %Units, in meters/sec^2, in which the device's acceleration values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        
        deviceErrorResp='';
        deviceSimpleResp='';
        
        stageTypeMap = getStageTypeMap();
        resolutionModeMap = getResolutionModeMap();
    end
    
    properties (Constant, Hidden)  %TMW: Combination of 'Abstract' and 'Constant' in superclass works (as it well should), but documentation would suggest otherwise.
        hardwareInterface='serial'; %One of {'serial'}. Indicates type of hardware interface used to control device. NOTE: Other hardware interface types may be supported in the future.        
        safeReset=false;
        
        maxNumStageAssemblies=4; %Maximum nuber of stage assemblies supported by device
        requiredCustomStageProperties={'resolution'}; %Cell array of properties that must be set on construction if one or more of the stages is 'custom'
        
        moveCompletedDetectionStrategy = 'hardwareInterfaceEvent'; %Use serial asyncReply event on terminator
        moveCompleteHookFcn = 'moveCompleteHook'; %Can wait for terminator
       
        %stageLimits = [25000 25000 25000];        
    end
    
    %Some subclasses may make these properties Hidden as well, in particular if there is only one mode supported
    properties (Constant)
        moveModes={'straightLine' 'accelerated'}; %Cell array of possible moveModes for particular subclass device type
        %moveTerminator='255(\s+){3}(\d+\s+){9}13'; %a regex terminator (since it's a binary transfer, we can't use the simple terminator).  translation:
                                                   %find 255 followed by whitespace (x3), then find a digit followed by whitespace (x9), followed by 13.
    end
    
    properties
        zeroHardWarning=true; %Logical flag indicating, if true, that warning should be given prior to executing zeroHard() operations
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %% OTHER CLASS-SPECIFIC PROPERTIES
    properties (Hidden) 
        %Properties determined by stage type, upon processing the 'stageTypeMap' 
        %TMW: Would prefer these were protected/private, but this is not possible as they are set by superclass logic        
        initialVelocity;      
        maxVelocityStore;       
        
        isMoveInterrupted=false; %Logical indicating, if true, that a move has been interrupted.
    end
    
    properties (Hidden, Constant)
        defaultMoveMode = 'accelerated';           
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = MPC200(varargin)     
            % Prop-Value pair args
           %    comPort: (REQUIRED) Number specifiying COM port to which linear stage controller is connected
           %    stageType: One of {'mp-285'}. Specifies type of stage assembly connected to stage controller.
           %    resolution: Resolution, in um, for all dimensions (specified as scalar) or per-dimension (specified as 3 element vector).If not, default resolution associated with specified 'stageType' is used. 
           
            %Determine stage type from input argument, if supplied. However, do not require, since MP-285 controller uses same name for its default and only officially supported linear stage, so no need to make user specify.
            pvargs = most.util.filterPVArgs(varargin,{'stageType'});
            if isempty(pvargs) || isempty(pvargs{2})
                stageType = 'mp285'; %Same name used for stage and controller
            else
                stageType = pvargs{2};
            end
                        
            %Call superclass constructors %TMW: This is required, because
            %arguments must be passed. Would be nice to avoid, or at least avoid fully specifying class names (as it is done above)
            obj = obj@dabs.interfaces.LinearStageControllerBasic(stageType,'availableBaudRates',[128000],'terminatorDefault','CR',varargin{:});   
            
            %Process resolution argument, if supplied. Not required.
            pvargs = obj.filterPropValArgs(varargin,{'resolution'});
            if ~isempty(pvargs) %TMW: Annoying this can't be done via abstract superclass or separate function for private/protected properties
                obj.set(pvargs(1:2:end),pvargs(2:2:end));
            end
            
            %Initialize serial port properties
            obj.hHardwareInterface.skipSendTerminatorDefault = true; %Terminator not required on send commands
            
            %Subclass-specific initialization           
            obj.devicePositionUnits =  obj.resolution * obj.positionUnits; %MPC-200 reports coordinates in microsteps -- i.e. the unit of finest resolution
            obj.velocity = obj.initialVelocity;
            
            %Method invoked to (re)initialize property values, applying values to hardware interface
            obj.initializeDefaultValues(); 
        end
    end
    
    
    %% PROPERTY ACCESS METHODS
    
    %%%Pseudo property-access for pseudo-dependent properties
    methods (Access=protected)
        function pdepPropHandleGetHook(obj,src,evnt)
            propName = src.Name;
            
            switch propName
                case {'positionAbsoluteRaw' 'isMoving' 'maxVelocity' 'stageAssemblyIndex' 'infoHardware'}
                    obj.pdepPropIndividualGet(src,evnt);
                case {'velocity' 'moveMode' 'resolutionMode'}
                    %Do nothing --> pass-through (shoudl there be a method for this?)
                    %                 case {'limitReached' 'velocityStart' 'acceleration'}
                    %                     obj.pdepPropGroupedGet(@obj.getNonProperty,src,evnt);
                otherwise %Defer to superclass for default handling
                    obj.pdepPropGetUnavailable(src,evnt);
            end
                
        end       
        
        function pdepPropHandleSetHook(obj,src,evnt)
            propName = src.Name;
            
            switch propName
                case {'stageAssemblyIndex' 'velocity'} 
                    obj.pdepPropIndividualSet(src,evnt);
                case {'moveMode' 'resolutionMode'}
                    %Do nothing --> pass-through
                otherwise
                    obj.pdepPropSetDisallow(src,evnt);
            end            
        end
        
    end
    
    methods (Hidden) 
        
        function val = getPositionAbsoluteRaw(obj)
            %Retrive data byte-wise, strip first byte, then convert to uint32 class      
            temp = obj.hHardwareInterface.sendCommandBinaryReply('C','uint8'); 
            posn = obj.hHardwareInterface.convertToReplyClass(temp(2:end),'uint32');           
            
            val = obj.device2ClassUnits(posn,'position'); %Converts to units of class instance
        end

        
        function val = getMaxVelocity(obj)
            val = obj.maxVelocityStore;
        end
                
        function setVelocity(obj,val)
            if ~isscalar(val)
                error('It is not possible to set axis-specific velocities for device of class %s',class(obj));
            end
            
            if  val > obj.maxVelocity
                error('Velocity value provided exceeds maximum permitted value (%d)',obj.maxVelocity);
            end
            
            obj.velocity = val;
        end
        
        function tf = getIsMoving(obj)
            tf = obj.hHardwareInterface.isAwaitingReply();           
        end       
        
        function val = getStageAssemblyIndex(obj)
            resp = obj.hHardwareInterface.sendCommandBinaryReply('K', 'int8');
            val = resp(1);
        end
        
        function val = getInfoHardware(obj)
            u = obj.hHardwareInterface.sendCommandBinaryReply('U','int8');
            k = obj.hHardwareInterface.sendCommandBinaryReply('K', 'int8');
            
            manipulators = num2str(u(1));
            activeDrive = num2str(k(1));
            firmwareVersion = [num2str(k(3)) '.' num2str(k(2))];
            
            val = ['This MPC-200 is running firmware version ' firmwareVersion '. ' ...
                   'There are currently ' manipulators ' manipulators attached.  Drive ' activeDrive ' is active.'];
        end
        
    end       
    
    
    %% ABSTRACT METHOD IMPLEMENTATIONS
    methods (Access=protected,Hidden)        
        
        function moveStartHook(obj,targetPosn)
            posn = obj.moveHookHelper(targetPosn);
            pause(0.01); 
            obj.hHardwareInterface.sendCommandAsyncReply(int32(posn));            
        end      

        function posn = moveHookHelper(obj,targetPosn)
            
            %targetPosn = obj.validatePositionValidity(targetPosn); %ensure that the position doesn't exceed the device's range
            posn = obj.class2DeviceUnits(targetPosn,'position'); %Converts into units used by device
            
            switch lower(obj.moveMode)
                case 'straightline'
                    obj.hHardwareInterface.sendCommand('S','terminator','');
                    pause(0.01);
                    obj.hHardwareInterface.sendCommand(int8(obj.velocity),'terminator','');
                case 'accelerated'
                    obj.hHardwareInterface.sendCommand('M','terminator','');
            end
        end
        
        function isHardwareConnected = testHardwareConnection(obj) 
            %Tests the device's hardware connection
            try 
                obj.getInfoHardware();
                isHardwareConnected = true;
            catch ME
               isHardwareConnected = false; 
            end
        end
    end
    
    
    %% USER METHODS
    
    methods
        
        function home(obj)
            % moves the manipulator to (0,0,0)
            obj.hHardwareInterface.sendCommandStringReply('H');
        end
        
        function workPosition(obj)
            % moves the manipulator to the position manually defined (with the ROE) 
            % as the "work position" (but only if the command was preceded by home() or reset().
           pos = obj.positionAbsolute;
           
           if max(pos) == 0
              obj.hHardwareInterface.sendRsendCommandStringReply('Y');
           else
               warning('Calls to workPosition() must be preceded by a call to home() or reset()');
           end
        end        
        
        function pauseMove(obj)
            %Pause the current move. The nominal 'interrupt' command does not interrupt move, so much as pausing it
            %Following an 'interrupt', appears that move *must* be finished before anything else can happen.
            %There does not seem to be way to 'stop' a move
            obj.hHardwareInterface.sendCommand(char(3));
            obj.isMoveInterrupted = true;
            disp(['The current move has been interrupted.  This move must be finished ' ...
                    '(via resumeMove()) before any further commands can be sent.']);
        end   
        
        function resumeMove(obj)
            if obj.isMoveInterrupted
                obj.moveStartAbsolute([1 1 1]); %send it garbage coords to restart the previous move
                obj.isMoveInterrupted = false;
            end
        end
        
    end
    
    
    %% DEVELOPER METHODS
    
    methods (Hidden)        
        function moveCompleteHook(obj,targetPosn)
            posn = obj.moveHookHelper(targetPosn);
            obj.hHardwareInterface.sendCommandSimpleReply(int32(posn),'replyTimeout',obj.moveTimeout,'robustTerminatedReplyAttempts',0);
        end               
    end
    
    methods (Access=protected)


        function pos = validatePositionValidity(obj, posIn)
            pos = zeros(1,3);
            for i=1:3
                if posIn(i) > obj.stageLimits(i)
                    warning([num2str(posIn(i)) ' is outside the stage''s range of travel. Clamping to ' num2str(obj.stageLimits(i))]);
                    pos(i) = obj.stageLimits(i);
                elseif posIn(i) < 0
                    warning([num2str(posIn(i)) ' is outside the stage''s range of travel. Clamping to zero.']);
                    pos(i) = 0;
                else
                    pos(i) = posIn(i);
                end
            end
        end
        
    end

end

function stageTypeMap = getStageTypeMap()
    %Implements a static property containing Map indexed by the valid stageType values supported by this class, and containing properties for each
    stageTypeMap = containers.Map();

    stageTypeMap('mp285') = struct( ... %Note that stage assembly has same name as controller (as only one assembly type is officially supported)
        'maxVelocityStore', 15, ... 
        'resolution', .0625, ... %62.5nm resolution
        'initialVelocity',15); %Use 'initialVelocity' instead of 'defaultVelocity' -- as we do not defer to superclass default property value for velocity for this class                               
end

function resolutionModeMap = getResolutionModeMap()
    %Implements a static property containing Map of resolution multipliers to apply for each of the named resolutionModes
    resolutionModeMap = containers.Map();
    resolutionModeMap('default') = 1;
end

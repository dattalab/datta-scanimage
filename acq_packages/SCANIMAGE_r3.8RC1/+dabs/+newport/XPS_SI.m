classdef XPS_SI < dabs.interfaces.LinearStageControllerBasic
    %LinearStageController Class for Newport XPS Controller.
    
  %% REALIZATION OF ABSTRACT PROPERTIES (DEVICES/INTERFACES/LINEARSTAGECONTROLLERBASIC)
    
    properties (GetAccess=protected,Constant)
        setErrorStrategy = 'leaveErrorValue';
    end   
    
    %Abstract properties MUST be realized in subclasses, generally by copy/pasting these property blocks (sans 'Abstract', with subclass-specific constant/initial values as needed, and possibly with Hidden attribute added/removed), into each concrete subclass.
    %TMW: For case where subclasses are defining subclass-specific constant or intial values, this is reasonable. But documentation inheritance would be nice.
    properties (SetAccess=protected, Hidden)
        devicePositionUnits=1E-6; %Units, in meters, in which the device's position values (as reported by its hardware interface) are given
        deviceVelocityUnits=1E-6; %Units, in meters/sec, in which the device's velocity values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        deviceAccelerationUnits=1E-6;; %Units, in meters/sec^2, in which the device's acceleration values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        deviceErrorResp;
        deviceSimpleResp;
        
        stageTypeMap = mapInitStageTypeMap(); %Map containing property intializations for each of the stage types supported by subclass controller
        resolutionModeMap = mapInitResolutionModeMap(); %Map containing resolution multipliers for each of the named resolutionModes
    end
    
    properties (Constant, Hidden)  %TMW: Combination of 'Abstract' and 'Constant' in superclass works (as it well should), but documentation would suggest otherwise.
        hardwareInterface='custom'; %One of {'serial'}. Indicates type of hardware interface used to control device. NOTE: Other hardware interface types may be supported in the future.
        safeReset=0;; %Logical indicating, if true, that reset() operation (if any) should be considered safe backup to recover() operation, if former fails or doesn't exist. 'Safe' implies that operation has no side-effects and that motor operation can continue following reset() in same state as existed prior to error condition.
        
        maxNumStageAssemblies=1; %Maximum nuber of stage assemblies supported by device                
        requiredCustomStageProperties={}; %Cell array of properties that must be set on construction if one or more of the stages is 'custom'
        
        %Identifies strategy that subclass uses to signal move completed event on moveStartXXX() operations
        %   'hardwareInterfaceEvent': Appropriate underlying hardware interface (e.g. RS232DeviceBasic) 'asyncReplyEvent' event will be used
        %   'moveCompletedTimer': A Matlab timer object maintained by this class will periodically poll the isMoving property to determine if move has completed.
        %   <eventNameString>: The subclass is responsible for generating a move-completed event (given by <eventNameString>)
        moveCompletedDetectionStrategy='moveCompletedTimer'; % One of {'hardwareInterfaceEvent','moveCompletedTimer',<eventNameString>}
        
        % A subclass may implement a hook method which handles moveCompleteXXX() operations. (Otherwise, the 'isMoving' property will be polled in a tight loop until the move has completed.)
        moveCompleteHookFcn;
    end

    properties (Abstract, Constant)
        moveModes={}; %Cell array of possible moveModes for particular subclass device type. If only one type of move is supported, mode is 'default'.
    end
    
    %%%%%%%Following are Abstract only for purpose of allowing subclasses to override the Hidden attribute.
    %TMW: Would be nice if there were a) another mechanism to add/remove Hidden attribute based on class or b) some documentation inheritance, so documentation string need not be copy/pasted
    
    properties (Abstract)
        zeroHardWarning=true; %Logical flag indicating, if true, that warning should be given prior to executing zeroHard() operations
    end
    
   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% PRIVATE/PROTECTED PROPERTIES
    
    properties (SetAccess=protected)
        %contstructor initialized
        numberOfGroups;
        groupNames;
        groupToAxisMap;
        hStage; %handle to the XPS stage object
    end
   
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = XPS_SI(varargin)            
           % Prop-Value pair args
           %    positioners: (required): cell array of strings representing group name of each stage (i.e. 'GROUP1')
           %    ipAddress: (required) Default 192.168.0.254
           %    resolution: Resolution, in um, for all dimensions (specified as scalar) or per-dimension (specified as 3 element vector).If not, default resolution associated with specified 'stageType' is used.              
           
                       %Call superclass constructors 
            %TMW: This is required, because arguments must be passed. Would be nice to avoid, or at least avoid fully specifying class names (as it is done above)
            
            
            obj = obj@dabs.interfaces.LinearStageControllerBasic('generic');
            
           [dummy i]=ismember('positioners',varargin);
           if i==0
               error('Positioner names not given to XPS_SI')
           end
           positioners=varargin(i+1);
           
           [dummy i]=ismember('ipAddress',varargin);
           if i==0
               error('Positioner names not given to XPS_SI')
           end
           positioners=varargin(i+1);

           
           % pvargs = most.DClass.filterPropValArgs(varargin,{'stageType'});
                                    
           
           %Process resolution argument, if supplied. Not required. (left over from MP285...may not be necessary -Steve)
           pvargs = obj.filterPropValArgs(varargin,{'resolution'});
           if ~isempty(pvargs) %TMW: Annoying this can't be done via abstract superclass or separate function for private/protected properties
               obj.set(pvargs(1:2:end),pvargs(2:2:end));
           end
           
           %TODO get Constructor inputs from m file
           obj.hStage=XPS(positioners,ipAddress);%positioners must be 3 elements
           obj.groupToAxisMap=containers.Map;
           for i=1:3
               [groupName positionerName]=strtok(positioner{i},'.');
               obj.groupToAxisMap(groupName)=i;
           end
           obj.groupNames=groupToAxisMap.keys;
           [obj.numberOfGroups n]=size(obj.groupToAxisMap);
           
            obj.hStage.currentGroup='all';
           
        end
        
        
      
    end
       
    %% PROPERTY ACCESS
    %% PROPERTY ACCESS METHODS
    

    
    %%%Pseudo property-access for pseudo-dependent properties
    methods (Access=protected,Hidden)
        function pdepPropHandleGetHook(obj,src,evnt)
            propName = src.Name;
            
            switch propName
                case {'positionAbsolute','isMoving','infoHardware'}
                     obj.pdepPropIndividualGet(src,evnts);
            
                case {'velocity','acceleration'}
                    obj.pdepPropGroupedGet(@obj.getMotionProp,src,evnts);
                case {'invertCoordinates' 'infoHardware'} %TODO: Perhaps replace infoHardware with individuated get, since the firmware version word from controller seems inscrutable/buggy
                    obj.pdepPropGroupedGet(@obj.getStatusProperty,src,evnt);
                case {'limitReached'}
                    %TODO: potentially look into limitReached                    
                    obj.pdepPropGetUnavailable(src,evnt);
                case {'moveMode' 'resolutionMode' 'stageAssemblyIndex'}
                    %Do nothing --> pass-through (shoudl there be a method for this?)
                otherwise %Defer to superclass for default handling (error)
                    obj.pdepPropGetDisallow(src,evnt);
            end 
        end       
        
        function val=getPositionAbsolute(obj)
            %example of individualGet (made individual b/c property names don't match)
            val=obj.hStage.positionCurrentArray;
        end
        
        function val=getIsMoving(obj)
           
            val=any(obj.hStage.groupStatus==44);
            %example of individualGet
        end
        
        function val=getInfoHardware(obj)
            val=obj.hStage.firmwareVersion;
        
        function val=getMotionProp(obj,propName)
            %use grouped get because property names match
            val= obj.hStage.(propName);
        end
        
        function pdepPropHandleSetHook(obj,src,evnt)
            propName = src.Name;
            
            switch propName
                case {'velocity' 'acceleration'} 
                    obj.pdepPropIndividualSet(src,evnt);
                case {'moveMode'}
                    %Do nothing --> pass-through
                otherwise
                    obj.pdepPropSetDisallow(src,evnt);
                    %obj.pdepPropHandleSet@most.DClass(src,evnt);                    
            end            
        end
    end
    
 %% REALIZATION OF ABSTRACT METHODS (including 'semi-abstract')

    %Methods that all subclasses MUST define in a subclass-specific way.
    methods (Access=protected,Hidden)        
        function moveStartHook(obj,targetPosn) %Starts move and returns immediately. 
             for i=1:obj.numberOfGroups
                 currentGroup=obj.groupNames{i};
                 relaventPositionIndices=obj.groupToAxisMap(currentGroup);
                 targetPosnAdjusted=targetPosn(relaventPositionIndices);
                 hStage.groupMoveAbsolute(obj.hStage,targetPosnAdjusted,currentGroup);
             end

        end
        
        function  isHardwareConnected = testHardwareConnection(obj)
            isHardwareConnected = true;
        end

    end
    
    %Semi-abstract methods - generic implementations that are often overridden by subclasses
    methods (Access=protected,Hidden)   
        
        function interruptMoveHook(obj)
   
            for i=1:obj.numberOfGroups
                hstage.groupMoveAbort(hstage,obj.groupNames{i});
            end
            
           
        end
        
        %TODO: Implement if this has any sense for Newport controller...
        %   Do this if there's some benign operation to do after an error
        %         function recoverHook(obj)
        %         end

        %TODO: Implement if this has any sense for Newport controller...
        %         function resetHook(obj)
        %         end
        
        %TODO: Could be related to homing;
        %         function zeroHardHook(obj)
        %         end
        
        
    end
    
    
    
end

%% HELPER FUNCTIONS
function stageTypeMap = mapInitStageTypeMap()
stageTypeMap = containers.Map();

%TODO: Add defaultVelocity/defaultAcceleration values
%stageTypeMap('generic') = struct('defaultVelocity',<some value>, 'defaultAcceleration',<some value>);

stageTypeMap('generic') = struct();

end

function resolutionModeMap = getResolutionModeMap()
%Implements a static property containing Map of resolution multipliers to apply for each of the named resolutionModes
resolutionModeMap = containers.Map();
resolutionModeMap('default') = 1;
end


    
    
    


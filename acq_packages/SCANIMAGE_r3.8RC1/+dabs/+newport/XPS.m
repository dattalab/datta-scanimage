classdef XPS < most.PDEPProp & most.APIWrapper
    
    
    %% REALIZED ABSTRACT PROPERTIES (Programming.Interfaces.PDEPProp)
    properties  (Constant, Hidden)
        pdepSetErrorStrategy = 'restoreCached';
    end
    
    %% REALIZED ABSTRACT PROPERTIES (Programming.Interfaces.APIWrapper)
    
    properties (Constant, Hidden)
        apiPrettyName='Newport XPS Stage Controller Library';
        apiCompactName='XPSAPI';
        apiSupportedVersionNames={'current'};
        apiDLLNames='XPS_C8_drivers';
        apiHeaderFilenames='xps_load_drivers.h';
        apiCachedDataPath='';
    end
    
    properties (SetAccess=protected, Hidden)
        
        %API 'pre-fab' cached data variables
        apiStandardFuncRegExp; %Regular expression used to parse function prototypes and identify 'standard' functions of the API, about which standard API data (e.g. methodNargoutMap, responseCodeMap) will be stored. If not supplied, data will be stored for /all/ functions found in library.
        apiHasFuncNargoutMap=true; %<LOGICAL - Default=false> If true, 'funcNargoutMap' API data var is extracted from list of 'standard' functions, using extractFuncNargoutMap() method.
        
        %API response code handling
        %If API provides a responseCode duruing many or all of its API calls, the apiResponseCodeSuccess can be specified to identify the code for success -- all others are assumed to imply an error occurred
        %Subclasses can optionally utilize 1) a responseCodeMap API data var or 2) implement an apiResponseCodeFcn() method to convert a status code into meaningful string(s) for user
        %The value of Map or return value of method is either 1) a simple string specifying 'errorName', or 2) a structure with fields 'errorName' and 'errorDescription', containing short and longer string descriptors, respectively.
        %For case of responseCodeMap API data var, subclass can either 1) implment an apiResponseCodeMapFcn, or 2) suply a regular expression as the apiResponseCodeProcessor value, which will be supplied to extractCodeMaps() to extract/save the responseCodeMap API data var
        apiResponseCodeSuccess=0; %<NUMERIC> If specified, the first output argument of API 'standard' functions is taken to be a response code, with the specified response value(s) indicating call was successful.
        apiResponseCodeProcessor=apiResponseCodeHookFcn; %<One of {'none', 'apiResponseCodeMapHookFcn','apiResponseCodeHookFcn', <responseCodeMap regular expression>} - Default = 'none'>
        
        %API 'custom' cached data variables
        apiCachedDataVarMap; %A Map whose keys (strings) specify custom class-specific data variables to store to API Data file, and whose values (strings) specify method names used to extract each of the 'apiCachedDataVars'. If same name is used for more than one variable, method is only invoked once.
        
        %API Version auto-detection
        %For APIs which support it, auto-version detection is recommened, avoiding need for user specification
        %For a subclass to support API version auto-detection, the following should be satisfied:
        %   1) Set apiVersionDetectEnable=true
        %   2) Implement a method apiVersionDetectHookFcn(), which determines apiCurrentVersion value
        %   3) <RECOMMENDED> 'apiDLLNames' should /not/ be version-indexed and 'apiDLLPaths' should be empty or a non-version-indexed value
        %   4) <RECOMMENDED> A prototype file, apiVersionDetect.m, should be created in the apiHeaderRootPath, which selects  subset of API functions required for auto-version detection (to be used in apiVersionDetectHookFcn())
        % If either conditions 3 or 4 are not met, then the apiVersionDetect() method should be overridden
        apiVersionDetectEnable=0; %<LOGICAL - Default=false> If true, indicates that subclass implements an 'apiVersionDetectHookFcn' method which performs auto-detection of API version installed on system, and returns apiCurrentVersion value. If false, the centrally maintained apiVersionData file is used for version specification of this API.
        
        %Location of files associated with this API.
        %apiHeaderRootPath and apiHeaderPaths work in tandem. APIWrapper
        %looks for headers in <apiHeaderRootPath>/apiHeaderPaths(ver)/.
        %Derived classes may override apiHeaderRootPath only, or
        %apiHeaderPaths only, or both.
        apiHeaderRootPath; %NOT version-indexed. Default is class private dir.
        apiHeaderPathStem; %NOT version-indexed. Default is <apiCompactName>.
        apiHeaderPaths; %version-indexed. Default is map where values are [<apiHeaderPathStem>_<apiSupportedVersionNames with dots replaced by fileseps>].
        
        apiDLLPaths = 'useAPIHeaderPath';
        %apiDLLPaths = fullfile(most.DClass.classPrivatePathStatic(mfilename('class')),'XPSAPI_current'); %version-indexed. By default, no path will be used, implying system default location.
        
        apiAuxFile1Names; %version-indexed.
        apiAuxFile1Paths; %version-indexed. By default, the class private directory will be used.
        
        apiAuxFile2Names; %version-indexed.
        apiAuxFile2Paths; %version-indexed. By default, the class private directory will be used.
    end
    
    %% REALIZATIONS FROM MACHINEDATAFILE
     properties (Constant,Hidden)
        mdfHeading=mfilename('class');  
        % Fully-qualified classname, typically the class's own name.
        % Specifies the heading in the MDF that will be used to init object
        % properties for the class. Leave this empty to opt-out (initialize
        % no properties). This prop should never specify a class whose
        % mdfHeading is not itself.
        
        mdfPropPrefix='';
        % String. Variables names specified in the MDF have this prefix
        % appended when assigning values to properties in object instances.
        % For example, if mdfPropPrefix = 'md', then a variable 'MyProp' in
        % the MDF corresponds to an object property 'mdMyProp'.
        % mdfPropPrefix may be the empty string ''.        

        mdfDependentHeadings; 
        % Cellstr of fully-qualified classnames. Relevant when
        % thisclass.mdfHeading==<thisclassname>. Specifies the other
        % headings that this MDF heading "depends on," ie when this class's
        % heading is added to an MDF, the headings for its
        % dependentheadings should be added as well. (This might more
        % precisely be called 'mdfDependsOnHeadings'.)

        mdfPriority; 
        % Scalar number in [0,5]. Only relevant when
        % thisclass.mdfHeading==<thisclassname>. Determines relative
        % importance/positioning of header defined by this class in the
        % MDF. Smaller numbers are more important/higher up in the file.
    end
    
    %% DEVICE PROPERTIES (incl. Pseudo-dependent)
    
    %Positioner properties (PDEP) -- these are set/get as arrays (cell or numeric, as appropriate), one per positioner
    properties (SetObservable, GetObservable)
        positionerBacklash;
        
        
    end
    
    %Group properties (PDEP)
    % These are set/get based on the 'currentGroup' property. 
    % If currentGroup='all', then values for all groups are returned (as array, or as cell array if values are arrays)
    properties (SetObservable, GetObservable)
        groupPositionCurrent;
        groupPositionSetpoint;
        groupPositionTarget;
        groupJogCurrent;
        
    end    
        
    %Value-added properties (Non PDEP)    
    properties                               
        velocity; %Array of velocity values, one per positioner 
        acceleration; %Array of acceleration values, one per positioner 
        minJerk; %Array of minJerk values, one per positioner 
        maxJerk; %Array of maxJerk values, one per positioner                  
    end
    
    %Value-added properties (PDEP)
    properties (SetObservable,GetObservable)
        positionCurrentArray; %Array of positionsCurrent values for each element in positionerNamesUnique, regardless of group affiliation
        positionTargetArray; %
        positionSetpointArray; 
    end
    
    
    %% PUBLIC PROPERTIES
    
    
    
    properties
        currentGroup='all'; %Name of current group (one of 'groupNames', or 'all') to use for group property get/set operations, and to use by default for methods which accept a groupName                
    end
    
    
    
    %% PRIVATE/PROTECTED PROPERTIES
    
    properties (SetAccess=protected)
        %%%Constructor-Initialized%%%%%%%
        groupNames;
        positionerNames;
        positionerNamesUnique;
        
        ipAddress = '192.168.0.254';        
        socketID;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    properties (SetAccess=protected, Hidden)
        %%%Constructor-Initialized%%%%%%%
       groupPositionerMap; %Map of group name to positioner names within each group 
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       currentGroupCellArray; %String cell array of group names, determined by currentGroup
       
       propStringSizeMap = mapInitPropStringSize(); %Map of property names to one of {'small','medium','large'}              
    end    
    
    properties (Constant, Hidden)
       stringSizeMap = containers.Map({'small' 'medium' 'large'}, {100, 300, 3500}); 
    end
    
    %% CONSTRUCTOR
    methods
        function obj=XPS(positionerNames,ipAddress)
            % positionerNames: String cell array of full positioner names, including group to which it belongs, e.g. 'XY.X'. NOTE: It MAY be possible to have a single physical positioner belong to more than one group -- we're not sure.
            % ipAddress: <OPTIONAL>
            
            %Process input arguments
            obj.positionerNames = positionerNames;
            obj.positionerNamesUnique = unique(positionerNames);
            
            obj.positionerNamesUnique = {};
            obj.groupNames = {};                       
            obj.groupPositionerMap = containers.Map('KeyType','char','ValueType','char');
            for i=1:length(obj.positionerNames)
                [groupName,positionerName] = strtok(obj.positionerNames{i},'.'); %Gets portion before period
                positionerName = positionerName(2:end);   
                
                if ~ismember(positionerName, obj.positionerNamesUnique)
                    obj.positionerNamesUnique(end+1) = positionerName;
                end
                
                obj.groupNames(end+1) =  groupName;
                obj.groupPositionerMap(groupName) = obj.positionerNames{i};
            end
            obj.groupNames = unique(obj.groupNames);

            if nargin <= 2
                obj.ipAddress = ipAddress;
            end
            
            %connect
            port=5001; %These values are picked simply because they work -Steve
            timeout=10;
            obj.socketID=apiCall(obj,'TCP_ConnectToServer', obj.ipAddress,port,timeout);
        end
    end
    
    
    
    
    %% PROPERTY ACCESS METHODS
    
    methods
        function val = get.velocity(obj)
            sGammaParams = obj.positionerSGammaParameters;
            val = sGammaParams{1};            
        end
        
        function val = get.acceleration(obj)
            %TODO            
        end
        
        
        function val = get.minJerk(obj)
            %TODO            
        end
        
        
        function val = get.maxJerk(obj)
            %TODO            
        end

        
        function val = get.positionCurrentArray(obj)
            
                    
        end
        
        function val = get.positionTargetArray(obj)
            
            val = zeros(length(obj.positionerNamesUnique),1);
            
            for i=1:length(val)
                val(i) = obj.apiCall('GroupPositionCurrentGet',obj.socketID, obj.positionerNamesUnique{i}, 0);
            end
        end

        
        
        function set.currentGroup(obj,val) 
            doSet = true;
            if ischar(val) && ismember(val, obj.groupNames)
                obj.currentGroupCellArray = {val}; %#ok<*MCSUP>
            elseif ischar(val) && strcmpi(val,'all')
                obj.currentGroupCellArray = obj.groupNames;
            elseif iscellstr(val) && all(ismember(val,obj.groupNames))
                obj.currentGroupCellArray = val;
            else
                fprintf(2,'Invalid value specified for ''currentGroup''\n');
                doSet = false;
            end
            
            if doSet                
                obj.currentGroup = val;
            end
        end
        
    end
    
    
    %PDEP Prop Handling
    methods (Access=protected)
        %____________________get property___________________%
        function pdepPropHandleGet(obj,src,evnt)
            propName = src.Name;
            
            switch propName
%                 case {'velocity','acceleration','minJerk','maxJerk'}
%                     obj.pdepPropGroupGet(@obj.getXPSParameters,src,evnt);
%                 case{'isMoving'}
%                     obj.pdepPropGroupGet(@obj.getXPSIsMoving,src,evnt);
%                 case{'positionAbsolute'}
%                     obj.pdepPropGroupGet(@obj.getXPSPositionAbsolute,src,evnt);

                case {'positionerSGammaParametersGet' 'positionerBacklash' 'positionerCorrectorNotchFilters'}
                    obj.pdepPropGroupedGet(@obj.getPositionerPropArray,src,evnt);
                    
                case {'positionerCorrectorType'}
                    obj.pdepPropGroupedGet(@obj.getPositionerPropString,src,evnt);                                       
                    
                case {'positionerHardInterpolatorFactor'}
                    obj.pdepPropGroupedGet(@obj.getPositionerPropSimple,src,evnt);      
                    
                case {'positionerError'}
                    obj.pdepPropIndividualGet(src,evnt); %TODO: Use positionerErrorRead() instead of positionerErrorGet()
                      
                case {'positionCurrentArray' 'positionTargetArray' 'positionSetpointArray'}
                    obj.pdepPropGroupedGet(@obj.getPositionArray,src,evnt);
                    
                case {'groupPositionCurrent' 'groupPositionSetpoint' 'groupPositionTarget' 'groupStatus''groupAccelerationSetpoint','groupCorrectorOutput','groupCurrentFollowingError'}
                    obj.pdepPropGroupedGet(@obj.getGroupPropSimple,src,evnt);
                    
                case{'groupJogCurrent','groupJogParameters'}
                    obj.pdepPropGroupedGet(@obj.getGroupPropArray,src,evnt);    
                case('firmwareVersion')
                    obj.pdepPropGroupedGet(@obj.getString,src,evnt);
            
                    
%                 case {'actionList'}
%                     obj.pdepPropGroupedGet(@obj.getMediumStringProp,src,evnt);
%                     
%                 case {'apiList' 'errorList'}
%                     obj.pdepPropGroupedGet(@obj.getLongStringProp,src,evnt);

                otherwise
                    obj.pdepPropGroupedGet(@obj.getStandard,src,evnt)
                    
            end
        end
        
        
        function pdepPropHandleSet(obj,src,evnt)
            propName = src.Name;
            switch propName
                case {'velocity','acceleration','minJerk','maxJerk'}
                    obj.pdepPropGroupGet(@obj.setXPSParameters,src,evnt);
                otherwise
                    obj.pdepPropSetDisallow(src,evnt);
            end
        end
        
        
        function val = getPositionerPropSimple(obj,propName)           
            val = zeros(length(obj.positionerNames),1);
            for i=1:length(obj.positionerNames)
                val(i) = obj.apiCall([upper(propName(1)) propName(2:end) 'Get'],obj.socketID, obj.positionerNames{i}, 0);
            end
        end
        
        function val = getPositionerPropArray(obj,propName)
            val = cell(length(obj.positionerNames),1);
            funcNargoutMap = obj.accessAPIDataVar('funcNargoutMap');
            
            [inputArgs,outputArgs] = deal(repmat({0},funcNargoutMap(propName),1));            
            for i=1:length(obj.positionerNames)
                [outputArgs{:}] = obj.apiCall([upper(propName(1)) propName(2:end) 'Get'],obj.socketID, obj.positionerNames{i},inputArgs{:});
                val{i} = outputArgs;
            end
     
        end

        function val = getPositionerPropString(obj,propName)
            val = cell(length(obj.positionerNames),1);
                        
            dummyString = char(ones(obj.stringSizeMap(obj.propStringSizeMap(propName)),1));
            for i=1:length(obj.positionerNames)
                val{i} = obj.apiCall([upper(propName(1)) propName(2:end) 'Get'],obj.socketID, obj.positionerNames{i},dummyString);
            end
            
        end
        
        function val = getPositionArray(obj,propName)
            
            val = zeros(length(obj.positionerNamesUnique),1);                                               
            
            propName = propName(1:end-5); %strip away 'Array' 
            for i=1:length(val)
                val(i) = obj.apiCall(['Group' upper(propName(1)) propName(2:end)],obj.socketID, obj.positionerNamesUnique{i}, 0);
            end    
        end
                
        function val=getGroupPropSimple(obj,propName)
            
            val = zeros(length(obj.currentGroupCellArray),1);
            for i=1:length(obj.currentGroupCellArray)
                
                numPositioners = length(obj.groupPositionerMap(obj.currentGroupCellArray{i}));
                val{i} = zeros(numPositioners,1);                                
                val{i} = obj.apiCall([upper(propName(1)) propName(2:end) 'Get'],obj.socketID, obj.obj.currentGroupCellArray{i}, val{i});
            end
            
            if length(val) == 1
                val = val{1};
            end
        end
        
        function val = getGroupPropArray(obj,propName)
            %TODO!! cell array of arrays
            
        end
        
        function val=getString(obj,propName)
            dummyString = char(ones(obj.stringSizeMap(obj.propStringSizeMap(propName)),1));
             val = obj.apiCall([upper(propName(1)) propName(2:end) 'Get'],obj.socketID, dummyString);
        end
        

        
        function val=getXPSParameters(obj,propName)
            parameters=[];
            for i=1:3
                parameters(i,:)=apiCall(obj,'PositionerSGammaParametersGet',obj.socketID,obj.stageGroup{i});
            end
            
            switch propName
                case {'velocity'}
                    val=parameters(:,1);
                case {'acceleration'}
                    val=parameters(:,2);
                case {'minJerk'}
                    val=parameters(:,3);
                case {'maxJerk'}
                    val=parameters(:,4);
            end
            
        end
        
        function val = getPositionIndexed
        end
        
        function val=getXPSIsMoving(obj,propName)
            for i=1:3
                
                groupmoving(i)=apiCall(obj,'GroupStatusGet',obj.socketID,obj.stageGroup{i});
                
            end
            val = any(groupmoving == 44);
            %val=(groupmoving(1)==44 || groupmoving(2)==44 || groupmoving(3) == 44);
        end
        
        function val=getXPSPositionAbsolute(obj,propName)
            for i=1:3
                
                
                val(i)=apiCall(obj,'GroupStatusGet',obj.socketID,obj.stageGroup(i));
                
            end
        end
        
        function setXPSParameters(obj,propName,val)
            parameters=zeros(3,4);
            for i=1:3
                parameters(i,:)=apiCall(obj,'PositionSGammaParametersGet',obj.socketID,obj.stageGroup{i});
            end
            switch propName
                case {'velocity'}
                    parameters(:,1)=val';
                case {'acceleration'}
                    parameters(:,2)=val';
                case {'minJerk'}
                    parameters(:,3)=val';
                case {'maxJerk'}
                    parameters(:,4)=val;
            end
            for i=1:3
                apiCall(obj,'PositionSGammaParametersGet',obj.socketID,obj.stageGroup{i},parameters(i,1),parameters(i,2),parameters(i,3),parameters(i,4));
            end
        end
        
        
        
        
        
    end
    %% API Methods
    
    methods (Access=private)
        function version=apiVersionDetectHookFcn(obj)
            version=apiCall(obj,'GetLibraryVersion');
        end
    end
    
    methods
        
        function groupMoveAbsolute(obj,targetPosn, groupOrPositionerName)
            %groupOrPositionerName: ...
            
           if nargin < 3 || isempty(groupOrPositionerName)
               assert(length(obj.currentGroupCellArray) == 1, 'Method can only be called on one group or positioner at a time');
               groupOrPositionerName = obj.currentGroup;
           end
           
           if ismember(groupOrPositionerName, obj.groupNames)               
               obj.apiCall('GroupMoveAbsolute',targetPosn, length(targetPosn), groupOrPositionerName)
           elseif ismember(groupOrPositionerName, obj.positionerNames)
               obj.apiCall('GroupMoveAbsolute',targetPosn, 1, groupOrPositionerName);
           else
               error('Invalid group or positioner name');
           end
            
        end
        
        function moveToXPS(posn)
            [tmp, nbElement] = size(posn);
            for i=1:3                
                varargout=apiCall(obj,'GroupMoveAbsolute',obj.socketID,obj.stageGroup{i},nbElement,posn(i));                                
            end
        end
        
        function interruptMoveXPS
            for i=1:3
                
                apiCall(obj,'GroupMoveAbort',obj.socketID,obj.stageGroup{i});
            end
        end
        
        function isHardwareConnected = testHardwareConnection(obj)
            for i = 1:52
                ReturnString = [ReturnString '          '];
            end
            
            varargout=apiCall(obj,'TestTCP',obj.socketID,'teststring',ReturnString);
            isHardwareConnected=1;
        end
        
        function  responseCodeInfo = apiResponseCodeHookFcn(responseCode)
            responseCodeInfo=apiCall('ErrorStringGet',obj.socketID,responseCode);
        end
        
        
    end
    
end

%% HELPER FUNCTIONS

function propStringSizeMap = mapInitPropStringSize()

propStringSizeMap = containers.Map('KeyType','char','ValueType','char');

propStringSizeMap('actionList') = 'medium';
propStringSizeMap('apiList') = 'long';
propStringSizeMap('errorList') = 'long';
propStringSizeMap('firmwareVersion')='short';


end

    






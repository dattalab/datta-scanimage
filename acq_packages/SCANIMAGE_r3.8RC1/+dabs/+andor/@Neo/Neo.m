classdef Neo < most.APIWrapper & most.PDEPProp
    %NEO Class encapsulating functionality of Andor Neo (sCMOS) cameras
    %   Detailed explanation goes here
    
    %% USER PROPERTIES
    %PDEP Properties
    properties (SetObservable,GetObservable)
        %TODO: Fill in all PDEP props
        
        triggerMode;
    end
    
    
    
    %% DEVELOPER PROPERTIES
    properties (Hidden)
        cameraHandle;
        
        
        
    end
    
    %% ABSTRACT PROPERTY REALIZATION (most.APIWrapper)
    properties (Constant, Hidden)
        apiPrettyName = 'Andor SDK3';  %A unique descriptive string of the API being wrapped
        apiCompactName = 'AndorSDK3'; %A unique, compact string of the API being wrapped (must not contain spaces)
        apiSupportedVersionNames = {'3.1'}; %A cell array of shorthand names (strings) for API versions supported by this wrapper class
        
        apiDLLNames = 'atcore'; %version-indexed. The name of the DLL sans the '.dll' extension.
        apiHeaderFilenames = 'atcore.h'; %version-indexed. The name of the header file (with the '.h' extension - OR a .m or .p extension).
        
        apiCachedDataPath = ''; %Specifies path of apiData MAT file for this API wrapper class. If specified as empty(''), the class private directory will be used as default.
        %NOTE: The apiCachedDataPath might otherwise be in section below (i.e. not require that a value be specified), but it must be a Constant value, in order to be accessible from Static methods (and avoid using 'dummy' object scheme)
    end
    
    %Following properties are sometimes supplied values by concrete subclasses, or they can be left empty when realized - in which case default values are used.
    properties (SetAccess=protected, Hidden)
        
        %API 'pre-fab' cached data variables
        apiStandardFuncRegExp; %Regular expression used to parse function prototypes and identify 'standard' functions of the API, about which standard API data (e.g. methodNargoutMap, responseCodeMap) will be stored. If not supplied, data will be stored for /all/ functions found in library.
        apiHasFuncNargoutMap; %<LOGICAL - Default=false> If true, 'funcNargoutMap' API data var is extracted from list of 'standard' functions, using extractFuncNargoutMap() method.
        
        %API response code handling
        %If API provides a responseCode duruing many or all of its API calls, the apiResponseCodeSuccess can be specified to identify the code for success -- all others are assumed to imply an error occurred
        %Subclasses can optionally utilize 1) a responseCodeMap API data var or 2) implement an apiResponseCodeFcn() method to convert a status code into meaningful string(s) for user
        %The value of Map or return value of method is either 1) a simple string specifying 'errorName', or 2) a structure with fields 'errorName' and 'errorDescription', containing short and longer string descriptors, respectively.
        %For case of responseCodeMap API data var, subclass can either 1) implment an apiResponseCodeMapFcn, or 2) suply a regular expression as the apiResponseCodeProcessor value, which will be supplied to extractCodeMaps() to extract/save the responseCodeMap API data var
        apiResponseCodeSuccess = 0; %<NUMERIC> If specified, the first output argument of API 'standard' functions is taken to be a response code, with the specified response value(s) indicating call was successful.
        apiResponseCodeProcessor = '#define AT_ERR_(\w*)\s*(\d*)'; %<One of {'none', 'apiResponseCodeMapHookFcn','apiResponseCodeHookFcn', <responseCodeMap regular expression>} - Default = 'none'>
        
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
        apiVersionDetectEnable; %<LOGICAL - Default=false> If true, indicates that subclass implements an 'apiVersionDetectHookFcn' method which performs auto-detection of API version installed on system, and returns apiCurrentVersion value. If false, the centrally maintained apiVersionData file is used for version specification of this API.
        
        %Location of files associated with this API.
        %apiHeaderRootPath and apiHeaderFinalPaths work in tandem.
        %APIWrapper uses apiHeaderPaths = <apiHeaderRootPath>\<apiHeaderFinalPaths(ver)>
        %Derived classes may override apiHeaderRootPath only, or apiHeaderPaths only, or both.
        %TIP: If either apiHeaderRootPath or apiHeaderFinalPaths is specified as an empty string ('') -
        %   then other property can specify whole path or version-indexed cell-array or Map of paths (latter only possible with apiHeaderFinalPaths)
        apiHeaderRootPath = 'c:\program files\andor sdk3'; %NOT version-indexed. Either 'class', 'package', or <real path>. 'class' and 'package' indicate class or package private path, respectively.
        apiHeaderFinalPaths = ''; %version-indexed. Default is map where values are [<apiHeaderPathStem>_<apiSupportedVersionNames with dots replaced by fileseps>].
        apiHeaderPathStem; %NOT version-indexed. Default is <apiCompactName>.
        
        apiDLLPaths = 'useApiHeaderPaths'; %version-indexed. By default, no path will be used, implying the system default location. To use the same version-indexed paths as apiHeaderPaths, set apiDLLPaths to be the scalar string 'useApiHeaderPaths'. This is useful e.g. when the DLL is distributed with the headers.
        
        apiAuxFile1Names; %version-indexed.
        apiAuxFile1Paths; %version-indexed. By default, the class private directory will be used. Also can specify 'useApiHeaderRootPath' or 'useApiHeaderPaths'.
        
        apiAuxFile2Names; %version-indexed.
        apiAuxFile2Paths; %version-indexed. By default, the class private directory will be used. Also can specify 'useApiHeaderRootPath' or 'useApiHeaderPaths'.
    end
    
    
    
    %% ABSTRACT PROPERTY REALIZATION (most.PDEPProp)
        
    properties(Constant, Hidden)
        pdepSetErrorStrategy = 'restoreCached'; 
    end
    
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = Neo(cameraSerialNumber)
            
            %TODO: Determine device index for specified serial number
            %For now, assuming only one camera (device Index = 0)!!
            obj.cameraHandle = obj.apiCall('AT_Open',0,0);
            
        end
        
        function delete(obj)
            
        end
    end
    
    %% PROPERTY ACCESS METHODS
    
    methods (Access=protected)
        function pdepPropHandleGet(obj,src,evnt)
            propName = src.Name;

            
        end
    
        
        function pdepPropHandleSet(obj,src,evnt)            
            propName = src.Name;
            
        end
        
    end
    %% USER METHODS
    
    methods 
       
        function acquisitionStart(obj)
            obj.apiCall('AT_Command',obj.cameraHandle,'AcquisitionStart');
        end
        
        function acquisitionEnd(obj)
            
        end
        
        function cameraDump(obj)
            
        end
        
        function softwareTrigger(obj)
            
        end                        
        
        
    end
    
    
    %% DEVELOPER METHODS
    
    methods (Hidden)
       
        function responseCodeInfo = apiResponseCodeMapHookFcn(obj, responseCode)
            
            %TODO: Implement logic to decode response code
            
            
        end
        
        
    end
end


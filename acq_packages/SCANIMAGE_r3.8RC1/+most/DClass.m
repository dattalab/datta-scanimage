classdef DClass < hgsetget
    %DCLASS Current 'standard' Dabs class
    %
    %% NOTES
    %    
    %   TODO: Consider if it makes sense to factor filterPropValArgs & extractPropValArgMap out into utility functions -- they don't really need to be DClass methods..
	%	TODO: ensureClassDataFileStatic() should perhaps ensure that all specified variables exist in any pre-existing CDF and add/initialize any that don't. 
    %   TODO: Cache the 'classNameShort' property on object construction, rather than computing every time property is needed
    %   TODO: Consider subclassing MException, to make DException -- instead of packing utility functions here. But how to make this available to all DClass instances?
    %
    %% ************************************************************************    
       
    %% PRIVATE/PROTECTED PROPERTIES
    properties (SetAccess=private, Dependent)
       errorCondition; %Logical value indicating if class is in an error condition. Messages for all errors causing this condition can be queried using errorConditionMessages. 
       errorConditionMessages; %Cell array of error messages that have been stored to this class via errorConditionSet()
       errorConditionIdentifiers; %Cell array of error identifiers that have been been stored to this class via errorConditionSet()       
    end
    
    properties (SetAccess=protected,Hidden)
        %errorConditionMessages={}; %Cell array of error messages that have been generated by this class, in sequential order. When empty, the class is considered not in an error condition. Class users can reset this property using errorConditionClear()
        errorConditionArray; %Array of MException objects that have been stored to this class via errorConditionSet()
        
        cancelConstruct=false; %Logical flag, used by a superclass to signal to subclasses that construction should be cancelled, e.g. if a user-input step required by superclass was cancelled        
    end      
    
    properties (Hidden)
        errorConditionVerbose=false; %Logical value indicating, if true, to display information to command line every time errorConditionSet() adds new message
    end    
    
    properties (Dependent,Hidden)
        classNameShort; %Short version of object's class name, i.e. class name with all package information stripped.        
        classPrivatePath; %Path of private folder associated with this object's class definition        
        packagePrivatePath; %Path of private folder of containing package. If there is no containing package, then the value of this property is [].
        %TODO: Remove this property, when all dependencies are fixed..it's a bit too simple.
        classPath; %Path of this object's class definition 
    end
    
    %     properties (Hidden)
    %         customDisplayPropertyList = {};
    %     end
    %

      
    %% EVENTS
    events (NotifyAccess=protected)
        errorCondSet;
        errorCondReset;
    end
    

     %% PROPERTY ACCESS METHODS
    
    methods
        function classNameShort = get.classNameShort(obj)            
            classNameShort = obj.classNameShortStatic(class(obj));
        end           
                        
        function classPrivatePath = get.classPrivatePath(obj)
            classPrivatePath = obj.classPrivatePathStatic(class(obj));
        end

        function packagePrivatePath = get.packagePrivatePath(obj)
            packagePrivatePath = obj.packagePrivatePathStatic(class(obj));
        end

        %TODO: Remove this property, when all dependencies are fixed..it's a bit too simple.
        function classPath = get.classPath(obj)
            classPath = fileparts(which(class(obj)));
        end

        function set.errorConditionVerbose(obj,val)
            assert(islogical(val),'Value of ''errorConditionVerbose'' must be a logical (true, false, 0, 1)');
        end
        
        function tf = get.errorCondition(obj)
            tf = ~isempty(obj.errorConditionArray);            
        end
        
        function val = get.errorConditionMessages(obj)
            errorCondArray = obj.errorConditionArray;
            if isempty(errorCondArray) 
                val = {};
            else
                val = {errorCondArray.message};
            end
        end
        
        function val = get.errorConditionIdentifiers(obj)
            errorCondArray = obj.errorConditionArray;
            if isempty(errorCondArray)
                val = {};
            else
                val = {errorCondArray.identifier};
            end
        end

    end
    
    %% PUBLIC METHODS
    methods        
        
        function errorConditionReset(obj)
            %Clears (all) error conditions on object            
            obj.errorConditionArray(:) = [];
            notify(obj,'errorCondReset');
        end
        
        function errorConditionSet(obj,ME)
            assert(isa(ME,'MException'),'Supplied value must be of class MException');
            if ~isempty(ME)
                if obj.errorConditionVerbose
                    fprintf(2,'Error condition for object of class %s has been set: \n\t%s\n',class(obj),ME.message);
                end
                  
                if isempty(obj.errorConditionArray)
                    obj.errorConditionArray = ME; %Actually set the value
                    notify(obj,'errorCondSet');
                else
                    obj.errorConditionArray(end+1) = ME; %Appends the MException object, but does not signal new errorCondition for class
                end                      
            end
        end    
        
        
              
    end
        
    
    %% PROTECTED METHODS
   
    methods(Access=protected)
        
        % ClassData File Mechanism
        
        function ensureClassDataFile(obj,initValStruct,className)
            % Ensure that classData file store for specified class exists (creating, if necessary)
            % SYNTAX
            %   ensureClassDataFile(obj,initValStruct)
            %   ensureClassDataFile(obj,initValStruct,className)
            %
            %   initValStruct: A struct specifying the class data 'variables' and their initial values
            %   className: IF specified, the classData file will be associated with the specified className. If not, the class of the object is assumed.
            %              Typically, "mfilename('class')" is supplied for this argument, when used.
            %
            % NOTES (USAGE)
            %    * ensureClassData() OR ensureClassDataStatic() should be called once and only once in any class requiring a class data store
            %    * To implement a classData file store, generally either ensureClassData() is called from class constructor OR ensureClassDataStatic() is called from a static method

            error(nargchk(2,3,nargin,'struct'));            
            if nargin == 2
                className = class(obj);
            end
            most.DClass.ensureClassDataFileStatic(className,initValStruct);            
        end
        
        
        function val = getClassDataVar(obj,varName,className)
            %Read classData variable, i.e. a value stored in MAT file maintained by class
            % SYNTAX
            %   val = getClassDataVar(obj,varName)
            %   val = getClassDataVar(obj,varName,className)
            %   If className is specified, getClassDataVar looks for
            %   varName in the classData variables for the specified class.
            %   When className is not specified, getClassDataVar starts at
            %   the class of obj and searches up its inheritance tree,
            %   returning the first matching classData variable. In either
            %   case, if no matching classData variable is found, [] is
            %   returned.
            %
            % NOTES 
            %   The 'className' form should generally be used within abstract classes, or other classes that expect to be inherited from
           
            error(nargchk(2,3,nargin,'struct'));
            if nargin == 2
                className = class(obj);
                tfSearchSuperClasses = true;
            else %nargin=3
                tfSearchSuperClasses = false;
            end
            val = most.DClass.getClassDataVarStatic(className,varName,tfSearchSuperClasses);     
        end
        
        function setClassDataVar(obj,varName,val,className)
            %Write classData variable, i.e. value stored in MAT file maintained by class.
            % SYNTAX
            %   setClassDataVar(obj,varName,val)
            %   setClassDataVar(obj,varName,val,className)
            %
            %   className: If specified, setClassDataVar writes to the
            %   classData file for the specified class. Otherwise,
            %   setClassDataVar starts at the class of obj and searches up
            %   its inheritance tree, setting varName to be val in the
            %   first classData file found in which varName is a classData
            %   variable. In either case, if varName is not found as an
            %   existing classData variable, an error is thrown.
           %
            % NOTES
            %   The 'className' argument allows one to access classData file stores maintained by superclasses of the current object
            %   The 'className' form should generally be used within abstract classes, or other classes that expect to be inherited from

            error(nargchk(3,4,nargin,'struct'));            
            if nargin == 3
                className = class(obj);
                tfSearchSuperClasses = true;
            else
                tfSearchSuperClasses = false;
            end
            most.DClass.setClassDataVarStatic(className,varName,val,tfSearchSuperClasses);
        end
        

        function displaySmart(obj,propList,varargin)
            % Display object properties with special features including grouping by inheritance
            % SYNTAX
            %   displaySmart(propList)
            %   displaySmart(propList,prop1,value1,prop2,value2,...)
            %       propList: Cell string array of properties to display, in order to be displayed. If empty, the properties() method is used.
            %
            %   Props:
            %       customDisplayPropertyList: <Default={}>
            %       suppressInheritedProps: <Default=false> If true, inherited properties are not displayed
            %       explicitInheritanceDisplayEnable: <Default=false>
            %       inheritanceGroupingEnable: <Default=true> If true, inherited properties are grouped
            %       explicityExcludeList: <Default={}> Cell string array listing properties to explicitly exclude from display
            
            % TODO: Document optional arguments more fully
            % TODO: Explore idea of 'list inheritance' -- could be very useful for selecting displayed props at each level of inheritance tree
            
            if ~isvalid(obj)
                disp(obj);
            end
                
            % process any optional arguments:
            %argStruct = containers.Map();
            argStruct.suppressInheritedProps = false;
            argStruct.explicitInheritanceDisplayEnable = false;
            argStruct.inheritanceGroupingEnable = true;
            argStruct.explicitExcludeList = {};            
            
            %             optArgs = most.util.filterPVArgs(varargin,optArgDefaultMap.keys());
            %             if isempty(
            %             argMap = containers.Map(optArgs(1:2:end),optArgs(2:2:end));
            %
            %             argStruct = struct();
            %             for i=1:length(optArgs)
            %                 %TMW: There seems to be no way to store to workspace variable
            %                 if ~argMap.isKey(optArgs{i}) || isempty(argMap(optArgs{i}))
            %                     argStruct.(optArgs{i}) = optArgDefaultMap(optArgs{i});
            %                 else
            %                     argStruct.(optArgs{i}) = argMap(optArgs{i});
            %                 end
            %             end
            
            optArgs = most.util.filterPVArgs(varargin,fieldnames(argStruct));
            if ~isempty(optArgs)
                optArgMap = containers.Map(optArgs(1:2:end),optArgs(2:2:end));
                
                keys = optArgMap.keys();
                for i = 1:length(keys)
                    argStruct.(keys{i}) = optArgMap(keys{i});
                end
            end
            
            mClass = metaclass(obj);
            
            % Show the top-level superclass:            
            parent = mClass.SuperClasses;
            while ~isempty(parent{1}.SuperClasses)
                parent = parent{1}.SuperClasses;
            end
            disp(['<a href = "matlab:help ' mClass.Name '">' mClass.Name '</a>, ' ...
                  '<a href = "matlab:help ' parent{1}.Name '">' parent{1}.Name '</a>']);
            
            %show this containing package for this class:
            disp(['Package: ' mClass.ContainingPackage.Name char(10)]);
            
            %show all of the properties enumerated in 'customDisplayPropertyList'
            if isempty(propList)
                propList = properties(obj);
            end
            
            assert(iscellstr(propList),'Property list must be specfied as a string cell array');
   
            
            for i = 1:length(propList)
                
                propName = propList{i};
                if ismember(propName,argStruct.explicitExcludeList)
                    continue;
                end
                
                value = obj.(propName);               
                
                left = sprintf('%35s%2s',propName,': '); 
                right = '';
                if isa(value,'cell')
                    right = '{ ';
                    
                    % test if we have nested cell array
                    isNested = sum(cellfun('isclass', value, 'cell'));
                    if isNested
                        for cell=[value]
                            dim = size(cell{1});
                            right = [right '{' num2str(dim(1)) 'x' num2str(dim(2)) ' cell} '];
                        end
                    elseif iscellstr(value)
                        dims = size(value);
                        if dims(2) == 1
                            for i=1:dims(1)
                                right = [right '''' value{i} ''''];
                                if i ~= dims(1)
                                    right = [right '; '];
                                end
                            end
                        else
                            for cell=[value]
                                right = [right '''' cell{:} ''' '];
                            end
                        end
                    else
                        dims = size(value);
                        if dims(2) == 1
                            for i=1:dims(1)
                                right = [right '[' obj.formatVal(value{i})  ']'];
                                if i ~= dims(1)
                                    right = [right '; '];
                                end
                            end
                        else
                            for cell=[value{:}]
                                right = [right '['];
                                right = [right obj.formatVal(cell)];
                                right = [deblank(right) '] '];
                            end
                        end
                    end
                    
                    right = [deblank(right) ' }'];
                elseif ~isscalar(value) && ~isa(value,'char')                    
                    dims = size(value);
                    if ndims(value) > 2 || max(dims) > 4
                        right = [right '['];
                        for i=1:ndims(value)
                            right = [right num2str(dims(i))];
                            if i ~= ndims(value)
                                right = [right 'x'];
                            end
                        end
                        right = [right ' ' class(value) ']'];
                    elseif islogical(value) % boolean values
                        right = mat2str(value);
                    else
                       %right = mat2str(value,3); %This (DOES NOT) formats all 1D and 2D numeric arrays nicely!
                        dims = size(value);
                        
                        if dims(1)*dims(2) > 16 % don't print more than 16 elements
                            right = [right dims(1) 'x' dims(2) ' ' class(value) ']'];
                        else
                            right = [right '['];
                            for j=1:dims(1)
                                for i=1:dims(2)
                                    element = obj.formatVal(value(j,i));
                                    right = [right element];
                                    if i~=dims(2)
                                        right = [right ' '];
                                    end
                                end
                                if j~= dims(1)
                                    right = [right '; '];
                                end
                            end
                            right = [right ']'];
                        end
                       
                    end

                else %scalar OR a string 
                    if size(value,1) > 1
                        dims = size(value);
                        right = ['[' right num2str(dims(1)) 'x' num2str(dims(2)) ' ' class(value) ']'];
                    else
                        right = [right obj.formatVal(value)];
                    end
                end
                    
                disp([left right]);
            end
            
            %construct/display a list of all inherited properties
            if ~argStruct.suppressInheritedProps
                inheritedProps = containers.Map({'dummyClassName'}, {{'dummyPropOne' 'dummyPropTwo'}});
                for prop=[mClass.Properties{:}]
                    if ismember(prop,argStruct.explicitExcludeList)
                        continue;
                    end
                    
                    if ~strcmp(prop.DefiningClass.Name,mClass.Name) && ~prop.Hidden %only show inherited, non-hidden props
                        if ~inheritedProps.isKey(prop.DefiningClass.Name)
                            inheritedProps(prop.DefiningClass.Name) = {prop.Name};
                        else
                            current = inheritedProps(prop.DefiningClass.Name);
                            inheritedProps(prop.DefiningClass.Name) = {current{:} prop.Name};
                        end
                    end
                end
                remove(inheritedProps,'dummyClassName');
                
                for super=[inheritedProps.keys]
                    if argStruct.explicitInheritanceDisplayEnable
                        disp([char(10) 'Inherited from <a href = "matlab:help ' super{1} '">' super{1} '</a>:']);
                    elseif argStruct.inheritanceGroupingEnable
                        disp(' ');
                    end
                    propNames = inheritedProps(super{1});
                    for i=1:length(propNames)
                        prop = propNames{i};
                        
                        if ismember(prop,argStruct.explicitExcludeList)
                            continue;
                        end
                        
                        disp([sprintf('%35s%2s',prop,': ') obj.formatVal(obj.(prop))]);
                    end
                end
            end
            
            disp([char(10) '<a href = "matlab:methods(''' mClass.Name ''')">Methods</a>, ' ...
                          '<a href = "matlab:events(''' mClass.Name ''')">Events</a>, ' ...
                          '<a href = "matlab:superclasses(''' mClass.Name ''')">Superclasses</a>']);
        end
        
        function val = formatVal(obj,input)
            val = '';

            if islogical(input)
                if input
                    val = [val sprintf('%s ','true')];
                else
                    val = [val sprintf('%s ','false')];
                end
            elseif isnumeric(input)
                if round(input) == input %print double as an integer
                    val = [val sprintf('%d',input)];
                elseif strcmp(class(input),'double') || strcmp(class(input),'float')
                    if input > 99999.99
                        val = [val sprintf('%.2e',input)];
                    elseif input < 9.9999
                        val = [val sprintf('%.4g',input)];
                    else
                        val = [val sprintf('%.2f',input)];
                    end
                else
                    val = mat2str(input,3);
                end
            elseif isa(input,'char')
                val = [val sprintf('%s ',input)];
            end
        end
        
        function ME = DException(obj,errorNamespace,errorName,errorMessage,varargin)
            %Streamlined creation of MException objects
            %   errorNamespace: [OPTIONAL - Default=<classNameShort>] A string describing 'namespace' of error, will appear before colon in Matlab error ID. Can be a full class name, but all package information will be stripped.
            %   errorName: A brief string, with no spaces, identifying error. Will appear after colon in Matlab error ID.
            %   errorMessage: A full string describing error to display to user. Can include sprintf tokens, e.g. %d, %g.
            %   varargin: If sprintf tokens are used in errorMessage, corresponding values are supplied as additional arguments.
            
            if isempty(errorNamespace)
                errorNamespace = obj.classNameShort;
            elseif ~isempty(strfind(errorNamespace,'.')) %Handle case where full classname is specified
                errorNamespace = obj.classNameShortStatic(errorNamespace);
            end
            
            ME = MException([errorNamespace ':' errorName],errorMessage,varargin{:});           
            
        end        
        
        function DError(obj,errorNamespace,errorName,errorMessage,varargin)
            %Streamlined generation of error, in recommended MException format
            %   errorNamespace: [OPTIONAL - Default=<classNameShort>] A string describing 'namespace' of error, will appear before colon in Matlab error ID. Can be a full class name, but all package information will be stripped.
            %   errorName: A brief string, with no spaces, identifying error. Will appear after colon in Matlab error ID.
            %   errorMessage: A full string describing error to display to user. Can include sprintf tokens, e.g. %d, %g.
            %   varargin: If sprintf tokens are used in errorMessage, corresponding values are supplied as additional arguments. 
            
            throw(obj.DException(errorNamespace,errorName,errorMessage,varargin{:}));                      
        end
            
    end
    
   %% STATIC METHODS
   
   %Class Data File mechanism
   
   methods (Static, Hidden)
       
       function ensureClassDataFileStatic(className,initValStruct) %#ok<INUSD>
           %Ensures that class data store exists for specified className (creating, if necessary)
           %    initValStruct: A struct specifying the class data 'variables' and their initial values
           %
           % NOTES (USAGE)
           %    * ensureClassData() OR ensureClassDataStatic() should be called once and only once in any class requiring a class data store
           %    * To implement a classData file store, generally either ensureClassData() is called from class constructor OR ensureClassDataStatic() is called from a static method
           % 
           % NOTES (DEV)
           %    * At moment, there is no check to prevent a double call to ensureClassData() -- this would required of the classData.mat variables on every call
           %    
           
           classDataFileName = getClassDataFileName(className);
           
           %Ensure class data file exists, and create if needed
           if ~exist(classDataFileName, 'file')
               if ~exist(fileparts(classDataFileName),'dir')
                   mkdir(fileparts(classDataFileName));
               end
               save(classDataFileName,'-struct','initValStruct');
           else
               %Ensure all specified fields exist -- if not, add them
               missingFields = setdiff(fieldnames(initValStruct),who('-file',classDataFileName));
               
               if ~isempty(missingFields)
                   tmp = struct();
                   for i=1:length(missingFields)
                       tmp.(missingFields{i}) = initValStruct.(missingFields{i});
                   end
                   save(classDataFileName,'-struct','tmp','-append');
               end
           end
       end
       
       
       function val = getClassDataVarStatic(className,varName,tfSearchSuperclasses)
           %Read classData variable, i.e. value stored in MAT file
           %maintained by class           
           % className: Name of class whose classData file will be read
           % varName: Name of variable
           % tfSearchSuperclasses (optional): If true (the default), this
           % method starts at className and searches up its inheritance
           % hierarchy, returning the first 'hit'. The search order is that
           % returned by the 'superclasses' method (apparently
           % depth-first). If false, only the classData file for className
           % is considered.
           %
           % If no matching classData var is found, an error is thrown.

           if nargin < 3, tfSearchSuperclasses = true; end
           val = lclClassDataVarHelper(className,varName,@nstedLoadVar,tfSearchSuperclasses);
           function v = nstedLoadVar(fn)
              tmp = load(fn,varName);
              v = tmp.(varName);
           end
       end
       
       function setClassDataVarStatic(className,varName,val,tfSearchSuperclasses)
           %Write classData variable, i.e. value stored in MAT file
           %maintained by class.
           % className: Name of class to whose classData file will be written
           % varName: Name of variable
           % val: Value to be set
           % tfSearchSuperclasses (optional): If true (the default), this
           % method starts at className and searches up its inheritance
           % tree, setting the first classData variable that matches
           % varName. The search order is that returned by the
           % 'superclasses' method (apparently depth-first). If false, this
           % method considers only the particular class className.
           %
           % If no matching classData var is found, an error is thrown.
           
           if nargin < 4, tfSearchSuperclasses = true; end
           tmp.(varName) = val;  %#ok<STRNU>
           lclClassDataVarHelper(className,varName,@nstedSaveVar,tfSearchSuperclasses);           
           function v = nstedSaveVar(fn)
                save(fn,'-struct','tmp','-append');
                v = [];
           end           
       end
   end        
   
   methods (Static, Hidden)
       function classNameShort = classNameShortStatic(className)          
           classNameParts = textscan(className,'%s','Delimiter','.');
           classNameShort = classNameParts{1}{end};
       end
       
       function classPrivatePath = classPrivatePathStatic(className)
           classPrivatePath = fullfile(fileparts(which(className)),'private');
       end
       
       function packagePrivatePath = packagePrivatePathStatic(className)
           mc = meta.class.fromName(className);
           containingpack = mc.ContainingPackage;
           if isempty(containingpack)
               packagePrivatePath = [];
           else
               p = fileparts(fileparts(which(className)));
               packagePrivatePath = fullfile(p,'private');
           end           
       end
       
       function classDataFileName = classDataFileNameStatic(className)
           classDataFileName = [most.DClass.classPrivatePath(className) '_classData.mat'];

       end
       
   end
   
   methods (Static, Hidden)        
        
        function pvArgMap = extractPropValArgMap(argList,validProps, mandatoryProps)
            %Utility method for subclasses to convert a method's prop-val pair arguments into a Map for further use
            
            if nargin < 3 || isempty(mandatoryProps)
               mandatoryProps = {}; 
            end
            
            %TMW: This is workaround for lack of shorthand for 'this' class
            pvargs =  feval([mfilename('class') '.filterPropValArgs'],argList,validProps, mandatoryProps);
            
            if isempty(pvargs)
                pvArgMap = containers.Map();
            else
                pvArgMap = containers.Map(pvargs(1:2:end),pvargs(2:2:end));
            end                        
            
        end

        
        
        function [filteredPropValArgs,otherPropValArgs] = filterPropValArgs(argList,validProps,mandatoryProps)
            %Method for subclasses to filter property-value pairs from supplied argList of property-value pairs
            
            %TODO: Eliminate this method altogether -- should just leave as a utility
            
            try 
                if nargin > 2
                    [filteredPropValArgs,otherPropValArgs] = most.util.filterPVArgs(argList,validProps, mandatoryProps);
                else
                    [filteredPropValArgs,otherPropValArgs] = most.util.filterPVArgs(argList,validProps);
                end
            catch ME
                ME.throwAsCaller();
            end
            
        end
        
        function errorName = getErrorName(ME)
            errorName =  strtok(ME.identifier,':');               
        end
        
        function errorNamespace = getErrorNameSpace(ME)
            [~,errorNamespace] =  strtok(ME.identifier,':');
        end
    end

end

%% HELPER FUNCTIONS
function classDataFileName = getClassDataFileName(className) 
getClassPrivatePath = str2func([mfilename('class') '.classPrivatePathStatic']);
getClassNameShort = str2func([mfilename('class') '.classNameShortStatic']);

classDataFileName = fullfile(getClassPrivatePath(className), [getClassNameShort(className) '_classData.mat']);
end

function result = lclClassDataVarHelper(clsName,varName,fcn,tfSearchSuperclasses)

if tfSearchSuperclasses
    classlist = [{clsName};superclasses(clsName)];
else
    classlist = {clsName};
end

for c = 1:numel(classlist)
    fname = getClassDataFileName(classlist{c});
    if exist(fname,'file')==2
        s = whos('-file',fname,varName);
        if ~isempty(s)
            % the classData file exists, and it contains varName
            result = fcn(fname);
            return;
        end
    end
end

error('DClass:ClassDataVarNotFound',...
    'Class data var ''%s'' not found for class ''%s''.',...
    varName,clsName);
end





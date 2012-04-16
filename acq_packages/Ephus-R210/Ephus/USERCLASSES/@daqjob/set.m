% DAQJOB/SET - Set any non-read-only fields in a DAQJOB object array
%
%% SYNTAX
%  PROPERTIES = set(SIGNAL) - Gets all the fields in a DAQJOB object array
%  set(DAQJOB_OBJ, NAME, VALUE) - Sets the value of the NAME field in a DAQJOB object array to VALUE.
%  set(DAQJOB_OBJ, NAME, VALUE, ...) - Gets the value of each named field in a DAQJOB object array to the corresponding value.
%
%% NOTES
%   Added this general set method to @daqjob object, to be conformant with Matlab OOP conventions
%
%   Generally follow implementation, employed by previous objects, except for two differences. 
%   First, the readOnlyFields property is not used. 
%   Second, the set only is allowed for the 'settable' fields specified in this method.
%   
%   Unlike previous classes, this object presumes properties are not settable unless explicitly allowed in this method. 
%
%   The writeable field ideally would be declared/defined as a property in the @daqjob constructor method. But it's so much easier to put it and maintain it here. Oh for single file class definitions.
%
%% CHANGES
%   VI082708A Vijay Iyer 8/27/08 - Add masterSampleClock to settable property list
%   VI102308A Vijay Iyer 10/23/08 - Accomodate new triggerDestinations/triggerDestinationIndex properties
%   VI102408A Vijay Iyer 10/24/08 - Removed all lower() calls -- property names are now case-sensitive
%  
%% CREDITS
% Created 8/7/08 - Vijay Iyer
%
%% ******************************************************************
function varargout = set(this, varargin)
global daqjobGlobalStructure;

%Handle array case
if length(this) > 1
    for i = 1 : length(this)
        set(this(i), varargin{:});
    end
    return;
end
   
if isempty(varargin)
    varargout{1} = get(this);
    return;
end

if mod(length(varargin), 2) ~= 0
    error('An equal number of names and values must be supplied.');
end

propnames = fieldnames(daqjobGlobalStructure);
propnames = {propnames{:} 'triggerDestination'}; %VI102308A: Add 'triggerDestination' as a 'virtual' settable property (equiv. to 'dependent' property concept in Matlab's new MCOS scheme)
unrecognized = {};
recognized = {};
writeable = {'masterSampleClock' 'readErrorMode' 'sampleClockDestination'  'triggerDestination' 'triggerDestinations' 'triggerOrigin' 'triggerRepeats'}; %VI082708A
unwriteable = {};
    
%It's slower, but doing it in two passes allows better error handling/reporting.
for i = 1 : 2 : length(varargin)
    if ~ismember(varargin{i},propnames)
        unrecognized{length(unrecognized) + 1} = varargin{i};
    elseif ~ismember(varargin{i}, writeable) %TO022706D
        unwriteable{length(unwriteable) + 1} = varargin{i};
    else
        recognized{length(recognized) + 1} = propnames{find(strcmpi(propnames, varargin{i}))};
        values{length(recognized)} = varargin{i + 1};
    end
end

if ~isempty(unrecognized)
    s = 'Unrecognized field(s) - ';
    for i = 1 : length(unrecognized) - 1
        s = sprintf('%s''%s'', ', s, unrecognized{i});
    end
    s = sprintf('%s''%s''.', s, unrecognized{end});
    
    error(s);
end

if ~isempty(unwriteable)
    s = 'The following field(s) are either read-only or not directly settable- ';
    for i = 1 : length(unwriteable) - 1
        s = sprintf('%s''%s'', ', s, unwriteable{i});
    end
    s = sprintf('%s''%s''.', s, unwriteable{end});
    
    error(s);
end

%Handle property setting on a case-by-case basis
for i = 1 : length(recognized)
    typicalSet = true;
    switch recognized{i} %Handle type-checking and other property-specific set logic
        case 'masterSampleClock' 
            if ~isa(values{i},'nimex')
                error('Must set masterSampleClock to a NIMEX task object (@nimex)');
            end
        case 'triggerDestination' %VI102308A
            typicalSet = false;
            setTriggerDestination(this,values{i});                       
        case 'triggerDestinations' %VI102308A
            typicalSet = false;
            setTriggerDestinations(this,values{i});                      
    end
    if typicalSet
        daqjobGlobalStructure(this.ptr).(recognized{i}) = values{i};
    end          
end

return;
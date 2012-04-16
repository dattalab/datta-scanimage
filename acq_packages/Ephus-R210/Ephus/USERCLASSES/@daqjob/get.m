% DAQJOB/GET - GET properties of a DAQJOB object 
%
%% SYNTAX
%  PROPERTIES = get(DAQJOB_OBJ, NAME) - Gets vlaue of the NAME field(s) in a DAQJOB object
%  [PROPERTY1, PROPERTY2, ...] = get(DAQJOB_OBJ, NAME1, NAME2, ...) 
%% NOTES
%   Added this general get method to @daqjob object, to be conformant with Matlab OOP conventions
%
%   At present, this function only works on a single DAQJOB object, not object arrays
%
%% CHANGES
%  
%% CREDITS
% Created 10/26/08 - Vijay Iyer
%
%% ******************************************************************
function varargout = get(this, varargin)
global daqjobGlobalStructure;

if isempty(varargin)
    error('At least one property name must be supplied');
end

propnames = fieldnames(daqjobGlobalStructure);
propnames = {propnames{:} 'triggerDestination'}; %VI102308A: Add 'triggerDestination' as a 'virtual' gettable property (equiv. to 'dependent' property concept in Matlab's new MCOS scheme)
unrecognized = {};
recognized = {};

%It's slower, but doing it in two passes allows better error handling/reporting.
for i = 1 : length(varargin)
    if ~ismember(varargin{i},propnames)
        unrecognized{length(unrecognized) + 1} = varargin{i};
    else
        recognized{length(recognized) + 1} = propnames{find(strcmpi(propnames, varargin{i}))};
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

%Handle property setting on a case-by-case basis
varargout = cell(length(recognized),1);
for i = 1 : length(recognized)
    typicalGet = true;
    switch recognized{i} %Handle type-checking and other property-specific set logic
          case 'triggerDestination' 
            typicalGet = false;
            varargout{i} = getTriggerDestination(this);                       
        case 'triggerDestinations' 
            typicalGet = false;
            varargout{i} = getTriggerDestinations(this);                       
    end
    if typicalGet
        varargout{i} = daqjobGlobalStructure(this.ptr).(recognized{i});
    end          
end

return;
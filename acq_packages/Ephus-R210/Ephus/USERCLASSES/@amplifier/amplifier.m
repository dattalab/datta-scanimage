% AMPLIFIER - An object representing an electrophysiology amplifier.  This
% is the base class for specific amplifier classes (derived classes)
% including @axo_200B and @multi_Clamp, which inherit from the base
% class.
%
% SYNTAX
%  amp = amplifier - Gets an empty amplifier object.
%  amp = amplifier('fieldname',value) - initializes the object fields with
%        values specified.
%
% USAGE
%  This class wraps the internal working of the amplifiers, including
%  access to their current properties and methdos for updating them.  The
%  main fields of the amplifier structure are the input_gain and
%  output_gain, as well as the units. 
%
% STRUCTURE
%  All fields of the @amplifier object and its children (e.g. @axopatch_200B and @multi_clamp)
%  are readable through the case-insensitive `get` method. 
%
%  Fields:
%   input_gain- double; scaling factor to convert voltage input (in Volts)
%                to the units specified by input_units.
%   input_units-string; can be 'mV' (milliVolts) or 'pA' (picoAmps)
%   input_fcn-  fcn handle; specifies function that takes the data to be processed and
%                returns the data multiplied by the input_gain in the units specified 
%                by the input_units field.
%
%   output_gain- double; scaling factor to convert voltage output (in Volts)
%               to the units specified by output_units.
%   output_units-string; can be 'mV' (milliVolts) or 'pA' (picoAmps)
%   output_fcn- fcn handle; specifies function that takes the data to be processed and
%                returns the data multiplied by the output_gain in the units specified 
%                by the output_units field.
% Methods:
%   update-  runs amplifier specific update of the input_gain and
%   output_gain.  Need a new update method for each amplifier.
%
% NOTES
%   This class is designed to be used with the @AIMUX, @AOMUX, and @SIGNAL
%   classes for simplifying electrophysiology data acquisition software.
%   
%   The amplifier object and its derived classes (e.g. @axopatch_200B and @multi_clamp)
%   all use the private function getfieldnames to specify the fields used in the class.  
%   New derived classes can use the same get, set, constructors,  saveobj, and loadobj
%   methods as the derived classes already created.  You will want to chaneg the strings
%   in the methods to make the error messages more clear.
% 
% CHANGES
%  TO021505a - Modified to use a "pointer" system, like our other objects. -- Tim O'Connor 2/15/05
%  TO022505b - Decided to do something with 'internal', and make it only allow this class and subclasses to write to the corresponding fields. - Tim O'Connor 2/25/05
%  TO032406F - Use callbackManager instance to notify state listeners. -- Tim O'Connor 3/24/06
%  TO071906A - Case sensitivity. -- Tim O'Connor 7/19/06
%
% Created 1/12/05 - Tom Pologruto
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical
% Institute 2005

function obj = amplifier(varargin)
% obj is the object to be returned
global amplifierObjects;

% if the input is the same object, just spit it back out.
if nargin > 0 & isa(varargin{1},'amplifier')
    obj=varargin{1};
    varargin(1)=[]; % remove the first object from the varargin list.
else
    obj.ptr = length(amplifierObjects) + 1;
    obj.serialized = [];
    
    %TO022505b
    [fieldnames,default_vals,data_types, internal] = getfieldnames;
    % initialize a blank object
    for i=1:length(fieldnames)
        amplifierObjects(obj.ptr).(fieldnames{i})=default_vals{i};
    end
    
    %Some other nice fields to have. TO021005a - See also TO021505b
    amplifierObjects(obj.ptr).saveTime = -1;
    amplifierObjects(obj.ptr).loadTime = -1;
    amplifierObjects(obj.ptr).instantiationTime = clock;
    amplifierObjects(obj.ptr).name = sprintf('AMPLIFIER_%s', num2str(obj.ptr));
    amplifierObjects(obj.ptr).callbackManager = callbackmanager;%TO071906A
    addEvent(amplifierObjects(obj.ptr).callbackManager, 'amplifierStateUpdate');%TO032406F
    %amplifierObjects(obj.ptr).stateListeners = {};%Listen for state changes (gain, mode, v-hold, etc).%TO032406F
    amplifierObjects(obj.ptr).internal = internal;%TO022505b
end
  
while length(varargin) >= 2
    if isfield(amplifierObjects(obj.ptr),varargin{1})
        if isa(varargin{2},data_types{find(strcmp(fieldnames,varargin{1}))});  %Check data type
            amplifierObjects(obj.ptr).(varargin{1})=varargin{2};
            varargin=varargin(3:end);
        else
            error(['amplifier: ' varargin{1} ' must be of class ' data_types{find(strcmp(fieldnames,varargin{1}))} '.']);
        end
    else
        error(['amplifier: ' varargin{1} ' is not a field of the amplifier class.']);
    end
end
obj = class(obj,'amplifier');


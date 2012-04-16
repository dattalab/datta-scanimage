% Multi_Clamp - An object representing a Multi Clamp electrophysiology amplifier.  This
% is a derived class from the amplifier class.  The properties of the base
% class are placed in a field of the derived object called AMPLIFIER.
%
% SYNTAX
%  mc = multi_clamp - Gets an empty multiclamp object.
%  mc = multi_clamp('fieldname',value) - initializes the object fields with
%        values specified.
%
% USAGE
%  This class wraps the internal working of a multi_clamp, including
%  access to its current properties and methdos for updating them.  The
%  main fields of the amplifier structure are the input_gain and
%  output_gain, as well as the units. 
%
% STRUCTURE
%  All fields of the @multi_clamp object and its children (e.g. @Axoclamp_200B and @Multi_Clamp)
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
%            output_gain.  Inherited by all derived classes.
%
% NOTES:
%   This class is designed to be used with the @AIMUX, @AOMUX, and @SIGNAL
%   classes for simplifying electrophysiology data acquisition software.
%
% CHANGES:
%  TO062305A: Moved over to using "pointers". Moved over to work with the @AIMUX/@AOMUX architecture. -- Tim O'Connor 6/23/05
%  TO070605E: Vastly simplify this, while adding the ability to set superclass fields. See TO050605C. -- Tim O'Connor 7/6/05
%  TO123005A - Force subclass case-sensitivity to be Matlab 7.1 style (capitalized superclass field). -- Tim O'Connor 12/30/05'
%  TO102406D - Always duplicate the superclass for case-sensitivity issues, regardless of the version. -- Tim O'Connor 10/24/06
%
% Created 1/12/05 - Tom Pologruto
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical
% Institute 2005
function this = multi_clamp(varargin)
global multi_clampObjects;

if isempty(multi_clampObjects) | ~isfield(multi_clampObjects, 'connected')
    multi_clampObjects(1).connected = 0;
end

this.ptr = length(multi_clampObjects) + 1;

% if ~multi_clampObjects(1).connected
% %     eval('!C:\MATLAB6p1\work\Physiology\Axon\MultiClamp1\MC700.exe &');
% %     eval('!C:\Axon\MultiClamp 700B Commander\MC700B.exe &');
%     path = fileparts(which('multi_clamp'));
%     eval('!C:\Axon\MultiC~1\MC700B.exe &');
% %     pause(5);
%     eval(sprintf('!%sMCTeleClient_700B.exe &', [path '\']));
% %     eval('!C:\MATLAB6p1\work\Physiology\Axon\MultiClampWriter\MCTeleClient\Release\MCTeleClient.exe &');
%     multi_clampObjects(1).connected = 1;
% end

% mc is the object to be returned
% if the input is the same object, just spit it back out.
if nargin > 0 & isa(varargin{1},'multi_clamp')
    this=varargin{1};
    varargin(1)=[]; % remove the first object from the varargin list.
else
    this.serialized = [];
    amp=amplifier('name', ['MULTICLAMP_' num2str(this.ptr)]);% initialize base object
    [fieldnames,default_vals,data_types] = getfieldnames;
    % initialize a blank object
    for i=1:length(fieldnames)
        multi_clampObjects(this.ptr).(fieldnames{i})=default_vals{i};
    end
end

%TO123005A - Stick in the capitalized parent class, if Matlab won't be doing it (ver < 7.1). -- Tim O'Connor 12/30/05
%TO102406D
% matlabVersionInfo = ver('MATLAB');
% if str2num(matlabVersionInfo.Version) < 7.1
    this.AMPLIFIER = amp;
% end

this = class(this,'multi_clamp',amp);

while length(varargin) >= 2
    %TO070605E: Vastly simplify this, while adding the ability to set superclass fields. See TO050605C. -- Tim O'Connor 7/6/05
    set(this, varargin{1}, varargin{2});
    varargin=varargin(3:end);
%     if isfield(multi_clampObjects(this.ptr),varargin{1})
%         if isa(varargin{2}, data_types{find(strcmp(fieldnames, varargin{1}))});  %Check data type
%             multi_clampObjects(this.ptr).(varargin{1})=varargin{2};
%             varargin=varargin(3:end);
%         else
%             error(['multi_clamp: ' varargin{1} ' must be of class ' data_types{find(strcmp(fieldnames, varargin{1}))} '.']);
%         end
%     else
%         error(['multi_clamp: ' varargin{1} ' is not a field of the amplifier class.']);
%     end
end
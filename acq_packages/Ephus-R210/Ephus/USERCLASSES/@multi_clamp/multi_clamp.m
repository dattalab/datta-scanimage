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
%  TO012709C - Deprecate the old text file nonsense, and broadcast early for immediate detection. -- Tim O'Connor 1/27/09
%
% Created 1/12/05 - Tom Pologruto
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical
% Institute 2005
function this = multi_clamp(varargin)
global multi_clampObjects;

MultiClampTelegraph('broadcast');%TO012709C

% if isempty(multi_clampObjects) || ~isfield(multi_clampObjects, 'connected')
%     multi_clampObjects(1).connected = 0;
% end

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
if nargin > 0 && isa(varargin{1},'multi_clamp')
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

%TO012709C - Give some time, up front (when time's not critical), to get a response from MultiClamp Commander (which can take a few seconds).
filename=get(this,'text_file_location');
if isempty(filename)
    fprintf(1, 'Connecting to amplifier ''%s''...\n', get(this, 'name'));
    uComPortID = get(this, 'uComPortID');
    uChannelID = get(this, 'uChannelID');
    if uComPortID == -1
        uSerialNum = get(this, 'uSerialNum');
        %ID = [uSerialNum, uChannelID];
        ID = MultiClampTelegraph('get700BID', uint32(uSerialNum), uint32(uChannelID));
    else
        uAxoBusID = get(this, 'uAxoBusID');
        %ID = [uComPortID, uAxoBusID, uChannelID];
        ID = MultiClampTelegraph('get700AID', uint32(uComPortID), uint32(uAxoBusID), uint32(uChannelID));
    end
    found = 0;
    for i = 1 : 5 %This functions as roughly the number of seconds to wait to connect to a MultiClampCommander instance.
        amps = MultiClampTelegraph('getAllAmplifiers');
        if isempty(amps)
            MultiClampTelegraph('broadcast');
            fprintf(1, '\tWaiting...\n');
            pause(1);
        else
            for j = 1 : length(amps)
                if amps{j}.ID == ID
                    found = 1;
                    if uComPortID == -1
                        fprintf(1, 'Connected to 700B amplifier ''%s'':\n\tuSerialNum: %s\n\tuChannelID: %s\n\tID: %s\n\n', ...
                            get(this, 'name'), num2str(uSerialNum), num2str(uChannelID), num2str(ID));
                    else
                        fprintf(1, 'Connected to 700A amplifier ''%s'':\n\tuComPortID: %s\n\tuComPortID: %s\n\tuChannelID: %s\n\tID: %s\n\n', ...
                            get(this, 'name'), num2str(uComPortID), num2str(uComPortID), num2str(uChannelID), num2str(ID));
                    end
                    break;
                end
            end
        end
        if found == 1
            break;
        end
    end
    if found == 0
        fprintf(2, 'multi_clamp - Failed to find amplifier ''%s''.\n', get(this, 'name'));
        if uComPortID ~= -1
            fprintf(1, '                     No 700A amplifier found with uComPortID:%s, uAxoBusID:%s, uChannelID:%s\n', num2str(uComPortID), num2str(uAxoBusID), num2str(uChannelID));
            fprintf(1, '                      For a 700A, make sure that uComPortID, uAxoBusID, and uChannelID are correct.\n');
        else
            fprintf(1, '                     No 700B amplifier found with uSerialNum:%s, uChannelID:%s\n', num2str(uSerialNum), num2str(uChannelID));
            fprintf(1, '                      For a 700B, make sure that uSerialNum and uChannelID are correct.\n');
        end
        fprintf(1, '                      Ensure that MultiClamp Commander is running and the amplifier is connected to the computer.\n');
        fprintf(1, '                     In some cases, MultiClamp Commander may just be slow to respond, and future state updates may work correctly.\n\n');
    else
        MultiClampTelegraph('requestTelegraph', ID);%TO031109A - Make sure we request a telegraph here, just because.
    end
else
   error('The ''text_file_location'' field (related to Telegraph Client application) has been deprecated. Use ''uSerialNum'' and ''uChannelID'' for 700B devices, and ''uComPortID'' and ''uAxoBusID'' for 700A devices.');    
end

try
    update(this);%TO012709C
catch
    fprintf(2, 'Warning - Failed to update multi_clamp: %s', getLastErrorStack);
end
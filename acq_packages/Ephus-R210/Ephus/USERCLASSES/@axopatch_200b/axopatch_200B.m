% axopatch_200B - An object representing a Axopatch 200B electrophysiology amplifier.  This
% is a derived class from the amplifier class.  The properties of the base
% class are placed in a field of the derived object called AMPLIFIER.
%
% SYNTAX
%  ap = axopatch_200B - Gets an empty axopatch_200B object.
%  ap = axopatch_200B('fieldname',value) - initializes the object fields with
%        values specified.
%
% USAGE
%  This class wraps the internal working of a axopatch_200B, including
%  access to its current properties and methdos for updating them.  The
%  main fields of the amplifier structure are the input_gain and
%  output_gain, as well as the units. 
%
% STRUCTURE
%  All fields of the @axopatch_200B object and its children (e.g. @Axoclamp_200B and @Multi_Clamp)
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
%   gain_daq_board_id - the index of the DAQ board receiving the telegraphs
%   mode_daq_board_id - the index of the DAQ board receiving the telegraphs
%   v_hold_daq_board_id - the index of the DAQ board receiving the telegraphs
%   gain_channel - the index of the DAQ board receiving the gain telegraph
%   mode_channel - the index of the DAQ board receiving the mode telegraph
%   v_hold_channel - the index of the DAQ board receiving the 10Vm telegraph
%   v_clamp_input_factor - the hardware gain on the 200 B amplifier in the
%                          voltage clamp mode.
%   i_clamp_input_factor - the hardware gain on the 200 B amplifier in the
%                          current clamp mode
%   v_clamp_output_factor - the hardware gain on the 200 B amplifier in the
%                           voltage clamp mode.
%   i_clamp_output_factor - the hardware gain on the 200 B amplifier in the
%                           current clamp mode
%
% Methods:
%   update-  runs amplifier specific update of the input_gain and
%            output_gain.  Inherited by all derived classes.
%
% NOTES:
%   This class is designed to be used with the @AIMUX, @AOMUX, and @SIGNAL
%   classes for simplifying electrophysiology data acquisition software.
%
% CHANGES:
%  TO021005a - Modified to use a "pointer" system, like our other objects. -- Tim O'Connor 2/10/05
%  TO021005d - Allow it to work with a running AIMUX (massive design change, lots of new methods). -- Tim O'Connor 2/10/05
%  TO021105b - Allow telegraphs to come in on different boards. Why wasn't this done properly from the beginning (a recurring theme in these classes)?!? -- Tim O'Connor 2/10/05
%  TO050605C - Vastly simplify this, while adding the ability to set superclass fields. -- Tim O'Connor 5/6/05
%  TO123005A - Force subclass case-sensitivity to be Matlab 7.1 style (capitalized superclass field). -- Tim O'Connor 12/30/05
%
% Created 1/12/05 - Tom Pologruto
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical
% Institute 2005
function this = axopatch_200B(varargin)
global axopatch200bs;

% this is the thisect to be returned
% if the input is the same thisect, just spit it back out.
if nargin > 0 & isa(varargin{1},'axopatch_200B')
    this = varargin{1};
    set(this, varargin{2:end});%TO021005a
else
    amp=amplifier;    % initialize base thisect
    this.ptr = length(axopatch200bs) + 1;%TO021005a

    %To be used in saving. TO021005a
    this.serialized = [];

    %TO123005A - Stick in the capitalized parent class, if Matlab won't be doing it (ver < 7.1). -- Tim O'Connor 12/30/05
    matlabVersionInfo = ver('MATLAB');
    if str2num(matlabVersionInfo.Version) < 7.1
        this.AMPLIFIER = amp;
    end
    this = class(this,'axopatch_200B',amp);%Go ahead and make the class association now.

    [fieldnames,default_vals,data_types] = getfieldnames;
    % initialize a blank thisect
    for i=1:length(fieldnames)
        axopatch200bs(this.ptr).(fieldnames{i})=default_vals{i};%TO021005a
    end
    
    %Some other nice fields to have. TO021005a - See also TO021505b
    axopatch200bs(this.ptr).saveTime = -1;
    axopatch200bs(this.ptr).loadTime = -1;
    axopatch200bs(this.ptr).instantiationTime = clock;
    axopatch200bs(this.ptr).name = sprintf('AXOPATCH_200B_%s', num2str(this.ptr));
    axopatch200bs(this.ptr).aimux = [];
end
  
while length(varargin) >= 2
    %TO050605C - Vastly simplify this, while adding the ability to set superclass fields. -- Tim O'Connor 5/6/05
    set(this, varargin{1}, varargin{2});
    varargin=varargin(3:end);
%     if isfield(axopatch200bs, varargin{1})
%         if isa(varargin{2},data_types{find(strcmp(fieldnames,varargin{1}))});  %Check data type
%             axopatch200bs(this.ptr).(varargin{1})=varargin{2};%TO021005a
%             varargin=varargin(3:end);
%         else
%             error(['axopatch_200B: ' varargin{1} ' must be of class ' data_types{find(strcmp(fieldnames,varargin{1}))} '.']);
%         end
%     else
%         error(['axopatch_200B: ' varargin{1} ' is not a field of the amplifier class.']);
%     end
end

return;
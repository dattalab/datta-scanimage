function [fieldnames,default_vals,data_types] = getfieldnames
% This is a private function to access the valide fieldnames for the
% axopatch_200B class.  The only updates that need to be made are to this list
% when changing the object fields.  The constructors automatically reflect
% these updates.
%
% OUTPUTS
% fieldnames - cell array of strings;  current fieldnames.
% default_vals - cell array; default values for constructor.
% data_types - cell array of strings; default classes of each field.
% internal - array of bools; 1 = not settable by user through set and get
%            methods.
%
% Field definitions:
%   gain_daq_board_id - the index of the DAQ board receiving the telegraphs
%   mode_daq_board_id - the index of the DAQ board receiving the telegraphs
%   v_hold_daq_board_id - the index of the DAQ board receiving the telegraphs
% gain_channel is the index of the DAQ board receiving the gain telegraph
% mode_channel is the index of the DAQ board receiving the mode telegraph
% v_hold_channel is the index of the DAQ board receiving the 10Vm telegraph
% v_clamp_input_factor is the hardware gain on the 200 B amplifier in the
% voltage clamp mode.
% i_clamp_input_factor is the hardware gain on the 200 B amplifier in the
% current clamp mode
% v_clamp_output_factor is the hardware gain on the 200 B amplifier in the
% voltage clamp mode.
% i_clamp_output_factor is the hardware gain on the 200 B amplifier in the
% current clamp mode
% aiobject is the DAQ object used for reading the telegraphs
% amplifier internal gain
% amplifier internal mode (possibly ...)
% boolean; is amplifier in a current clamp mode?
% amplifier internal v_hold (holding potential (voltage clamp) or holding current (current clamp)
% parent is the name of the base class
%
% CHANGES
%  TO021105b - Allow telegraphs to come in on different boards. Why wasn't this done properly from the beginning (a recurring theme in these classes)?!? -- Tim O'Connor 2/10/05
%  TO021505b - Had to add to the fieldnames, default_vals, data_types, and internal lists, because this whole design is retarded. -- Tim O'Connor 2/15/05
%  TO050505A - Take the 'beta' setting into account. -- Tim O'Connor 5/5/05
%  TOKS122305A - Fixed the i_clamp_ouput_factor (0.0005), i_clamp_input_factor (0.1) and v_clamp_input_factor (0.1). -- Tim O'Connor, Karel Svoboda 12/23/05
%
% NOTES
%  When is the 'internal' array ever used?!? The retardation continues... -- Tim O'Connor 2/15/05
%
% Created 1/??/05 - Tom Pologruto
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
    
fieldnames = {'gain_daq_board_id', 'mode_daq_board_id', 'v_hold_daq_board_id', 'gain_channel','mode_channel','v_hold_channel','gain','mode','current_clamp','v_hold','parent',...
    'i_clamp_input_factor','v_clamp_input_factor','i_clamp_output_factor','v_clamp_output_factor', 'saveTime', 'loadTime', 'instantiationTime', 'name', 'aimux', 'beta'};

% Default DAQ properties and objects setup...
daq_board_id_default=1;
gain_channel_default = 1;
mode_channel_default = 2;
v_hold_channel_default = 3;
matlab_version = version;
if str2num(matlab_version(1:3)) < 7
    parent='amplifier';
else
     parent='AMPLIFIER';
end
default_vals = {-1, -1, -1, gain_channel_default, mode_channel_default, v_hold_channel_default, ...
     1, 'V_CLAMP', 0, 0, parent,0.1, 0.1, 0.0005, 0.05, -1, -1, clock, 'unnamed', [], 1};
data_types = {'double', 'double', 'double','double','double','double','double','char','double','double','char','double','double','double','double', 'double', 'double', 'double', 'char', 'aimux', 'double'};
internal = [0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0];
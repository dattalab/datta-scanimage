function [fieldnames,default_vals,data_types, internal] = getfieldnames
% This is a private function to access the valide fieldnames for the
% amplifier class.  The only updates that need to be made are to this list
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
% CHANGES
%  TO021505b - Had to add to the fieldnames, default_vals, data_types, and internal lists, because this whole design is retarded. -- Tim O'Connor 2/15/05
%  TO022105a - Added inputChannels and outputChannels fields. -- Tim O'Connor 2/21/05
%  TO022505a - Added scaledOutputChannel and commandInputChannel fields. -- Tim O'Connor 2/25/05
%  TO022505b - Decided to do something with 'internal', and make it only allow this class and subclasses to write to the corresponding fields. - Tim O'Connor 2/25/05
%  TO032805a - Added scaledOutput/vCom board and channel IDs.
%  TO022706D - Optimization(s). Allow heavy debugging to be disabled with the `debug` field. -- Tim O'Connor 2/27/06
%
% NOTES
%  When is the 'internal' array ever used?!? The retardation continues... -- Tim O'Connor 2/15/05
%
% Created - Tom Pologruto ??/??/??
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004/2005

%TO032805a
fieldnames = {'input_gain','input_units','input_fcn','output_gain','output_units','output_fcn','tag', 'saveTime', 'loadTime', 'instantiationTime', ...
        'name', 'stateListeners', 'inputChannels', 'outputChannels', 'scaledOutputChannel', 'vCom', ...
        'vComBoardID', 'vComChannelID', 'scaledOutputBoardID', 'scaledOutputChannelID', 'outputChannels', 'modeString', 'debug'};
default_vals = {1, 'mV', @input_fcn, 1, 'mV', @output_fcn,'default_tag', -1, -1, -1, 'unnamed', {}, {}, {}, '', '', 1, 0, 1, 0, {}, 'INDETERMINATE', 0};
data_types = {'double','char','function_handle','double','char','function_handle','char', 'saveTime', 'loadTime', 'instantiationTime', 'char', 'aimux', 'cell', 'cell', ...
        'char', 'char', 'double', 'double', 'double', 'double', 'cell', 'char', 'double'};
internal = [1 1 1 1 1 1 0 1 1 1 0 0 1 1 1 1 0 0 0 0 1 1 0];
% internal = [0 1 1 0 1 1 0 0 0 0 0 0 0 0];

function data_out = input_fcn(data_in,amplifier_obj)
% This function serves as the template for the function handle specified in
% the amplifier class fields.  It is useful when using the @AIMUX class.

if isnumeric(data_in)
    data_out=get(amplifier_obj,'input_gain').*data_in;
else
    error('amplifier->input_fcn: data_in must be a numeric array');
end

function data_out = output_fcn(data_in,amplifier_obj)
% This function serves as the template for the function handle specified in
% the amplifier class fields.  It is useful when using the @SIGNAL class.

if isnumeric(data_in)
    data_out=get(amplifier_obj,'output_gain').*data_in;
else
    error('amplifier->output_fcn: data_in must be a numeric array');
end

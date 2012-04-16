%@dumbamp/dumbamp - An object representing a simple gain/offset amplifier 
% SYNTAX
%  amp = dumbamp - Gets an empty dumb amplifier object.
%  amp = dumbamp('fieldname',value) - initializes the object fields with
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
%   input_gain- double; scaling factor by which acquired data is multiplied.
%   input_offset- double; offset factor, which is added to acquired data.
%    Input data: y = input_gain * raw_data + input_offset
%   output_gain- double; scaling factor by which outbound data is multiplied.
%   output_offset- double; offset factor, which is added to outbound data.
%    Output data: y = output_gain * raw_data + output_offset
% NOTES:
%
% CHANGES:
%
% Created 1/12/05 - Tom Pologruto
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical
% Institute 2005
function this = dumbamp(varargin)
global globalDumbampObjects;

this.ptr = length(globalDumbampObjects) + 1;

globalDumbampObjects(this.ptr).input_gain = 1;
globalDumbampObjects(this.ptr).output_gain = 1;
globalDumbampObjects(this.ptr).input_offset = 0;
globalDumbampObjects(this.ptr).output_offset = 0;
globalDumbampObjects(this.ptr).inputBoardID = [];
globalDumbampObjects(this.ptr).outputBoardID = [];
globalDumbampObjects(this.ptr).inputChannelID = [];
globalDumbampObjects(this.ptr).outputChannelID = [];
globalDumbampObjects(this.ptr).inputName = ['dumbampInput' num2str(this.ptr)];
globalDumbampObjects(this.ptr).outputName = ['dumbampOutput' num2str(this.ptr)];
globalDumbampObjects(this.ptr).current_clamp = 1; %this causes output to display in volts

amp = amplifier('name', ['dumbamp_' num2str(this.ptr)]);
this.AMPLIFIER = amp;%Class case sensitivity change from Matlab 6.5 to 7.
this.serialized = [];

this = class(this, 'dumbamp', amp);

set(this, varargin{:});

end
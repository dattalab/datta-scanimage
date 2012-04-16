% @AMPLIFIER/getHeaderInfo - Creates a structure of information that should get stored into headers of any program using this object.
%
% SYNTAX
%  headerInfo = getHeaderInfo(AMPLIFIER)
%   AMPLIFIER - An @amplifier instance.
%   headerInfo - A structure with hardware specific information for this instance.
%
% USAGE
%
% NOTES
%  This method is only intended for use by subclasses. Calling from anywhere else will generate an error.
%  Subclasses must override this and augment the structure with their own specific information.
%
% CHANGES
%
% Created 12/2/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function headerInfo = getHeaderInfo(this)

%Make sure the call came from a subclass' method.
stackTraceStruct = dbstack;
fname = '';
if length(stackTraceStruct) > 1
    [path fname ext] = fileparts(stackTraceStruct(2).name);
end
if ~ismethod(this, fname)
    error('@AMPLIFIER/getHeaderInfo - This method is only allowed to be called by subclasses.');
end

headerInfo.input_gain = get(this, 'input_gain');
headerInfo.output_gain = get(this, 'output_gain');
headerInfo.input_units = get(this, 'input_units');
headerInfo.output_units = get(this, 'output_units');
headerInfo.mode = get(this, 'modeString');

return;
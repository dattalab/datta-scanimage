% @MULTI_CLAMP/getHeaderInfo - Creates a structure of information that should get stored into headers of any program using this object.
%
% SYNTAX
%  headerInfo = getHeaderInfo(AMPLIFIER)
%   AMPLIFIER - An @amplifier instance.
%   headerInfo - A structure with hardware specific information for this instance.
%
% USAGE
%
% NOTES
%
% CHANGES
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%
% Created 12/2/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function headerInfo = getHeaderInfo(this)

headerInfo = getHeaderInfo(this.AMPLIFIER);%TO122205A

headerInfo.v_clamp_input_factor = get(this, 'v_clamp_input_factor');
headerInfo.i_clamp_input_factor = get(this, 'i_clamp_input_factor');
headerInfo.v_clamp_output_factor = get(this, 'v_clamp_output_factor');
headerInfo.i_clamp_output_factor = get(this, 'i_clamp_output_factor');

return;
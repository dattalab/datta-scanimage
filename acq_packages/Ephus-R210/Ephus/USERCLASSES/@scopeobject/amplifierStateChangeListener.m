% SCOPEOBJECT/amplifierStateChangeListener - Function to be notified when an amplifier state changes.
%
% SYNTAX
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO022305d - Take the amplifier as an argument. -- Tim O'Connor 2/23/05
%
% Created 2/15/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function amplifierStateChangeListener(this, amplifier)
global scopeObjects;

set(this, 'yUnitsString', get(amplifier, 'input_units'));%TO022305d

return;
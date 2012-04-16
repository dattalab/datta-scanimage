% getFillFraction(SIGNAL) - Gets the 'symmetry' field for this SIGNAL object.
%
% SYNTAX
%   fillFraction = getFillFraction(SIGNAL)
%       SIGNAL - The signal object.
%       fillFraction - A number between 0 and 1, representing the ScanImage-style fill-fraction.
%
% MATH
%  symmetry = (2 * fillFraction) - 1
%  fillFraction = (symmetry + 1) / 2
%
%  Such that a symmetry of 1 results in a fillFraction of 1 and a symmetry of -1 results in a fillFraction of 0.
%
% Translates from the concept of symmetry into the concept of a fill-fraction.
%
% Created: Timothy O'Connor 11/03/04 
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function fillFraction = getFillFraction(this)

fillFraction = (get(this, 'Symmetry') + 1) / 2;

return;
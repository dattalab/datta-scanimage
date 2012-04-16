% setFillFraction(SIGNAL, fillFraction) - Sets the 'symmetry' field for this SIGNAL object.
%
% SYNTAX
%   setFillFraction(SIGNAL, fillFraction)
%       SIGNAL - The signal object.
%       fillFraction - A number between 0 and 1, representing the ScanImage-style fill-fraction.
%
% MATH
%  fillFraction = (symmetry + 1) / 2
%  symmetry = (2 * fillFraction) - 1
%
%  Such that a fillFraction of 1 results in a symmetry of 1 and a fillFraction of 0 results in a symmetry of -1.
%
% Translates from the concept of a fill-fraction into the concept of symmetry.
%
% Created: Timothy O'Connor 11/03/04 
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function setFillFraction(this, fillFraction)

if fillFraction > 1 | fillFraction < 0
    error('FillFraction out of bounds (0-1): %s', num2str(fillFraction));
end

set(this, 'Symmetry', (2 * fillFraction) - 1);

return;
% square(SIGNAL, amplitude, offset, delay, width) - Parameterizes this SIGNAL object as train of square pulses.
% square(SIGNAL, amplitude, offset, delay, width, repetitions)
%
% See signalobject/squarePulseTrain for details.
%
% CHANGES:
%   Tim O'Connor 2/3/05 TO020305b: Added optional parameter, repetitions, to set a fixed number of pulses.
%
% Created: Timothy O'Connor 1/24/05
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function square(this, amplitude, offset, phi, width, spacing, varargin)

if isempty(varargin)
    squarePulseTrain(this, amplitude, offset, phi, width, spacing);
else
    squarePulseTrain(this, amplitude, offset, phi, width, spacing, varargin{:});
end

return;
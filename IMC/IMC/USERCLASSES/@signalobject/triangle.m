% triangle(SIGNAL, amplitude, offset, frequency, phi) - Parameterizes this SIGNAL object as a triangle wave.
%
% SYNTAX
%   triangle(SIGNAL, amplitude, offset, frequency, phi)
%       SIGNAL - The signal object.
%       amplitude - The amplitude (in arbitrary units) of this analytic signal.
%       offset - The offset (in amplitude space) of this analytic signal, relative to the origin.
%       phi - The offset (in time space) of this analytic signal, relative to the origin.
%
% Created: Timothy O'Connor 11/03/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function triangle(this, amplitude, offset, frequency, phi)
global signalobjects;

if frequency < 0
    error('Negative frequencies are not allowed: %s', num2str(frequency));
end

pointer = indexOf(this);

signalobjects(pointer).type = 'Analytic';
signalobjects(pointer).periodic = 1;
signalobjects(pointer).waveform = 'triangle';
setDefaultsByType(this);

signalobjects(pointer).amplitude = amplitude;
signalobjects(pointer).offset = offset;
signalobjects(pointer).frequency = frequency;
signalobjects(pointer).phi = phi;

return;
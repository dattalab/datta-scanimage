% cos(SIGNAL, amplitude, offset, frequency, phi) - Parameterizes this SIGNAL object as a cosine wave.
%
% SYNTAX
%   cos(SIGNAL, amplitude, offset, frequency, phi)
%       SIGNAL - The signal object.
%       amplitude - The amplitude (in arbitrary units) of this analytic signal.
%       offset - The offset (in amplitude space) of this analytic signal, relative to the origin.
%       phi - The offset (in time space) of this analytic signal, relative to the origin.
%
% Created: Timothy O'Connor 11/03/04 
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function cos(this, amplitude, offset, frequency, phi)
global signalobjects;

if frequency < 0
    error('Negative frequencies are not allowed: %s', num2str(frequency));
end

pointer = indexOf(this);

set(this, 'Type', 'Analytic', 'Periodic', 1, 'Waveform', 'cosine');
setDefaultsByType(this);

signalobjects(pointer).amplitude = amplitude;
signalobjects(pointer).offset = offset;
signalobjects(pointer).frequency = frequency;
signalobjects(pointer).phi = phi;

return;
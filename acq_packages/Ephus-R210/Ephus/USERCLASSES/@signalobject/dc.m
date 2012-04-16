% dc(SIGNAL, offset) - Parameterizes this SIGNAL object as a dc signal.
%
% SYNTAX
%   dc(SIGNAL, offset)
%       SIGNAL - The signal object.
%       offset - The offset of this analytic signal.
%
% Created: Timothy O'Connor 11/04/04 
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function dc(this, offset)
global signalobjects;

pointer = indexOf(this);

signalobjects(pointer).type = 'Analytic';
signalobjects(pointer).method = 'add';
setDefaultsByType(this);

signalobjects(pointer).waveform = 'square';
signalobjects(pointer).periodic = 1;
signalobjects(pointer).amplitude = 0;
signalobjects(pointer).offset = offset;
signalobjects(pointer).frequency = 0;
signalobjects(pointer).repeatable = 1;
signalobjects(pointer).length = -1;

return;
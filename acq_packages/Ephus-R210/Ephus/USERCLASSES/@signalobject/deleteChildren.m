% deleteChildren(SIGNAL) - Destroys all children of this signal.
%
% SYNTAX
%   sin(SIGNAL, amplitude, offset, frequency, phi)
%       SIGNAL - The signal object.
%       amplitude - The amplitude (in arbitrary units) of this analytic signal.
%       offset - The offset (in amplitude space) of this analytic signal, relative to the origin.
%       phi - The offset (in time space) of this analytic signal, relative to the origin.
%
% Created: Timothy O'Connor 11/03/04 
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function deleteChildren(this)
global signalobjects;
% fprintf(1, '@signalobject/delete: this.ptr = %s\n%s\n', num2str(this.ptr), getStackTraceString);
pointer = indexOf(this);

if ~isempty(signalobjects(pointer).children)
    delete(signalobjects(pointer).children);
end

return;
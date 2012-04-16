% recursive(SIGNAL, method, children, <phaseShifts>) - Parameterizes this SIGNAL as a composite signal.
%
% SYNTAX
%   recursive(SIGNAL, method, children, <phaseShifts>)
%       SIGNAL - The signal object.
%       method - The mathematical operation used to combine sub-signals.
%       children - An array of signal objects. Sub-signals, which will get combined, in a recursive signal.
%       signalPhaseShifts - The phase difference, in seconds, between individual children (relative to the origin). 
%           This argument is optional, and must be an array of numbers, of the same length as children.
%
% CHANGES
%  TO060208E - Check for attempts to nest a pulse within itself. -- Tim O'Connor 6/2/08
%
% Created: Timothy O'Connor 11/03/04 
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function recursive(this, method, children, varargin)
global signalobjects;

if ~isempty(varargin)
    if length(varargin) > 1
        error('Too many arguments.');
    elseif length(varargin{1}) ~= length(children)
        error('If the optional phaseShift argument is used, it must be of the same length as children.');
    end
end

for i = 1 : length(children)
    if this == children(i)
        error('A signal may not be a child of itself.');
    end
end

pointer = indexOf(this);
signalobjects(pointer).type = 'Recursive';
signalobjects(pointer).method = method;
setDefaultsByType(this);

signalobjects(pointer).children = children;

if ~isempty(varargin)
    signalobjects(pointer).signalPhaseShift = varargin{1};
else
    signalobjects(pointer).signalPhaseShift = zeros(size(children));
end

return;
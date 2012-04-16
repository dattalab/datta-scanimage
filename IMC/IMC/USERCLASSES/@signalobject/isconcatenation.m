% isconcatenation(SIGNAL) - Returns true if this signalobject is a concatenation of other signalobjects.
%
% SYNTAX
%   isconcatenation(SIGNAL)
%
% Created: Timothy O'Connor 6/28/06
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function isConcat = isconcatenation(this)
global signalobjects;

isConcat = 0;

pointer = indexOf(this);
if strcmpi(signalobjects(pointer).type, 'Recursive') & any(strcmpi(signalobjects(pointer).method, {'cat', 'concat', 'concatenate', 'append'}))
    isConcat = 1;
end

return;
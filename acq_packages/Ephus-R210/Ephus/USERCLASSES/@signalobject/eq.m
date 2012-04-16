% eq(SIGNAL1, SIGNAL2) - Determines shallow equivalency.
%
% SYNTAX
%   eq(SIGNAL1, SIGNAL2)
%
% Created: Timothy O'Connor 6/2/08
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function same = eq(sig1, sig2)
global signalobjects;

same = 0;
if ~strcmpi(class(sig2), 'signalobject')
    return;
end

if sig1.ptr == sig2.ptr
    same = 1;
    return;
end

if indexOf(sig1) == indexOf(sig2)
    same = 1;
    return;
end

return;
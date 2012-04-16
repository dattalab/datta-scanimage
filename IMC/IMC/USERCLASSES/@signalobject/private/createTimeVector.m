% SIGNAL/private/createTimeVector - Retrieve the time basis (domain) of this signal.
%
% SYNTAX
%  t = createTimeVector(SIGNAL, time) - Creates an array of time values (0 : 1 / sampleRate : time), 
%  with applied symmetry (sampling frequency distribution fluctuation).
%
%  t is a vector of the appropriate length for the current sampleRate and the requested time extent,
%  the values of t are evenly spaced if the symmetry of the signal is 0, otherwise, they compress
%  and stretch (sort of get chirped) according to the symmetry.
%
% Created 8/19/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function t = createTimeVector(this, time)
global signalobjects;

pointer = indexOf(this);

%Time vector.
t = (0 : 1 / signalobjects(pointer).sampleRate : time)';

if signalobjects(pointer).symmetry ~= 0
    %Apply symmetry
    chirpMask = (0 : 1 / length(t) : (1 - (1 / length(t))) * .5)';
    chirpMask(length(chirpMask) : length(t)) = ((1 - (1 / length(t))) * .5 : -1 / length(t) : 0)';
    
    if signalobjects(pointer).symmetry > 0
        t = t + (0 : 1 : length(t) - 1)' .* chirpMask;
    else
        t = t - (0 : 1 : length(t) - 1)' .* chirpMask;
    end
end

return
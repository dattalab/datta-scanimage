% distributional(SIGNAL, distribution, amplitude, offset, args...) - Parameterizes this SIGNAL object as a time distribution.
%
% SYNTAX
%   distributional(SIGNAL, distribution, amplitude, offset, args...)
%       SIGNAL - The signal object.
%       distribution - The name of a supported distribution.
%       amplitude - The amplitude (in arbitrary units) of this analytic signal.
%       offset - The offset (in amplitude space) of this analytic signal, relative to the origin.
%       args... - One or more distribution specific arguments.
%
%   Valid distributions (and their arguments) include:
%    gaussian - (mean, variance)
%    poisson - (lambda)
%    binomial - (N, P)
%    beta - (A, B)
%    chi-squared - (V)
%    non-central chi-squared - (V, delta)
%    discrete uniform - (N)
%    exponential - (mean)
%    f - (v1, v2)
%    non-central f - (nu1, nu2, delta)
%    gamma - (A, B)
%    geometric - (P)
%    lognormal - (mean, variance)
%    negative binomial - (R, P)
%    rayleigh - (B)
%    t - (V)
%    non-central t - (V, delta)
%    weibull - (A, B)
%    hypergeometric - (A, B)
%   See Matlab's documentation on "Probability Distributions" for more details.
%
% Created: Timothy O'Connor 11/03/04 
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function distributional(this, distribution, amplitude, offset, varargin)
global signalobjects;

if isempty(varargin)
    error('Distributional parameters must be supplied.');
end

pointer = indexOf(this);

signalobjects(pointer).type = 'Analytic';
signalobjects(pointer).distributional = 1;
signalobjects(pointer).distribution = distribution;
setDefaultsByType(this);

signalobjects(pointer).amplitude = amplitude;
signalobjects(pointer).offset = offset;

signalobjects(pointer).arg1 = varargin{1};
if length(varargin) > 1
    signalobjects(pointer).arg2 = varargin{2};
elseif length(varargin) > 2
    signalobjects(pointer).arg3 = varargin{3};
end

return;
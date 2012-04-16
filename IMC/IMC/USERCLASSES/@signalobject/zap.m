% zap - Parameterizes this SIGNAL object as a linearly modulated frequency chirp with a sinusoidal time-squared dependence.
%
% SYNTAX
%   zap(SIGNAL, amplitude, amplitudeOffset, rootFrequency, modSlope, modOffset)
%   zap(SIGNAL, amplitude, amplitudeOffset, rootFrequency, modSlope, modOffset, phi)
%   zap(SIGNAL, amplitude, amplitudeOffset, rootFrequency, modSlope, modOffset, phi, maskBegin, maskEnd)
%       SIGNAL - The signal object.
%       amplitude - The amplitude of the sine wave (A).
%       amplitudeOffset - The offset in the amplitude (offset).
%       rootFrequency - The root frequency, used in the equation (w_0).
%       modSlope - The slope of the frequency modulation (m).
%       modOffset - The offset of the frequency modulation (b).
%       phi - The phase shift of the sine wave (phi).
%       maskBegin - A convenience parameter to only expose a portion of the modulation, in seconds.
%       maskEnd - A convenience parameter to only expose a portion of the modulation, in seconds.
%
% NOTES
%  Equation - The frequency modulation is computed by the following equation:
%   f(t) = A * sin(((m * t + b) * w_0) .* t.^2 + phi) + offset
%
%  As can be seen, the frequency modulation is linear in time: ((m * t + b) * w_0)
%  Also note that the second time term is squared.
%
%  If the optional mask is used, a square pulse, with offset 0 and amplitude 1, will be multiplied
%  by the result of the above equation.
%
% Created: Timothy O'Connor 5/31/08
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function zap(this, amplitude, amplitudeOffset, rootFrequency, modSlope, modOffset, varargin)

phi = 0;
maskBegin = [];
maskEnd = [];
if length(varargin) >= 1
    phi = varargin{1};
end
if length(varargin) >= 3
    maskBegin = varargin{2};
    maskEnd = varargin{3};
end

if isempty(maskBegin)
	freq = this;
else
    freq = signalobject('sampleRate', get(this, 'sampleRate'));
    mask = signalobject('sampleRate', get(this, 'sampleRate'));
    squarePulseTrain(mask, 1, 0, maskBegin, maskEnd - maskBegin, maskEnd - maskBegin + 1, 1);
    set(this, 'deleteChildrenAutomatically', 1);
    recursive(this, 'multiply', [freq, mask]);
end

equation(freq, sprintf('%s * sin((%s * t + %s) * %s .* t.^2 + %s) + %s', ...
    num2str(amplitude), num2str(modSlope), num2str(modOffset), num2str(rootFrequency), num2str(phi), num2str(amplitudeOffset)));

return;
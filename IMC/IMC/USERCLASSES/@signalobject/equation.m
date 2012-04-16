% equation(SIGNAL, equation) - Parameterizes this SIGNAL object as an arbitrary equation, a function in time.
%
% SYNTAX
%   equation(SIGNAL, equationString)
%       SIGNAL - The signal object.
%       equationString - An string expression that acts on a variable, 't', which is time in seconds.
%                        Examples:
%                                  '2 * t'
%                                  't.^2'
%                                  'sin(1000 * t + 50)'
%
% Created: Timothy O'Connor 5/29/08
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function equation(this, equationString)

if endsWithIgnoreCase(equationString, ';')
    equationString = equationString(1:end-1);
end

set(this, 'Type', 'Analytic', 'equational', 1, 'equation', equationString);
setDefaultsByType(this);

return;
% literal(SIGNAL, data) - Parameterizes this SIGNAL object as a literal array of arbitrary data.
%
% SYNTAX
%   literal(SIGNAL, data)
%       SIGNAL - The signal object.
%       data - The literal data array.
%
% Created: Timothy O'Connor 5/29/08
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function literal(this, data)

set(this, 'Type', 'Literal', 'signal', data);
setDefaultsByType(this);

return;
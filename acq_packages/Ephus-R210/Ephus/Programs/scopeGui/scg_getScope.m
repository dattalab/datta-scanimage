% scg_getScope - Get the underlying scopeObject to interact with.
%
% SYNTAX
%
% USAGE
%
% NOTES:
%
% CHANGES:
%
% Created 2/4/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function scope = scg_getScope(hObject)

scope = getLocal(progmanager, hObject, 'scopeObject');

return;
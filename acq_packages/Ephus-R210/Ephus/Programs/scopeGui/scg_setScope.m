% scg_setScope - Set the underlying scopeObject to interact with.
%
% SYNTAX
%   scg_setScope(hObject, scope)
%       hObject - The handle to this scopeGui.
%       scope - The scopeObject to be set.
%
% USAGE
%
% NOTES:
%
% CHANGES:
%
% Created 2/4/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function scg_setScope(hObject, scope)

setLocal(progmanager, hObject, 'scopeObject', scope);

%Make the scope hideable, without deleting the underlying object.
f = get(scope, 'figure');
set(f, 'CloseRequestFcn', {@set, scope, 'Visible', 'Off'});

scg_updateGuiFromScope(hObject);

bindSetListener(scope, {@scg_updateGuiFromScope, hObject});
bindAddChannelListener(scope, {@scg_updateGuiFromScope, hObject});

return;
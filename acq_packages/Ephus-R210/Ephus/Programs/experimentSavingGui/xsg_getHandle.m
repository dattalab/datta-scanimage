% xsg_getHandle - Get the saving gui's handle, start the program, if necessary.
%
%  SYNTAX
%   hObject = xsg_getHandle
%
%  CHANGES
%
% Created 5/19/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function hObject = xsg_getHandle

p = program('xsg', 'xsg', 'experimentSavingGui');
if ~isstarted(progmanager, p)
    openprogram(progmanager, p);
end

hObject = getLocal(progmanager, p, 'hObject');

return;
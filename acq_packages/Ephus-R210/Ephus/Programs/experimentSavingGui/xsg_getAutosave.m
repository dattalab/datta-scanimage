% xsg_getAutosave - Get the status of the autosave feature.
%
%  SYNTAX
%   autosave = xsg_getAutosave
%
%  CHANGES
%
% Created 6/21/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function autosave = xsg_getAutosave

autosave = getLocal(progmanager, xsg_getHandle, 'autosave');

return;
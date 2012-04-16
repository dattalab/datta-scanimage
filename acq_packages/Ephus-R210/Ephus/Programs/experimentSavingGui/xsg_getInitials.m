% xsg_getInitials - Get the initials.
%
%  SYNTAX
%   initials = xsg_getInitials
%
%  CHANGES
%
% Created 5/19/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function initials = xsg_getInitials

initials = getLocal(progmanager, xsg_getHandle, 'initials');

return;
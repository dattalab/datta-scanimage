% xsg_getSetID - Get the set ID.
%
%  SYNTAX
%   setID = xsg_getSetID
%
%  CHANGES
%
% Created 5/19/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function setID = xsg_getSetID

setID = getLocal(progmanager, xsg_getHandle, 'setID');

return;
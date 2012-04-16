% xsg_getDirectory - Get the save directory.
%
%  SYNTAX
%   directory = xsg_getDirectory
%
%  CHANGES
%
% Created 5/19/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function directory = xsg_getDirectory

directory = getLocal(progmanager, xsg_getHandle, 'directory');

return;
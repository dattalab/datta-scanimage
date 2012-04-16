% xsg_getExperimentNumber - Get the experiment number.
%
%  SYNTAX
%   experimentNumber = xsg_getExperimentNumber
%
%  CHANGES
%
% Created 5/19/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function experimentNumber = xsg_getExperimentNumber

experimentNumber = getLocal(progmanager, xsg_getHandle, 'experimentNumber');

return;
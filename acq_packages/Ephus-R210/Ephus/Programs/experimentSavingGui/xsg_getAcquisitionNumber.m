% xsg_getAcquisitionNumber - Get the acquisition number.
%
%  SYNTAX
%   acquisitionNumber = xsg_getAcquisitionNumber
%
%  CHANGES
%
% Created 5/19/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function acquisitionNumber = xsg_getAcquisitionNumber

acquisitionNumber = getLocal(progmanager, xsg_getHandle, 'acquisitionNumber');

return;
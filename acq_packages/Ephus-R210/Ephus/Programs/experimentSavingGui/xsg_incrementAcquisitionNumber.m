% xsg_incrementAcquisitionNumber - Increment the acquisition number.
%
% SYNTAX
%  xsg_incrementAcquisitionNumber
%
% USAGE
%
% NOTES
%
% CHANGES
%  BSTO060910A - Allow non-numeric values in the experiment number, without choking this function. -- Ben Suter/Tim O'Connor 6/9/10
%
% Created 4/7/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function xsg_incrementAcquisitionNumber

acqNumber = str2num(xsg_getAcquisitionNumber) + 1;
if isempty(acqNumber) %BSTO060910A
    return;
end

if acqNumber > 9999
    xsg_incrementSetID;
    acqNumber = 0;
end

xsg_setAcquisitionNumber(acqNumber);

return;
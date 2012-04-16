% xsg_setAcquisitionNumber - Set the acquisitionNumber.
%
% SYNTAX
%  xsg_setAcquisitionNumber(acqNumber)
%  xsg_setAcquisitionNumber(hObject, acqNumber)
%   acqNumber - Any integer from 0 to 9999.
%
% USAGE
%
% NOTES
%  See TO020206C (creation of this function).
%
% CHANGES
%  TO040706H: Don't require the handle as an argument. -- Tim O'Connor 4/7/06
%
% Created 2/2/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function xsg_setAcquisitionNumber(varargin)

if length(varargin) == 1
    hObject = xsg_getHandle;
    acqNumber = varargin{1};
else
    hObject = varargin{1};
    acqNumber = varargin{2};
end

if isnumeric(acqNumber)
    acqNumber = num2str(acqNumber);
end

if length(acqNumber) > 4
    acqNumber = acqNumber(1:4);
elseif length(acqNumber) == 1
    acqNumber = ['000' acqNumber];
elseif length(acqNumber) == 2
    acqNumber = ['00' acqNumber];
elseif length(acqNumber) == 3
    acqNumber = ['0' acqNumber];
end

for i = 1 : length(acqNumber)
    if isempty(str2num(acqNumber(i)))
        acqNumber(i) = '0';
    end
end

setLocal(progmanager, hObject, 'acquisitionNumber', acqNumber);

return;
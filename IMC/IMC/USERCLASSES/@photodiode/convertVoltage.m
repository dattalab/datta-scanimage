% photodiode/convertVoltage - Convert a voltage into a power, using this photodiode's scaling.
%
% SYNTAX
%  bfpPowerInMw = convertVoltage(this, voltage)
%  [bfpPowerInMw specimenPowerInMw] = convertVoltage(this, voltage)
%   this - The object instance.
%   voltage - The voltage to be converted (may be an array).
%   powerInMw - The corresponding back focal plane power, for the given voltage.
%   specimenPowerInMw - The corresponding specimen plane power, for the given voltage.
%
% USAGE
%
% STRUCTURE
%
% NOTES
%
% CHANGES
%  TO030706C - Added `lensTransmission`. -- Tim O'Connor 3/7/06
%
% Created 8/2/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = convertVoltage(this, voltage)
global photodiodeObjects;


if isempty(photodiodeObjects(this.ptr).calibrationSlope) || isempty(photodiodeObjects(this.ptr).calibrationOffset)
    errordlg(sprintf('Photodiode ''%s'' is not calibrated, voltage to power conversions are impossible.', photodiodeObjects(this.ptr).name));
    warning('Photodiode ''%s'' is not calibrated, voltage to power conversions are impossible.', photodiodeObjects(this.ptr).name);
    varargout{1} = 0;
    if nargout == 2
        varargout{2} = 0;
    end
    return;
end

powerInMw = photodiodeObjects(this.ptr).calibrationSlope * voltage + photodiodeObjects(this.ptr).calibrationOffset;
varargout{1} = powerInMw;%TO030706C

%TO030706C
if nargout == 2
    specimenPowerInMw = photodiodeObjects(this.ptr).lensTransmission * powerInMw / 100;
    varargout{2} = specimenPowerInMw;
end

return;
% photodiode/clearCalibration - Remove all calibration points.
%
% SYNTAX
%  clearCalibration(this)
%   this - The object instance.
%
% USAGE
%
% STRUCTURE
%
% NOTES
%
% CHANGES
%
% Created 8/3/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function clearCalibration(this)
global photodiodeObjects;

if isempty(photodiodeObjects(this.ptr).calibrationUser)
    error('A user name must be specified for a calibration to be changed.');
end

photodiodeObjects(this.ptr).calibrationPowers = [];
photodiodeObjects(this.ptr).calibrationVoltages = [];
photodiodeObjects(this.ptr).calibrationOffset = [];
photodiodeObjects(this.ptr).calibrationSlope = [];
photodiodeObjects(this.ptr).calibrationDate = clock;

return;
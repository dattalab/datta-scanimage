% scanner/microns2Normalized - Convert micron values into normalized coordinates.
%
% SYNTAX
%  normalizedCoordinates = microns2Normalized(INSTANCE, micronCoordinates)
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 3/16/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function normalized = microns2Normalized(this, microns)
global scannerObjectsGlobal;

if size(microns, 1) > size(microns, 2)
    normalized = microns ./ [scannerObjectsGlobal(this.ptr).horizontalMicrons, scannerObjectsGlobal(this.ptr).verticalMicrons];
else
    normalized = microns ./ [scannerObjectsGlobal(this.ptr).horizontalMicrons, scannerObjectsGlobal(this.ptr).verticalMicrons]';
end

return;
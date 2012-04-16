% scanner/normalized2Microns - Convert micron values into normalized coordinates.
%
% SYNTAX
%  micronCoordinates = normalized2Microns(INSTANCE, normalizedCoordinates)
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 3/16/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function microns = normalized2Microns(this, normalized)
global scannerObjectsGlobal;

if size(microns, 1) > size(microns, 2)
    microns = normalized .* [scannerObjectsGlobal(this.ptr).horizontalMicrons, scannerObjectsGlobal(this.ptr).verticalMicrons];
else
    microns = normalized .* [scannerObjectsGlobal(this.ptr).horizontalMicrons, scannerObjectsGlobal(this.ptr).verticalMicrons]';
end

return;
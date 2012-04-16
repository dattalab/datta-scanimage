% photodiode/loadobj - The Matlab function required for loading the object.
%
% SYNTAX
%
% USAGE
%
% STRUCTURE
%
% NOTES
%
% CHANGES
%
% Created 8/2/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = loadobj(this)
global photodiodeObjects;

if this.ptr == -1
    this.ptr = length(photodiodeObjects) + 1;
end

this.serialized.lastLoadTime = clock;
photodiodeObjects(this.ptr) = this.serialized;
this.serialized = [];

return;
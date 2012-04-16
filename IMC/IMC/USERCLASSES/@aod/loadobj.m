% aod/loadobj - The Matlab function required for loading the object.
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
% Created 3/16/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function this = loadobj(this)
global isometAodObjects;

if this.ptr == -1
    this.ptr = length(isometAodObjects) + 1;
end

this.serialized.lastLoadTime = clock;
isometAodObjects(this.ptr) = this.serialized;
this.serialized = [];

return;
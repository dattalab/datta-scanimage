% ttlObject/saveobj - The Matlab function required for saving the object.
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
% Created 8/4/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = saveobj(this)
global ttlObjects;

ttlObjects(this.ptr).lastSaveTime = clock;
this.serialized = ttlObjects(this.ptr);
this.ptr = -1;

return;
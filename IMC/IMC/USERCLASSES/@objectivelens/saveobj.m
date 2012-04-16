% photodiode/saveobj - The Matlab function required for saving the object.
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
function this = saveobj(this)
global photodiodeObjects;

photodiodeObjects(this.ptr).lastSaveTime = clock;
this.serialized = photodiodeObjects(this.ptr);
this.ptr = -1;

return;
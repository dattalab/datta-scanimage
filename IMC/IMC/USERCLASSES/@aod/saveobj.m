% aod/saveobj - The Matlab function required for saving the object.
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
function this = saveobj(this)
global isometAodObjects;

isometAodObjects(this.ptr).lastSaveTime = clock;
this.serialized = isometAodObjects(this.ptr);
this.serialized.horizontalSerialObj = [];
this.serialized.verticalSerialObj = [];
this.ptr = -1;

return;
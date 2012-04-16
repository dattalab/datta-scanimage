% photodiode/getStruct - Get a structure representation of this photodiode instance.
%
% SYNTAX
%  pdiodeStruct = getStruct(pdiode)
%   pdiode - A @photodiode instance.
%   pdiodeStruct - A structure representing the current state of pdiode.
%
% USAGE
%
% STRUCTURE
%
% NOTES
%  This is intended as only a temporary hack to allow saving/loading of photodiode objects to get the mapper functionally complete.
%
% CHANGES
%
% SEEALSO
%  @photodiode/setStruct
%
% Created 3/8/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function thisStruct = getStruct(this)
global photodiodeObjects;

thisStruct = photodiodeObjects(this.ptr);

return;
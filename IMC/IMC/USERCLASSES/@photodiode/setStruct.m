% photodiode/setStruct - Recover a photodiode instance state from the given structure and apply it to this instance.
%
% SYNTAX
%  getStruct(pdiode, pdiodeStruct)
%   pdiode - A @photodiode instance.
%   pdiodeStruct - A structure representing the state of a pdiode.
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
%  @photodiode/getStruct
%
% Created 3/8/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function thisStruct = setStruct(this, thisStruct)
global photodiodeObjects;

photodiodeObjects(this.ptr) = thisStruct;

return;
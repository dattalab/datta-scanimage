% SIGNAL/toInternalStructure - Converts this object into the internal structure, for debugging use only.
%
% SYNTAX
%  strct = toInternalStructure(SIGNAL) - Strip out the hidden class structure and return it.
%
% NOTES
%
% CHANGES
%  See also @signalobject/getPointer.m
%
% Created - Tim O'Connor 3/3/10
% Copyright - Northwestern University/Howard Hughes Medical Institute 2010
function strct = toInternalStructure(this)

strct.ptr = this.ptr;
strct.serialized = this.serialized;

return;
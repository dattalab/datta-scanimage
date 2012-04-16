% SIGNAL/getPointer - Returns the internal object pointer, for debugging use only.
%
% SYNTAX
%  [pointer, ptr] = getPointer(SIGNAL)
%   SIGNAL - The @signalObject instance to be probed.
%   pointer - The index into the `global signalobjects` array.
%   ptr - The internal class pointer, used to do a table look-up for pointer.
%
% NOTES
%  This function will not throw an error if the pointer can not be indexed, it will instead
%  print an error message and return [] in place of pointer.
%
% CHANGES
%  See also @signalobject/toInternalStructure.m
%
% Created - Tim O'Connor 3/3/10
% Copyright - Northwestern University/Howard Hughes Medical Institute 2010
function [pointer, ptr] = getPointer(this)

ptr = this.ptr;
try
    pointer = indexOf(this);
catch
    pointer = [];
    fprintf(2, 'Failed to convert ptr to pointer:\n%s\n', getLastErrorStack);
end

return;
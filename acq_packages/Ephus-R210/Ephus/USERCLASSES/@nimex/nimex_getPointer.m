% @nimex/nimex_getPointer - Return the C-level pointer to the underlying NIMEX structure.
% 
% SYNTAX
%  p = nimex_getPointer(nimextask)
%   nimextask - An instance of the nimex class.
%   p - The memory address of the underlying C structure.
%  
% NOTES
%  
% Created
%  Timothy O'Connor 10/15/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function p = nimex_getPointer(this)

p = this.NIMEX_TaskDefinition;

return;
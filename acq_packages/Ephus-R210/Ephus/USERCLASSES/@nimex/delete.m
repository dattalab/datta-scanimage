% @nimex/delete - Deletes all resources associated with a nimex instance.
% 
% SYNTAX
%  delete(nimextask, ...)
%   nimextask - An instance of the nimex class.
%  
% NOTES
%  Relies on nimex_delete.m
%  Convenience method, conforms to standard Matlab syntax.
%
% Created
%  Timothy O'Connor 4/1/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function delete(this)

nimex_delete(this);

return;
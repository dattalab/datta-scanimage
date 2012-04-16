% @handleWrapper/ishandle - A callthrough to a handle's `ishandle` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function result = ishandle(this)

result = ishandle(this.hObject);

return;
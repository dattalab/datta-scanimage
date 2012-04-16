% @handleWrapper/doselect - A callthrough to a handle's `doselect` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = doselect(this, varargin)

varargout = doselect(this.hObject, varargin{:});

return;
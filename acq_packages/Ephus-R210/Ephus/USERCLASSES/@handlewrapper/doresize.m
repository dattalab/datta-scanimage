% @handleWrapper/doresize - A callthrough to a handle's `doresize` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = doresize(this, varargin)

varargout = doresize(this.hObject, varargin{:});

return;
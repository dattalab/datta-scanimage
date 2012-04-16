% @handleWrapper/delete - A callthrough to a handle's `delete` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = delete(this, varargin)

varargout = delete(this.hObject, varargin{:});

return;
% @handleWrapper/get - A callthrough to a handle's `get` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = get(this, varargin)

varargout{1} = get(this.hObject, varargin{:});

return;
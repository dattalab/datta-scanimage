% @handleWrapper/select - A callthrough to a handle's `select` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = select(this, varargin)

varargout = select(this.hObject, varargin{:});

return;
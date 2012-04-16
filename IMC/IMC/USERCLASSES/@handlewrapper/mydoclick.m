% @handleWrapper/mydoclick - A callthrough to a handle's `mydoclick` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = mydoclick(this, varargin)

varargout = mydoclick(this.hObject, varargin{:});

return;
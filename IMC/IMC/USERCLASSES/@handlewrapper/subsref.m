% @handleWrapper/subsref - A callthrough to a handle's `subsref` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = subsref(this, varargin)

varargout = subsref(this.hObject, varargin{:});

return;
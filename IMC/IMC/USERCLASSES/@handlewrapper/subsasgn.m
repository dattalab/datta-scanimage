% @handleWrapper/subsasgn - A callthrough to a handle's `subsasgn` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = subsasgn(this, varargin)

varargout = subsasgn(this.hObject, varargin{:});

return;
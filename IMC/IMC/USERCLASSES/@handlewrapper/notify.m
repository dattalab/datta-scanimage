% @handleWrapper/notify - A callthrough to a handle's `notify` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = notify(this, varargin)

varargout = notify(this.hObject, varargin{:});

return;
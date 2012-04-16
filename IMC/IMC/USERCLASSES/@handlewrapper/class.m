% @handleWrapper/class - A callthrough to a handle's `class` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = class(this, varargin)

varargout{1} = class(this.hObject, varargin{:});

return;
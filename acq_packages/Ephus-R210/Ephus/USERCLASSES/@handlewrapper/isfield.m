% @handleWrapper/isfield - A callthrough to a handle's `isfield` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = isfield(this, varargin)

varargout = isfield(this.hObject, varargin{:});

return;
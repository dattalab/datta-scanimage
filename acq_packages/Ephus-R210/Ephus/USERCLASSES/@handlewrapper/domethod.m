% @handleWrapper/domethod - A callthrough to a handle's `domethod` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = domethod(this, varargin)

varargout = domethod(this.hObject, varargin{:});

return;
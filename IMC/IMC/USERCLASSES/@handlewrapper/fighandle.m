% @handleWrapper/fighandle - A callthrough to a handle's `fighandle` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = fighandle(this, varargin)

varargout = fighandle(this.hObject, varargin{:});

return;
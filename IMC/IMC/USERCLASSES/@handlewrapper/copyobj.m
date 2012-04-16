% @handleWrapper/copyobj - A callthrough to a handle's `copyobj` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = copyobj(this, varargin)

varargout = copyobj(this.hObject, varargin{:});

return;
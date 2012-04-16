% @handleWrapper/set - A callthrough to a handle's `set` method.
%
%  SYNTAX
%   See functions for graphics handles.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = set(this, varargin)

if nargout > 0
    varargout = set(this.hObject, varargin{:});
else
    set(this.hObject, varargin{:})
end

if strcmpi(get(this.hObject, 'Tag'), 'events')
    varargin{:}
    fprintf(1, '@handleWrapper/set: Tag=''events''\n%s', getStackTraceString);
end

return;
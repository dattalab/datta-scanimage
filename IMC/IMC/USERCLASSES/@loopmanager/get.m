% loopManager/get - Get loopManager properties.
%
% SYNTAX
%  get(lm, PROPERTY_NAME, ...)
%   lm - A loopManager in stance.
%   PROPERTY_NAME - The name of the property to be retrieved.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 6/9/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = get(this, varargin)
global loopManagers;

if isempty(varargin)
    varargout{1} = loopManagers(this.ptr);
elseif length(varargin) == 1
    if isempty(varargin{1})
        error('Unrecognized field: {} or []');
    end
    
    fnames = fieldnames(loopManagers(this.ptr));
    index = find(strcmpi(varargin{1}, fnames));
    if isempty(index)
        error('Unrecognized field: %s', varargin{1});
    end
    varargout{1} = loopManagers(this.ptr).(fnames{index(1)});
else
    fnames = fieldnames(loopManagers(this.ptr));
    for i = 1 : length(varargin)
        if isempty(varargin{i})
            error('Unrecognized field: {} or []');
        end
        
        index = find(strcmpi(varargin{i}, fnames));
        if isempty(index)
            error('Unrecognized field: %s', varargin{i});
        end
        
        varargout{1}.(fnames{index}) = loopManagers(this.ptr).(fnames{index(1)});
    end
end

return;
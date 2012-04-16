% loopManager/set - Set loopManager properties.
%
% SYNTAX
%  set(lm, PROPERTY_NAME, PROPERTY_VALUE, ...)
%   lm - A loopManager in stance.
%   PROPERTY_NAME - The name of the property to be set.
%   PROPERTY_VALUE - The new value of the property to be set.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 6/9/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = set(this, varargin)
global loopManagers;

if isempty(varargin)
    varargout{1} = get(this);
    return;
end

if mod(length(varargin), 2) ~= 0
    error('An even number of arguments (parameter-value pairs) must be supplied.');
end

fnames = fieldnames(loopManagers(this.ptr));
for i = 1 : 2 : length(varargin) - 1
    index = find(strcmpi(varargin{i}, fnames));
    if isempty(index)
        error('Unrecognized field: %s', varargin{i});
    end
    if ismember(lower(varargin{i}), lower(loopManagers(this.ptr).readOnly))
        error('Attempt to set read-only field: %s', varargin{i});
    end
    
    loopManagers(this.ptr).(fnames{index(1)}) = varargin{i + 1};
end

fireEvent(loopManagers(this.ptr).callbackManager, 'objectUpdate');

return;
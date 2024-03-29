% ttlObject/get - Query internal fields of the object.
%
% SYNTAX
%  PROPERTIES = get(ttlObject) - Gets all the fields in a ttlObject.
%  PROPERTY = get(ttlObject, NAME) - Gets the value of the NAME field in a ttlObject.
%  PROPERTIES = get(ttlObject, NAME, ...) - Gets the value of each named field in a ttlObject.
%                                       A cell array of names is permissible.
%
% Created 8/4/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = get(this, varargin)
global ttlObjects;

if isempty(varargin)
    varargout{1} = ttlObjects(this.ptr);
    return;
end

if length(varargin) == 1 & strcmpi(class(varargin{1}), 'cell')
    varargin = varargin{1};
end

if nargout > 0 & nargout < length(varargin) - 1
    warning('Number of outputs (%s) does not match requested number of inputs (%s).', num2str(nargout), num2str(length(varargin)));
end

fnames = fieldnames(ttlObjects);
fnamesLow = lower(fnames);
unrecognized = {};
recognized = {};
names = lower(varargin);

%It's slower, but doing it in two passes allows better error handling/reporting.
for i = 1 : length(names)
    if ~ismember(names{i}, fnamesLow)
        unrecognized{length(unrecognized) + 1} = varargin{i};
    else
        recognized{length(recognized) + 1} = fnames{find(strcmpi(fnames, varargin{i}))};
    end
end

if ~isempty(unrecognized)
    s = 'Unrecognized field(s) - ';
    for i = 1 : length(unrecognized) - 1
        s = sprintf('%s''%s'', ', s, unrecognized{i});
    end
    s = sprintf('%s''%s''.', s, unrecognized{end});
    
    error(s);
end

for i = 1 : length(recognized)
    varargout{i} = ttlObjects(this.ptr).(recognized{i});
end

return;
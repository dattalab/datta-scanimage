% photodiode/set - Set any non-read-only fields in the object.
%
% SYNTAX
%  PROPERTIES = set(photodiode) - Gets all the fields in a photodiode object.
%  set(photodiode, NAME, VALUE) - Sets the value of the NAME field in a photodiode object to VALUE.
%  set(photodiode, NAME, VALUE, ...) - Gets the value of each named field in a photodiode object to the corresponding value.
%
% Created 8/3/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = get(this, varargin)
global photodiodeObjects;

if isempty(varargin)
    varargout{1} = get(this);
    return;
end

if mod(length(varargin), 2) ~= 0
    error('An equal number of names and values must be supplied.');
end

fnames = fieldnames(photodiodeObjects);
fnamesLow = lower(fnames);
unrecognized = {};
recognized = {};
unwriteable = {};

%It's slower, but doing it in two passes allows better error handling/reporting.
for i = 1 : 2 : length(varargin)
    if ~ismember(lower(varargin{i}), fnamesLow)
        unrecognized{length(unrecognized) + 1} = varargin{i};
    elseif ismember(lower(varargin{i}), lower(photodiodeObjects(this.ptr).readOnlyFields))
        unwriteable{length(unwriteable) + 1} = varargin{i};
    else
        recognized{length(recognized) + 1} = fnames{find(strcmpi(fnames, varargin{i}))};
        values{length(recognized)} = varargin{i + 1};
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

if ~isempty(unwriteable)
    s = 'Can not set read-only field(s) - ';
    for i = 1 : length(unwriteable) - 1
        s = sprintf('%s''%s'', ', s, unwriteable{i});
    end
    s = sprintf('%s''%s''.', s, unwriteable{end});
    
    error(s);
end

for i = 1 : length(recognized)
    photodiodeObjects(this.ptr).(recognized{i}) = values{i};
end

return;
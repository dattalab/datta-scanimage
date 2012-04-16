% SIGNAL/GET - Query internal fields of a SIGNAL object.
%
% SYNTAX
%  PROPERTIES = get(SIGNAL) - Gets all the fields in a SIGNAL object.
%  PROPERTY = get(SIGNAL_OBJ, NAME) - Gets the value of the NAME field in a SIGNAL object.
%  PROPERTIES = get(SIGNAL_OBJ, NAME, ...) - Gets the value of each named field in a SIGNAL object.
%                                            A cell array of names is permissible.
%
% CHANGES
%  Tim O'Connor 2/11/05 TO021105c: Allow arrays of objects to be queried at once.
%
% Created 8/18/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function varargout = get(this, varargin)
global signalobjects;

%TO021105c
if length(this) > 1
    properties = cell(length(this), 1);
    for i = 1 : length(this)
        properties{i} = get(this(i), varargin);
    end
    
    varargout{1} = properties;
    return;
end

pointer = indexOf(this);

if isempty(varargin)
    varargout{1} = signalobjects(pointer);
    return;
end

if length(varargin) == 1 & strcmpi(class(varargin{1}), 'cell')
    varargin = varargin{1};
end

if nargout > 0 & nargout < length(varargin) - 1
    warning('Number of outputs (%s) does not match requested number of inputs (%s).', num2str(nargout), num2str(length(varargin)));
end

fnames = fieldnames(signalobjects);
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
    varargout{i} = signalobjects(pointer).(recognized{i});
end

return;
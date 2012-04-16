% aod/get - Query internal fields of the object.
%
% SYNTAX
%  PROPERTIES = get(aod) - Gets all the fields in a aod object.
%  PROPERTY = get(aod, NAME) - Gets the value of the NAME field in a aod object.
%  PROPERTIES = get(aod, NAME, ...) - Gets the value of each named field in a aod object.
%                                       A cell array of names is permissible.
%
% Created 3/16/06 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function varargout = get(this, varargin)
global isometAodObjects;

if isempty(varargin)
    varargout{1} = isometAodObjects(this.ptr);
    superclassStruct = get(this.SCANNER);
    f = fieldnames(superclassStruct);
    for i = 1 : length(f)
        varargout{1}.(f{i}) = superclassStruct.(f{i});
    end
    return;
end

if length(varargin) == 1 & strcmpi(class(varargin{1}), 'cell')
    varargin = varargin{1};
end

if nargout > 0 & nargout < length(varargin) - 1
    warning('Number of outputs (%s) does not match requested number of inputs (%s).', num2str(nargout), num2str(length(varargin)));
end

fnames = fieldnames(isometAodObjects);
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
    try
        varargout = get(this.SCANNER, unrecognized{:});
    catch
        s = 'Unrecognized field(s) - ';
        for i = 1 : length(unrecognized) - 1
            s = sprintf('%s''%s'', ', s, unrecognized{i});
        end
        s = sprintf('%s''%s''.', s, unrecognized{end});
        error(s);
    end
end

for i = 1 : length(recognized)
    varargout{end + 1} = isometAodObjects(this.ptr).(recognized{i});
end

return;
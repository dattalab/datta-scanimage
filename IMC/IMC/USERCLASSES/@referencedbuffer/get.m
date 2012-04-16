% referencedBuffer/GET - Set any non-read-only fields in a SIGNAL object.
%
% SYNTAX
%  PROPERTIES = get(referencedBuffer) - Gets all the fields in a referencedBuffer object.
%  get(referencedBuffer, NAME) - Gets the value of the NAME field in a referencedBuffer object.
%  get(referencedBuffer, NAME, ...) - Gets the value of each named field in a referencedBuffer object.
%
% Created 11/24/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function varargout = get(this, varargin)
global referencedBuffers;

pointer = indexOf(this);
names = fieldnames(referencedBuffers(dm.ptr));

if isempty(varargin)
    for i = 1 : length(names)
        varargout{i, 1} = names{i};
        varargout{i, 2} = getField(this, names{i});
    end

    return;
end

for i = 1 : length(varargin)
    matches = find(strcmpi(varargin{i}, names) == 1);
    if any(matches)
        if length(matches) > 1
            %Choose the first hit, there should only be one anyway, though.
            matches = matches(1);
        end
        varargout{i} = referencedBuffers(dm.ptr).(names{matches});
    else
        error('Invalid property name: ''%s''', varargin{i});
    end
end

return;
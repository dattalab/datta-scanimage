% referencedBuffer/SET - Set any non-read-only fields in a SIGNAL object.
%
% SYNTAX
%  PROPERTIES = set(referencedBuffer) - Gets all the fields in a referencedBuffer object.
%  set(referencedBuffer, NAME, VALUE) - Sets the value of the NAME field in a referencedBuffer object to VALUE.
%  set(referencedBuffer, NAME, VALUE, ...) - Sets the value of each named field in a referencedBuffer object to the corresponding VALUE.
%
% Created 11/24/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function value = set(this, varargin)
global referencedBuffers;

pointer = indexOf(this);
names = fieldnames(referencedBuffers(dm.ptr));

if isempty(varargin)
    for i = 1 : length(names)
        value{i, 1} = names{i};
        value{i, 2} = getField(this, names{i});
    end

    return;
end

if any(strcmpi(varargin{1 : 2 : length(varargin)}), 'data')
    error('Buffered data may not be altered via the ''set'' method.');
end

for i = 1 : 2 : length(varargin)
    matches = find(strcmpi(varargin{i}, names) == 1);
    if any(matches)
        if length(matches) > 1
            %Choose the first hit, there should only be one anyway, though.
            matches = matches(1);
        end
        referencedBuffers(dm.ptr).(names{matches}) = varargin{i + 1};
    else
        error('Invalid property name: ''%s''', varargin{i});
    end
end

return;
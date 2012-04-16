% SIGNAL/loadobj - Retrieve a saved form of this object.
%
%  This function is for Matlab to call when loading objects from m-files. It is not
%  intended to be used at any other time or for any other purpose.
%
%  NOTE: Matlab will automatically iterate over and unpack all children, through this function.
%        A @signal object should never have itself as a decendant.
%
% CHANGES
%  TO111006A - Backwards compatibility: Make sure all fields exist (see TO020305d - noPadding), create it if it's missing in an older saved pulse. -- Tim O'Connor 11/10/06
%  TO060108F - Matlab doesn't properly serialize nested objects. Do it here. -- Tim O'Connor 6/1/08
%
% Created 10/22/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function this = loadobj(this, varargin)
global signalobjects;
% fprintf(1, '%s - @signalobject/loadobj\n', datestr(now));

if isempty(signalobjects)
    signalobjects(1).name = 'Master';
    signalobjects(1).signal = [];
end

if length(this) > 1
    for i = 1 : length(this)
        this(i) = loadobj(this(i));
    end
    return;
end

if isempty(this.serialized)
    fprintf(1, 'Warning: Found empty @signalobject - Loading ptr = %s\n         This is bad news, in case you weren''t sure.\n', num2str(this.ptr));
end

%TO060108F - This is now going to happen when recursing through children, so don't complain.
% if this.ptr ~= -1
%     warning('A signal object pointer value got saved, this shouldn''t happen. It''s no big deal though. I just thought you should know...');
% end

%Dance!
if isempty(signalobjects)
    signalobjects(1).name = 'Master';
    signalobjects(1).signal = [];
end
%TO060108F - Have to handle the case where the pointer has already been created (unpacking children).
if this.ptr == -1
    if isempty(signalobjects(1).signal)
        this.ptr = length(signalobjects) + 1;
        pointer = this.ptr;
    else
        this.ptr = max(signalobjects(1).signal(:, 1)) + 1;
        pointer = length(signalobjects) + 1;
    end
    signalobjects(1).signal(size(signalobjects(1).signal, 1) + 1, 1) = this.ptr;
    signalobjects(1).signal(size(signalobjects(1).signal, 1), 2) = pointer;
else
    pointer = indexOf(this);
end

%TO111006A - This is the time to introduce backwards compatibility.
if any(~ismember(fieldnames(signalobjects), fieldnames(this.serialized)))
    oldVersionFieldNames = fieldnames(this.serialized);
    for i = 1 : length(oldVersionFieldNames)
        signalobjects(pointer).(oldVersionFieldNames{i}) = this.serialized.(oldVersionFieldNames{i});
    end
else
    %Unpack the data.
    signalobjects(pointer) = this.serialized;
end

%Update timestamps.
signalobjects(pointer).loadTime = clock;

%TO060108F
if ~isempty(signalobjects(pointer).children)
    if isstruct(signalobjects(pointer).children)
        for i = 1 : length(signalobjects(pointer).children)
            %TO060108F - Convert a pure struct child into an @signalobject instance.
            kids(i) = signalobject;
            kids(i).serialized = signalobjects(pointer).children(i);
            kids(i) = loadobj(kids(i));
        end
        signalobjects(pointer).children = kids;
    end
end
% fprintf(1, 'class(signalobjects(pointer).children) = %s\n', class(signalobjects(pointer).children));
%Clean out the luggage.
this.serialized = [];
% fprintf(1, '@signalobject/loadobj: this.ptr=%s, pointer=%s, indexOf=%s, name=''%s''\n%s\n', num2str(this.ptr), num2str(pointer), num2str(indexOf(this)), signalobjects(pointer).name, getStackTraceString);

return;
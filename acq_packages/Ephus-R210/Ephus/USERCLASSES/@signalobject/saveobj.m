% SIGNAL/saveobj - Produce a saveable form of this object.
%
%  This function is for Matlab to call when saving objects to m-files. It is not
%  intended to be used at any other time or for any other purpose.
%
% CHANGES
%  TO060108F - Matlab doesn't properly serialize nested objects. Do it here. -- Tim O'Connor 6/1/08
%
% Created 10/22/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function this = saveobj(this, varargin)
global signalobjects;

if length(this) > 1
    for i = 1 : length(this)
        this(i) = saveobj(this(i));
    end
    return;
end

pointer = indexOf(this);

signalobjects(pointer).saveTime = clock;
this.serialized = signalobjects(pointer);
ptr = this.ptr;
this.ptr = -1;

%TO060108F - Save the children!
if isempty(varargin)
    if ~isempty(this.serialized.children)
        if strcmpi(class(this.serialized.children), 'signalobject')
            for i = 1 : length(this.serialized.children)
                kids(i) = saveobj(this.serialized.children(i), 'R');%'R' for recurse, and because it adds a splash of color to catch the eye.
            end
            this.serialized.children = kids;
        end
    end
else
    this = this.serialized;
    return;
end

if isempty(this.serialized)
    warning('@signalobject/saveobj: Saving %s->%s - Serialized struct is empty.\n', num2str(ptr), num2str(pointer));
    this
% else
%     fprintf(1, 'Saving %s->%s::%s\n', num2str(ptr), num2str(pointer), this.serialized.name);
end

return;
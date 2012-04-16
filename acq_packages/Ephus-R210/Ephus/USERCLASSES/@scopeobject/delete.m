% SCOPEOBJECT/delete - Clean up a scopeObject instance.
%
% SYNTAX
%  delete(SCOPEOBJECT)
%    SCOPEOBJECT - This object instance.
%
% USAGE
%
% NOTES:
%
% CHANGES:
%  TO050408A - Watch out for bad pointers. I don't know why this is happening (yet). -- Tim O'Connor 5/4/08
%  TO050508G - Support vectorized calls. -- Tim O'Connor 5/5/08
%  TO053008A - Return after iterating. -- Tim O'Connor 5/30/08
%
% Created 2/4/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function delete(varargin)
global scopeObjects;

if length(varargin) == 1
    this = varargin{1};
elseif length(varargin) == 3
    this = varargin{3};
end

%TO050508G
if length(this) > 1
    for i = 1 : length(this)
        delete(this(i));
    end
    return;%TO053008A
end

%TO050408A
if this.ptr > length(scopeObjects)
    warning('scopeObject/delete: pointer out of range - this.ptr=%s > %s', num2str(this.ptr), num2str(length(scopeObjects)));
    return;
elseif this.ptr < 1
    warning('scopeObject/delete: pointer out of range - this.ptr=%s', num2str(this.ptr));
    return;
end

if ~scopeObjects(this.ptr).deleted
    scopeObjects(this.ptr).name = [scopeObjects(this.ptr).name '-deleted'];
    % delete(get(scopeObjects(this.ptr).axes, 'Children'));
    % delete(scopeObjects(this.ptr).axes);
    delete(scopeObjects(this.ptr).figure);
    scopeObjects(this.ptr).bindings = {};
end

scopeObjects(this.ptr).deleted = 1;

return;
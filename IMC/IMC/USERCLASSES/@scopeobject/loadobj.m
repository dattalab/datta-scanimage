% SCOBEOBJECT/saveobj - Make this object saveable.
%
% SYNTAX
%  saveobj(SCOBEOBJECT)
%   SCOBEOBJECT - Object instance.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 3/4/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = loadobj(this)
global scopeObjects;

%Move handles around.
this.serialized.figure = scopeObjects(this.ptr).figure;
this.serialized.axes = scopeObjects(this.ptr).axes;
this.serialized.horizontalCenterLine = scopeObjects(this.ptr).horizontalCenterLine;
this.serialized.verticalCenterLine = scopeObjects(this.ptr).verticalCenterLine;
this.serialized.groundLine = scopeObjects(this.ptr).groundLine;

%Put the reference back into place.
scopeObjects(this.ptr) = this.serialized;
this.serialized = [];
scopeObjects(this.ptr).loadTime = clock;

%Pick up any changes between the constructor and the loaded data.
updateDisplayOptions(this);

return;
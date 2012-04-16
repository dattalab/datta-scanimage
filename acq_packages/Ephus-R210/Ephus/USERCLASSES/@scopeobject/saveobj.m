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
function this = saveobj(this)
global scopeObjects;

scopeObjects(this.ptr).saveTime = clock;
this.serialized = scopeObjects(this.ptr);

%Toss all graphics objects, which will get recreated on load.
this.serialized.figure = [];
this.serialized.axes = [];
this.serialized.horizontalCenterLine = [];
this.serialized.verticalCenterLine = [];
this.serialized.groundLine = [];

%This does not get saved/recovered.
scopeObjects(this.ptr).amplifier = [];

return;
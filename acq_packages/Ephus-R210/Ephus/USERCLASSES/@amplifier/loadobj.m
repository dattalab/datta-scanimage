%LOADOBJ - method for AMPLIFIER class
%  Calls the update methdo prior to loading.
%
% CHANGES
%
% Created Tim O'Connor 2/15/05
% Copyright Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = loadobj(this)
global amplifierObjects;

amplifierObjects(this.ptr) = this.serialized;
amplifierObjects(this.ptr).loadTime = clock;

return;
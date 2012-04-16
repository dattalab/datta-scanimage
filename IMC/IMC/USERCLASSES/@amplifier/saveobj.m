%SAVEOBJ - method for AMPLIFIER class
%  Calls the update methdo prior to saving.
%
% CHANGES
%
% Created Tim O'Connor 2/15/05
% Copyright Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = saveobj(this)
global amplifierObjects;

amplifierObjects(this.ptr).saveTime = clock;
this.serialized = axopatch200bs(this.ptr);
this.serialized.stateListeners = {};

return;
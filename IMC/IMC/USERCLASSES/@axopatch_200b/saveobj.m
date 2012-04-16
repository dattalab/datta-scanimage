%SAVEOBJ - method for axopatch_200B class
%  Calls the update methdo prior to saving.
%
% CHANGES
%   TO021005a - Modified to use a "pointer" system, like our other objects. Complete rewrite of function. -- Tim O'Connor 2/10/05
function this = saveobj(this)
global axopatch200bs;

axopatch200bs(this.ptr).saveTime = clock;
this.serialized = axopatch200bs(this.ptr);
this.serialized.aimux = [];%This shouldn't get saved as a field here.

return;
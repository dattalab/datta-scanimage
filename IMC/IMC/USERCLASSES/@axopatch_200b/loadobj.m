%LOADOBJ - method for axopatch_200B class
%  Calls the update methdo prior to loading.
%
% CHANGES
%   TO021005a - Modified to use a "pointer" system, like our other objects. Complete rewrite of function. -- Tim O'Connor 2/10/05
function this = loadobj(this)
global axopatch200bs;

axopatch200bs(this.ptr) = this.serialized;
axopatch200bs(this.ptr).loadTime = clock;

return;
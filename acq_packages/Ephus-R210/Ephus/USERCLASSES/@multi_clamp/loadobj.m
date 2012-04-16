% CHANGES
%  TO062305A: Moved over to using "pointers". Moved over to work with the @AIMUX/@AOMUX architecture. -- Tim O'Connor 6/23/05
%
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function out = loadobj(this)
% %LOADOBJ - method for axopatch_200B class
% %  Calls the update methdo prior to loading.
% out = update(mc_obj);
global multi_clampObjects;

multi_clampObjects(this.ptr) = this.serialized;
multi_clampObjects(this.ptr).loadTime = clock;

return;
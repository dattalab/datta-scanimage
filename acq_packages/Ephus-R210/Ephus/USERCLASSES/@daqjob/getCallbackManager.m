% @daqjob/getCallbackManager - Returns the internal @callbackManager instance.
% 
% SYNTAX
%  cbm = getCallbackManager(dq)
%   dq - The daqjob instance from which to retrieve the @callbackManager instance.
%   cbm - The internal @callbackManager instance.
%  
% NOTES
%  See TO072310A in shared_Start.m.
%
% CHANGES
%
% Created
%  Tim O'Connor 7/23/10
%  
% Copyright
%  Northwestern University/Howard Hughes Medical Institute 2010
function cbm = getCallbackManager(this)
global daqjobGlobalStructure;

cbm = daqjobGlobalStructure(this.ptr).callbackManager;

return;
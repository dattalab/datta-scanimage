%  - 
% 
% SYNTAX
%  
% NOTES
%
% CHANGES
%  
% Created
%  Timothy O'Connor 10/10/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function started = isStarted(this)
global daqjobGlobalStructure;

started = daqjobGlobalStructure(this.ptr).started;

return;
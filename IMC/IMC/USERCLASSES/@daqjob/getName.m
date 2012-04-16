%  - 
% 
% SYNTAX
%  
% NOTES
%
% CHANGES
%  
% Created
%  Vijay Iyer 12/25/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function name = getName(this)
global daqjobGlobalStructure;

name = daqjobGlobalStructure(this.ptr).name;

return;
%  - 
% 
% SYNTAX
%  
% NOTES
%
% CHANGES
%  
% Created
%  Timothy O'Connor 8/14/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function setTriggerRepeats(this, triggerRepeats)
global daqjobGlobalStructure;

daqjobGlobalStructure(this.ptr).triggerRepeats = triggerRepeats;

return;
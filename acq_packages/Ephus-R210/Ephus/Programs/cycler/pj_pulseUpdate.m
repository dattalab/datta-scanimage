% pj_pulseUpdate - Callback for updating the selected pulses when changed externally.
%
% SYNTAX
%  pj_pulseUpdate(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 11/30/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function pj_pulseUpdate(hObject)
% fprintf(1, '%s - pj_pulseUpdate\n%s', datestr(now), getStackTraceString);

%Just call `pj_pulseSetCreation` for now. That's slow, but will do the task, optimizing for just pulseUpdates can be done later. Tim O'Connor 11/30/07
% pj_pulseSetCreation(hObject);

return;
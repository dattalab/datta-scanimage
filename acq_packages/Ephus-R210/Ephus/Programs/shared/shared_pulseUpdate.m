% shared_pulseUpdate - Callback for updating the selected pulses when changed externally.
%
% SYNTAX
%  shared_pulseUpdate(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 11/30/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function shared_pulseUpdate(hObject)
% fprintf(1, '%s - ''%s''_pulseUpdate\n%s', datestr(now), getProgramName(progmanager, hObject), getStackTraceString);

%Just call `shared_pulseSetCreation` for now. That's slow, but will do the task, optimizing for just pulseUpdates can be done later. Tim O'Connor 11/30/07
shared_pulseSetCreation(hObject);

return;
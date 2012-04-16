% stim_pulseSetDeletion - Callback for updating the selected pulses when changed externally.
%
% SYNTAX
%  stim_pulseSetDeletion(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 2/24/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function stim_pulseSetDeletion(hObject)

%For now, just run the pulse creation routine, since it should handle these cases as well.
stim_pulseSetCreation(hObject);

return;
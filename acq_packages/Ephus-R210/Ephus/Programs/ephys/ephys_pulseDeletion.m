% ephys_pulseDeletion - Callback for updating the selected pulses when changed externally.
%
% SYNTAX
%  ephys_pulseDeletion(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 2/24/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function ephys_pulseDeletion(hObject)

%For now, just run the pulse creation routine, since it should handle these cases as well.
ephys_pulseCreation(hObject);

return;
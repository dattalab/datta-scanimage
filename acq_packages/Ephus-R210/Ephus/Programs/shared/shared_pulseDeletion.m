% shared_pulseDeletion - Callback for updating the selected pulses when changed externally.
%
% SYNTAX
%  shared_pulseDeletion(hObject)
%
% USAGE
%
% NOTES
%  Adapted from ephys_pulseDeletion.m
%
% CHANGES
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%
% Created 2/24/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function shared_pulseDeletion(hObject)

%For now, just run the pulse creation routine, since it should handle these cases as well.
shared_pulseCreation(hObject);

return;
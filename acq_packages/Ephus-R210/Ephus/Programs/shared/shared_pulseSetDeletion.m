% ephys_pulseSetDeletion - Callback for updating the selected pulses when changed externally.
%
% SYNTAX
%  ephys_pulseSetDeletion(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO111908D - Changed 'ephys_' to 'shared_'. -- Tim O'Connor 11/19/08
%
% Created 2/24/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function shared_pulseSetDeletion(hObject)

%For now, just run the pulse creation routine, since it should handle these cases as well.
shared_pulseSetCreation(hObject);

return;
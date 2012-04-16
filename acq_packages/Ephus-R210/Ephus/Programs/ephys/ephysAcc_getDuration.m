% ephysAcc_getDuration - Get the duration, for the current clamp mode, for the indicated amplifier.
%
% SYNTAX
%  ephysAcc_getDuration(hObject, ampIndex)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO092605M: Fixed to work properly with different settings across amplifiers. -- Tim O'Connor 9/26/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%
% Created 3/29/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function duration = ephysAcc_getDuration(hObject, ampIndex)

duration = -1;

amplifiers = getLocal(progmanager, hObject, 'amplifiers');
if get(amplifiers{ampIndex}, 'current_clamp') %TO120205A
    duration = getLocal(progmanager, hObject, 'iClampDurationArray');
    duration = duration(ampIndex);
else
    duration = getLocal(progmanager, hObject, 'vClampDurationArray');
    duration = duration(ampIndex);
end

return;
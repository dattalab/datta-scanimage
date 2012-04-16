% ephysAcc_selectAmplifier - Select a particular amplifier for the ephysScope.
%
% SYNTAX
%  ephysAcc_selectAmplifier(hObject, ampIndex)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO062405A: Added modeString property to amplifiers. -- Tim O'Connor 6/24/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%
% Created 3/31/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephysAcc_selectAmplifier(hObject, ampIndex)

amplifiers = getLocal(progmanager, hObject, 'amplifiers');

if ampIndex >= 1 & ampIndex <= length(amplifiers)
    setLocal(progmanager, hObject, 'amplifierList', ampIndex);
    
    vClampAmplitudeArray = getLocal(progmanager, hObject, 'vClampAmplitudeArray');
    setLocal(progmanager, hObject, 'vClampAmplitude', vClampAmplitudeArray(ampIndex));

    iClampAmplitudeArray = getLocal(progmanager, hObject, 'iClampAmplitudeArray');
    setLocal(progmanager, hObject, 'iClampAmplitude', iClampAmplitudeArray(ampIndex));

    vClampDurationArray = getLocal(progmanager, hObject, 'vClampDurationArray');
    setLocal(progmanager, hObject, 'vClampDuration', vClampDurationArray(ampIndex));

    iClampDurationArray = getLocal(progmanager, hObject, 'iClampDurationArray');
    setLocal(progmanager, hObject, 'iClampDuration', iClampDurationArray(ampIndex));

    stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
    setLocal(progmanager, hObject, 'stimOn', stimOnArray(ampIndex));

    acqOnArray = getLocal(progmanager, hObject, 'acqOnArray');
    setLocal(progmanager, hObject, 'acqOn', acqOnArray(ampIndex));

    averageArray = getLocal(progmanager, hObject, 'averageArray');
    setLocal(progmanager, hObject, 'averageOn', averageArray(ampIndex));
    
    %TO062405A
    setLocal(progmanager, hObject, 'mode', get(amplifiers{ampIndex}, 'modeString'));%TO120205A
else
    error('ampIndex out of range.');
end

return;
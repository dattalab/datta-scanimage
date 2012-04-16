% SYNTAX
%   ephys_amplifierStateListenerFcn(hObject)
%     hObject - @progmanager handle
%
% USAGE
%   Propogates changes in the amplifier state to the scope display.
%
% CHANGES
%  TO092605D: Updated to handle multiple scope objects. -- Tim O'Connr 9/26/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%
% Created 2/11/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function ephys_amplifierStateListenerFcn(hObject)

if ~getLocal(progmanager, hObject, 'startButton')
    return;
end

amp = getLocal(progmanager, hObject, 'amplifiers');
amp = amp{1};%TO120205A - This will always be a cell array, so always dereference here.
% if length(amp) > 1
%     amp = amp{1};%TO120205A
% end

sc = getMain(progmanager, hObject, 'scopeObject');
if length(sc) > 1
    %TO092605D
    sc = sc(1);
end

units = get(amp, 'input_units');
set(sc, 'yUnitsString', units);
setMain(progmanager, hObject, 'yUnitsString', units);
setMain(progmanager, hObject, 'yUnitsPerDiv', get(sc, 'yUnitsPerDiv'));

% units = get(amp, 'input_units');

return;
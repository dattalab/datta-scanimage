% mapper_getMirrorVoltages - Calculate the X and Y mirror signals, based on current settings, in raw millivolts.
%
% SYNTAX
%  [xMirrorVoltages, yMirrorVoltages] = mapper_getMirrorVoltages(hObject);
%  [xMirrorVoltages, yMirrorVoltages] = mapper_getMirrorVoltages(hObject, coordinates);
%    hObject - The handle to the mapper program.
%    xMirrorSignal - The X mirror signal, in millivolts.
%    xMirrorVoltages - The Y mirror signal, in millivolts.
%    coordinates - TODO: Not Yet Implemented.
%
% NOTES
%  The signals are in volts, not microns, so no preprocessing should be performed.
%  This was refactored from mapper.m/map_Callback.
%
% TODO
%  Only calculate coordinates, then let mapper_mirrorChannelPreprocessor convert into voltages, to eliminate code redundancy. -- Tim O'Connor 5/5/08
%
% CHANGES
%   TO102407B - Scale from volts to millivolts. -- Tim O'Connor 10/24/07
%   TO110607B - Scaling to millivolts also applies to the offset, not just the gain. -- Tim O'Connor 11/6/07
%   TO060308A - Refactor all mirror voltage calculations to remove redunancy. -- Tim O'Connor 6/3/08
%   VI061308A - Account for possibility of axes being switched. Renamed internal vars 'xMirrorVoltages/yMirrorVoltages' to 'horMirrorCoords' and 'vertMirrorCoords'-- Vijay Iyer 6/13/08
%
% CREDITS
% Created 10/22/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
%TO032906B
function [xMirrorVoltages, yMirrorVoltages] = mapper_getMirrorVoltages(hObject)

[isi, sampleRate, map] = getLocalBatch(progmanager, hObject, 'isi', 'sampleRate', 'map');
[xCoords, yCoords] = mapper_getMapCoordinates(hObject);

samplesPerPoint = ceil(sampleRate * isi);
horMirrorCoords = ones(samplesPerPoint * length(xCoords), 1);
vertMirrorCoords = horMirrorCoords;
lastIndex = 1;
for i = 1 : length(xCoords)
    index = i * samplesPerPoint;
    horMirrorCoords(lastIndex : index) = xCoords(i);
    vertMirrorCoords(lastIndex : index) = yCoords(i);
    lastIndex = index;
% fprintf(1, ' %d: (row %d, col %d) --> (%7.4f, %7.4f) --> [%7.4f mV, %7.4f mV]\n', i, row, col, xComponent, yComponent, xMirrorVoltages(i), yMirrorVoltages(i));
end

if getLocal(progmanager,hObject,'axesSwitch') %VI061308A
    xMirrorVoltages = mapper_coordinates2Voltages(hObject, 'X', vertMirrorCoords);
    yMirrorVoltages = mapper_coordinates2Voltages(hObject, 'Y', horMirrorCoords);
else
    xMirrorVoltages = mapper_coordinates2Voltages(hObject, 'X', horMirrorCoords);
    yMirrorVoltages = mapper_coordinates2Voltages(hObject, 'Y', vertMirrorCoords);    
end

return;
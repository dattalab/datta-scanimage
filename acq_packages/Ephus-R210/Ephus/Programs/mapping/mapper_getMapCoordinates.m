% mapper_getMapCoordinates - Calculate the X and Y mirror signals, based on current settings, in raw millivolts.
%
% SYNTAX
%  [xCoords, yCoords] = mapper_getMapCoordinates(hObject);
%    hObject - The handle to the mapper program.
%    xCoords - The X mirror coordinates, in microns.
%    yCoords - The Y mirror coordinates, in microns.
%
% NOTES
%  The coordinates are in microns, so they are suitable for preprocessing.
%  This was refactored from mapper_getMirrorVoltages. Then later switched to use the
%  calculation from mapper.m/updateDisplay.
%
% TODO
%  Vectorize this! -- Tim O'Connor 6/3/08
%
% CHANGES
%  TO060308A - Refactor all mirror voltage calculations to remove redunancy. -- Tim O'Connor 6/3/08
%
% Created 5/31/08 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function [xCoords, yCoords] = mapper_getMapCoordinates(hObject)

mapPatternArray = mapper_getMapPattern(hObject);

[xSpacing, ySpacing, xOffset, yOffset, spatialRotation] = getLocalBatch(progmanager, hObject,...
    'xSpacing', 'ySpacing', 'xPatternOffset', 'yPatternOffset', 'spatialRotation');

% % mapPatternArray = flipdim(mapPatternArray, 1);
% xorig = reshape(repmat((0 : size(mapPatternArray, 2) - 1) * xSpacing - 0.5 * (size(mapPatternArray, 2) - 1) * xSpacing, [size(mapPatternArray, 1) 1]), [numel(mapPatternArray) 1]);
% yorig = reshape(repmat((0 : size(mapPatternArray, 1) - 1) * ySpacing - 0.5 * (size(mapPatternArray, 1) - 1) * ySpacing, [1 size(mapPatternArray, 2)]), [numel(mapPatternArray) 1]);
% 
% %TO030206B - Implemented a spatial rotation and offset. Mix the signals accordingly. -- Tim O'Connor 3/2/06
% xCoordsUnordered = xorig * cos(pi / 180 * spatialRotation) + yorig * (-sin(pi / 180 * spatialRotation)) + xOffset;
% yCoordsUnordered = xorig * sin(pi / 180 * spatialRotation) + yorig * cos(pi / 180 * spatialRotation) + yOffset;
% %Sort the points into the mapPattern's order.
% xIndex = [];
% yIndex = [];
% xCoords = ones(size(xCoordsUnordered));
% yCoords = ones(size(yCoordsUnordered));
% 
% % %Reshape the map pattern in the same way we reshaped the coordinate vectors, and use it to index them in order.
% % orderedIndices = reshape(mapPatternArray, [numel(mapPatternArray) 1]);
% % xCoords = xCoordsUnordered(reshape(mapPatternArray, [numel(mapPatternArray) 1]));
% % yCoords = flipdim(yCoordsUnordered(reshape(mapPatternArray, [1, numel(mapPatternArray)])), 1);
% 
% for i = 1 : numel(mapPattern)
%     [xIndex, yIndex] = find(mapPattern == i);
%     xCoords(i) = xCoords
% end

xCoords = ones(numel(mapPatternArray), 1);
yCoords = ones(numel(mapPatternArray), 1);
xMirrorRange = (size(mapPatternArray, 2) - 1) * xSpacing;%TO102407B
yMirrorRange = (size(mapPatternArray, 1) - 1) * ySpacing;%TO102407B
sinRotation = sin(pi / 180 * spatialRotation);%TO030206B %TO050806A
cosRotation = cos(pi / 180 * spatialRotation);%TO030206B %TO050806A
mapPatternArray = flipdim(mapPatternArray, 1);
for i = 1 : numel(mapPatternArray)
    [row col] = find(mapPatternArray == i);

    %TO030206A - Added inversion. -- Tim O'Connor 3/2/06
    %TO030906C: Fix the beam display to take into account any inversions. -- Tim O'Connor 3/9/06
    %TO050306D: Factored everything out, to simplify use of xSign and ySign and eliminate xInvert and yInvert from calculations. -- Tim O'Connor 5/3/06
    xComponent = (((col - 1) / (size(mapPatternArray, 2)-1) * xMirrorRange) - 0.5 * xMirrorRange);
    yComponent = (((row - 1) / (size(mapPatternArray, 1)-1) * yMirrorRange) - 0.5 * yMirrorRange);

    %TO050306E: Backed out 'gs 2006 04 26', at least temporarily. -- Tim O'Connor 5/3/06
    % changed sign of the sinRotation terms to correct the rotation problem (on my rig!) -- gs 2006 04 26
    xCoords(i) = cosRotation * xComponent - sinRotation * yComponent + xOffset;%TO030206B % gs 2006 04 26
    yCoords(i) = sinRotation * xComponent + cosRotation * yComponent + yOffset;%TO030206B % gs 2006 04 26
% fprintf(1, ' %d: (row %d, col %d) --> (%7.4f, %7.4f) --> [%7.4f um, %7.4f um]\n', i, row, col, xComponent, yComponent, xCoords(i), yCoords(i));
    % NB: might have to do a similar thing (with cosRotation sign) for case of (imagingSys) Vertical Invert checked 
end

return;
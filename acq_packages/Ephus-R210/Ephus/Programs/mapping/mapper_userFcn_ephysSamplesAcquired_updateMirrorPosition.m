% mapper_userFcn_ephysSamplesAcquired_updateMirrorPosition - Used to implement online update of the beamPosition glyph.
%
% SYNTAX
%  mapper_userFcn_ephysSamplesAcquired_updateMirrorPosition(data, bufferName)
%   data - The most recently acquired chunk of data (a single trace).
%
% USAGE
%  Bind this function to the ephys:SamplesAcquired event.
%
% NOTES
%  See TO112907G. Mostly refactored from mapper_userFcn_ephysSamplesAcquired_display.m
%  Relies on the global `mapper_userFcn_display` variable, which is configured by mapper_userFcn_mapStart_display.m or mapper_userFcn_mouseStart_updateMirrorPosition.m.
%
% CHANGES
%  TO022208A - This should ignore traces other than the one we're interested in, just like mapper_userFcn_ephysSamplesAcquired_display.m does. -- Tim O'Connor 2/22/08
%
% Created 11/29/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_userFcn_ephysSamplesAcquired_updateMirrorPosition(data, bufferName)
global mapper_userFcn_display;

%TO022208A - This should ignore traces other than the one we're interested in, just like mapper_userFcn_ephysSamplesAcquired_display.m does.
%Select the correct trace data.
if getNumericSuffix(bufferName) ~= mapper_userFcn_display.traceNumber
    return;
end

%Get any necessary variables from the mapper.
mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
[beamHandles, map, mouse] = getLocalBatch(progmanager, mapperObj, 'beamHandles', 'map', 'mouse');
beamCoordinates = [];

if map && mapper_userFcn_display.started && all(ishandle(beamHandles)) && mapper_userFcn_display.position <= numel(mapper_userFcn_display.mapPattern)
    %Determine the current column and row.
    [xIndex, yIndex] = find(mapper_userFcn_display.mapPattern == mapper_userFcn_display.position);
    if mapper_userFcn_display.position == numel(mapper_userFcn_display.mapPattern)
        xIndexNext = xIndex;
        yIndexNext = yIndex;
    else
        [xIndexNext, yIndexNext] = find(mapper_userFcn_display.mapPattern == mapper_userFcn_display.position + 1);
    end

    %TO083009A - Transform beam position from map coordinates back into image coordinates. -- Tim O'Connor 8/30/07
    %nextCoords = [mapper_userFcn_display.xpoints(xIndexNext, yIndexNext), mapper_userFcn_display.ypoints(xIndexNext, yIndexNext)];
    nextCoordsOrig = [mapper_userFcn_display.xpoints(xIndexNext, yIndexNext), mapper_userFcn_display.ypoints(xIndexNext, yIndexNext)];
    nextCoords(1) = nextCoordsOrig(1) * cos(pi / 180 * mapper_userFcn_display.spatialRotation) + nextCoordsOrig(2) * (-sin(pi / 180 * mapper_userFcn_display.spatialRotation)) + mapper_userFcn_display.xOffset;
    nextCoords(2) = nextCoordsOrig(1) * sin(pi / 180 * mapper_userFcn_display.spatialRotation) + nextCoordsOrig(2) * cos(pi / 180 * mapper_userFcn_display.spatialRotation) + mapper_userFcn_display.yOffset;
    setLocal(progmanager, mapperObj, 'positionNumber', mapper_userFcn_display.position);

    %The coordinate inversion between images and matrices has already been accounted for (see mapper_userFcn_mapStart_display.m).
    beamCoordinates = [mapper_userFcn_display.xpoints(xIndex, yIndex), mapper_userFcn_display.ypoints(xIndex, yIndex)];

    mapper_userFcn_display.position =  mapper_userFcn_display.position + 1;
    if mapper_userFcn_display.position > numel(mapper_userFcn_display.mapPattern)
        mapper_userFcn_display.started = 0;
    end
end
if mouse && mapper_userFcn_display.mousing
    if numel(mapper_userFcn_display.mousePoints) == 2
        nextCoords = mapper_userFcn_display.mousePoints;
        beamCoordinates = mapper_userFcn_display.mousePoints;
    elseif mapper_userFcn_display.mousePosition <= size(mapper_userFcn_display.mousePoints, 1)
        if mapper_userFcn_display.mousePosition == size(mapper_userFcn_display.mousePoints, 1)
            nextCoords = mapper_userFcn_display.mousePoints(mapper_userFcn_display.mousePosition, :);
        else
            nextCoords = mapper_userFcn_display.mousePoints(mapper_userFcn_display.mousePosition + 1, :);
        end
        beamCoordinates = mapper_userFcn_display.mousePoints(mapper_userFcn_display.mousePosition, :);
    else
        nextCoords = mapper_userFcn_display.mousePoints(mapper_userFcn_display.mousePosition, :);
        beamCoordinates = mapper_userFcn_display.mousePoints(mapper_userFcn_display.mousePosition, :);
    end
    mapper_userFcn_display.mousePosition =  mapper_userFcn_display.mousePosition + 1;
    if mapper_userFcn_display.mousePosition > size(mapper_userFcn_display.mousePoints, 1)
        mapper_userFcn_display.mousing = 0;
    end
end

if  ~isempty(beamCoordinates)
    %Update the beam position display.
    % beamCoordinates = 10 * beamCoordinates;%TEST_TEST_TEST_TEST_TEST_TEST_TEST
    setLocalBatch(progmanager, mapperObj, 'xMirrorPos', round(beamCoordinates(1)), 'yMirrorPos', round(beamCoordinates(2)), 'beamCoordinates', beamCoordinates);
    %TO112907C - Make sure the beamHandles can be manipulated on the video figure.
    if all(ishandle(beamHandles))
        videoF = getParent(beamHandles(1), 'figure');
        fHV = get(videoF, 'HandleVisibility');
        set(videoF, 'HandleVisibility', 'On');
        set(beamHandles(1), 'Position', [nextCoords(1) - mapper_userFcn_display.beamHandleRadius, nextCoords(2) - mapper_userFcn_display.beamHandleRadius, ...
            2 * mapper_userFcn_display.beamHandleRadius, 2 * mapper_userFcn_display.beamHandleRadius]);
        set(videoF, 'HandleVisibility', fHV);%TO112907C
    end
end

return;
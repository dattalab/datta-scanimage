% mapper_userFcn_mapStart_display - Used to initiate online display of map data.
%
% SYNTAX
%  mapper_userFcn_mapStart_display
%
% USAGE
%  Bind this function to the mapper:MapStart event.
%
% NOTES
%
% CHANGES
%  LP033106A: Rewrote the pixel value algorithm. Set autodefault values. Add colorbar. -- Leopoldo Petreanu 3/31/06
%  TO062907A: Compensate for map pattern rotation & offset when displaying somata. -- Tim O'Connor 6/29/07
%  TO083009A: Use map-centered coordinates, instead of image centered. -- Tim O'Connor 8/30/07
%  TO083009B: Colorize soma to match image. -- Tim O'Connor 8/30/07
%  TO083107A: Make the soma marker a fraction of a pixel, not just a fraction of the total image size. -- Tim O'Connor 8/31/07
%  TO112807A: Matlab 7.x syntax optimizations. -- Tim O'Connor 11/28/07
%  TO112907G - New user function(s), for moving the beam display and updating the beam coordinates (during both map and mouse). -- Tim O'Connor 11/29/07
%
% Created 3/30/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_userFcn_mapStart_display(varargin)
global mapper_userFcn_display;

%Enable this set of functions.
mapper_userFcn_display.started = 1;

%Gather the relevant variables from the mapper.
mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
[mapper_userFcn_display.mapPattern, mapper_userFcn_display.beamHandles, xSpacing, ySpacing, xOffset, yOffset, spatialRotation, im, ...
    mapper_userFcn_display.xInvert, mapper_userFcn_display.yInvert, soma1Coordinates, soma2Coordinates] = getLocalBatch(progmanager, mapperObj, ...
        'mapPatternArray', 'beamHandles', 'xSpacing', 'ySpacing', 'xPatternOffset', 'yPatternOffset', 'spatialRotation', 'videoImage', ...
        'temp_xInvert', 'temp_yInvert', 'soma1Coordinates', 'soma2Coordinates');

%TO062907A
if ~isempty(soma1Coordinates)
    try
        cart = soma1Coordinates - [xOffset, yOffset];
        [theta, rho] = cart2pol(cart(1), cart(2));
        [sx, sy] = pol2cart(theta + (-spatialRotation * (pi/180)), rho);
        soma1Coordinates = [sx, sy];
    catch
        lasterr
    end
end
if ~isempty(soma2Coordinates)
    try
        cart = soma2Coordinates - [xOffset, yOffset];
        [theta, rho] = cart2pol(cart(1), cart(2));
        [sx, sy] = pol2cart(theta + (-spatialRotation * (pi/180)), rho);
        soma2Coordinates = [sx, sy];
    catch
        lasterr
    end
end

xSign = +1;
if mapper_userFcn_display.xInvert
    xSign = -1;
end
ySign = +1;
if mapper_userFcn_display.yInvert
    ySign = -1;
end
mapper_userFcn_display.mapPattern = flipdim(mapper_userFcn_display.mapPattern, 1);

%The original algorithm for calculating the coordinates in microns from the map pattern came from mapper/updateDisplay.
%The x and y axes have been exchanged, and the y-axis inverted, for easy image coordinate referencing.
xorig = reshape(repmat((0 : size(mapper_userFcn_display.mapPattern, 2) - 1) * xSpacing - 0.5 * (size(mapper_userFcn_display.mapPattern, 2) - 1) * xSpacing, [size(mapper_userFcn_display.mapPattern, 1) 1]), [numel(mapper_userFcn_display.mapPattern) 1]);
yorig = reshape(repmat((0 : size(mapper_userFcn_display.mapPattern, 1) - 1) * ySpacing - 0.5 * (size(mapper_userFcn_display.mapPattern, 1) - 1) * ySpacing, [1 size(mapper_userFcn_display.mapPattern, 2)]), [numel(mapper_userFcn_display.mapPattern) 1]);

%TO083009A
%Reshape the calculated coordinates into an array that matches the map pattern.
% mapper_userFcn_display.xpoints = xorig * cos(pi / 180 * spatialRotation) + yorig * (-sin(pi / 180 * spatialRotation)) + xOffset;
% mapper_userFcn_display.xpoints = reshape(mapper_userFcn_display.xpoints, size(mapper_userFcn_display.mapPattern));
% mapper_userFcn_display.ypoints = xorig * sin(pi / 180 * spatialRotation) + yorig * cos(pi / 180 * spatialRotation) + yOffset;
% mapper_userFcn_display.ypoints = reshape(mapper_userFcn_display.ypoints, size(mapper_userFcn_display.mapPattern));
mapper_userFcn_display.xpoints = reshape(xorig, size(mapper_userFcn_display.mapPattern));
mapper_userFcn_display.ypoints = reshape(yorig, size(mapper_userFcn_display.mapPattern));
mapper_userFcn_display.xOffset = xOffset;
mapper_userFcn_display.yOffset = yOffset;
mapper_userFcn_display.spatialRotation = spatialRotation;

%The radius of the circle used to display the beam position should be some fraction of the total number of pixels.
%TO083107A - Make the soma marker a fraction of a pixel, not just a fraction of the total image size. -- Tim O'Connor 8/31/07
xdata = get(im, 'xdata');
ydata = get(im, 'ydata');
mapper_userFcn_display.beamHandleRadius = ceil(mean(xdata(2), ydata(2)) * 0.03);
% mapper_userFcn_display.beamHandleRadius = ceil(max(xSpacing, ySpacing) * 0.5);

%Initialize the variables.
mapper_userFcn_display.position = 1;
mapper_userFcn_display.pixels = zeros(size(mapper_userFcn_display.mapPattern));

xdata = [min(min(mapper_userFcn_display.xpoints)) max(max(mapper_userFcn_display.xpoints))];
ydata = [min(min(mapper_userFcn_display.ypoints)) max(max(mapper_userFcn_display.ypoints))];

%Initialize the display.
initDisplay = 0;
if ~isfield(mapper_userFcn_display, 'figure')
    initDisplay = 1;
else
    %TO112907G
    if isempty(mapper_userFcn_display.figure) || isempty(mapper_userFcn_display.axes) || isempty(mapper_userFcn_display.im) || isempty(mapper_userFcn_display.colorbar) || ...
            all(isempty(mapper_userFcn_display.somataHandles))
        initDisplay = 1;
    elseif ~ishandle(mapper_userFcn_display.figure) || ~ishandle(mapper_userFcn_display.axes) || ~ishandle(mapper_userFcn_display.im) || ~ishandle(mapper_userFcn_display.colorbar) || ...
            ~all(ishandle(mapper_userFcn_display.somataHandles))
        fprintf(2, 'mapper_userFcn_mapStart_display: The user function appears to be enabled and the global structure already exists, but the graphics handles are invalid. Recreating...\n');
        initDisplay = 1;
    end
end
if initDisplay
    mapper_userFcn_display.figure = figure('Name', 'mapper_userFcn_display', 'NumberTitle', 'Off', 'ColorMap', jet);
    try
        %TO082907E - Allow one-click cloning of a map. -- Tim O'Connor 8/29/07
        toolbarIcon = load('holdon.mat');
        cloneButton = uipushtool(findall(mapper_userFcn_display.figure, 'Type', 'Uitoolbar'), 'CData', toolbarIcon.CData, 'TooltipString','Clone map figure',...
            'Separator', 'off', 'HandleVisibility', 'off', 'ClickedCallback', @cloneFigure);
        %'f = gcf; hV = get(f, ''HandleVisibility''); set(f, ''HandleVisibility'', ''On''); copyobj(f, 0); set(f, ''HandleVisibility'', hV);');
    catch
        lasterr
    end
    mapper_userFcn_display.axes = axes('Parent', mapper_userFcn_display.figure, 'DataAspectRatio', [1 1 1]);
    xlabelHandle = get(mapper_userFcn_display.axes, 'XLabel');
    set(xlabelHandle, 'String', 'X [microns]');
    ylabelHandle = get(mapper_userFcn_display.axes, 'YLabel');
    set(ylabelHandle, 'String', 'Y [microns]');

    %LP033106A: Set it to be a scaled image with a colorbar.
    mapper_userFcn_display.im = imagesc(xdata, ydata, zeros(length(xorig), length(yorig)), 'Parent', mapper_userFcn_display.axes);
    mapper_userFcn_display.colorbar = colorbar('peer', mapper_userFcn_display.axes);
    mapper_userFcn_display.colorbarIm = get(mapper_userFcn_display.colorbar, 'Children');
    set(mapper_userFcn_display.axes, 'XLimMode', 'auto', 'YLimMode', 'auto', 'YDir', 'normal');
    %TO083009B
    mapper_userFcn_display.somataHandles(1) = rectangle('Position', [0 0 1 1], 'Curvature', [1 1], ...
        'EdgeColor', [1 1 1], 'FaceColor', [0, 0, 1], 'Tag', 'Soma1', 'LineWidth', 2, 'Visible', 'On');
    if ~isempty(soma1Coordinates)
        set(mapper_userFcn_display.somataHandles(1), 'Visible', 'Off');
    end
    %TO083009B
    mapper_userFcn_display.somataHandles(2) = rectangle('Position', [0 0 1 1], 'Curvature', [1 1], ...
        'EdgeColor', [1 1 1], 'FaceColor', [.1 .8 .1], 'Tag', 'Soma2', 'LineWidth', 2, 'Visible', 'On');
    if ~isempty(soma2Coordinates)
        set(mapper_userFcn_display.somataHandles(2), 'Visible', 'Off');
    end
end

%Bring the figure into the foreground.
set(mapper_userFcn_display.figure, 'Visible', 'Off');
set(mapper_userFcn_display.figure, 'Visible', 'On');

%Set up the image's coordinate system.
% fprintf(1, 'mapper_userFcn_mapStart_display: Resetting image...\n%s', getStackTraceString);
set(mapper_userFcn_display.im, 'CData', mapper_userFcn_display.pixels, 'XData', xdata, 'YData', ydata);

%Update the soma positions.
if ~isempty(soma1Coordinates)
    set(mapper_userFcn_display.somataHandles(1), 'Position', [soma1Coordinates(1) - mapper_userFcn_display.beamHandleRadius, soma1Coordinates(2) - mapper_userFcn_display.beamHandleRadius, ...
            2 * mapper_userFcn_display.beamHandleRadius, 2 * mapper_userFcn_display.beamHandleRadius], ...
        'Visible', 'On');
else
    set(mapper_userFcn_display.somataHandles(1), 'Visible', 'Off');
end
if ~isempty(soma2Coordinates)
    set(mapper_userFcn_display.somataHandles(2), 'Position', [soma2Coordinates(1) - mapper_userFcn_display.beamHandleRadius, soma2Coordinates(2) - mapper_userFcn_display.beamHandleRadius, ...
            2 * mapper_userFcn_display.beamHandleRadius, 2 * mapper_userFcn_display.beamHandleRadius], ...
        'Visible', 'On');
else
    set(mapper_userFcn_display.somataHandles(2), 'Visible', 'Off');
end

%Make sure the axes are tight, without cutting off part of the edge pixels.
xPixelExtent = abs(diff(xdata)) / size(mapper_userFcn_display.mapPattern, 1);
yPixelExtent = abs(diff(ydata)) / size(mapper_userFcn_display.mapPattern, 2);
set(mapper_userFcn_display.axes, 'XLim', [xdata(1)-0.5*xPixelExtent xdata(2)+0.5*xPixelExtent], 'YLim', [ydata(1)-0.5*yPixelExtent ydata(2)+0.5*yPixelExtent], ...
    'DataAspectRatio', [1 1 1]);

%LP033106A: Update the beam position to reflect the next position.
if all(ishandle(mapper_userFcn_display.beamHandles))
    [xIndexNext yIndexNext] = find(mapper_userFcn_display.mapPattern == 1);
    %TO083009A - Transform beam position from map coordinates back into image coordinates. -- Tim O'Connor 8/30/07
    %nextCoords = [mapper_userFcn_display.xpoints(xIndexNext, yIndexNext), mapper_userFcn_display.ypoints(xIndexNext, yIndexNext)];
    nextCoordsOrig = [mapper_userFcn_display.xpoints(xIndexNext, yIndexNext), mapper_userFcn_display.ypoints(xIndexNext, yIndexNext)];
    nextCoords(1) = nextCoordsOrig(1) * cos(pi / 180 * mapper_userFcn_display.spatialRotation) + nextCoordsOrig(2) * (-sin(pi / 180 * mapper_userFcn_display.spatialRotation)) + mapper_userFcn_display.xOffset;
    nextCoords(2) = nextCoordsOrig(1) * sin(pi / 180 * mapper_userFcn_display.spatialRotation) + nextCoordsOrig(2) * cos(pi / 180 * mapper_userFcn_display.spatialRotation) + mapper_userFcn_display.yOffset;
    set(mapper_userFcn_display.beamHandles(1), 'Position', [nextCoords(1, 1) - mapper_userFcn_display.beamHandleRadius, nextCoords(1, 2) - mapper_userFcn_display.beamHandleRadius, ...
            2 * mapper_userFcn_display.beamHandleRadius, 2 * mapper_userFcn_display.beamHandleRadius]);
    setLocalBatch(progmanager, mapperObj, 'xMirrorPos', round(nextCoords(1, 1)), 'yMirrorPos', round(nextCoords(1, 2)));
end

set(mapper_userFcn_display.figure, 'HandleVisibility', 'Off');

%LP033106A 
if ~isfield(mapper_userFcn_display, 'mode')
    fprintf(2, 'mapper_userFcn_mapStart_display: No mode selected.\n Set global mapper_userFcn_display.mode to {''meanOfPeaks'' | ''numberOfPeaks''}.\n Defaulting to ''meanOfPeaks''.\n');
    mapper_userFcn_display.mode = 'meanOfPeaks';
end
if ~isfield(mapper_userFcn_display, 'traceNumber')
    fprintf(2, 'mapper_userFcn_mapStart_display: No trace selected.\n Set global mapper_userFcn_display.traceNumber to the value that corresponds to the recording electrode (probably 1).\n  Defaulting to 1.\n');
    mapper_userFcn_display.traceNumber = 1;
end
if ~isfield(mapper_userFcn_display, 'baselineStart')
    fprintf(2, 'mapper_userFcn_mapStart_display: No baselineStart selected.\n Set global mapper_userFcn_display.baselineStart to the first sample of the baseline.\n Defaulting to 1.\n');
    mapper_userFcn_display.baselineStart = 1;
end
if ~isfield(mapper_userFcn_display, 'baselineEnd')
    fprintf(2, 'mapper_userFcn_mapStart_display: No baselineEnd selected.\n Set global mapper_userFcn_display.baselineEnd to the last sample of the baseline.\n Defaulting to 999.\n');
    mapper_userFcn_display.baselineEnd = 999;
end
if ~isfield(mapper_userFcn_display, 'analysisWindowStart')
    fprintf(2, 'mapper_userFcn_mapStart_display: No analysisWindowStart selected.\n Set global mapper_userFcn_display.analysisWindowStart to the first sample of the analysis window.\n Defaulting to 1000.\n');
    mapper_userFcn_display.analysisWindowStart = 1000;
end
if ~isfield(mapper_userFcn_display, 'analysisWindowEnd')
    fprintf(2, 'mapper_userFcn_mapStart_display: No analysisWindowEnd selected.\n Set global mapper_userFcn_display.analysisWindowEnd to the last sample of the analysis window.\n Defaulting to 2000.\n');
    mapper_userFcn_display.analysisWindowEnd = 2000;
end
if ~isfield(mapper_userFcn_display, 'spikeThreshold')
    fprintf(2, 'mapper_userFcn_mapStart_display: No spikeThreshold selected.\n Set global mapper_userFcn_display.spikeThreshold to minimum value a spike must hit to be counted.\n Defaulting to 1.\n');
    mapper_userFcn_display.spikeThreshold = 1;
end

return;

%---------------------------------------------------------------------------------------
%TO082907E
function cloneFigure(hObject, eventdata, handles)
global mapper_userFcn_display;

hV = get(mapper_userFcn_display.figure, 'HandleVisibility');
f = copyobj(mapper_userFcn_display.figure, 0);
set(mapper_userFcn_display.figure, 'HandleVisibility', hV);

pos = get(f, 'Position');
pos(3:4) = pos(3:4) / 2;
pos(1:2) = pos(1:2) + pos(1:2) .* 0.05;
set(f, 'Position', pos);
set(f, 'Name', ['Copy of mapNumber: ' num2str(getGlobal(progmanager, 'mapNumber', 'mapper', 'mapper') - 1)], 'CloseRequestFcn', @closeClone);

return;

%---------------------------------------------------------------------------------------
%TO082907E
function closeClone(hObject, eventdata, handles)
global mapper_userFcn_display;

delete(hObject);

if ishandle(mapper_userFcn_display.axes)
    mapper_userFcn_display.colorbar = colorbar('peer', mapper_userFcn_display.axes);
    mapper_userFcn_display.colorbarIm = get(mapper_userFcn_display.colorbar, 'Children');
end

return
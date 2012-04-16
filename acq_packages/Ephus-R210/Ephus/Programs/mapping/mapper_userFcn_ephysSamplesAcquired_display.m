% mapper_userFcn_ephysSamplesAcquired_display - Used to implement online display of map data.
%
% SYNTAX
%  mapper_userFcn_ephysSamplesAcquired_display(data)
%   data - The most recently acquired chunk of data (a single trace).
%
% USAGE
%  Bind this function to the ephys:SamplesAcquired event.
%
% NOTES
%
% CHANGES
%  LP033106A: Rewrote the pixel value algorithm. -- Leopoldo Petreanu 3/31/06
%  TO042106D: Be more careful about checking for the existence of the global variable (see if it's empty). -- Tim O'Connor 4/21/06
%  TO050306C: Make sure the colorbar YLim is increasing. -- Tim O'Connor 5/3/06
%  TO091106D: Check that the `started` field exists, since the GUI auto-creates the rest of the struct. -- Tim O'Connor 9/11/06
%  TO083009A - Transform beam position from map coordinates back into image coordinates. -- Tim O'Connor 8/30/07
%  TO112907A - Matlab R2007a corrupts the colorbarIm handle by 0.002, for no obvious reason. -- Tim O'Connor 11/29/07
%  TO112907C - Make sure the beamHandle can be manipulated on the mapper's video figure. -- Tim O'Connor 11/29/07
%  TO112907E - There were two minus signs as part of the KS060707 (baseline subtraction in peak counting) change. -- Tim O'Connor 11/29/07
%  TO112907F - Check to see that no map is being performed, don't just rely on the global `mapper_userFcn_display` variable. -- Tim O'Connor 11/29/07
%  TO112907G - New user function(s), for moving the beam display and updating the beam coordinates (during both map and mouse). -- Tim O'Connor 11/29/07
%
% Created 3/30/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_userFcn_ephysSamplesAcquired_display(data, bufferName)
global mapper_userFcn_display;

%Make sure we really want to run here.
if exist('mapper_userFcn_display', 'var') ~= 1
% fprintf(1, 'mapper_userFcn_ephysSamplesAcquired_display: NO_GLOBAL\n');
    return;
end

%TO042106D
if isempty(mapper_userFcn_display)
    return;
end

%TO091106D
if ~isfield(mapper_userFcn_display, 'started')
    return;
end

if ~mapper_userFcn_display.started
% fprintf(1, 'mapper_userFcn_ephysSamplesAcquired_display: STOPPED\n');
    return;
end

if ~isfield(mapper_userFcn_display, 'figure')
    fprintf(2, 'mapper_userFcn_ephysSamplesAcquired_display: The user function appears to be enabled and the global structure exists, but figure has not been created.\n');
    mapper_userFcn_display.started = 0;
    return;
end

if ~isfield(mapper_userFcn_display, 'mode')
    fprintf(2, 'mapper_userFcn_ephysSamplesAcquired_display: No mode selected.\n Set global mapper_userFcn_display.mode to {''meanOfPeaks'' | ''numberOfPeaks''}.\n');
    mapper_userFcn_display.started = 0;
    return;
end

if ~isfield(mapper_userFcn_display, 'traceNumber')
    fprintf(2, 'mapper_userFcn_ephysSamplesAcquired_display: No trace selected.\n Set global mapper_userFcn_display.traceNumber to the value that corresponds to the recording electrode (probably 1).\n');
    mapper_userFcn_display.started = 0;
    return;
end

if ~ishandle(mapper_userFcn_display.figure) || ~ishandle(mapper_userFcn_display.axes) || ~ishandle(mapper_userFcn_display.im)
    fprintf(2, 'mapper_userFcn_ephysSamplesAcquired_display: The user function appears to be enabled and the global structure exists, but the graphics handle(s) may be invalid.\n');
    mapper_userFcn_display.started = 0;
    return;
end

%TO112907F - Check to see that no map is being performed, don't just rely on the global `mapper_userFcn_display` variable. -- Tim O'Connor 11/29/07
if ~getGlobal(progmanager, 'map', 'mapper', 'mapper')
    mapper_userFcn_display.started = 0;
    return;
end

%Select the correct trace data.
if getNumericSuffix(bufferName) ~= mapper_userFcn_display.traceNumber
    return;
end
    
% %Get any necessary variables from the mapper.
% mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
% beamHandles = getLocal(progmanager, mapperObj, 'beamHandles');
% 
% %Determine the current column and row.
% [xIndex yIndex] = find(mapper_userFcn_display.mapPattern == mapper_userFcn_display.position);
% 
% %Update the beam position display.
% %The coordinate inversion between images and matrices has already been accounted for (see mapper_userFcn_mapStart_display.m).
% beamCoordinates = [mapper_userFcn_display.xpoints(xIndex, yIndex), mapper_userFcn_display.ypoints(xIndex, yIndex)];
% % beamCoordinates = 10 * beamCoordinates;%TEST_TEST_TEST_TEST_TEST_TEST_TEST
% setLocalBatch(progmanager, mapperObj, 'xMirrorPos', mapper_userFcn_display.xpoints(mapper_userFcn_display.position), ...
%     'yMirrorPos', mapper_userFcn_display.ypoints(mapper_userFcn_display.position), 'beamCoordinates', beamCoordinates);
% if all(ishandle(beamHandles)) && mapper_userFcn_display.position < numel(mapper_userFcn_display.mapPattern)
%     [xIndexNext yIndexNext] = find(mapper_userFcn_display.mapPattern == mapper_userFcn_display.position + 1);
%     %TO083009A - Transform beam position from map coordinates back into image coordinates. -- Tim O'Connor 8/30/07
%     %nextCoords = [mapper_userFcn_display.xpoints(xIndexNext, yIndexNext), mapper_userFcn_display.ypoints(xIndexNext, yIndexNext)];
%     nextCoordsOrig = [mapper_userFcn_display.xpoints(xIndexNext, yIndexNext), mapper_userFcn_display.ypoints(xIndexNext, yIndexNext)];
%     nextCoords(1) = nextCoordsOrig(1) * cos(pi / 180 * mapper_userFcn_display.spatialRotation) + nextCoordsOrig(2) * (-sin(pi / 180 * mapper_userFcn_display.spatialRotation)) + mapper_userFcn_display.xOffset;
%     nextCoords(2) = nextCoordsOrig(1) * sin(pi / 180 * mapper_userFcn_display.spatialRotation) + nextCoordsOrig(2) * cos(pi / 180 * mapper_userFcn_display.spatialRotation) + mapper_userFcn_display.yOffset;
%     %TO112907C - Make sure the beamHandles can be manipulated on the video figure.
%     videoF = getParent(beamHandles(1), 'figure');
%     fHV = get(videoF, 'HandleVisibility');
%     set(videoF, 'HandleVisibility', 'On');
%     set(beamHandles(1), 'Position', [nextCoords(1, 1) - mapper_userFcn_display.beamHandleRadius, nextCoords(1, 2) - mapper_userFcn_display.beamHandleRadius, ...
%             2 * mapper_userFcn_display.beamHandleRadius, 2 * mapper_userFcn_display.beamHandleRadius]);
%     set(videoF, 'HandleVisibility', fHV);%TO112907C
% end

%LP033106A
if strcmpi(mapper_userFcn_display.mode, 'meanOfPeaks')
    pixelValue = mean(data(mapper_userFcn_display.analysisWindowStart:mapper_userFcn_display.analysisWindowEnd))-median(data(mapper_userFcn_display.baselineStart:mapper_userFcn_display.baselineEnd));
%     pixelValue
%figure, plot(0:mapper_userFcn_display.analysisWindowEnd-mapper_userFcn_display.analysisWindowStart, data(mapper_userFcn_display.analysisWindowStart:mapper_userFcn_display.analysisWindowEnd), ...
 %    0:mapper_userFcn_display.baselineEnd-mapper_userFcn_display.baselineStart, data(mapper_userFcn_display.baselineStart:mapper_userFcn_display.baselineEnd));
elseif strcmpi(mapper_userFcn_display.mode, 'numberOfPeaks')
    %KS060707 %TO112907E
    % thresholdIndices = find(data(mapper_userFcn_display.analysisWindowStart:mapper_userFcn_display.analysisWindowEnd) > mapper_userFcn_display.spikeThreshold);
    thresholdIndices = find((data(mapper_userFcn_display.analysisWindowStart:mapper_userFcn_display.analysisWindowEnd) - ...
        median(data(mapper_userFcn_display.baselineStart:mapper_userFcn_display.baselineEnd))) > mapper_userFcn_display.spikeThreshold);
    if isempty(thresholdIndices)
        pixelValue = 0;
    else
        %Count up non-adjacent points that are above the threshold.
        %There must always be at least one, since something was found above the threshold (however, it may be just that single peak).
        pixelValue = length(find(diff(thresholdIndices) > 1)) + 1;
    end
else
    fprintf(2, 'mapper_userFcn_ephysSamplesAcquired_display: Unrecognized mode value ''%s''\n', mapper_userFcn_display.mode);
    return;
end

%Determine the current column and row.
[xIndex, yIndex] = find(mapper_userFcn_display.mapPattern == mapper_userFcn_display.position);

% pixelValue = mapper_userFcn_display.position * 100;%TEST_TEST_TEST_TEST_TEST_TEST_TEST
% pixelValue = rand;%TEST_TEST_TEST_TEST_TEST_TEST_TEST
%Update the appropriate pixel.
mapper_userFcn_display.pixels(xIndex, yIndex) = pixelValue;

% fprintf(1, 'mapper_userFcn_ephysSamplesAcquired_display - \n Position: %s\n pixelValue: %s\n xIndex: %s\n yIndex: %s\n pixels: %s\n Coords: (%s, %s)\n BufferName: %s\n Trace Number: %s\n\n', ...
%     num2str(mapper_userFcn_display.position), num2str(pixelValue), num2str(xIndex), num2str(yIndex), mat2str(mapper_userFcn_display.pixels), ...
%     num2str(beamCoordinates(1)), num2str(beamCoordinates(2)), ...
%     bufferName, num2str(mapper_userFcn_display.traceNumber));

% mapper_userFcn_display.position =  mapper_userFcn_display.position + 1;
% if mapper_userFcn_display.position > numel(mapper_userFcn_display.mapPattern)
%     mapper_userFcn_display.started = 0;
% end

set(mapper_userFcn_display.figure, 'HandleVisibility', 'On');
set(mapper_userFcn_display.im, 'CData', mapper_userFcn_display.pixels);
colorLims = [min(min(mapper_userFcn_display.pixels)) max(max(mapper_userFcn_display.pixels))];

%TO050306C: Make sure the colorbar YLim is increasing. -- Tim O'Connor 5/3/06
if colorLims(1) ~= colorLims(2)
    set(mapper_userFcn_display.colorbar, 'YLim', colorLims);
else
    set(mapper_userFcn_display.colorbar, 'YLim', [colorLims(1) colorLims(2)+1]);
end
%TO112907A - Matlab R2007a corrupts the colorbarIm handle by 0.002, for no obvious reason. -- Tim O'Connor 11/29/07
if mapper_userFcn_display.colorbarIm ~= get(mapper_userFcn_display.colorbar, 'Children')
   mapper_userFcn_display.colorbarIm = get(mapper_userFcn_display.colorbar, 'Children');
end
set(mapper_userFcn_display.colorbarIm, 'YData', colorLims);
set(mapper_userFcn_display.figure, 'HandleVisibility', 'Off');

%TO112907G - New user function(s), for moving the beam display and updating the beam coordinates (during both map and mouse). -- Tim O'Connor 11/29/07
mapper_userFcn_display.mousing = 0;
mapper_userFcn_display.mousePosition = 0;
mapper_userFcn_display.mousePoints = [];

drawnow expose;%TO042309A - Not using expose can cause C-spawned events to fire out of order.

return;
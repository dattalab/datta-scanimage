% mapper_userFcn_mouseStart_updateMirrorPosition - Used to initiate online update of mouse display parameters.
%
% SYNTAX
%  mapper_userFcn_mapStart_display
%
% USAGE
%  Bind this function to the mapper:MouseStart event.
%
% NOTES
%  See TO112907G.
%
% CHANGES
%
% Created 3/30/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_userFcn_mouseStart_updateMirrorPosition(varargin)
global mapper_userFcn_display;

%Enable this set of functions.
mapper_userFcn_display.mousing = 1;

%Gather the relevant variables from the mapper.
mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
[mapper_userFcn_display.beamHandles, xSpacing, ySpacing, xOffset, yOffset, spatialRotation, im, mapper_userFcn_display.mousePoints, ...
    mapper_userFcn_display.xInvert, mapper_userFcn_display.yInvert, im, beamHandles] = getLocalBatch(progmanager, mapperObj, ...
        'beamHandles', 'xSpacing', 'ySpacing', 'xPatternOffset', 'yPatternOffset', 'spatialRotation', 'videoImage', 'mousePoints', ...
        'temp_xInvert', 'temp_yInvert', 'videoImage', 'beamHandles');

xdata = get(im, 'xdata');
ydata = get(im, 'ydata');

mapper_userFcn_display.mapPattern = [];
mapper_userFcn_display.xpoints = [];
mapper_userFcn_display.ypoints = [];
mapper_userFcn_display.xOffset = xOffset;
mapper_userFcn_display.yOffset = yOffset;
mapper_userFcn_display.spatialRotation = spatialRotation;

%The radius of the circle used to display the beam position should be some fraction of the total number of pixels.
mapper_userFcn_display.beamHandleRadius = ceil(mean(xdata(2), ydata(2)) * 0.03);
% mapper_userFcn_display.beamHandleRadius = ceil(max(xSpacing, ySpacing) * 0.5);
mapper_userFcn_display.position = 1;
mapper_userFcn_display.pixels = zeros(size(mapper_userFcn_display.mapPattern));
if ~isfield(mapper_userFcn_display, 'figure')
    mapper_userFcn_display.figure = [];
    mapper_userFcn_display.axes = [];
    mapper_userFcn_display.im = [];
    mapper_userFcn_display.colorbar = [];
    mapper_userFcn_display.colorbarIm = [];
    mapper_userFcn_display.somataHandles = [];
end

%TO112907C - Make sure the beamHandles can be manipulated on the video figure.
videoF = getParent(beamHandles(1), 'figure');
fHV = get(videoF, 'HandleVisibility');
set(videoF, 'HandleVisibility', 'On');
set(beamHandles(1), 'Position', [mapper_userFcn_display.mousePoints(1, 1) - mapper_userFcn_display.beamHandleRadius, mapper_userFcn_display.mousePoints(1, 2) - mapper_userFcn_display.beamHandleRadius, ...
    2 * mapper_userFcn_display.beamHandleRadius, 2 * mapper_userFcn_display.beamHandleRadius]);
set(videoF, 'HandleVisibility', fHV);%TO112907C
setLocalBatch(progmanager, mapperObj, 'xMirrorPos', round(mapper_userFcn_display.mousePoints(1, 1)), 'yMirrorPos', round(mapper_userFcn_display.mousePoints(1, 2)));

mapper_userFcn_display.mousePosition = 1;

return;
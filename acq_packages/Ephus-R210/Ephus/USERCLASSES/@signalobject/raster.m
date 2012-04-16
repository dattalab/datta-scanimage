% raster - Parameterizes this pair of signals as a (series of) raster scan(s).
%
% SYNTAX
%   raster(xSignal, ySignal, xAmplitude, xOffset, yAmplitude, yOffset, msPerLine, linesPerFrame)
%   raster(xSignal, ySignal, xAmplitude, xOffset, yAmplitude, yOffset, msPerLine, linesPerFrame, delay)
%   raster(xSignal, ySignal, xAmplitude, xOffset, yAmplitude, yOffset, msPerLine, linesPerFrame, delay, interFrameInterval)
%   raster(xSignal, ySignal, xAmplitude, xOffset, yAmplitude, yOffset, msPerLine, linesPerFrame, delay, interFrameInterval, xPark, yPark)
%   raster(xSignal, ySignal, xAmplitude, xOffset, yAmplitude, yOffset, msPerLine, linesPerFrame, delay, interFrameInterval, xPark, yPark, numberOfFrames)
%    xSignal - The @signalobject for the 'X' (horizontal, fast-scanning) axis.
%    ySignal - The @signalobject for the 'Y' (vertical, slow-scanning) axis.
%              May be an empty array, for a 1D raster.
%    xAmplitude - The peak-to-peak amplitude of the X scan.
%    xOffset - The offset of the X-scan, equal to the minimum peak.
%    yAmplitude - The peak-to-peak amplitude of the Y scan.
%    yOffset - The offset of the Y-scan, equal to the minimum peak.
%    msPerLine - The milliseconds per line on the fast-scanning axis.
%    linesPerFrame - The total number of lines per frame, such that msPerFrame = msPerLine * linesPerFrame.
%    xPark - The X park position (where to go when not scanning).
%            Default: xOffset
%    yPark - The Y park position (where to go when not scanning).
%            Default: yOffset
%    delay - The onset delay, in milliseconds, before any scanning occurs. The signal is parked at (xOffset, yOffset).
%            Default: 0
%    interFrameInterval - The time from the start of one frame until the start of the next.
%                         Default: msPerLine * linesPerFrame
%    numberOfFrames - The total number of frames calculated.
%                     In many cases, only one is necessary, with the output repeated.
%                     Default: 1
%
% CHANGES
%
% Created: Timothy O'Connor 12/08/09 
% Copyright: Northwestern University/Howard Hughes Medical Institute 2009
function raster(xSignal, ySignal, xAmplitude, xOffset, yAmplitude, yOffset, msPerLine, linesPerFrame, varargin)

rasterify(xSignal, xAmplitude, xOffset, msPerLine, linesPerFrame, 'fast', varargin{:});%Configure X
rasterify(ySignal, yAmplitude, yOffset, msPerLine, linesPerFrame, 'slow', varargin{:});%Configure Y

%--------------------------------------------------------------------------------------------------------------
function rasterify(this, amplitude, offset, msPerLine, linesPerFrame, axisType, varargin)
global signalobjects;

%Configure X
set(this, 'Type', 'raster');
setDefaultsByType(this);
pointer = indexOf(this);

if signalobjects(pointer).deleteChildrenAutomatically
    delete(signalobjects(pointer).children);
end
signalobjects(pointer).children = [];    

signalobjects(pointer).periodic = 0;
signalobjects(pointer).amplitude = amplitude;
signalobjects(pointer).offset = offset;
signalobjects(pointer).frequency = 1000 / msPerLine;

signalobjects(pointer).rasterLinesPerFrame = linesPerFrame;
signalobjects(pointer).rasterAxis = axisType;

if length(varargin) >= 1
    signalobjects(pointer).phi = varargin{1};
else
    signalobjects(pointer).phi = 0;
end
if length(varargin) >= 2
    if varargin{2} < msPerLine * linesPerFrame
        error('interFrameInterval (%s) can not be less than msPerLine * linesPerFrame (%s).', num2str(varargin{2}), num2str(msPerLine * linesPerFrame));
    end
    signalobjects(pointer).rasterInterFrameInterval = varargin{2};
else
    signalobjects(pointer).rasterInterFrameInterval = msPerLine * linesPerFrame;
end
signalobjects(pointer).rasterPark = offset;
if strcmpi(axisType, 'fast') && length(varargin) >= 3
    signalobjects(pointer).rasterPark = varargin{3};
elseif length(varargin) >= 4
    signalobjects(pointer).rasterPark = varargin{4};
end
if length(varargin) >= 5
    signalobjects(pointer).rasterNumberOfFrames = varargin{5};
else
    signalobjects(pointer).rasterNumberOfFrames = -1;
end

return;
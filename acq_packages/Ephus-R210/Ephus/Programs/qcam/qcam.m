% qcam - A small video control program, for use with a QImaging camera (formerly qcamProto).
%
% SYNTAX
%  qcam
%
% USAGE
%  Running this command will bring up a GUI.
%  The GUI allows users to start/stop a live preview window and control acquisition, disk logging, and preprocessing.
%  A configurable look-up table is provided.
%  A zoom control is available, including a button allowing the user to draw the ROI directly on the preview.
%  The scale of the full field of view, in microns, is configurable.
%
% NOTES
%  This requires the QCam drivers from QImaging and the qcammex.mexw32.
%  See qcammex for interface and behavior details.
%
% CHANGES
%  TO060407A - Added aspect ratio locking, binning, and disk logging. -- Tim O'Connor 6/4/07
%  TO022408A - Ported qcamProto to qcam, now using qcammex.mexw32 (which in turn uses the QCamAPI from QImaging, directly). -- Tim O'Connor 2/24/08
%  TO032408A - Store filename, for Matlab to check file rollover events. -- Tim O'Connor 3/24/08
%  TO032508B - Added menu item access to set the streaming mode. -- Tim O'Connor 3/25/08
%  TO032708I - Added stdev look up table button, Snapshot button, and frames to acquire. -- Tim O'Connor 3/27/08
%  TO032708K - Recreate the image, when updating, if it has been closed. -- Tim O'Connor 3/27/08
%  TO032708L - Implemented save functions on the file menu. -- Tim O'Connor 3/27/08
%  TO033108F - Implement online auto-contrast adjustment. -- Tim O'Connor 3/31/08
%  TO033108G - Make the 'external' and 'preview' properties configurable. -- Tim O'Connor 3/31/08
%  TO033108H - Save figure position as part of configuration. -- Tim O'Connor 3/31/08
%  TO033108I - Lock the aspect ratio. -- Tim O'Connor 3/31/08
%  JL041708A - Set triggertype to auto or it keeps edgehigh after using external trigger
%  JL041708B - Add about Qcammex information
%  JL041708C - Remove the streammode and debug swiths from the menu for deploy version
%  TO071310D - Switch to use getRectFromAxes, instead of getrect. -- Tim O'Connor 7/13/10
%
% SEE ALSO
%
% Created 5/18/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function varargout = qcam(varargin)
% QCAM M-file for qcam.fig
%      QCAM, by itself, creates a new QCAM or raises the existing
%      singleton*.
%
%      H = QCAM returns the handle to a new QCAM or the handle to
%      the existing singleton*.
%
%      QCAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QCAM.M with the given input arguments.
%
%      QCAM('Property','Value',...) creates a new QCAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before qcam_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to qcam_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help qcam

% Last Modified by GUIDE v2.5 13-Jul-2010 17:29:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @qcam_OpeningFcn, ...
                   'gui_OutputFcn',  @qcam_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%---------------------------------------------------------------------
% --- Executes just before qcam is made visible.
function qcam_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to qcam (see VARARGIN)

% Choose default command line output for qcam
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
return;

% UIWAIT makes qcam wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

%---------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = qcam_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'binFactor', 1, 'Class', 'numeric', 'Gui', 'binFactor', 'Config', 7, ...
       'xOffset', 0, 'Class', 'numeric', 'Gui', 'xOffset', 'Max', 1599, 'Min', 0, 'Config', 7, ...
       'yOffset', 0, 'Class', 'numeric', 'Gui', 'yOffset', 'Max', 1199, 'Min', 0, 'Config', 7, ...
       'width', 1600, 'Class', 'numeric', 'Gui', 'width', 'Max', 1600, 'Min', 1, 'Config', 7, ...
       'height', 1200, 'Class', 'numeric', 'Gui', 'height', 'Max', 1200, 'Min', 1, 'Config', 7, ...
       'outputFile', '', 'Class', 'char', 'Gui', 'outputFile', 'Config', 7, ...
       'recordToDisk', 0, 'Class', 'numeric', 'Gui', 'recordToDisk', 'Config', 7, ...
       'timingComment', '', 'Class', 'char', 'Gui', 'timingComment', 'Config', 7, ...
       'userHeaderComment', '', 'Class', 'char', 'Gui', 'userHeaderComment', 'Config', 7, ...
       'onlineDisplayFrameRate', 10, 'Class', 'numeric', 'Gui', 'onlineDisplayFrameRate', 'Min', 0.1, 'Max', 25, 'Config', 7, ...
       'enableOnlineDisplay', 1, 'Class', 'numeric', 'Gui', 'enableOnlineDisplay', 'Config', 7, ...
       'exposure', 16.5, 'Class', 'numeric', 'Gui', 'exposure', 'Config', 7, ...
       'exposureSlider', 0.5, 'Class', 'numeric', 'Gui', 'exposureSlider', 'Min', 0, 'Max', 1, 'Config', 7, ...
       'frameAveraging', 1, 'Class', 'numeric', 'Min', 1, 'Gui', 'frameAveraging', 'Config', 7, ...
       'framesPerFile', 1, 'Class', 'numeric', 'Min', 1, 'Max', 5000, 'Gui', 'framesPerFile', 'Config', 7, ...
       'preview', 0, 'Class', 'numeric', 'Gui', 'preview', 'Config', 7, ...
       'start', 0, 'Class', 'numeric', 'Gui', 'start', 'Config', 2, ...
       'external', 0, 'Class', 'numeric', 'Gui', 'external', 'Config', 7, ...
       'namingScheme', 'Manual', 'class', 'char', 'Gui', 'namingScheme', ...
       'black', 0, 'Class', 'numeric', 'Gui', 'black', 'Min', 0, 'Config', 7, ...
       'white', 200, 'Class', 'numeric', 'Gui', 'white', 'Min', 0, 'Config', 7, ...
       'fig', [], ...
       'im', [], ...
       'debugOn', 0, 'Config', 7, ...
       'fullview', 1, 'Config', 7, ...
       'statusMessage', '', 'class', 'char', 'Gui', 'statusMessage', ...
       'diskLoggingOutputFile', '', ...
       'streamingMode', 'qcammex', 'class', 'char', 'Config', 7, ...
       'framesToAcquire', Inf, 'class', 'numeric', 'Gui', 'framesToAcquire', 'Config', 7, 'Min', 1, 'Max', Inf, ...
       'minmaxLUT', 0, 'class', 'numeric', 'Config', 7, 'Gui', 'minmaxLUT', 'Min', 0, 'Max', 1, ...
       'meanstdLUT', 0, 'class', 'numeric', 'Config', 7, 'Gui', 'meanstdLUT', 'Min', 0, 'Max', 1, ...
       'autoScaleFrameCounter', 0, 'class', 'numeric', ...
       'figurePosition', [], 'Config', 5, ...
       'simulateCamera', 0, ...
       'displayRotation', 0, 'Class', 'Numeric', 'Gui', 'displayRotation', ...
       'flipHorizontal', 0, 'Class', 'Numeric', 'Gui', 'flipHorizontal', 'Config', 5, ...
       'flipVertical', 0, 'Class', 'Numeric', 'Gui', 'flipVertical', 'Config', 5, ...
   };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'displayTimer', timer('BusyMode', 'drop', 'ExecutionMode', 'fixedRate', ...
    'Name', 'displayTimer', 'Period', 0.2, 'StartDelay', 0.2, 'TasksToExecute', inf, 'TimerFcn', {@displayTimerFcn_Callback, hObject}));

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~getLocal(progmanager, hObject, 'simulateCamera')
    qcammex('releaseDriver');%Clean up afer a possible crash or previous bad shutdown.
    qcammex('loadCamera');%Try to load the camera immediately.
end
cbm = getUserFcnCBM;
%TO060910B - Check for event existence before adding the event. -- Tim O'Connor 6/9/10
if ~isEvent(cbm, 'qcam:FileFinalized')
    addEvent(cbm, 'qcam:FileFinalized');
end

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

fig = getLocal(progmanager, hObject, 'fig');
if ishandle(fig)
    delete(fig);
end

displayTimer = getLocal(progmanager, hObject, 'displayTimer');
if ~isempty(displayTimer)
    delete(displayTimer);
    setLocal(progmanager, hObject, 'displayTimer', []);
end

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~getLocal(progmanager, hObject, 'simulateCamera')
    qcammex('stop');
    qcammex('releaseDriver');
end

%TO060910B - Remove the event when we're done. -- Tim O'Connor 6/9/10
removeEvent(getUserFcnCBM, 'qcam:FileFinalized');

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 1.2;

return;

% ------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

%TO033108H
fig = getLocal(progmanager, hObject, 'fig');
if ishandle(fig)
    setLocal(progmanager, hObject, 'figurePosition', get(fig, 'Position'));
end

return;

% ------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPreLoadMiniSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles, varargin)

setLocalBatch(progmanager, hObject, 'start', 0);%TO033108G - Don't reset external or preview, we may want it turned on by the config.
updateVidSettings(hObject);

[minmaxLUT, meanstdLUT, figurePosition, fig, im] = getLocalBatch(progmanager, hObject, 'minmaxLUT', 'meanstdLUT', 'figurePosition', 'fig', 'im');

%TO102508A - Turns out that `ishandle([])` returns `[]`, so check for emptiness first.
%TO111908E - Fixed the line below, from: `if ~isempty(fig) && ~isempty(handle)` -- Tim O'Connor 11/19/08
if ~isempty(fig) && ~isempty(ishandle(fig))
    %TO033108H
    if ishandle(fig) && ishandle(im)
        if ~isempty(figurePosition)
            set(fig, 'Position', figurePosition);
        end
        %TO033108F - Implement online auto-contrast adjustment.
        if minmaxLUT
            minmaxLUT_Callback(hObject, [], []);
        elseif meanstdLUT
            meanstdLUT_Callback(hObject, [], []);
        end
    end
end

return;

% ------------------------------------------------------------------
function genericPostLoadMiniSettings(hObject, eventdata, handles, varargin)

genericPostLoadSettings(hObject, eventdata, handles, varargin{:});

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

gotThreeData = 0;
[filename, pathname] = uigetfile(fullfile(getDefaultCacheDirectory(progmanager, 'qcamDir'), '\*.qcamraw'));
if isequal(filename, 0) || isequal(pathname, 0)
    return;
end

pf = fopen(fullfile(pathname, filename), 'r');
fseek(pf, 0, 'eof');
fsize = ftell(pf);

%get header infomation from the file
frewind(pf);
while gotThreeData < 3 
    tline = fgets(pf);
    [left, rem] = strtok( tline, ':');
    if strcmp(left, 'Fixed-Header-Size')
        right = strtok(rem, ':');
        fHeaderSize = strtok(right);
        fHeaderSize = str2num(fHeaderSize);
        gotThreeData = gotThreeData +1;
    elseif strcmp(left, 'Frame-Size')
        right = strtok(rem, ':');
        frameSize = strtok(right);
        frameSize = str2num(frameSize);
        gotThreeData = gotThreeData +1;
    elseif strcmp(left, 'ROI')
        right = strtok(rem, ':');
        [left, right]=strtok(right, ',');
        [left, right]=strtok(right, ',');
        [width, right]=strtok(right, ',');
        height = strtok(right, ',');
        width = str2num(width);
        height = str2num(height);
        gotThreeData = gotThreeData +1;
    else   
        continue;
    end
end

numberOfFrames = (fsize -fHeaderSize)/frameSize;

%numberOfFrames = qcammex('getNumberOfFrames', fullfile(pathname, filename))

frameNumber = inputdlg(['Load frame number(s) [no values higher than ' num2str(numberOfFrames) ' allowed]:'], 'List frame(s)...', 1, {'1'});
if isempty(frameNumber)
    return;
end
frameNumber = frameNumber{1};
if isempty(frameNumber)
    return;
end
frameNumber = str2num(frameNumber);
if isempty(frameNumber)
    errordlg('Invalid list of frames. Must evaluate to a Matlab array.');
    return;
end
if frameNumber > numberOfFrames
    errordlg(['Frame number (' num2str(frameNumber) ') exceeded maximum (' num2str(numberOfFrames) ').']);
    return;
end

%frameData = qcammex('getFrames', fullfile(pathname, filename), frameNumber);

for i = 1 : length(frameNumber)
    fseek(pf, fHeaderSize + (frameNumber(i)-1)* frameSize, 'bof');
    frameData = fread(pf, [width, height], 'uint16');
    f = figure('Name', [filename ':' num2str(frameNumber(i))], 'NumberTitle', 'Off', 'IntegerHandle', 'Off');
    set(f, 'ColorMap', gray);
    ax = axes('Parent', f);
    %imagesc(frameData(:, :, i), 'Parent', ax);
    imagesc(frameData', 'Parent', ax);
    setDefaultCacheValue(progmanager, 'qcamDir', pathname);
end

return;

% ------------------------------------------------------------------
%TO032708L
function genericSaveProgramData(hObject, eventdata, handles)

genericSaveProgramDataAs(hObject, eventdata, handles);
return;

% ------------------------------------------------------------------
%TO032708L
function genericSaveProgramDataAs(hObject, eventdata, handles)
im = getLocal(progmanager, hObject, 'im');
if ~ishandle(im)
    errordlg('No image to save.');
    return;
end

[filename, pathname] = uiputfile([getDefaultCacheDirectory(progmanager, 'qcamSaveImagePath') '\*.tif']);
if length(filename) == 1
    if filename == 0
        return;
    end
end

if ~endsWithIgnoreCase(filename, '.tiff') && ~endsWithIgnoreCase(filename, '.tif')
    filename = [filename '.tif'];
end
setDefaultCacheValue(progmanager, 'qcamSaveImagePath', pathname);

qcamHeader = get(im, 'UserData');
[xOffset, yOffset, width, height, frameAveraging, exposure, binFactor, userHeaderComment, userHeaderComment] = getLocalBatch(progmanager, hObject, ...
    'xOffset', 'yOffset', 'width', 'height', 'frameAveraging', 'exposure', 'binFactor', 'userHeaderComment', 'userHeaderComment');
header = sprintf('qcam v%s image\r\n', getVersion(hObject, [], []));
header = sprintf('%sROI: %s, %s, %s, %s\r\n', header, num2str(xOffset), num2str(yOffset), num2str(width), num2str(height));
header = sprintf('%sTemporal-Averaging: %s [frames]\r\n', header, num2str(frameAveraging));
header = sprintf('%sExposure: %s [ms]\r\n', header, num2str(exposure));
header = sprintf('%sSpatial-Binning: %sx%s [pixels]\r\n', header, num2str(binFactor), num2str(binFactor));
if ~isempty(qcamHeader)
    if isfield(qcamHeader, 'timestamp')
        header = sprintf('%sTimestamp: %s\r\n', header, datestr(qcamHeader.timestamp));
    else
        header = sprintf('%sTimestamp: %s\r\n', header, datestr(now));
    end
end
header = sprintf('%sUser-Timing-Data: ''%s''\r\n', header, userHeaderComment);
header = sprintf('%sUser-Defined-Header: ''%s''\r\n', header, userHeaderComment);
if ~isempty(qcamHeader)
    if isfield(qcamHeader, 'type')
        header = sprintf('%sAcquisition-Type: %s\r\n', header, qcamHeader.type);
    else
        header = sprintf('%sAcquisition-Type: UNKNOWN\r\n', header);
    end
end
fprintf(1, 'qcam: %s - Saved image to ''%s''\n', datestr(now), fullfile(pathname, filename));
imwrite(uint16(get(im, 'CData')), fullfile(pathname, filename), 'tif', 'Description', header);

return;

% ------------------------------------------------------------------
function genericPreCacheSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPreCacheMiniSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostCacheSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostCacheMiniSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCacheOperationBegin(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCacheOperationComplete(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function startDisplayTimer(hObject)

[displayTimer, onlineDisplayFrameRate] = getLocalBatch(progmanager, hObject, 'displayTimer', 'onlineDisplayFrameRate');
set(displayTimer, 'Period', roundTo(1/onlineDisplayFrameRate, 3));
start(displayTimer);

return;

%---------------------------------------------------------------------
% --- Executes on button press in preview.
function preview_Callback(hObject, eventdata, handles)

% if getLocal(progmanager, hObject, 'preview')
%     updateVidSettings(hObject);
% else
    updateVidSettings(hObject);
% end

return;

% --------------------------------------------------------------------
% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)

        updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in external.
function external_Callback(hObject, eventdata, handles)

        updateVidSettings(hObject);   

return;

%---------------------------------------------------------------------
function stopPreview(hObject)

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~getLocal(progmanager, hObject, 'simulateCamera')
    qcammex('stop');
end

stop(getLocal(progmanager, hObject, 'displayTimer'));

setLocal(progmanager, hObject, 'statusMessage', '');

return;

%---------------------------------------------------------------------
function white_Callback(hObject, eventdata, handles)

setCLims(hObject);
setLocalBatch(progmanager, hObject, 'meanstdLUT', 0, 'minmaxLUT', 0);%TO033108F

return;

%---------------------------------------------------------------------
function white_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%---------------------------------------------------------------------
function black_Callback(hObject, eventdata, handles)

setCLims(hObject);
setLocalBatch(progmanager, hObject, 'meanstdLUT', 0, 'minmaxLUT', 0);%TO033108F

return;

%---------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function black_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%---------------------------------------------------------------------
function setCLims(hObject)

[im, blackVal, whiteVal] = getLocalBatch(progmanager, hObject, 'im', 'black', 'white');
if ~ishandle(im)
    return;
end

set(get(im, 'Parent'), 'CLim', [blackVal, whiteVal]);

return;

%---------------------------------------------------------------------
function roiSize = getROISize(hObject)

%In pixel coordinates: roi = [xoffset, yoffset, width, height].
[width, height] = getLocalBatch(progmanager, hObject, 'width', 'height');

%roiSize = [width, height];
roiSize = [height, width];

return;

%---------------------------------------------------------------------
function roi = getROI(hObject)

%In pixel coordinates: roi = [xoffset, yoffset, width, height].
[xOffset, yOffset, width, height] = getLocalBatch(progmanager, hObject, 'xOffset', 'yOffset', 'width', 'height');
roi = [xOffset, yOffset, width, height];

return;

%---------------------------------------------------------------------
function scale = getScale(hObject)

[xMicrons, yMicrons] = getLocalBatch(progmanager, hObject, 'xMicrons', 'yMicrons');
scale = [xMicrons, yMicrons];

return;

%---------------------------------------------------------------------
function updateImageAxes(hObject)

im = getLocal(progmanager, hObject, 'im');
roi = getROI(hObject);
%Stupid stuff goes on here, because Matlab uses retarded up coordinate conventions.
%It looks like the preview window doesn't like axes being displayed with tick marks, no matter what is done.
% xdata = [roi(1) : roi(3) - 1] * umPerPixel(1);
% % xLims = [xdata(1) xdata(end)]
% ydata = [roi(2) : roi(4) - 1] * umPerPixel(2);
% % yLims = [ydata(1) ydata(end)]
% % set(im, 'XData', xdata, 'YData', ydata);
% % set(get(im, 'Parent'), 'XTickMode', 'auto', 'YTickMode', 'auto');
ax = get(im, 'Parent'); 
set(ax, 'XTickMode', 'auto', 'YTickMode', 'auto', 'Position', [0 0 1 1]);

return;

%---------------------------------------------------------------------
%TO062208B - Allow cloning of image windows, for another type of "snapshot". -- Tim O'Connor 6/22/08
function cloneFig(varargin)

hObject = varargin{end};
% hObject = getParent(hObject, 'figure');
[fig1, im, figurePosition] = getLocalBatch(progmanager, hObject, 'fig', 'im', 'figurePosition');
if ishandle(fig1)
    pos = get(fig1, 'Position');
end
if isempty(pos)
    pos = figurePosition;
end
pos = [pos(1) + 0.25 * pos(3), pos(2) - 0.25 * pos(4), pos(3), pos(4)];

fig = figure('Name', sprintf('qcam_v0.1 Cloned @ %s', datestr(now)), ...
    'NumberTitle', 'Off', 'IntegerHandle', 'Off');
movegui(fig);%Make sure the figure pops up on the main screen initially.
set(fig, 'ColorMap', gray);
if ~isempty(pos)
    set(fig, 'Position', pos);
elseif ~isempty(figurePosition)
    set(fig, 'Position', figurePosition);
end

copyobj(get(fig1, 'Children'), fig);

return;

%---------------------------------------------------------------------
function initImage(hObject)

pos = [];
[fig, im, figurePosition] = getLocalBatch(progmanager, hObject, 'fig', 'im', 'figurePosition');
if ishandle(fig)
    pos = get(fig, 'Position');
    delete(fig);
end
if ishandle(im)
    delete(im);
end

fig = figure('Name', 'qcam_v0.1 Preview Window', ...
    'NumberTitle', 'Off', 'IntegerHandle', 'Off');
movegui(fig);%Make sure the figure pops up on the main screen initially.
set(fig, 'ColorMap', gray);
if ~isempty(pos)
    set(fig, 'Position', pos);
elseif ~isempty(figurePosition)
    set(fig, 'Position', figurePosition);
end
setLocal(progmanager, hObject, 'fig', fig);

%TO062208B - Allow cloning of image windows, for another type of "snapshot". -- Tim O'Connor 6/22/08
uimenu(fig, 'Label', '&Clone', 'Position', 9, 'Callback', {@cloneFig, hObject}, 'Tag', 'clone');

ax = axes('Parent', fig);
im = imagesc(zeros(getROISize(hObject)), 'Parent', ax);%Matlab nonsense about retarded changing of coordinate systems.
daspect(ax, [1 1 1]);

setLocal(progmanager, hObject, 'im', im);

updateImageAxes(hObject);

setCLims(hObject);

return;

%---------------------------------------------------------------------
%TO060407A
function lockedAspectRatioResizeFcn(hObject, eventdata, handles)

if get(handles.lockAspectRatio, 'Value')
    roi = getROI(hObject);
    pos = get(hObject, 'Position');
    pos(3) = pos(4) * roi(3) / roi(4);
    set(hObject, 'Position', pos);
end

return;

%---------------------------------------------------------------------
%TO060407A
function binFactor = getBinFactor(hObject)

binFactor = getLocal(progmanager, hObject, binFactor);
if isempty(binFactor)
    binFactor = 1;
else
    binFactor = round(binFactor);
end

return;

%---------------------------------------------------------------------
function updateVidSettings(hObject)

[binFactor, xOffset, yOffset, width, height, outputFile, recordToDisk, timingComment, userHeaderComment, displayTimer, debugOn, oldDiskLoggingOutputFile, framesToAcquire, ...
    onlineDisplayFrameRate, enableOnlineDisplay, exposure, frameAveraging, framesPerFile, preview, start, external, namingScheme, fullview,streamingMode, simulateCamera] = getLocalBatch(progmanager, hObject, ...
    'binFactor', 'xOffset', 'yOffset', 'width', 'height', 'outputFile', 'recordToDisk', 'timingComment', 'userHeaderComment', 'displayTimer','debugOn', 'diskLoggingOutputFile', 'framesToAcquire', ...
    'onlineDisplayFrameRate', 'enableOnlineDisplay', 'exposure', 'frameAveraging', 'framesPerFile', 'preview', 'start', 'external', 'namingScheme', 'fullview', 'streamingMode', 'simulateCamera');

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~simulateCamera
    %TO032408A - Poll the current output file.
    diskLoggingOutputFile = qcammex('getOutputFileName');
else
    diskLoggingOutputFile = '';
end

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~simulateCamera
    % JL04022008A setFilename to empty string should be put in front of stop to avoid Matlab crash
    qcammex('setFilename', '');
end
stop(displayTimer);
%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~simulateCamera
    %Stop the camera before changing settings.
    qcammex('stop');
end

setLocal(progmanager, hObject, 'statusMessage', '');

%TO032408A - Fire a finalization event.
if ~isempty(diskLoggingOutputFile)
    fireEvent(getUserFcnCBM, 'qcam:FileFinalized', diskLoggingOutputFile);
end
setLocal(progmanager, hObject, 'diskLoggingOutputFile', '');
if fullview
      width = 1600 / binFactor;
      height = 1200 / binFactor;
end

setLocalBatch(progmanager, hObject, 'width', width, 'height', height);


if recordToDisk && ~preview
    if strcmpi(namingScheme, 'XSG')
        [pathname, filename, ext] = fileparts(xsg_getFilename);%Remove the extension, if it exists, as per qcammex.
        outputFile = fullfile(pathname, filename);
    else
        [pathname, filename, ext] = fileparts(outputFile);
    end
    if exist(pathname, 'dir') ~= 7
        fprintf(2, 'qcam - Invalid save path ''%s'' for disk logging.\n', pathname);
        errordlg('qcam - Invalid save path for disk logging.');
        %TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
        if ~simulateCamera
            qcammex('setFilename', '');
        end
        preview = 0;
        start = 0;
        external = 0;
        setLocalBatch(progmanager, hObject, 'preview', 0, 'start', 0, 'external', 0);
    else
        %TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
        if ~simulateCamera
            qcammex('setFilename', outputFile);
            qcammex('setFramesPerFile', framesPerFile);
            qcammex('setFramesToAcquire', framesToAcquire);
        end
    end
end

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~simulateCamera
    qcammex('debugOn', debugOn);
    qcammex('setROI', xOffset, yOffset, width, height);
    qcammex('setBinFactor', binFactor);
    qcammex('setImageFormatToMono16');
    qcammex('setUserHeaderField', userHeaderComment);
    qcammex('setUserTimingField', timingComment);
    qcammex('setAverageFrames', frameAveraging);
    qcammex('setExposureTime', 1000000 * exposure);%Convert to nanoseconds.

    if preview
        qcammex('setTriggerType', 'auto');
        qcammex('setCameraMode', 'rtv'); % set the camera mode to the real time viewing mode, RTV mode is avaliable on MicroPublisher models
    elseif start
        qcammex('setTriggerType', 'auto');
        qcammex('setCameraMode', 'std'); % set the camera mode to the standard mode,
    elseif external
        qcammex('setTriggerType', 'edgeHigh');
        qcammex('setCameraMode', 'std'); % set the camera mode to the standard mode,
    end

    qcammex('commitSettingsToCam');
end

if (start || external) && (recordToDisk) && (exist([outputFile '.qcamraw'], 'file') == 2)
    errordlg('qcam - the specified file exists!');
    %TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
    if ~simulateCamera
        qcammex('setFilename', '');
    end
    setLocalBatch(progmanager, hObject, 'preview', 0, 'start', 0, 'external', 0);
    return;
end

if preview
    setLocalGh(progmanager, hObject, 'preview', 'String', 'Stop', 'ForegroundColor', [1 0 0]);
else
    setLocalGh(progmanager, hObject, 'preview', 'String', 'Preview', 'ForegroundColor', [0.2 0.8 0.2]);
end
if start
    setLocalGh(progmanager, hObject, 'start', 'String', 'Stop', 'ForegroundColor', [1 0 0]);
else
    setLocalGh(progmanager, hObject, 'start', 'String', 'Start', 'ForegroundColor', [0.2 0.8 0.2]);
end
if external
    setLocalGh(progmanager, hObject, 'external', 'String', 'Stop', 'ForegroundColor', [1 0 0]);
else
    setLocalGh(progmanager, hObject, 'external', 'String', 'External', 'ForegroundColor', [0.2 0.8 0.2]);
end

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~simulateCamera
    qcammex('setStreamingMode', streamingMode);
end
if start || external || preview
    if enableOnlineDisplay
        initImage(hObject);
    end
    
    %TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
    if ~simulateCamera
        %Restart the camera, if necessary.
        qcammex('start');
    end
    
    if enableOnlineDisplay
        startDisplayTimer(hObject);
    end
end

return;

%---------------------------------------------------------------------
%TO060407A
function displayTimerFcn_Callback(timerObject, eventdata, hObject)

[im,preview, start, external, minmaxLUT, meanstdLUT, autoScaleFrameCounter, onlineDisplayFrameRate, simulateCamera, displayRotation, ...
    flipHorizontal, flipVertical] = getLocalBatch(progmanager, hObject, ...
    'im', 'preview', 'start', 'external', 'minmaxLUT', 'meanstdLUT', 'autoScaleFrameCounter', 'onlineDisplayFrameRate', 'simulateCamera', 'displayRotation', ...
    'flipHorizontal', 'flipVertical');
if ~(preview || start || external)
    return;
end

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if simulateCamera
    roiSize = getROISize(hObject);%[width, height]
    imdata = 500 * rand([roiSize(2) roiSize(1)]);
    frameRate = 0;
    totalframe = 0;
else
    [imdata, frameRate, totalframe] = qcammex('getCurrentFrame');
end
timestamp = now;

%TO032408A - Poll the current output file, and fire an event if the file has been finalized.
if ~simulateCamera
    diskLoggingOutputFile = qcammex('getOutputFileName');
    oldOutputFile = getLocal(progmanager, hObject, 'diskLoggingOutputFile');
    if ~isempty(oldOutputFile)
        if ~strcmpi(diskLoggingOutputFile, oldOutputFile)
            fireEvent(getUserFcnCBM, 'qcam:FileFinalized', oldOutputFile);
        end
    end
    setLocal(progmanager, hObject, 'diskLoggingOutputFile', diskLoggingOutputFile);
end

if ~isempty(imdata)
    im = getLocal(progmanager, hObject, 'im');
    %TO032708K
    if ~ishandle(im)
        initImage(hObject);
        im = getLocal(progmanager, hObject, 'im');
    end

    %TO071310G - Add a horizontal and vertical flip to the display. -- Tim O'Connor 7/13/10
    if flipHorizontal
        imdata = fliplr(imdata);
    end
    if flipVertical
        imdata = flipup(imdata);
    end

    if displayRotation ~= 0
        try
            %TO071310F - Only use imrotate if it's available, otherwise round to the nearest 90-degree increment and do a matrix rotation. -- Tim O'Connor 7/13/10
            if exist('imrotate', 'file') == 2
                imdata = imrotate(imdata, displayRotation, 'nearest', 'loose');
            else
                switch round(mod(displayRotation, 360) / 90)
                    case 1
                        imdata = rot90(imdata);
                    case 2
                        imdata = rot90(imdata);
                        imdata = rot90(imdata);
                    case 3
                        imdata = rot90(imdata);
                        imdata = rot90(imdata);
                        imdata = rot90(imdata);
                end
            end
        catch
            fprintf(2, '%s - qcam - Failed to rotate display image: ''%s''\n', datestr(now), lasterr);
        end
    end

    set(im, 'CData', imdata');

    header = get(im, 'UserData');
    qcamHeader.timestamp = timestamp;
    if preview
        qcamHeader.type = 'preview';
    elseif start
        qcamHeader.type = 'start';
    elseif external
        qcamHeader.type = 'external';
    end
    set(im, 'UserData', qcamHeader);

    drawnow;
end

%TO033108F - Implement online auto-contrast adjustment.
if autoScaleFrameCounter >= onlineDisplayFrameRate
    if minmaxLUT
        minmaxLUT_Callback(hObject, [], []);
    elseif meanstdLUT
        meanstdLUT_Callback(hObject, [], []);
    end
    autoScaleFrameCounter = 0;
else
    autoScaleFrameCounter = autoScaleFrameCounter + 1;
end
setLocalBatch(progmanager, hObject, 'statusMessage', ['Frame rate: ' num2str(roundTo(frameRate, 2)) ' [Hz]' 10 'Total frames: ',num2str(totalframe)], ...
    'autoScaleFrameCounter', autoScaleFrameCounter);%10 == '\n'

return;

%---------------------------------------------------------------------
function framesPerTrigger_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

%---------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function framesPerTrigger_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%---------------------------------------------------------------------
function yMicrons_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

%---------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yMicrons_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%---------------------------------------------------------------------
function xOffset_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

%---------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xOffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%---------------------------------------------------------------------
function yOffset_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

%---------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yOffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%---------------------------------------------------------------------
function width_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

%---------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function width_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%---------------------------------------------------------------------
function height_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

%---------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function height_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%---------------------------------------------------------------------
% --- Executes on button press in zoom.
function zoom_Callback(hObject, eventdata, handles)

newROI = round(getRectFromAxes(getLocal(progmanager, hObject, 'fig')));%TO071310D

roi = getROI(hObject);

setLocalBatch(progmanager, hObject, ...
   'xOffset', roi(1) + newROI(1), 'yOffset', roi(2) + newROI(2), 'width', newROI(3), 'height', newROI(4), 'fullview', 0);

[preview, start, external] = getLocalBatch(progmanager, hObject, 'preview', 'start', 'external');
if ~(preview || start || external)
    snapshot_Callback(hObject, eventdata, handles);
else
    updateVidSettings(hObject);
end

return;

%---------------------------------------------------------------------
% --- Executes on button press in resetZoom.
function resetZoom_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, ...
    'xOffset', 0, 'yOffset', 0, 'width', 1600, 'height', 1200, 'fullview', 1);

[preview, start, external] = getLocalBatch(progmanager, hObject, 'preview', 'start', 'external');

if ~(preview || start || external)
     snapshot_Callback(hObject, eventdata, handles);
else
    updateVidSettings(hObject);
end

return;

% --------------------------------------------------------------------
% --- Executes on button press in lockAspectRatio.
function lockAspectRatio_Callback(hObject, eventdata, handles)

lockedAspectRatioResizeFcn(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function binFactor_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function binFactor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
function outputFile_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function outputFile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
% --- Executes on button press in aviFileBrowse.
function aviFileBrowse_Callback(hObject, eventdata, handles)

fname = getLocal(progmanager, hObject, 'outputFile');
if isempty(fname)
    pathname = getDefaultCacheDirectory(progmanager, 'qcamDir');
else
    [fname, pathname] = fileparts(fname);
end
[filename, pathname] = uiputfile(fullfile(pathname, '*.qcamraw'), 'Save frame data as...');
if length(pathname) == 1 && length(filename) == 1
    return;%Cancel.
end
[pathname, filename, ext] = fileparts(fullfile(pathname, filename));%Remove the extension, if it exists, as per qcammex.
setLocal(progmanager, hObject, 'outputFile', fullfile(pathname, filename));
setDefaultCacheValue(progmanager, 'qcamDir', pathname);
updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in recordToDisk.
function recordToDisk_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
function exposure_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function exposure_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
function frameAveraging_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function frameAveraging_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
function onlineDisplayFrameRate_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function onlineDisplayFrameRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
% --- Executes on button press in enableOnlineDisplay.
function enableOnlineDisplay_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
function framesPerFile_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function framesPerFile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
function xMicrons_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xMicrons_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
function userHeaderComment_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function userHeaderComment_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
% --- Executes on selection change in fileFormat.
function fileFormat_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function fileFormat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
% --- Executes on selection change in namingScheme.
function namingScheme_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function namingScheme_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
% --- Executes on button press in minmaxLUT.
function minmaxLUT_Callback(hObject, eventdata, handles)

%TO033108F - Implement online auto-contrast adjustment.
if ~getLocal(progmanager, hObject, 'minmaxLUT')
    return;
end

imdata = get(getLocal(progmanager, hObject, 'im'), 'CData');
%im = getLocal(progmanager, hObject, 'im');
white = roundTo(max(max(imdata)), 0);
black = roundTo(min(min(imdata)), 0);
if black == white
    white = black + 1;
end
setLocalBatch(progmanager, hObject, 'white', white, 'black', black, 'meanstdLUT', 0);
setCLims(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in histogram.
function histogram_Callback(hObject, eventdata, handles)

imdata = get(getLocal(progmanager, hObject, 'im'), 'CData');
figure;
hist(single(reshape(imdata, [numel(imdata), 1])), 256);
title('Pixel Value Histogram');
xlabel('Pixel Value');

return;

% --------------------------------------------------------------------
function getCameraInfo_Callback(hObject, eventdata, handles)

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~getLocal(progmanager, hObject, 'simulateCamera')
    qcammex('printCamera');
end

return;

% --------------------------------------------------------------------
function releaseDriver_Callback(hObject, eventdata, handles)

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~getLocal(progmanager, hObject, 'simulateCamera')
    qcammex('releaseDriver');
end

return;

% --------------------------------------------------------------------
% JL041708B Add about Qcammex information
function aboutQcammex_Callback(hObject, eventdata, handles)

helpdlg(['qcammex version ' num2str(getVersion(hObject, eventdata, handles)) 10 'Copyright: CSHL/HHMI 2008'...
    10 'Authours: Tim O' 39 'Connor & Jinyang Liu' 10 'April 2008'],'About qcammex');

return;

% --- Executes on slider movement.
function exposureSlider_Callback(hObject, eventdata, handles)

[exposure, slider] = getLocalBatch(progmanager, hObject, 'exposure', 'exposureSlider');
if slider > 0.5
    setLocalBatch(progmanager, hObject, 'exposure', exposure + 5, 'exposureSlider', 0.5);
else
    setLocalBatch(progmanager, hObject, 'exposure', exposure - 5, 'exposureSlider', 0.5);
end

updateVidSettings(hObject);

return;

% --- Executes during object creation, after setting all properties.
function exposureSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
return;

% --------------------------------------------------------------------
function timingComment_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function timingComment_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
function printState_Callback(hObject, eventdata, handles)

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~getLocal(progmanager, hObject, 'simulateCamera')
    qcammex('printState');
end

return;

% --------------------------------------------------------------------
function reset_Callback(hObject, eventdata, handles)

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~getLocal(progmanager, hObject, 'simulateCamera')
    qcammex('reset');
end

return;

% --------------------------------------------------------------------
function loadCamera_Callback(hObject, eventdata, handles)

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if ~getLocal(progmanager, hObject, 'simulateCamera')
    qcammex('loadCamera');%Try to load the camera immediately.
end

return;

% --------------------------------------------------------------------
function debugOn_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'debugOn', 1);
updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
function debugOff_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'debugOn', 0);
updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
function streamingModeMenuItem_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function streamingModeQCamMex_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'streamingMode', 'qcammex');
updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
function streamingModeAPI_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'streamingMode', 'API');
updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in meanstdLUT.
function meanstdLUT_Callback(hObject, eventdata, handles)

%TO033108F - Implement online auto-contrast adjustment.
if ~getLocal(progmanager, hObject, 'meanstdLUT')
    return;
end

imdata = get(getLocal(progmanager, hObject, 'im'), 'CData');
imdata = reshape(imdata, [numel(imdata) 1]);
centroid = mean(imdata);
sigma = std(double(imdata));

white = roundTo(max(centroid + 2 * sigma, 1), 0);
black = roundTo(max(centroid - 2 * sigma, 0), 0);
if black == white
    white = black + 1;
end
setLocalBatch(progmanager, hObject, 'white', white, 'black', black, 'minmaxLUT', 0);
setCLims(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in snapshot.
function snapshot_Callback(hObject, eventdata, handles)

[preview, start, external, minmaxLUT, meanstdLUT, simulateCamera] = getLocalBatch(progmanager, hObject, ...
    'preview', 'start', 'external', 'minmaxLUT', 'meanstdLUT', 'simulateCamera');

if ~(preview || start || external)
    updateVidSettings(hObject);
    initImage(hObject);
end

im = getLocal(progmanager, hObject, 'im');

%TO062208A - Allow simulation of the camera, for GUI development without a $12,000 piece of hardware.
if simulateCamera
    roiSize = getROISize(hObject);%[width, height]
    imdata = 500 * rand([roiSize(2) roiSize(1)]);
else
    %JL04172008A Set triggertype to auto or it keeps edgehigh after using external trigger
    qcammex('setTriggerType', 'auto');
    imdata = qcammex('getSnapshot');
end
timestamp = now;

if ~isempty(imdata)
    %set(im, 'CData', double(imdata));
    set(im, 'CData', imdata');

    header = get(im, 'UserData');
    qcamHeader.timestamp = timestamp;
    qcamHeader.type = 'snapshot';
    set(im, 'UserData', qcamHeader);

    drawnow;
end

%TO033108F - Implement online auto-contrast adjustment.
if minmaxLUT
    minmaxLUT_Callback(hObject, [], []);
elseif meanstdLUT
    meanstdLUT_Callback(hObject, [], []);
end

return;

% --------------------------------------------------------------------
function framesToAcquire_Callback(hObject, eventdata, handles)

updateVidSettings(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function framesToAcquire_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
function about_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function About_Callback(hObject, eventdata, handles)
return;

function displayRotation_Callback(hObject, eventdata, handles)

if exist('imrotate', 'file') ~= 2
    displayRotation = getLocal(progmanager, hObject, 'displayRotation');
    if ~any(mod(displayRotation, 360) / 90 == [0, 1, 2, 3])
        warndlg('The image processing toolbox does not appear to be available. Only rotations in increments of 90 degrees are supported.');
        switch round(mod(displayRotation, 360) / 90)
            case 1
                setLocal(progmanager, hObject, 'displayRotation', 90);
                fprintf(1, '%s - qcam: Requested image rotation of %s degrees is only available with the image processing toolbox. The rotation has been rounded to the nearest 90 degree increment (90).\n', ...
                    datestr(now), num2str(displayRotation));
            case 2
                setLocal(progmanager, hObject, 'displayRotation', 180);
                fprintf(1, '%s - qcam: Requested image rotation of %s degrees is only available with the image processing toolbox. The rotation has been rounded to the nearest 180 degree increment (90).\n', ...
                    datestr(now), num2str(displayRotation));
            case 3
                setLocal(progmanager, hObject, 'displayRotation', 270);
                fprintf(1, '%s - qcam: Requested image rotation of %s degrees is only available with the image processing toolbox. The rotation has been rounded to the nearest 270 degree increment (90).\n', ...
                    datestr(now), num2str(displayRotation));
        end
    end
end

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function displayRotation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
% --- Executes on button press in flipHorizontal.
function flipHorizontal_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
% --- Executes on button press in flipVertical.
function flipVertical_Callback(hObject, eventdata, handles)
return;
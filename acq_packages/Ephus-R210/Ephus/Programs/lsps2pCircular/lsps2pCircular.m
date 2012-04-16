function varargout = lsps2pCircular(varargin)
% LSPS2PCIRCULAR M-file for lsps2pCircular.fig
%      LSPS2PCIRCULAR, by itself, creates a new LSPS2PCIRCULAR or raises the existing
%      singleton*.
%
%      H = LSPS2PCIRCULAR returns the handle to a new LSPS2PCIRCULAR or the handle to
%      the existing singleton*.
%
%      LSPS2PCIRCULAR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LSPS2PCIRCULAR.M with the given input arguments.
%
%      LSPS2PCIRCULAR('Property','Value',...) creates a new LSPS2PCIRCULAR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lsps2pCircular_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lsps2pCircular_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lsps2pCircular

% Last Modified by GUIDE v2.5 08-Nov-2004 20:45:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lsps2pCircular_OpeningFcn, ...
                   'gui_OutputFcn',  @lsps2pCircular_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before lsps2pCircular is made visible.
function lsps2pCircular_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lsps2pCircular (see VARARGIN)

% Choose default command line output for lsps2pCircular
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lsps2pCircular wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lsps2pCircular_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

startButton_Callback(hObject, eventdata, handles);

%Mirror signal display.
f1 = figure('Doublebuffer', 'On', 'Tag', 'lsps2pCircularPockelsDisplayFigure', 'Name', 'Scan Signal', 'NumberTitle', 'Off', ...
    'CloseRequestFcn', 'set(gcf, ''Visible'', ''Off'');', 'Visible', 'On');
a1 = axes('Parent', f1, 'Tag', 'lsps2pCircularMirrorDisplayAxes');
setLocal(progmanager, hObject, 'mirrorSignalDisplayFigure', f1);
setLocal(progmanager, hObject, 'mirrorSignalDisplayAxes', a1);
p1 = plot(0:1, ':o', 'Parent', a1, 'Tag', 'lsps2pCircularMirrorDisplayPlot');
pbaspect(a1, [1 1 1]);
set(get(a1, 'Title'), 'String', 'Mirror Signals');
set(get(a1, 'XLabel'), 'String', 'X-Mirror Signal [V]');
set(get(a1, 'YLabel'), 'String', 'Y-Mirror Signal [V]');
setLocal(progmanager, hObject, 'mirrorDisplayPlot', p1);


%Pockels signal display.
f2 = figure('Doublebuffer', 'On', 'Tag', 'lsps2pCircularPockelsDisplayFigure', 'Name', 'Pockels Cell Signal', 'NumberTitle', 'Off', ...
    'CloseRequestFcn', 'set(gcf, ''Visible'', ''Off'');', 'Visible', 'Off');
a2 = axes('Parent', f2, 'Tag', 'lsps2pCircularPockelsDisplayAxes');
setLocal(progmanager, hObject, 'pockelsSignalDisplayFigure', f2);
setLocal(progmanager, hObject, 'pockelsSignalDisplayAxes', a2);
p2 = plot(0:1, ':o', 'Parent', a2, 'Tag', 'lsps2pCircularPockelsDisplayPlot');
set(get(a2, 'Title'), 'String', 'Pockels Cell Signal');
set(get(a2, 'XLabel'), 'String', 'Time [s]');
set(get(a2, 'YLabel'), 'String', 'Amplitude [V]');
setLocal(progmanager, hObject, 'pockelsDisplayPlot', p2);

%Signal objects.
xMirrorSignal = signalobject;
set(xMirrorSignal, 'Name', 'X-Mirror');
setLocal(progmanager, hObject, 'xMirrorSignal', xMirrorSignal);

yMirrorSignal = signalobject;
set(yMirrorSignal, 'Name', 'Y-Mirror');
setLocal(progmanager, hObject, 'yMirrorSignal', yMirrorSignal);

envelopeSignal = signalobject;
set(envelopeSignal, 'Name', 'Envelope');
setLocal(progmanager, hObject, 'envelopeSignal', envelopeSignal);

xEnveloped = signalobject;
set(xEnveloped, 'Name', 'X-Mirror-Enveloped');
recursive(xEnveloped, 'Multiply', [xMirrorSignal envelopeSignal]);
setLocal(progmanager, hObject, 'xEnveloped', xEnveloped);

yEnveloped = signalobject;
set(yEnveloped, 'Name', 'Y-Mirror-Enveloped');
recursive(yEnveloped, 'Multiply', [yMirrorSignal envelopeSignal]);
setLocal(progmanager, hObject, 'yEnveloped', yEnveloped);

pockelsSignal = signalobject;
set(pockelsSignal, 'Name', 'Pockels-Cell');
setLocal(progmanager, hObject, 'pockelsSignal', pockelsSignal);

updateFromScanImage_Callback(hObject, eventdata, handles);

%Update the signals.
updateSignals(hObject);
updateSignalDisplays(hObject);

try
    dm = daqmanager('nidaq');
    setLocal(progmanager, hObject, 'daqmanager', dm);
    nameOutputChannel(dm, state.init.mirrorOutputBoardIndex, 0, 'X-Mirror');
    nameOutputChannel(dm, state.init.mirrorOutputBoardIndex, 1, 'Y-Mirror');
    nameOutputChannel(dm, state.init.eom.pockelsBoardIndex2, state.init.eom.pockelsChannelIndex2, 'Pockels-Cell');

    setAOProperty(dm, 'X-Mirror', 'TriggerType', 'HwDigital');
    setAOProperty(dm, 'Y-Mirror', 'TriggerType', 'HwDigital');
    setAOProperty(dm, 'Pockels-Cell', 'TriggerType', 'HwDigital');
    
    setAOProperty(dm, 'X-Mirror', 'StopFcn', @closeShutter);
    setAOProperty(dm, 'Y-Mirror', 'StopFcn', @closeShutter);
    setAOProperty(dm, 'Pockels-Cell', 'StopFcn', @closeShutter);

    sampleRate = getLocal(progmanager, hObject, 'SampleRate');
    setAOProperty(dm, 'X-Mirror', 'SampleRate', sampleRate);
    setAOProperty(dm, 'Y-Mirror', 'SampleRate', sampleRate);
    setAOProperty(dm, 'Pockels-Cell', 'SampleRate', sampleRate);
catch
    warning('Failed to create output object(s) - %s', lasterr);
end

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

deleteChildren(getLocal(progmanager, hObject, 'pockelsSignal'));

try
    delete(getLocal(progmanager, hObject, 'mirrorSignalDisplayFigure'));
catch
    warning('Failed to remove mirror signal figure.');
end

try
    delete(getLocal(progmanager, hObject, 'pockelsSignalDisplayFigure'));
catch
    warning('Failed to remove pockels cell signal figure.');
end

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
        'xFrequency', 100, 'Gui', 'xFrequency', 'Min', 0, 'Max', 500, 'Class', 'Numeric', ...
        'xAmplitude', 2, 'Gui', 'xAmplitude', 'Min', -3, 'Max', +3, 'Class', 'Numeric', ...
        'xOffset', 0, 'Gui', 'xOffset', 'Min', -3, 'Max', +3', 'Class', 'Numeric', ...
        'xEllipticalWeight', 1, 'Gui', 'xEllipticalWeight', 'Gui', 'xEllipticalWeightSlider', 'Min', 0, 'Max', 1, 'Class', 'Numeric', ...
        'yFrequency', 100, 'Gui', 'yFrequency', 'Min', 0, 'Max', 500, 'Class', 'Numeric', ...
        'yAmplitude', 2, 'Gui', 'yAmplitude', 'Min', -3, 'Max', +3, 'Class', 'Numeric', ...
        'yOffset', 0, 'Gui', 'yOffset', 'Min', -3, 'Max', +3', 'Class', 'Numeric', ...
        'yEllipticalWeight', 1, 'Gui', 'yEllipticalWeight', 'Gui', 'yEllipticalWeightSlider', 'Min', 0, 'Max', 1, 'Class', 'Numeric', ...
        'envelopeFrequency', 500, 'Gui', 'envelopeFrequency', 'Min', 0, 'Max', 5000, 'Class', 'Numeric', ...
        'envelopeAmplitude', 0.1, 'Gui', 'envelopeAmplitude', 'Gui', 'envelopeAmplitudeSlider', 'Min', 0, 'Max', 1, 'Class', 'Numeric', ...
        'envelopeOffset', 0.9, 'Gui', 'envelopeOffset', 'Gui', 'envelopeOffsetSlider', 'Min', 0, 'Max', 1, 'Class', 'Numeric', ...
        'pockelsAmplitude', 400, 'Gui', 'pockelsAmplitude', 'Gui', 'pockelsAmplitudeSlider', 'Min', 1, 'Max', 1000, 'Class', 'Numeric', ...
        'pockelsDelay', 0.004, 'Gui', 'pockelsDelay', 'Class', 'Numeric', ...
        'pockelsWidth', 0.004, 'Gui', 'pockelsWidth', 'Class', 'Numeric', ...
        'sampleRate', 40000, 'Gui', 'sampleRate', 'Class', 'Numeric', ...
        'scanDuration', 0.7, 'Gui', 'scanDuration', 'Class', 'Numeric', ...
        'mirrorSignalDisplayFigure', [], ...
        'mirrorSignalDisplayAxes', [], ...
        'mirrorDisplayPlot', [], ...
        'pockelsSignalDisplayFigure', [], ...
        'pockelsSignalDisplayAxes', [], ...
        'pockelsDisplayPlot', [], ...
        'xMirrorSignal', [], ...
        'yMirrorSignal', [], ...
        'envelopeSignal', [], ...
        'pockelsSignal', [], ...
        'xEnveloped', [], ...
        'yEnveloped', [], ...
        'externalTrigger', 0, 'Gui', 'externalTrigger', 'Min', 0, 'Max', 1, 'Class', 'Numeric', ...
        'startButton', 0, 'Gui', 'startButton', 'Min', 0, 'Max', 1, 'Class', 'Numeric', ...
        'limitSignalDisplay', 1, 'Gui', 'limitSignalDisplay', 'Min', 0, 'Max', 1, 'Class', 'Numeric', ...
        'hObject', hObject, ...
        'daqmanager', [], ...
        'rotation', 0, 'Gui', 'rotation', 'Gui', 'rotationSlider', 'Min', -360, 'Max', 360, 'Class', 'Numeric', ...
};

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xEllipticalWeightSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function xEllipticalWeightSlider_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xFrequency_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function xFrequency_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xAmplitude_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function xAmplitude_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xEllipticalWeight_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function xEllipticalWeight_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xOffset_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function xOffset_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yEllipticalWeightSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function yEllipticalWeightSlider_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yFrequency_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function yFrequency_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yAmplitude_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function yAmplitude_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yEllipticalWeight_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function yEllipticalWeight_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yOffset_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function yOffset_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function envelopeAmplitudeSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function envelopeAmplitudeSlider_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function envelopeFrequency_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function envelopeFrequency_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function envelopeAmplitude_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function envelopeAmplitude_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function envelopeOffset_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function envelopeOffset_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function envelopeOffsetSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function envelopeOffsetSlider_Callback(hObject, eventdata, handles)

updateSignals(hObject);

return;

% ------------------------------------------------------------------
function updateSignals(hObject)

sampleRate = getLocal(progmanager, hObject, 'sampleRate');

xMirrorSignal = getLocal(progmanager, hObject, 'xMirrorSignal');

set(xMirrorSignal, 'SampleRate', sampleRate);
sin(xMirrorSignal, getLocal(progmanager, hObject, 'xAmplitude'), getLocal(progmanager, hObject, 'xOffset'), ...
    getLocal(progmanager, hObject, 'xFrequency'), 0);

yMirrorSignal = getLocal(progmanager, hObject, 'yMirrorSignal');
set(yMirrorSignal, 'SampleRate', sampleRate);
cos(yMirrorSignal, getLocal(progmanager, hObject, 'yAmplitude'), getLocal(progmanager, hObject, 'yOffset'), ...
    getLocal(progmanager, hObject, 'yFrequency'), 0);
envelopeSignal = getLocal(progmanager, hObject, 'envelopeSignal');
set(envelopeSignal, 'SampleRate', sampleRate);
triangle(envelopeSignal, getLocal(progmanager, hObject, 'envelopeAmplitude'), getLocal(progmanager, hObject, 'envelopeOffset'), ...
    getLocal(progmanager, hObject, 'envelopeFrequency'), 0);

xEnveloped = getLocal(progmanager, hObject, 'xEnveloped');
set(xEnveloped, 'SampleRate', sampleRate);

yEnveloped = getLocal(progmanager, hObject, 'yEnveloped');
set(yEnveloped, 'SampleRate', sampleRate);

global state;
pockelsSignal = getLocal(progmanager, hObject, 'pockelsSignal');
lowTransmissionVoltage = state.init.eom.lut(2, 1);
index = min(100, max(1, floor(100 * getLocal(progmanager, hObject, 'pockelsAmplitude') / ...
    state.init.eom.powerConversion2 / state.init.eom.maxPhotodiodeVoltage(2))));
highTransmissionVoltage = state.init.eom.lut(2, index);
deleteChildren(pockelsSignal);
set(pockelsSignal, 'SampleRate', sampleRate);
squarePulse(pockelsSignal, highTransmissionVoltage - lowTransmissionVoltage, lowTransmissionVoltage, ...
    getLocal(progmanager, hObject, 'pockelsDelay'), getLocal(progmanager, hObject, 'pockelsWidth'));

return;

% ------------------------------------------------------------------
function updateSignalDisplays(hObject)

updateMirrorSignalDisplay(hObject);
updatePockelsSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
function updateMirrorSignalDisplay(hObject)

duration = getLocal(progmanager, hObject, 'scanDuration');

xEnveloped = getLocal(progmanager, hObject, 'xEnveloped');
yEnveloped = getLocal(progmanager, hObject, 'yEnveloped');
p1 = getLocal(progmanager, hObject, 'mirrorDisplayPlot');

try
    xdata = getData(xEnveloped, duration);
    ydata = getData(yEnveloped, duration);

    if getLocal(progmanager, hObject, 'limitSignalDisplay')
        dataStart = max(1, floor(getLocal(progmanager, hObject, 'sampleRate') * getLocal(progmanager, hObject, 'pockelsDelay')));
        dataEnd =  floor(min(length(xdata), dataStart + getLocal(progmanager, hObject, 'sampleRate') * getLocal(progmanager, hObject, 'pockelsWidth')));
        if dataStart > length(xdata)
            dataStart = -1;
        end
    else
        dataStart = 1;
        dataEnd = length(xdata);
    end

    xEllipticalWeight = getLocal(progmanager, hObject, 'xEllipticalWeight');
    yEllipticalWeight = getLocal(progmanager, hObject, 'yEllipticalWeight');
    rotation = getLocal(progmanager, hObject, 'rotation');
    c = cos(rotation * pi / 180);
    s = sin(rotation * pi / 180);
    adjustedX = xEllipticalWeight * c * xdata(dataStart : dataEnd) + s * ydata(dataStart : dataEnd);
    adjustedY = yEllipticalWeight * c * ydata(dataStart : dataEnd) + s * xdata(dataStart : dataEnd);
    if dataStart > 0
        set(p1, 'XData', adjustedX, 'YData', adjustedY);
    else
        set(p1, 'XData', [], 'YData', []);
    end
    
    ax = getLocal(progmanager, hObject, 'mirrorSignalDisplayAxes');

    xAmp = getLocal(progmanager, hObject, 'xAmplitude');
    xOff = getLocal(progmanager, hObject, 'xOffset');
    xLim = [xOff-xAmp xOff+xAmp];
    set(ax, 'XLim', xLim);
    
    yAmp = getLocal(progmanager, hObject, 'yAmplitude');
    yOff = getLocal(progmanager, hObject, 'yOffset');
    yLim = [yOff-yAmp yOff+yAmp];
    set(ax, 'YLim', yLim);
    
    if xEllipticalWeight == yEllipticalWeight
        pbaspect(getParent(p1, 'axes'), [1 1 1]);
    else
        pbaspect('auto');
    end
catch
    warning('Failed to update Mirror Signal Display: %s', lasterr);
end

% ------------------------------------------------------------------
function updatePockelsSignalDisplay(hObject)

duration = getLocal(progmanager, hObject, 'scanDuration');

pockelsSignal = getLocal(progmanager, hObject, 'pockelsSignal');
p2 = getLocal(progmanager, hObject, 'pockelsDisplayPlot');
% try
    data = getData(pockelsSignal, duration);
    set(p2, 'XData', (1:length(data)) / getLocal(progmanager, hObject, 'sampleRate'), 'YData', data);
% catch
%     warning('Failed to update Mirror Signal Display: %s', lasterr);
% end

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pockelsAmplitudeSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function pockelsAmplitudeSlider_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updatePockelsSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pockelsAmplitude_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function pockelsAmplitude_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);
updatePockelsSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pockelsDelay_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function pockelsDelay_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);
updatePockelsSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pockelsWidth_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function pockelsWidth_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);
updatePockelsSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function sampleRate_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function sampleRate_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'sampleRate', max([getLocal(progmanager, hObject, 'sampleRate') ...
    getLocal(progmanager, hObject, 'xFrequency') getLocal(progmanager, hObject, 'yFrequency'), ...
    getLocal(progmanager, hObject, 'envelopeFrequency')]));

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);
updatePockelsSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function scanDuration_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function scanDuration_Callback(hObject, eventdata, handles)

updateMirrorSignalDisplay(hObject);
updatePockelsSignalDisplay(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in externalTrigger.
function externalTrigger_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in updateFromScanImage.
function updateFromScanImage_Callback(hObject, eventdata, handles)
global state;

fprintf(1, '\nUpdating from ScanImage...\n');
fprintf(1, 'Update X/Y amplitude/offset to match ScanImage.\n');
try
    setLocal(progmanager, hObject, 'xAmplitude', state.acq.scanAmplitudeX / state.acq.zoomFactor);
    setLocal(progmanager, hObject, 'xOffset', state.acq.scanOffsetX);
    
    setLocal(progmanager, hObject, 'yAmplitude', state.acq.scanAmplitudeY / state.acq.zoomFactor);
    setLocal(progmanager, hObject, 'yOffset', state.acq.scanOffsetY);
    
    setLocal(progmanager, hObject, 'rotation', state.acq.scanRotation);
catch
    warning('Failed to cull variables from ScanImage - %s', lasterr);
end

updateSignals(hObject);
updateSignalDisplays(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'startButton')
    setLocalGh(progmanager, hObject, 'startButton', 'String', 'Stop', 'ForegroundColor', [1 0 0]);
    try
        startScan(hObject);
    catch
        warning('Failed to properly stop scan: %s', lasterr);
        stopScan(hObject);
        setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0.2 0.8 0.2]);
        setLocal(progmanager, hObject, 'startButton', 0);
    end
else
    setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0.2 0.8 0.2]);
    stopScan(hObject);
end

return;

% ------------------------------------------------------------------
function startScan(hObject)

fprintf(1, '\nStarting scan...\n');
fprintf(1, 'Put X/Y-mirror signal to output board(s).\n');
fprintf(1, 'Put Pockels cell signal to output board.\n');

dm = getLocal(progmanager, hObject, 'daqmanager');
    
%Putdata
duration = getLocal(progmanager, hObject, 'scanDuration');
try
    xData = getdata(getLocal(progmanager, hObject, 'xEnveloped'), duration);
    yData = getdata(getLocal(progmanager, hObject, 'yEnveloped'), duration);
    xEllipticalWeight = getLocal(progmanager, hObject, 'xEllipticalWeight');
    yEllipticalWeight = getLocal(progmanager, hObject, 'yEllipticalWeight');
    rotation = getLocal(progmanager, hObject, 'rotation');
    c = cos(rotation * pi / 180);
    s = sin(rotation * pi / 180);
    adjustedX = getLocal(progmanager, hObject, 'yEllipticalWeight') * c * xData + s * yData;
    adjustedY = getLocal(progmanager, hObject, 'yEllipticalWeight') * c * yData + s * xData;
    putdaqdata(dm, 'X-Mirror', adjustedX);
    putdaqdata(dm, 'Y-Mirror', adjustedY);
    putdaqdata(dm, 'Pockels-Cell', getdata(getLocal(progmanager, hObject, 'pockelsSignal'), duration));

    sampleRate = getLocal(progmanager, hObject, 'SampleRate');
    setAOProperty(dm, 'X-Mirror', 'SampleRate', sampleRate);
    setAOProperty(dm, 'Y-Mirror', 'SampleRate', sampleRate);
    setAOProperty(dm, 'Pockels-Cell', 'SampleRate', sampleRate);
catch
    warning('Failed to put data to output board(s) - %s', lasterr);
    setLocal(progmanager, hObject, 'startButton', 0);
    setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0.2 0.8 0.2]);
    return;
end

%Start
try
    startChannel(dm, 'X-Mirror', 'Y-Mirror', 'Pockels-Cell');
    openShutter;
catch
    warning('Failed to start output on mirror board - %s', lasterr);
    setLocal(progmanager, hObject, 'startButton', 0);
    setLocalGh(progmanager, hObject, 'startButton', 'String', 'Start', 'ForegroundColor', [0.2 0.8 0.2]);
    closeShutter;
    return;
end

%Trigger
fprintf(1, 'Start output board(s).\n');
if ~getLocal(progmanager, hObject, 'externalTrigger')
    fprintf(1, 'Trigger output board(s).\n');
    try
        dioTrigger;
    catch
        warning('Failed to initiate trigger - %s', lasterr);
        closeShutter;
    end
end

return;

% ------------------------------------------------------------------
function stopScan(hObject)

fprintf(1, '\nStopping scan...\n');
fprintf(1, 'Stop output board(s).\n');

dm = getLocal(progmanager, hObject, 'daqmanager');

try
    startChannel(dm, 'X-Mirror', 'Y-Mirror', 'Pockels-Cell');
catch
    warning('Failed to stop output board(s) - %s', lasterr);
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in limitSignalDisplay.
function limitSignalDisplay_Callback(hObject, eventdata, handles)

updateMirrorSignalDisplay(hObject);

return;

% --------------------------------------------------------------------
function viewScanSignal_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'mirrorSignalDisplayFigure'), 'Visible', 'On');

return;

% --------------------------------------------------------------------
function viewPockelsSignal_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'pockelsSignalDisplayFigure'), 'Visible', 'On');

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function rotationSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
% --- Executes on slider movement.
function rotationSlider_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function rotation_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function rotation_Callback(hObject, eventdata, handles)

updateSignals(hObject);
updateMirrorSignalDisplay(hObject);

return;
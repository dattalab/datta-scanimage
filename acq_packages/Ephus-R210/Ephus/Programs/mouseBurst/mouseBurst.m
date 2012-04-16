function varargout = mouseBurst(varargin)
% MOUSEBURST M-file for mouseBurst.fig
%      MOUSEBURST, by itself, creates a new MOUSEBURST or raises the existing
%      singleton*.
%
%      H = MOUSEBURST returns the handle to a new MOUSEBURST or the handle to
%      the existing singleton*.
%
%      MOUSEBURST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOUSEBURST.M with the given input arguments.
%
%      MOUSEBURST('Property','Value',...) creates a new MOUSEBURST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mouseBurst_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mouseBurst_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mouseBurst

% Last Modified by GUIDE v2.5 10-Nov-2006 12:40:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mouseBurst_OpeningFcn, ...
                   'gui_OutputFcn',  @mouseBurst_OutputFcn, ...
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
return;

%----------------------------------------------------------------
% --- Executes just before mouseBurst is made visible.
function mouseBurst_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mouseBurst (see VARARGIN)

% Choose default command line output for mouseBurst
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mouseBurst wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

%----------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = mouseBurst_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;
return;

%----------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function delay_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%----------------------------------------------------------------
function delay_Callback(hObject, eventdata, handles)
updatePulses(hObject);
return;

%----------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function isi_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%----------------------------------------------------------------
function isi_Callback(hObject, eventdata, handles)
updatePulses(hObject);
return;

%----------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pockelsDur_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%----------------------------------------------------------------
function pockelsDur_Callback(hObject, eventdata, handles)
updatePulses(hObject);
return;

%----------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pockelsAmp_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%----------------------------------------------------------------
function pockelsAmp_Callback(hObject, eventdata, handles)
updatePulses(hObject)
return;

%----------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function traceLength_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%----------------------------------------------------------------
function traceLength_Callback(hObject, eventdata, handles)
updatePulses(hObject);
return;

%----------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function settlingTime_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%----------------------------------------------------------------
function settlingTime_Callback(hObject, eventdata, handles)
updatePulses(hObject);
return;

%----------------------------------------------------------------
% --- Executes on button press in getPoints.
function getPoints_Callback(hObject, eventdata, handles)

f = getGlobal(progmanager, 'videoFigure', 'mapper', 'mapper');
if ishandle(f)
    set(f, 'HandleVisibility', 'On', 'Pointer', 'cross');
    [x, y] = getPointsFromAxes(get(f, 'Children'));%TO031910D
else
    warndlg('MouseBurst: No video image found for mouse selection.');
    fprintf(1, 'Warning: MouseBurst - No video image found for mouse selection.');
    return;
end

directory = uigetdir(getDefaultCacheDirectory(progmanager, 'pulseDir'), 'Choose a pulse directory in which to create MouseBurst pulses.');
if length(directory) == 1
    if directory == 0
        return;
    end
end
if exist(fullfile(directory, 'mouseBurst')) ~= 7
    mkdir(directory, 'mouseBurst');
    directory = fullfile(directory, 'mouseBurst');
else
    directory = fullfile(directory, 'mouseBurst');
end
setLocalBatch(progmanager, hObject, 'xCoord', x, 'yCoord', y, 'directory', directory);

generatePulses(hObject);

%----------------------------------------------------------------
% --- Executes on call.
function updatePulses(hObject)

directory = getLocal(progmanager, hObject, 'directory');
if exist(directory, 'dir') == 7
    generatePulses(hObject);
end

%----------------------------------------------------------------
% --- Executes on call.
function generatePulses(hObject)

[delay, isi, pockelsDur, pockelsAmp, settlingTime, plotPulses, x, y, directory] = getLocalBatch(progmanager, hObject, ...
    'delay', 'isi', 'pockelsDur', 'pockelsAmp', 'settlingTime', 'plotPulses', 'xCoord', 'yCoord', 'directory');
if isempty(x) || isempty(y)
    return
end
sampleRate = 10000;
xLiteral = cat(1, zeros(sampleRate * delay / 1000 - 1, 1), reshape(repmat(x', [(sampleRate * isi / 1000), 1]), [], 1), 0);
xSig = signalobject('Name', 'mouseBurstX', 'SampleRate', sampleRate, 'signal', xLiteral, 'Repeatable', 0, 'Type', 'literal');
if plotPulses
    xf1 = figure; xax = axes;
    plot(xSig, xax, 1);
    set(xax, 'XLim', [(delay / 1000) - 0.004, (delay / 1000) + length(x) * isi / 1000 + 0.002]);
end

yLiteral = cat(1, zeros(sampleRate * delay / 1000 - 1, 1), reshape(repmat(y', [(sampleRate * isi / 1000), 1]), [], 1), 0);
ySig = signalobject('Name', 'mouseBurstY', 'SampleRate', sampleRate, 'signal', yLiteral, 'Repeatable', 0, 'Type', 'literal');
if plotPulses
    yf1 = figure; yax = axes;
    plot(ySig, yax, 1);
    set(yax, 'XLim', [(delay / 1000) - 0.004, (delay / 1000) + length(x) * isi / 1000 + 0.002]);
end

pockelsSig = signalobject('Name', 'mouseBurstPockels', 'SampleRate', sampleRate);
squarePulseTrain(pockelsSig, pockelsAmp, 0, (delay + settlingTime) / 1000, pockelsDur / 1000, isi / 1000, length(x));
if plotPulses
    pockels_f1 = figure; pockels_ax = axes;
    plot(pockelsSig, pockels_ax, 1);
    set(pockels_ax, 'XLim', [(delay / 1000) - 0.004, (delay / 1000) + length(x) * isi / 1000 + 0.002]);
end

shutterSig = signalobject('Name', 'mouseBurstShutter', 'SampleRate', sampleRate);
squarePulseTrain(shutterSig, 5000, 0, (delay / 1000) - 0.002, length(x) * isi / 1000 + 0.002, isi, 1);
if plotPulses
    shutter_f1 = figure; shutter_ax = axes;
    plot(shutterSig, shutter_ax, 1);
    set(shutter_ax, 'XLim', [(delay / 1000) - 0.004, (delay / 1000) + length(x) * isi / 1000 + 0.002]);
end

mouseBurstSignals = [xSig, ySig, pockelsSig, shutterSig];
for i = 1 : length(mouseBurstSignals)
    signal = mouseBurstSignals(i);
    saveCompatible(fullfile(directory, [get(signal, 'Name') '.signal']), 'signal', '-mat');
    fprintf(1, ' Saved MouseBurst signal %s\n', fullfile(directory, [get(signal, 'Name') '.signal']));
end
for i = 1 : length(mouseBurstSignals)
    delete(mouseBurstSignals(i));
end

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
        'hObject', hObject, ...
        'delay', 100, 'Class', 'Numeric', 'Gui', 'delay', 'Config', 7, ...
        'isi', 2, 'Class', 'Numeric', 'Gui', 'isi', 'Config', 7, ...
        'pockelsDur', 1, 'Class', 'Numeric', 'Gui', 'pockelsDur', 'Config', 7, ...
        'pockelsAmp', 100, 'Class', 'Numeric', 'Gui', 'pockelsAmp', 'Config', 7, ...
        'settlingTime', 1, 'Class', 'Numeric', 'Gui', 'settlingTime', 'Config', 7, ...
        'plotPulses', 0, 'Class', 'Numeric', 'Gui', 'plotPulses', 'Config', 5, ...
        'xCoord', [], ...
        'yCoord', [], ...
        'directory', [], ...
    };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

%TO021510A - mouseBurst is deprecated (for the forseeable future). -- Tim O'Connor 2/15/10
warning('The mouseBurst program is not currently supported. See TO021510A.');

genericUpdateFcn(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

return;

% ------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

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

genericUpdateFcn(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericPostLoadMiniSettings(hObject, eventdata, handles, varargin)

genericPostLoadSettings(hObject, eventdata, handles, varargin);

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericNewData(hObject, eventdata, handles)

errordlg('New functionality not supported by this GUI.');

return;

% ------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

errordlg('Open functionality not supported by this GUI.');

return;

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

errordlg('Save functionality not supported by this GUI.');

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

errordlg('Save As functionality not supported by this GUI.');

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
% --- Executes on button press in plotPulses.
function plotPulses_Callback(hObject, eventdata, handles)

return;
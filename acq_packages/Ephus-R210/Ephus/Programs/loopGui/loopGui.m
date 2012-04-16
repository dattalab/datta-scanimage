function varargout = loopGui(varargin)
% LOOPGUI M-file for loopGui.fig
%      LOOPGUI, by itself, creates a new LOOPGUI or raises the existing
%      singleton*.
%
%      H = LOOPGUI returns the handle to a new LOOPGUI or the handle to
%      the existing singleton*.
%
%      LOOPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOOPGUI.M with the given input arguments.
%
%      LOOPGUI('Property','Value',...) creates a new LOOPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before loopGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to loopGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help loopGui

% Last Modified by GUIDE v2.5 14-Jun-2005 16:07:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @loopGui_OpeningFcn, ...
                   'gui_OutputFcn',  @loopGui_OutputFcn, ...
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


% --- Executes just before loopGui is made visible.
function loopGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to loopGui (see VARARGIN)

% Choose default command line output for loopGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes loopGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = loopGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'loopManager', loopManager, ...
       'preciseTiming', 0, 'Class', 'Numeric', 'Gui', 'preciseTiming', 'Config', 3, ...
       'cpuTiming', 1, 'Class', 'Numeric', 'Gui', 'cpuTiming', 'Config', 3, ...
       'busyMode', 'Queue', 'Class', 'char', 'Gui', 'busyMode', 'Config', 1, ...
       'iterationCounter', 0, 'Class', 'Numeric', 'Gui', 'iterationCounter', 'Config', 2, ...
       'interval', 0, 'Class', 'Numeric', 'Gui', 'interval', 'Config', 3, ...
       'iterations', 0, 'Class', 'Numeric', 'Gui', 'iterations', 'Config', 3, ...
       'lastIterationTime', 0, 'Class', 'Char', 'Gui', 'lastIterationTime', ...
       'lastStartTime', 0, 'Class', 'Char', 'Gui', 'lastStartTime', ...
       'startLoop', 0, 'Class', 'Numeric', 'Gui', 'startLoop', ...
       'updateRecursion', 0, 'Class', 'Numeric', ...
      };

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

errordlg('Open is not supported by this GUI.');

return;

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

errordlg('Save is not supported by this GUI.');

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

errordlg('Save As is not supported by this GUI.');

return;

% ------------------------------------------------------------------
function updateGuiFromObject(hObject, varargin)

%TO120105I - Block recursion to prevent variable clobbering.
if getLocal(progmanager, hObject, 'updateRecursion')
    return;
end

lm = getLocal(progmanager, hObject, 'loopManager');

preciseTimeMode = get(lm, 'preciseTimeMode');
setLocal(progmanager, hObject, 'preciseTiming', preciseTimeMode);
setLocal(progmanager, hObject, 'cpuTiming', ~preciseTimeMode);

setLocal(progmanager, hObject, 'busyMode', get(lm, 'busyMode'));
setLocal(progmanager, hObject, 'iterationCounter', get(lm, 'iterationCounter'));
setLocal(progmanager, hObject, 'interval', get(lm, 'interval'));
setLocal(progmanager, hObject, 'iterations', get(lm, 'iterations'));
setLocal(progmanager, hObject, 'lastIterationTime', datestr(get(lm, 'lastIterationTime'), 14));
setLocal(progmanager, hObject, 'lastStartTime', datestr(get(lm, 'lastStartTime'), 14));

if preciseTimeMode
    if ~get(lm, 'running')
        setLocalGh(progmanager, hObject, 'preciseTiming', 'Enable', 'Inactive');
        setLocalGh(progmanager, hObject, 'cpuTiming', 'Enable', 'On');
    end
    
    setLocalGh(progmanager, hObject, 'text4', 'Visible', 'Off');
    setLocalGh(progmanager, hObject, 'text6', 'Visible', 'Off');
    setLocalGh(progmanager, hObject, 'lastIterationTime', 'Visible', 'Off');
    setLocalGh(progmanager, hObject, 'iterationCounter', 'Visible', 'Off');
else
    if ~get(lm, 'running')
        setLocalGh(progmanager, hObject, 'preciseTiming', 'Enable', 'On');
        setLocalGh(progmanager, hObject, 'cpuTiming', 'Enable', 'Inactive');
    end
    
    setLocalGh(progmanager, hObject, 'text4', 'Visible', 'On');
    setLocalGh(progmanager, hObject, 'text6', 'Visible', 'On');
    setLocalGh(progmanager, hObject, 'lastIterationTime', 'Visible', 'On');
    setLocalGh(progmanager, hObject, 'iterationCounter', 'Visible', 'On');
end

if get(lm, 'running')
    setLocalGh(progmanager, hObject, 'interval', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'iterations', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'busyMode', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'preciseTiming', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'cpuTiming', 'Enable', 'Off');
    
    setLocal(progmanager, hObject, 'startLoop', 1);
    setLocalGh(progmanager, hObject, 'startLoop', 'ForegroundColor', [1 0 0], 'String', 'Stop');
else
    setLocalGh(progmanager, hObject, 'interval', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'iterations', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'busyMode', 'Enable', 'On');

    setLocal(progmanager, hObject, 'startLoop', 0);
    setLocalGh(progmanager, hObject, 'startLoop', 'ForegroundColor', [0 0 1], 'String', 'Loop');
end

% drawnow expose; %TO042309A - Not using expose can cause C-spawned events to fire out of order.

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

registerObjectListener(getLocal(progmanager, hObject, 'loopManager'), {@updateGuiFromObject, hObject}, 'loopGuiObjectMonitor');
updateGuiFromObject(hObject);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
%TO071906B: Make sure the loopManager has been properly cleaned up, executing callbacks during shutdown is a bad idea. -- Tim O'Connor 7/19/06
function genericCloseFcn(hObject, eventdata, handles)

lm = getLocal(progmanager, hObject, 'loopManager');
if get(lm, 'running')
    stop(lm);
end
%delete(lm);%No delete exists, yet. It may never exist.
setLocal(progmanager, hObject, 'loopManager', []);

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.2;

return;

%------------------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

return;

%------------------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

return;

%------------------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

return;

%------------------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'updateRecursion', 1);
lm = getLocal(progmanager, hObject, 'loopManager');
if getLocal(progmanager, hObject, 'preciseTiming')
    set(lm, 'preciseTimeMode', 1);
    setLocalGh(progmanager, hObject, 'preciseTiming', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'cpuTiming', 'Enable', 'On');
    preciseTiming_Callback(hObject, eventdata, handles);%TO111706D: Make sure the gui gets updated.
else
    set(lm, 'preciseTimeMode', 0);
    setLocalGh(progmanager, hObject, 'preciseTiming', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'cpuTiming', 'Enable', 'Inactive');
    cpuTiming_Callback(hObject, eventdata, handles);%TO111706D: Make sure the gui gets updated.
end
%TO120105I: These were getting clobbered when the object reverse notified the gui of an update, so recursion has been blocked.
set(lm, 'interval', getLocal(progmanager, hObject, 'interval'));
set(lm, 'busyMode', getLocal(progmanager, hObject, 'busyMode'));
set(lm, 'iterations', getLocal(progmanager, hObject, 'iterations'));
setLocal(progmanager, hObject, 'updateRecursion', 0);

return;

% ------------------------------------------------------------------
% --- Executes on button press in startLoop.
function startLoop_Callback(hObject, eventdata, handles)

%TO031306A: First pass of an implementation.
% if getLocal(progmanager, hObject, 'preciseTiming')
%     errordlg('NOT_YET_IMPLEMENTED', 'Unimplemeneted Error', 'modal');
%     setLocal(progmanager, hObject, 'startLoop', 0);
%     return;
% end

if getLocal(progmanager, hObject, 'startLoop')
    start(getLocal(progmanager, hObject, 'loopManager'));
else
    stop(getLocal(progmanager, hObject, 'loopManager'));
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in preciseTiming.
function preciseTiming_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'loopManager'), 'preciseTimeMode', 1);

return;

% ------------------------------------------------------------------
% --- Executes on button press in cpuTiming.
function cpuTiming_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'loopManager'), 'preciseTimeMode', 0);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function interval_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function interval_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'loopManager'), 'interval', getLocal(progmanager, hObject, 'interval'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function iterations_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function iterations_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'loopManager'), 'iterations', getLocal(progmanager, hObject, 'iterations'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function lastIterationTime_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function lastIterationTime_Callback(hObject, eventdata, handles)
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function lastStartTime_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function lastStartTime_Callback(hObject, eventdata, handles)
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function iterationCounter_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function iterationCounter_Callback(hObject, eventdata, handles)
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function busyMode_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on selection change in busyMode.
function busyMode_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'loopManager'), 'busyMode', getLocal(progmanager, hObject, 'busyMode'));

return;
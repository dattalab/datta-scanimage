function varargout = analogOutputGui(varargin)
% ANALOGOUTPUTGUI M-file for analogOutputGui.fig
%      ANALOGOUTPUTGUI, by itself, creates a new ANALOGOUTPUTGUI or raises the existing
%      singleton*.
%
%      H = ANALOGOUTPUTGUI returns the handle to a new ANALOGOUTPUTGUI or the handle to
%      the existing singleton*.
%
%      ANALOGOUTPUTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALOGOUTPUTGUI.M with the given input arguments.
%
%      ANALOGOUTPUTGUI('Property','Value',...) creates a new ANALOGOUTPUTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before analogOutputGui_OpeningFunction gets called.  An
%      unrecognized property ttlName or invalid value makes property application
%      stop.  All inputs are passed to analogOutputGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help analogOutputGui

% Last Modified by GUIDE v2.5 04-Aug-2005 18:34:39

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @analogOutputGui_OpeningFcn, ...
                   'gui_OutputFcn',  @analogOutputGui_OutputFcn, ...
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

% ------------------------------------------------------------------
% --- Executes just before analogOutputGui is made visible.
function analogOutputGui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for analogOutputGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes analogOutputGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = analogOutputGui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'highPolarity', 1, 'Class', 'Numeric', 'Gui', 'highPolarity', ...
       'lowPolarity', 0, 'Class', 'Numeric', 'Gui', 'lowPolarity', ...
       'analog', 0, 'Class', 'Numeric', 'Gui', 'analog', ...
       'digital', 1, 'Class', 'Numeric', 'Gui', 'digital', ...
       'ttlName', '', 'Class', 'char', 'Gui', 'ttlName', ...
       'boardID', -1, 'Class', 'Numeric', 'Gui', 'boardID', ...
       'channelID', -1, 'Class', 'Numeric', 'Gui', 'channelID', ...
       'ttlObject', [], ...
   };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

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
function genericSaveSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function boardID_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function boardID_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'ttlObject'), 'boardID', getLocal(progmanager, hObject, 'boardID'));
update(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function channelID_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function channelID_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'ttlObject'), 'channelID', getLocal(progmanager, hObject, 'channelID'));
update(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in on.
function on_Callback(hObject, eventdata, handles)

on(getLocal(progmanager, hObject, 'ttlObject'));

return;

% ------------------------------------------------------------------
% --- Executes on button press in highPolarity.
function highPolarity_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'lowPolarity', 0);
set(getLocal(progmanager, hObject, 'ttlObject'), 'onValue', 1, 'offValue', 0);
setLocalGh(progmanager, hObject, 'highPolarity', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'lowPolarity', 'Enable', 'On');
update(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in lowPolarity.
function lowPolarity_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'highPolarity', 0);
set(getLocal(progmanager, hObject, 'ttlObject'), 'onValue', 0, 'offValue', 1);
setLocalGh(progmanager, hObject, 'highPolarity', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'lowPolarity', 'Enable', 'Inactive');
update(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in off.
function off_Callback(hObject, eventdata, handles)

off(getLocal(progmanager, hObject, 'ttlObject'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function ttlName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function ttlName_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'ttlObject'), 'ttlName', getLocal(progmanager, hObject, 'ttlName'));
update(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in digital.
function digital_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'analog', 0);
set(getLocal(progmanager, hObject, 'ttlObject'), 'type', 0);
setLocalGh(progmanager, hObject, 'digital', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'analog', 'Enable', 'On');
update(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in analog.
function analog_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'digital', 0);
set(getLocal(progmanager, hObject, 'ttlObject'), 'type', 1);
setLocalGh(progmanager, hObject, 'digital', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'analog', 'Enable', 'Inactive');
update(hObject);

return;

% ------------------------------------------------------------------
function update(hObject)

ttlObject = getLocal(progmanager, hObject, 'ttlObject');
boardID = get(ttlObject, 'boardID');
channelID = get(ttlObject, 'channelID');

if get(ttlObject, 'onValue') > get(ttlObject, 'offValue')
    highPolarity = 1;
    lowPolarity = 0;
    setLocalGh(progmanager, hObject, 'highPolarity', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'lowPolarity', 'Enable', 'On');
else
    highPolarity = 0;
    lowPolarity = 1;
    setLocalGh(progmanager, hObject, 'highPolarity', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'lowPolarity', 'Enable', 'Inactive');
end

type = get(ttlObject, 'type');
if type == 0
    digital = 1;
    analog = 0;
    setLocalGh(progmanager, hObject, 'digital', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'analog', 'Enable', 'On');
elseif type == 1
    digital = 0;
    analog = 1;
    setLocalGh(progmanager, hObject, 'digital', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'analog', 'Enable', 'Inactive');
else
    digital = 1;
    analog = 0;
    warning('Unrecognized TTL type: %s', num2str(type));
end

setLocalBatch(progmanager, hObject, 'boardID', boardID, 'channelID', channelID, 'ttlName', get(ttlObject, 'Name'), ...
    'highPolarity', highPolarity, 'lowPolarity', lowPolarity, 'digital', digital, 'analog', analog);

if boardID >= 0 & channelID >= 0
    setLocalGh(progmanager, hObject, 'on', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'off', 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'on', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'off', 'Enable', 'Off');
end

return;
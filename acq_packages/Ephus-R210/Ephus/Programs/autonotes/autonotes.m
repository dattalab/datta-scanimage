function varargout = autonotes(varargin)
% AUTONOTES M-file for autonotes.fig
%      AUTONOTES, by itself, creates a new AUTONOTES or raises the existing
%      singleton*.
%
%      H = AUTONOTES returns the handle to a new AUTONOTES or the handle to
%      the existing singleton*.
%
%      AUTONOTES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUTONOTES.M with the given input arguments.
%
%      AUTONOTES('Property','Value',...) creates a new AUTONOTES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before autonotes_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to autonotes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help autonotes

% Last Modified by GUIDE v2.5 29-Aug-2007 16:44:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @autonotes_OpeningFcn, ...
                   'gui_OutputFcn',  @autonotes_OutputFcn, ...
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


% --- Executes just before autonotes is made visible.
function autonotes_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes autonotes wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

% --- Outputs from this function are returned to the command line.
function varargout = autonotes_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

return;

%--------------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'filename', xsg_getFilename, 'Class', 'char', 'Gui', 'filename', 'Config', 2, ...
       'displayActive', 1, 'Class', 'numeric', 'Gui', 'displayActive', 'Config', 1, ...
       'log', '', 'Class', 'char', ...
       'userNote', '', 'Class', 'char', 'Gui', 'userNote', ...
       'logDisplay', '', 'Class', 'char', 'Gui', 'logDisplay', ...
       'textSlider', 0, 'Class', 'Numeric', 'Min', 0, 'Max', 1, 'Gui', 'textSlider', ...
   };

return;

%--------------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

%This callback should never be called.
%TO082907A - The progmanager shouldn't be called here, but process the callback, to remove any changes.
%TO082907A - Switched to a text uicontrol style, instead of an edit. Added 'textSlider' to compensate.
% setLocalGh(progmanager, hObject, 'logDisplay', 'Callback', {@logDisplay_Callback, hObject, eventdata, handles});

return;

%--------------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

%--------------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

%--------------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

errordlg('Open is not supported by this GUI.');

return;

%--------------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

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

displayActive_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

browse_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

browse_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function logDisplay_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function logDisplay_Callback(hObject, eventdata, handles)

% hObject = getLocalGh(progmanager, hObject, 'log');
% set(hObject, 'String', getLocal(progmanager, hObject, 'log'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function filename_Callback(hObject, eventdata, handles)

if exist(getLocal(progmanager, hObject, 'filename')) ~= 2
    setLocalGh(progmanager, hObject, 'filename', 'ForegroundColor', [1 0 0]);
else
    setLocalGh(progmanager, hObject, 'filename', 'ForegroundColor', [0 0 0]);
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)

filename = getLocal(progmanager, hObject, 'filename');
if exist(filename) ~= 2
    path = getDefaultCacheDirectory(progmanager, 'datapath');%TO030906A
    %TO030906A
    %if isempty(path)
    %    path = pwd;
    %end
else
    path = fileparts(filename);
end

[filename, path] = uiputfile(fullfile(path, '*.txt'), 'Save autonotes as...');
if length(filename) == 1
    if filename == 0
        return;
    end
end
if length(path) == 1
    if path == 0
        return;
    end
end
if ~endsWithIgnoreCase(filename, '.txt')
    filename = [filename '.txt'];
end
filename = [datestr(now, 5) '-' datestr(now, 7) '-' datestr(now, 11) '_' filename];

setLocal(progmanager, hObject, 'filename', fullfile(path, filename));
setDefaultCacheValue(progmanager, 'datapath', path);

return;

% ------------------------------------------------------------------
% --- Executes on button press in displayActive.
function displayActive_Callback(hObject, eventdata, handles)

hObject = getParent(hObject, 'figure');
pos = get(hObject, 'Position');
if getLocal(progmanager, hObject, 'displayActive')
%     pos(3) = 56.2;
    pos(4) = 23.846153846153847;
    setLocalGh(progmanager, hObject, 'clearGui', 'Enable', 'On', 'Visible', 'On');
else
    pos(4) = 7.515384615384616;
    setLocal(progmanager, hObject, 'logDisplay', '');
    setLocalGh(progmanager, hObject, 'clearGui', 'Enable', 'Off', 'Visible', 'Off');
end
set(hObject, 'Position', pos);    

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function userNote_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function userNote_Callback(hObject, eventdata, handles)

add_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)

autonotes_addNote(getLocal(progmanager, hObject, 'userNote'));
setLocal(progmanager, hObject, 'userNote', '');

return;

% ------------------------------------------------------------------
% --- Executes on button press in clearGui.
function clearGui_Callback(hObject, eventdata, handles)

% setLocal(progmanager, hObject, 'logDisplay', '');
autonotes_clearGui;%TO082907A

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function textSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function textSlider_Callback(hObject, eventdata, handles)

autonotes_setScroll(hObject);

return;
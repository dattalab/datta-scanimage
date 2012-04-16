function varargout = mirrorCycler(varargin)
% MIRRORCYCLER M-file for mirrorCycler.fig
%      MIRRORCYCLER, by itself, creates a new MIRRORCYCLER or raises the existing
%      singleton*.
%
%      H = MIRRORCYCLER returns the handle to a new MIRRORCYCLER or the handle to
%      the existing singleton*.
%
%      MIRRORCYCLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIRRORCYCLER.M with the given input arguments.
%
%      MIRRORCYCLER('Property','Value',...) creates a new MIRRORCYCLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mirrorCycler_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mirrorCycler_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mirrorCycler

% Last Modified by GUIDE v2.5 13-Sep-2006 14:03:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mirrorCycler_OpeningFcn, ...
                   'gui_OutputFcn',  @mirrorCycler_OutputFcn, ...
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
% --- Executes just before mirrorCycler is made visible.
function mirrorCycler_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for mirrorCycler
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mirrorCycler wait for user response (see UIRESUME)
% uiwait(handles.figure1);

return;

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = mirrorCycler_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function currentPositionIncrement_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function currentPositionIncrement_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function currentPositionDecrement_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function currentPositionDecrement_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function currentPosition_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function currentPosition_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in enable.
function enable_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in select.
function select_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in importFromMapper.
function importFromMapper_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xum_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function xum_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xVolts_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function xVolts_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yum_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function yum_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yVolts_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function yVolts_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
        'hObject', hObject, ...
        'positions', [], ...
        'mapperObj', [], ...
      };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

try
    mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
    setLocal(progmanager, hObject, 'mapperObj', mapperObj);
catch
    warning('Failed to find running Mapper program.');
end

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

try
    mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
    setLocal(progmanager, hObject, 'mapperObj', mapperObj);
catch
    warning('Failed to find running Mapper program.');
end

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
% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in delete.
function delete_Callback(hObject, eventdata, handles)


return;
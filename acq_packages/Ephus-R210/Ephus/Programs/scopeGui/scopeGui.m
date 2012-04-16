% scopeGui - A gui for interacting with a scopeObject.
%
% SYNTAX
%
% USAGE
%
% NOTES:
%
% CHANGES:
%
% Created 1/24/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = scopeGui(varargin)
% SCOPEGUI M-file for scopeGui.fig
%      SCOPEGUI, by itself, creates a new SCOPEGUI or raises the existing
%      singleton*.
%
%      H = SCOPEGUI returns the handle to a new SCOPEGUI or the handle to
%      the existing singleton*.
%
%      SCOPEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCOPEGUI.M with the given input arguments.
%
%      SCOPEGUI('Property','Value',...) creates a new SCOPEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before scopeGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to scopeGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help scopeGui

% Last Modified by GUIDE v2.5 11-Feb-2005 20:05:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scopeGui_OpeningFcn, ...
                   'gui_OutputFcn',  @scopeGui_OutputFcn, ...
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
% --- Executes just before scopeGui is made visible.
function scopeGui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

return;

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = scopeGui_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'scopeObject', [], ...
       'xOffset', 0, 'Gui', 'xOffset', 'Class', 'Numeric', ...
       'xOffsetSlider', 0, 'Gui', 'xOffsetSlider', 'Class', 'Numeric', 'Min', 1, 'Max', 10, ...
       'xOffsetSliderLast', 0, ...
       'xUnitsPerDiv', 0, 'Gui', 'xUnitsPerDiv', 'Class', 'Numeric', ...
       'xUnitsPerDivSlider', 0, 'Gui', 'xUnitsPerDivSlider', 'Class', 'Numeric', 'Min', 1, 'Max', 10, ...
       'xUnitsString', 'Seconds', 'Gui', 'xUnitsString', 'Class', 'char', ...
       'yOffset', 0, 'Gui', 'yOffset', 'Class', 'Numeric', ...
       'yOffsetSlider', 0, 'Gui', 'yOffsetSlider', 'Class', 'Numeric', 'Min', 1, 'Max', 10, ...
       'xOffsetSliderLast', 0, ...
       'yUnitsPerDiv', 0, 'Gui', 'yUnitsPerDiv', 'Class', 'Numeric', ...
       'yUnitsPerDivSlider', 0, 'Gui', 'yUnitsPerDivSlider', 'Class', 'Numeric', 'Min', 1, 'Max', 10, ...
       'yUnitsString', 'Volts', 'Gui', 'yUnitsString', 'Class', 'char', ...
       'channelOffset', 0, 'Gui', 'channelOffset', 'Class', 'Numeric', ...
       'channelGain', 0, 'Gui', 'channelGain', 'Gui', 'channelGainSlider', 'Class', 'Numeric', ...
       'channelVisibility', 0, 'Gui', 'channelVisibility', 'Class', 'Numeric', ...
       'channelList', 'None', 'Gui', 'channelList', 'Class', 'char', ...
       'channelListLast', 'None', 'Class', 'char', ...
       'noUpdate', 0, ...
       'autoRange', 0, 'Class', 'Numeric', 'Gui', 'autoRange', ...
       'updatingGuiFromScope', 0, ...
       'lastUpdateTime', clock, ...
       'minUpdateTime', 0.55, ...
    };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

scg_setScope(hObject, scopeObject);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

sc = getLocal(progmanager, hObject, 'scopeObject');
if ~isempty(sc)
    %TO100705B: scopeObject/delete does not currently work on arrays. -- Tim O'Connor 10/7/05
    for i = 1 : length(sc)
        delete(sc(i));
    end
else
    warning('Found a non-instantiated and/or corrupted handle for a ScopeObject.');
end

return;

% ------------------------------------------------------------------
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
% --- Executes during object creation, after setting all properties.
function xUnitsPerDiv_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function xUnitsPerDiv_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'noUpdate', 1);
set(getLocal(progmanager, hObject, 'scopeObject'), 'xUnitsPerDiv', getLocal(progmanager, hObject, 'xUnitsPerDiv'));
setLocal(progmanager, hObject, 'noUpdate', 0);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xUnitsPerDivSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function xUnitsPerDivSlider_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'noUpdate', 1);

xUnitsPerDivSlider = getLocal(progmanager, hObject, 'xUnitsPerDivSlider');
switch xUnitsPerDivSlider
    case 1
    case 2
    case 3
    case 4
    case 5
    case 6
    case 7
    case 8
    case 9
    case 10
    otherwise
end
set(getLocal(progmanager, hObject, 'scopeObject'), 'xUnitsPerDiv', val);
setLocal(progmanager, hObject, 'xUnitsPerDiv', val);

setLocal(progmanager, hObject, 'noUpdate', 0);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yUnitsPerDivSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function yUnitsPerDivSlider_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yUnitsPerDiv_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function yUnitsPerDiv_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'scopeObject'), 'autoRange', 0);
setLocal(progmanager, hObject, 'autoRange', 0);
setLocal(progmanager, hObject, 'noUpdate', 1);
set(getLocal(progmanager, hObject, 'scopeObject'), 'yUnitsPerDiv', getLocal(progmanager, hObject, 'yUnitsPerDiv'));
setLocal(progmanager, hObject, 'noUpdate', 0);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xOffsetSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function xOffsetSlider_Callback(hObject, eventdata, handles)

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

setLocal(progmanager, hObject, 'noUpdate', 1);
set(getLocal(progmanager, hObject, 'scopeObject'), 'xOffset', getLocal(progmanager, hObject, 'xOffset'));
setLocal(progmanager, hObject, 'noUpdate', 0);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yOffsetSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function yOffsetSlider_Callback(hObject, eventdata, handles)

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

set(getLocal(progmanager, hObject, 'scopeObject'), 'autoRange', 0);
setLocal(progmanager, hObject, 'autoRange', 0);
setLocal(progmanager, hObject, 'noUpdate', 1);
set(getLocal(progmanager, hObject, 'scopeObject'), 'yOffset', getLocal(progmanager, hObject, 'yOffset'));
setLocal(progmanager, hObject, 'noUpdate', 0);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yUnitsString_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function yUnitsString_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'noUpdate', 1);
set(getLocal(progmanager, hObject, 'scopeObject'), 'yUnitsString', getLocal(progmanager, hObject, 'yUnitsString'));
setLocal(progmanager, hObject, 'noUpdate', 0);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xUnitsString_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function xUnitsString_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'noUpdate', 1);
set(getLocal(progmanager, hObject, 'scopeObject'), 'xUnitsString', getLocal(progmanager, hObject, 'xUnitsString'));
setLocal(progmanager, hObject, 'noUpdate', 0);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function channelList_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on selection change in channelList.
function channelList_Callback(hObject, eventdata, handles)

if ~strcmp(getLocal(progmanager, hObject, 'channelListLast'), getLocal(progmanager, hObject, 'channelList'))
    scg_updateGuiFromScope(hObject);
end

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function channelOffsetSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function channelOffsetSlider_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function channelOffset_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function channelOffset_Callback(hObject, eventdata, handles)
%Let the enabling/disabling take care of the case when there are no channels.

offset = getLocal(progmanager, hObject, 'channelOffset');
if offset == 0
    setLocalGh(progmanager, hObject, 'channelOffset', 'ForegroundColor', [0 0 0], ...
        'FontWeight', 'Normal');
else
    setLocalGh(progmanager, hObject, 'channelOffset', 'ForegroundColor', [1 0 0], ...
        'FontWeight', 'Bold');
end

sc = getLocal(progmanager, hObject, 'scopeObject');
setChannelProperty(sc, getLocal(progmanager, hObject, 'channelList'), 'offset', offset);
updateDisplayOptions(sc);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function channelGainSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function channelGainSlider_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function channelGain_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function channelGain_Callback(hObject, eventdata, handles)
%Let the enabling/disabling take care of the case when there are no channels.

gain = getLocal(progmanager, hObject, 'channelGain');
if gain == 0
    %Don't let the gain equal 0.
    gain = 1;
    setLocal(progmanager, hObject, 'channelGain', gain);
end

if gain == 1
    setLocalGh(progmanager, hObject, 'channelGain', 'ForegroundColor', [0 0 0], ...
        'FontWeight', 'Normal');
else
    setLocalGh(progmanager, hObject, 'channelGain', 'ForegroundColor', [1 0 0], ...
        'FontWeight', 'Bold');
end

sc = getLocal(progmanager, hObject, 'scopeObject');
setChannelProperty(sc, getLocal(progmanager, hObject, 'channelList'), 'gain', gain);
updateDisplayOptions(sc);

return;

% ------------------------------------------------------------------
% --- Executes on button press in channelVisibility.
function channelVisibility_Callback(hObject, eventdata, handles)
%Let the enabling/disabling take care of the case when there are no channels.

sc = getLocal(progmanager, hObject, 'scopeObject');
setChannelProperty(sc, getLocal(progmanager, hObject, 'channelList'), 'visible', ...
    getLocal(progmanager, hObject, 'channelVisibility'));
updateDisplayOptions(sc);

return;

% ------------------------------------------------------------------
% --- Executes on button press in autoRange.
function autoRange_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'scopeObject'), 'autoRange', getLocal(progmanager, hObject, 'autoRange'));
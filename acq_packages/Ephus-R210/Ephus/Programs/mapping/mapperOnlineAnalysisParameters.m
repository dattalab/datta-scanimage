function varargout = mapperOnlineAnalysisParameters(varargin)
% MAPPERONLINEANALYSISPARAMETERS M-file for mapperOnlineAnalysisParameters.fig
%      MAPPERONLINEANALYSISPARAMETERS, by itself, creates a new MAPPERONLINEANALYSISPARAMETERS or raises the existing
%      singleton*.
%
%      H = MAPPERONLINEANALYSISPARAMETERS returns the handle to a new MAPPERONLINEANALYSISPARAMETERS or the handle to
%      the existing singleton*.
%
%      MAPPERONLINEANALYSISPARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAPPERONLINEANALYSISPARAMETERS.M with the given input arguments.
%
%      MAPPERONLINEANALYSISPARAMETERS('Property','Value',...) creates a new MAPPERONLINEANALYSISPARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mapperOnlineAnalysisParameters_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mapperOnlineAnalysisParameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mapperOnlineAnalysisParameters

% Last Modified by GUIDE v2.5 08-Sep-2006 20:06:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mapperOnlineAnalysisParameters_OpeningFcn, ...
                   'gui_OutputFcn',  @mapperOnlineAnalysisParameters_OutputFcn, ...
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
% --- Executes just before mapperOnlineAnalysisParameters is made visible.
function mapperOnlineAnalysisParameters_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mapperOnlineAnalysisParameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = mapperOnlineAnalysisParameters_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function traceNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function traceNumber_Callback(hObject, eventdata, handles)
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function baselineStart_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function baselineStart_Callback(hObject, eventdata, handles)

genericUpdateFcn(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function baselineEnd_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function baselineEnd_Callback(hObject, eventdata, handles)

genericUpdateFcn(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function analysisWindowStart_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function analysisWindowStart_Callback(hObject, eventdata, handles)

genericUpdateFcn(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function analysisWindowEnd_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function analysisWindowEnd_Callback(hObject, eventdata, handles)

genericUpdateFcn(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function spikeThreshold_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function spikeThreshold_Callback(hObject, eventdata, handles)

genericUpdateFcn(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mode_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on selection change in mode.
function mode_Callback(hObject, eventdata, handles)

genericUpdateFcn(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
        'hObject', hObject, ...
        'mode', 'meanOfPeaks', 'Class', 'char', 'Gui', 'mode', 'Config', 5, ...
        'traceNumber', 1, 'Class', 'Numeric', 'Gui', 'traceNumber', 'Config', 5, ...
        'baselineStart', 1, 'Class', 'Numeric', 'Gui', 'baselineStart', 'Config', 5, ...
        'baselineEnd', 999, 'Class', 'Numeric', 'Gui', 'baselineEnd', 'Config', 5, ...
        'analysisWindowStart', 1000, 'Class', 'Numeric', 'Gui', 'analysisWindowStart', 'Config', 5, ...
        'analysisWindowEnd', 2000, 'Class', 'Numeric', 'Gui', 'analysisWindowEnd', 'Config', 5, ...
        'spikeThreshold', 1, 'Class', 'Numeric', 'Gui', 'spikeThreshold', 'Config', 5, ...
        'figurePosition', [], 'Config', 5, ...
      };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

genericUpdateFcn(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)
global mapper_userFcn_display;

[mode, traceNumber, baselineStart, baselineEnd, analysisWindowStart, analysisWindowEnd, spikeThreshold, figurePosition] = getLocalBatch(progmanager, hObject, ...
    'mode', 'traceNumber', 'baselineStart', 'baselineEnd', 'analysisWindowStart', 'analysisWindowEnd', 'spikeThreshold', 'figurePosition');

mapper_userFcn_display.mode = mode;
mapper_userFcn_display.traceNumber = traceNumber;
mapper_userFcn_display.baselineStart = baselineStart;
mapper_userFcn_display.baselineEnd = baselineEnd;
mapper_userFcn_display.analysisWindowStart = analysisWindowStart;
mapper_userFcn_display.analysisWindowEnd = analysisWindowEnd;
mapper_userFcn_display.spikeThreshold = spikeThreshold;
if ~isempty(figurePosition)
    if isfield(mapper_userFcn_display, 'figure')
        if ishandle(mapper_userFcn_display.figure)
            set(mapper_userFcn_display.figure, 'Position', figurePosition);
        end
    end
end

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)
global mapper_userFcn_display;

if isfield(mapper_userFcn_display, 'figure')
    if ishandle(mapper_userFcn_display.figure)
        delete(mapper_userFcn_display.figure);
    end
end

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

return;

% ------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)
global mapper_userFcn_display;

if isfield(mapper_userFcn_display, 'figure')
    if ishandle(mapper_userFcn_display.figure)
        setLocal(progmanager, hObject, 'figurePosition', get(mapper_userFcn_display.figure, 'Position'));
    end
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
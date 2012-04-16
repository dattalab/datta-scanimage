function varargout = resQuickChange(varargin)
% RESQUICKCHANGE MATLAB code for resQuickChange.fig
%      RESQUICKCHANGE, by itself, creates a new RESQUICKCHANGE or raises the existing
%      singleton*.
%
%      H = RESQUICKCHANGE returns the handle to a new RESQUICKCHANGE or the handle to
%      the existing singleton*.
%
%      RESQUICKCHANGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESQUICKCHANGE.M with the given input arguments.
%
%      RESQUICKCHANGE('Property','Value',...) creates a new RESQUICKCHANGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before resQuickChange_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to resQuickChange_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help resQuickChange

% Last Modified by GUIDE v2.5 23-Sep-2011 03:28:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @resQuickChange_OpeningFcn, ...
    'gui_OutputFcn',  @resQuickChange_OutputFcn, ...
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


% --- Executes just before resQuickChange is made visible.
function resQuickChange_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to resQuickChange (see VARARGIN)

% Choose default command line output for resQuickChange
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes resQuickChange wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = resQuickChange_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton128.
function scanCallback(hObject, eventdata, handles, vargin)
% hObject    handle to pushbutton128 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state gh;
if (state.internal.status==2) || (state.internal.status==3)
    disp('Currently imaging!! Aborting quick change...');
    updateGUIByGlobal('state.acq.msPerLine');
    updateGUIByGlobal('state.acq.msPerLineGUI');
    
    return
end

type=get(hObject,'Style');

if (strcmp(type,'pushbutton'))  % res button press
    buttonName = get(hObject, 'Tag');
    res=str2num(buttonName(11:end));
    msPerLine=state.acq.msPerLine;
    msPerLineGUI=state.acq.msPerLineGUI;
else
    res=state.acq.pixelsPerLine;
    msPerLineGUI=get(hObject, 'Value');
    ms={1,2,2.5,4,8};
    msPerLine=ms{msPerLineGUI};
end

%keyboard;

%pixels/line
switch res
    case 128
        state.acq.pixelsPerLineGUI = 4; %4=128,5=256,6=512,7=1024;
    case 256
        state.acq.pixelsPerLineGUI = 5; %4=128,5=256,6=512,7=1024;
    case 512
        state.acq.pixelsPerLineGUI = 6; %4=128,5=256,6=512,7=1024;
    case 1024
        state.acq.pixelsPerLineGUI = 7; %4=128,5=256,6=512,7=1024;
end
state.acq.pixelsPerLine = res;

%lines/frame
state.acq.linesPerFrame = res;

%ms/line
state.acq.msPerLineGUI=msPerLineGUI;
state.acq.msPerLine=msPerLine;

updateGUIByGlobal('state.acq.pixelsPerLine');
updateGUIByGlobal('state.acq.pixelsPerLineGUI');
updateGUIByGlobal('state.acq.linesPerFrame');

updateGUIByGlobal('state.acq.msPerLine');
updateGUIByGlobal('state.acq.msPerLineGUI');

setAcquisitionParameters;
updateDataForConfiguration;


% --- Executes on button press in chan1_check.
function chan_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state gh;
value=get(hObject,'Value');
chanTag=get(hObject,'Tag');
chan=chanTag(5);

if (state.internal.status==2) || (state.internal.status==3)
    disp('Currently imaging!! Aborting quick change...');
    updateGUIByGlobal(['state.acq.acquiringChannel' chan]);
    updateGUIByGlobal(['state.acq.savingChannel' chan]);
    updateGUIByGlobal(['state.acq.imagingChannel' chan]);
    
    return
end
state.internal.channelChanged=1;

eval(['state.acq.acquiringChannel' chan '=value;']);
eval(['state.acq.savingChannel' chan '=value;']);
eval(['state.acq.imagingChannel' chan '=value;']);

updateGUIByGlobal(['state.acq.acquiringChannel' chan]);
updateGUIByGlobal(['state.acq.savingChannel' chan]);
updateGUIByGlobal(['state.acq.imagingChannel' chan]);

closeChannelGUI;
updateDataForConfiguration;

% --- Executes during object creation, after setting all properties.
function msPerLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to msPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

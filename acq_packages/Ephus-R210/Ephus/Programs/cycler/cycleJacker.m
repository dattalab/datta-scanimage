function varargout = cycleJacker(varargin)
% CYCLEJACKER M-file for cycleJacker.fig
%      CYCLEJACKER, by itself, creates a new CYCLEJACKER or raises the existing
%      singleton*.
%
%      H = CYCLEJACKER returns the handle to a new CYCLEJACKER or the handle to
%      the existing singleton*.
%
%      CYCLEJACKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CYCLEJACKER.M with the given input arguments.
%
%      CYCLEJACKER('Property','Value',...) creates a new CYCLEJACKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cycleJacker_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cycleJacker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cycleJacker

% Last Modified by GUIDE v2.5 24-Aug-2006 18:22:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cycleJacker_OpeningFcn, ...
                   'gui_OutputFcn',  @cycleJacker_OutputFcn, ...
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


% --- Executes just before cycleJacker is made visible.
function cycleJacker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cycleJacker (see VARARGIN)

% Choose default command line output for cycleJacker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cycleJacker wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cycleJacker_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function positionIncrementSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to positionIncrementSlider (see GCBO)
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


% --- Executes on slider movement.
function positionIncrementSlider_Callback(hObject, eventdata, handles)
% hObject    handle to positionIncrementSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function positionDecrementSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to positionDecrementSlider (see GCBO)
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


% --- Executes on slider movement.
function positionDecrementSlider_Callback(hObject, eventdata, handles)
% hObject    handle to positionDecrementSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function currentPosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function currentPosition_Callback(hObject, eventdata, handles)
% hObject    handle to currentPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentPosition as text
%        str2double(get(hObject,'String')) returns contents of currentPosition as a double


% --- Executes during object creation, after setting all properties.
function channelList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in channelList.
function channelList_Callback(hObject, eventdata, handles)
% hObject    handle to channelList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns channelList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channelList


% --- Executes during object creation, after setting all properties.
function pulseSetName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulseSetName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in pulseSetName.
function pulseSetName_Callback(hObject, eventdata, handles)
% hObject    handle to pulseSetName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pulseSetName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pulseSetName


% --- Executes during object creation, after setting all properties.
function pulseName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in pulseName.
function pulseName_Callback(hObject, eventdata, handles)
% hObject    handle to pulseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pulseName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pulseName


% --- Executes on button press in addPosition.
function addPosition_Callback(hObject, eventdata, handles)
% hObject    handle to addPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in deletePosition.
function deletePosition_Callback(hObject, eventdata, handles)
% hObject    handle to deletePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function cycleName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cycleName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in cycleName.
function cycleName_Callback(hObject, eventdata, handles)
% hObject    handle to cycleName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cycleName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cycleName


% --- Executes on button press in newCycle.
function newCycle_Callback(hObject, eventdata, handles)
% hObject    handle to newCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadCycle.
function loadCycle_Callback(hObject, eventdata, handles)
% hObject    handle to loadCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in enable.
function enable_Callback(hObject, eventdata, handles)
% hObject    handle to enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable



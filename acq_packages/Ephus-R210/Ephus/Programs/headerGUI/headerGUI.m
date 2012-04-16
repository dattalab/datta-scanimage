function varargout = headerGUI(varargin)
% HEADERGUI M-file for headerGUI.fig
%      HEADERGUI, by itself, creates a new HEADERGUI or raises the existing
%      singleton*.
%
%      H = HEADERGUI returns the handle to a new HEADERGUI or the handle to
%      the existing singleton*.
%
%      HEADERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HEADERGUI.M with the given input arguments.
%
%      HEADERGUI('Property','Value',...) creates a new HEADERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before headerGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to headerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help headerGUI

% Last Modified by GUIDE v2.5 11-Sep-2007 14:03:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @headerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @headerGUI_OutputFcn, ...
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


% --- Executes just before headerGUI is made visible.
function headerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to headerGUI (see VARARGIN)

% Choose default command line output for headerGUI
handles.output = hObject;

% Update handles structure

% UIWAIT makes headerGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = headerGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes during object creation, after setting all properties.
function speciesStrain_pm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speciesStrain_pm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in speciesStrain_pm.
function speciesStrain_pm_Callback(hObject, eventdata, handles)
% hObject    handle to speciesStrain_pm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns speciesStrain_pm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from speciesStrain_pm

str=get(hObject,'String');
val=get(hObject,'Value');
speciesStrain = str{val};

setLocal(progmanager, hObject, 'speciesStrain', speciesStrain);

genericSaveProgramData(hObject, eventdata, handles);
        
      
% --- Executes during object creation, after setting all properties.
function sliceTime_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliceTime_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function sliceTime_ed_Callback(hObject, eventdata, handles)
% hObject    handle to sliceTime_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sliceTime_ed as text
%        str2double(get(hObject,'String')) returns contents of sliceTime_ed as a double
sliceTime = get(hObject, 'String');

setLocal(progmanager, hObject, 'sliceTime', sliceTime);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



% --- Executes during object creation, after setting all properties.
function somaZ_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to somaZ_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function somaZ_ed_Callback(hObject, eventdata, handles)
% hObject    handle to somaZ_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of somaZ_ed as text
%        str2double(get(hObject,'String')) returns contents of somaZ_ed as a double

ccn = getlocal(progmanager, hObject, 'currentCellNumber');
somaZ = get(hObject, 'String');

if isempty(str2num(somaZ))
   errordlg('Please input a numerical value');
   return;
end

somaZ = str2num(somaZ);

switch ccn
    case 1
        setLocal(progmanager, hObject, 'somaZ1', somaZ);
    case 2
        setLocal(progmanager, hObject, 'somaZ2', somaZ);
    case 3
        setLocal(progmanager, hObject, 'somaZ3', somaZ);
    case 4
        setLocal(progmanager, hObject, 'somaZ4', somaZ);
end

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function vRest_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vRest_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function vRest_ed_Callback(hObject, eventdata, handles)
% hObject    handle to vRest_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vRest_ed as text
%        str2double(get(hObject,'String')) returns contents of vRest_ed as a double

ccn = getlocal(progmanager, hObject, 'currentCellNumber');
vRest = get(hObject, 'String');

if isempty(str2num(vRest))
   errordlg('Please input a numerical value');
   return;
end

vRest = str2num(vRest);

switch ccn
    case 1
        setLocal(progmanager, hObject, 'vRest1', vRest);
    case 2
        setLocal(progmanager, hObject, 'vRest2', vRest);
    case 3
        setLocal(progmanager, hObject, 'vRest3', vRest);
    case 4
        setLocal(progmanager, hObject, 'vRest4', vRest);
end

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function intracellularSolutionDrugs_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intracellularSolutionDrugs_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function intracellularSolutionDrugs_ed_Callback(hObject, eventdata, handles)
% hObject    handle to intracellularSolutionDrugs_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intracellularSolutionDrugs_ed as text
%        str2double(get(hObject,'String')) returns contents of intracellularSolutionDrugs_ed as a double
intracellularSolutionDrugs = get(hObject, 'String');

setLocal(progmanager, hObject, 'intracellularSolutionDrugs', intracellularSolutionDrugs);

genericSaveProgramData(hObject, eventdata, handles);





% --- Executes during object creation, after setting all properties.
function gender_pm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gender_pm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in gender_pm.
function gender_pm_Callback(hObject, eventdata, handles)
% hObject    handle to gender_pm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns gender_pm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gender_pm
str=get(hObject,'String');
val=get(hObject,'Value');
gender = str{val};

setLocal(progmanager, hObject, 'gender', gender);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function temp_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function temp_ed_Callback(hObject, eventdata, handles)
% hObject    handle to temp_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_ed as text
%        str2double(get(hObject,'String')) returns contents of temp_ed as a double
temp = get(hObject, 'String');

if isempty(str2num(temp))
   errordlg('Please input a numerical value');
   return;
end

temp = str2num(temp);
setLocal(progmanager, hObject, 'temp', temp);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function targetCells_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targetCells_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function targetCells_ed_Callback(hObject, eventdata, handles)
% hObject    handle to targetCells_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetCells_ed as text
%        str2double(get(hObject,'String')) returns contents of targetCells_ed as a double
targetCells = get(hObject, 'String');

setLocal(progmanager, hObject, 'targetCells', targetCells);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function construct_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to construct_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function construct_ed_Callback(hObject, eventdata, handles)
% hObject    handle to construct_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of construct_ed as text
%        str2double(get(hObject,'String')) returns contents of construct_ed as a double
construct = get(hObject, 'String');

setLocal(progmanager, hObject, 'construct', construct);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes on button press in inUtero_cb.
function inUtero_cb_Callback(hObject, eventdata, handles)
% hObject    handle to inUtero_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of inUtero_cb
if (get(hObject,'Value') == get(hObject,'Max'))
    setLocalBatch(progmanager,hObject,'targetCells','N/A','construct','N/A','inUtero', 1);
else
    setLocalBatch(progmanager,hObject,'targetCells','','construct','','inUtero', 0);
end

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function virusAge_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to virusAge_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function virusAge_ed_Callback(hObject, eventdata, handles)
% hObject    handle to virusAge_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of virusAge_ed as text
%        str2double(get(hObject,'String')) returns contents of virusAge_ed as a double
virusAge = get(hObject, 'String');

if isempty(str2num(virusAge))
   errordlg('Please input a numerical value');
   return;
end

virusAge = str2num(virusAge);
setLocal(progmanager, hObject, 'virusAge', virusAge);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes on button press in vi_cb.
function vi_cb_Callback(hObject, eventdata, handles)
% hObject    handle to vi_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vi_cb
if (get(hObject,'Value') == get(hObject,'Max'))
    setLocalBatch(progmanager,hObject,'virusAge',0,'construct_vi','N/A',...
        'virus','N/A','location','N/A','vi',1);
else 
    setLocalBatch(progmanager,hObject,'virusAge',0,'construct_vi','',...
        'virus','','location','','vi',0); 
end
genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function virus_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to virus_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function virus_ed_Callback(hObject, eventdata, handles)
% hObject    handle to virus_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of virus_ed as text
%        str2double(get(hObject,'String')) returns contents of virus_ed as a double
virus = get(hObject, 'String');

setLocal(progmanager, hObject, 'virus', virus);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function location_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to location_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function location_ed_Callback(hObject, eventdata, handles)
% hObject    handle to location_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of location_ed as text
%        str2double(get(hObject,'String')) returns contents of location_ed as a double
location = get(hObject, 'String');

setLocal(progmanager, hObject, 'location', location);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.



% --- Executes during object creation, after setting all properties.
function experimenter_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experimenter_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function experimenter_ed_Callback(hObject, eventdata, handles)
% hObject    handle to experimenter_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of experimenter_ed as text
%        str2double(get(hObject,'String')) returns contents of experimenter_ed as a double
experimenter = get(hObject, 'String');

setLocal(progmanager, hObject, 'experimenter', experimenter);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function rig_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rig_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function rig_ed_Callback(hObject, eventdata, handles)
% hObject    handle to rig_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rig_ed as text
%        str2double(get(hObject,'String')) returns contents of rig_ed as a double

rig = get(hObject, 'String');
setLocal(progmanager, hObject, 'rig', rig);
genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function transgenicLine_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transgenicLine_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function transgenicLine_ed_Callback(hObject, eventdata, handles)
% hObject    handle to transgenicLine_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of transgenicLine_ed as text
%        str2double(get(hObject,'String')) returns contents of transgenicLine_ed as a double
transgenicLine = get(hObject, 'String');

setLocal(progmanager, hObject, 'transgenicLine', transgenicLine);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes on button press in treatment_cb.
function treatment_cb_Callback(hObject, eventdata, handles)
% hObject    handle to treatment_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of treatment_cb
if (get(hObject,'Value') == get(hObject,'Max'))
    setLocalBatch(progmanager,hObject,'whatTreatment','N/A','treatment',1);
else
    setLocalBatch(progmanager,hObject,'whatTreatment','','treatment',0);
end
genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function whatTreatment_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whatTreatment_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function whatTreatment_ed_Callback(hObject, eventdata, handles)
% hObject    handle to whatTreatment_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of whatTreatment_ed as text
%        str2double(get(hObject,'String')) returns contents of whatTreatment_ed as a double
whatTreatment = get(hObject, 'String');

setLocal(progmanager, hObject, 'whatTreatment', whatTreatment);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function otherField_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to otherField_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function otherField_ed_Callback(hObject, eventdata, handles)
% hObject    handle to otherField_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of otherField_ed as text
%        str2double(get(hObject,'String')) returns contents of otherField_ed as a double
otherField = get(hObject, 'String');

setLocal(progmanager, hObject, 'otherField', otherField);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function otherValue_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to otherValue_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function otherValue_ed_Callback(hObject, eventdata, handles)
% hObject    handle to otherValue_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of otherValue_ed as text
%        str2double(get(hObject,'String')) returns contents of otherValue_ed as a double
otherValue = get(hObject, 'String');

setLocal(progmanager, hObject, 'otherValue', otherValue);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function brainArea_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brainArea_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function brainArea_ed_Callback(hObject, eventdata, handles)
% hObject    handle to brainArea_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of brainArea_ed as text
%        str2double(get(hObject,'String')) returns contents of brainArea_ed as a double

ccn = getLocal(progmanager, hObject, 'currentCellNumber');
brainArea = get(hObject, 'String');

switch ccn
    case 1
        setLocal(progmanager, hObject, 'brainArea1', brainArea);
    case 2
        setLocal(progmanager, hObject, 'brainArea2', brainArea);
    case 3
        setLocal(progmanager, hObject, 'brainArea3', brainArea);      
    case 4
        setLocal(progmanager, hObject, 'brainArea4', brainArea);      
end

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function subregion_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subregion_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function subregion_ed_Callback(hObject, eventdata, handles)
% hObject    handle to subregion_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subregion_ed as text
%        str2double(get(hObject,'String')) returns contents of subregion_ed as a double
ccn = getlocal(progmanager, hObject, 'currentCellNumber');
subregion = get(hObject, 'String');

switch ccn
    case 1
        setLocal(progmanager, hObject, 'subregion1', subregion);
    case 2
        setLocal(progmanager, hObject, 'subregion2', subregion);
    case 3
        setLocal(progmanager, hObject, 'subregion3', subregion);   
    case 4
        setLocal(progmanager, hObject, 'subregion4', subregion);   
end

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function cellType_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellType_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function cellType_ed_Callback(hObject, eventdata, handles)
% hObject    handle to cellType_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cellType_ed as text
%        str2double(get(hObject,'String')) returns contents of cellType_ed as a double

ccn = getlocal(progmanager, hObject, 'currentCellNumber');
cellType = get(hObject, 'String');

switch ccn
    case 1
        setLocal(progmanager, hObject, 'cellType1', cellType);
    case 2
        setLocal(progmanager, hObject, 'cellType2', cellType);
    case 3
        setLocal(progmanager, hObject, 'cellType3', cellType);
    case 4
        setLocal(progmanager, hObject, 'cellType4', cellType);
end

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function cellNumber_pm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellNumber_pm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in cellNumber_pm.
function cellNumber_pm_Callback(hObject, eventdata, handles)
% hObject    handle to cellNumber_pm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cellNumber_pm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cellNumber_pm
str=get(hObject,'String');
val=get(hObject,'Value');
currentCellNumber = str2num(str{val});
handles = guihandles(gcbo);

switch val
    case 1
        [saveCell1, brainArea1, region1, subregion1, cellType1, somaZ1, vRest1] = getLocalBatch(progmanager,...
    hObject, 'saveCell1', 'brainArea1', 'region1', 'subregion1','cellType1','somaZ1','vRest1');
         set(handles.saveCell_cb, 'Value', saveCell1);
         set(handles.brainArea_ed, 'String', brainArea1);
         set(handles.region_ed, 'String', region1);
         set(handles.subregion_ed, 'String', subregion1);
         set(handles.cellType_ed, 'String', cellType1);
         set(handles.somaZ_ed, 'String', somaZ1);
         set(handles.vRest_ed, 'String', vRest1);
    case 2
        [saveCell2, brainArea2, region2, subregion2, cellType2, somaZ2, vRest2] = getLocalBatch(progmanager,...
    hObject, 'saveCell2', 'brainArea2', 'region2', 'subregion2','cellType2','somaZ2','vRest2'); 
         set(handles.saveCell_cb, 'Value', saveCell2);
         set(handles.brainArea_ed, 'String', brainArea2);
         set(handles.region_ed, 'String', region2);
         set(handles.subregion_ed, 'String', subregion2);
         set(handles.cellType_ed, 'String', cellType2);
         set(handles.somaZ_ed, 'String', somaZ2);
         set(handles.vRest_ed, 'String', vRest2);
    case 3
        [saveCell3, brainArea3, region3, subregion3, cellType3, somaZ3, vRest3] = getLocalBatch(progmanager,...
    hObject, 'saveCell3','brainArea3', 'region3', 'subregion3','cellType3','somaZ3','vRest3');  
         set(handles.saveCell_cb, 'Value', saveCell3);
         set(handles.brainArea_ed, 'String', brainArea3);
         set(handles.region_ed, 'String', region3);
         set(handles.subregion_ed, 'String', subregion3);
         set(handles.cellType_ed, 'String', cellType3);
         set(handles.somaZ_ed, 'String', somaZ3);
         set(handles.vRest_ed, 'String', vRest3);
    case 4
        [saveCell4, brainArea4, region4, subregion4, cellType4, somaZ4, vRest4] = getLocalBatch(progmanager,...
    hObject, 'saveCell4', 'brainArea4', 'region4', 'subregion4','cellType4','somaZ4','vRest4');  
         set(handles.saveCell_cb, 'Value', saveCell4);
         set(handles.brainArea_ed, 'String', brainArea4);
         set(handles.region_ed, 'String', region4);
         set(handles.subregion_ed, 'String', subregion4);
         set(handles.cellType_ed, 'String', cellType4);
         set(handles.somaZ_ed, 'String', somaZ4);
         set(handles.vRest_ed, 'String', vRest4);
end

setLocal(progmanager, hObject, 'currentCellNumber', currentCellNumber);

%genericSaveProgramData(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function sliceType_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliceType_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function sliceType_ed_Callback(hObject, eventdata, handles)
% hObject    handle to sliceType_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sliceType_ed as text
%        str2double(get(hObject,'String')) returns contents of sliceType_ed
%        as a double
sliceType = get(hObject, 'String');

setLocal(progmanager, hObject, 'sliceType', sliceType);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function intracellularSolutionType_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intracellularSolutionType_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function intracellularSolutionType_ed_Callback(hObject, eventdata, handles)
% hObject    handle to intracellularSolutionType_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intracellularSolutionType_ed as text
%        str2double(get(hObject,'String')) returns contents of intracellularSolutionType_ed as a double
intracellularSolutionType = get(hObject, 'String');

setLocal(progmanager, hObject, 'intracellularSolutionType', intracellularSolutionType);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function bathSolutionDrugs_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bathSolutionDrugs_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function bathSolutionDrugs_ed_Callback(hObject, eventdata, handles)
% hObject    handle to bathSolutionDrugs_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bathSolutionDrugs_ed as text
%        str2double(get(hObject,'String')) returns contents of bathSolutionDrugs_ed as a double

bathSolutionDrugs = get(hObject, 'String');

setLocal(progmanager, hObject, 'bathSolutionDrugs', bathSolutionDrugs);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function bathSolutionType_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bathSolutionType_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function bathSolutionType_ed_Callback(hObject, eventdata, handles)
% hObject    handle to bathSolutionType_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bathSolutionType_ed as text
%        str2double(get(hObject,'String')) returns contents of bathSolutionType_ed as a double
bathSolutionType = get(hObject, 'String');

setLocal(progmanager, hObject, 'bathSolutionType', bathSolutionType);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function region_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to region_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function region_ed_Callback(hObject, eventdata, handles)
% hObject    handle to region_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of region_ed as text
%        str2double(get(hObject,'String')) returns contents of region_ed as a double

ccn = getlocal(progmanager, hObject, 'currentCellNumber');
region = get(hObject, 'String');

switch ccn
    case 1
        setLocal(progmanager, hObject, 'region1', region);
    case 2
        setLocal(progmanager, hObject, 'region2', region);
    case 3
        setLocal(progmanager, hObject, 'region3', region);   
    case 4
        setLocal(progmanager, hObject, 'region4', region);   
end

genericSaveProgramData(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function construct_vi_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to construct_vi_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function construct_vi_ed_Callback(hObject, eventdata, handles)
% hObject    handle to construct_vi_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of construct_vi_ed as text
%        str2double(get(hObject,'String')) returns contents of construct_vi_ed as a double
construct_vi = get(hObject, 'String');

setLocal(progmanager, hObject, 'construct_vi', construct_vi);

genericSaveProgramData(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function animalAge_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to animalAge_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function animalAge_ed_Callback(hObject, eventdata, handles)
% hObject    handle to animalAge_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of animalAge_ed as text
%        str2double(get(hObject,'String')) returns contents of animalAge_ed as a double
animalAge = get(hObject, 'String');

if isempty(str2num(animalAge))
   errordlg('Please input a numerical value');
   return;
end

animalAge = str2num(animalAge);
setLocal(progmanager, hObject, 'animalAge', animalAge);

genericSaveProgramData(hObject, eventdata, handles);


%Add the following part to integrate with @progmanager
%% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
        'hObject', hObject, ...
        'experimenter', '', 'Class', 'char', 'Gui', 'experimenter_ed', 'Config', 7, ...
        'rig', '', 'Class', 'char', 'Gui', 'rig_ed', 'Config', 7, ...
        'speciesStrain', 'mouse - C57Bl/6', 'Class', 'char', 'Gui', 'speciesStrain_pm', 'Config', 7, ...
        'animalAge', 0, 'Min', 0, 'Class', 'numeric','Gui','animalAge_ed','Config', 7, ...
        'gender', 'not noted', 'Class', 'char','Gui','gender_pm','Config', 7, ...
        'transgenicLine', '', 'Class', 'char','Gui','transgenicLine_ed','Config', 7, ...
        'sliceTime', '', 'Class', 'char','Gui','sliceTime_ed','Config', 7, ...
        'sliceType', '', 'Class', 'char','Gui','sliceType_ed','Config', 7, ...
        'temp', 0, 'Class', 'numeric','Gui','temp_ed','Config', 7, ...
        'otherField', '', 'Class', 'char','Gui','otherField_ed','Config', 7, ...
        'otherValue', '', 'Class', 'char','Gui','otherValue_ed','Config', 7, ...
        'inUtero', 0, 'Class', 'numeric','Gui','inUtero_cb','Config', 7, ...
        'targetCells', '','Class', 'char','Gui','targetCells_ed','Config', 7, ...
        'construct', '', 'Class', 'char','Gui','construct_ed','Config', 7, ...
        'treatment', 0, 'Class', 'numeric','Gui','treatment_cb','Config', 7, ...
        'whatTreatment', '','Class', 'char','Gui','whatTreatment_ed','Config', 7, ...
        'vi', 0, 'Min', 0, 'Class', 'numeric','Gui','vi_cb','Config', 7, ...
        'virusAge', 0, 'Min', 0, 'Class', 'numeric','Gui','virusAge_ed','Config', 7, ...
        'construct_vi', '','Class', 'char','Gui','construct_vi_ed','Config', 7, ...
        'virus', '', 'Class', 'char','Gui','virus_ed','Config', 7, ...
        'location', '','Class', 'char','Gui','location_ed','Config', 7, ...
        'currentCellNumber', 1, 'Min', 1, 'Class', 'numeric','Gui','cellNumber_pm','Config', 7, ...
        'saveCell1',1,'Class','numeric','Config',7,...
        'brainArea1', '','Class', 'char','Config', 7, ...
        'region1', '', 'Class', 'char','Config', 7, ...
        'subregion1', '','Class', 'char','Config', 7, ...
        'cellType1', '', 'Class', 'char','Config', 7, ...
        'somaZ1', 0, 'Min', 0, 'Class','numeric','Config', 7, ...
        'vRest1', 0, 'Class', 'numeric','Config', 7, ...
        'saveCell2',0,'Class','numeric','Config',7,...
        'brainArea2', '','Class', 'char','Config', 7, ...
        'region2', '', 'Class', 'char','Config', 7, ...
        'subregion2', '','Class', 'char','Config', 7, ...
        'cellType2', '', 'Class', 'char','Config', 7, ...
        'somaZ2', 0, 'Min', 0, 'Class', 'numeric','Config', 7, ...
        'vRest2', 0, 'Class', 'numeric','Config', 7, ...
        'saveCell3',0,'Class','numeric','Config',7,...        
        'brainArea3', '','Class', 'char','Config', 7, ...
        'region3', '', 'Class', 'char','Config', 7, ...
        'subregion3', '','Class', 'char','Config', 7, ...
        'cellType3', '', 'Class', 'char','Config', 7, ...
        'somaZ3', 0, 'Min', 0, 'Class', 'numeric','Config', 7, ...
        'vRest3', 0, 'Class', 'numeric','Config', 7, ...
        'saveCell4',0,'Class','numeric','Config',7,...        
        'brainArea4', '','Class', 'char','Config', 7, ...
        'region4', '', 'Class', 'char','Config', 7, ...
        'subregion4', '','Class', 'char','Config', 7, ...
        'cellType4', '', 'Class', 'char','Config', 7, ...
        'somaZ4', 0, 'Min', 0, 'Class', 'numeric','Config', 7, ...
        'vRest4', 0, 'Class', 'numeric','Config', 7, ...
        'intracellularSolutionType', '','Class', 'char','Gui','intracellularSolutionType_ed','Config', 7, ...
        'intracellularSolutionDrugs','','Class', 'char','Gui','intracellularSolutionDrugs_ed','Config', 7, ...
        'bathSolutionType', '','Class', 'char','Gui','bathSolutionType_ed','Config', 7, ...
        'bathSolutionDrugs', '','Class', 'char','Gui','bathSolutionDrugs_ed','Config', 7, ... 
        'filename', getDefaultCacheValue(progmanager, 'headerGUI_filename'), 'Class', 'char', ...
        'pathname', getDefaultCacheDirectory(progmanager, 'headerGUI_pathname'), 'Class', 'char', ...
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

hObject = getHandleFromName(progmanager,'headerGUI','headerGUI');
handles = guihandles(hObject);
[saveCell1, brainArea1, region1, subregion1, cellType1, somaZ1, vRest1] = getLocalBatch(progmanager,...
    hObject, 'saveCell1', 'brainArea1', 'region1', 'subregion1','cellType1','somaZ1','vRest1');
setLocal(progmanager, hObject, 'currentCellNumber',1);
set(handles.saveCell_cb, 'value', saveCell1);
set(handles.brainArea_ed, 'String', brainArea1);
set(handles.region_ed, 'String', region1);
set(handles.subregion_ed, 'String', subregion1);
set(handles.cellType_ed, 'String', cellType1);
set(handles.somaZ_ed, 'String', somaZ1);
set(handles.vRest_ed, 'String', vRest1);


% ------------------------------------------------------------------
function genericPostLoadMiniSettings(hObject, eventdata, handles, varargin)

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

header_saveMFile;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

errordlg('Saveas functionality not supported by this GUI.');

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


% --- Executes on button press in saveCell_cb.
function saveCell_cb_Callback(hObject, eventdata, handles)
% hObject    handle to saveCell_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveCell_cb

ccn = getlocal(progmanager, hObject, 'currentCellNumber');
saveCell = get(hObject, 'Value');

switch ccn
    case 1
        setLocal(progmanager, hObject, 'saveCell1', saveCell);
    case 2
        setLocal(progmanager, hObject, 'saveCell2', saveCell);
    case 3
        setLocal(progmanager, hObject, 'saveCell3', saveCell);   
    case 4
        setLocal(progmanager, hObject, 'saveCell4', saveCell);   
end

genericSaveProgramData(hObject, eventdata, handles);

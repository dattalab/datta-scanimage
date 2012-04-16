function varargout = batchPulseEditor(varargin)
% BATCHPULSEEDITOR M-file for batchPulseEditor.fig
%      BATCHPULSEEDITOR, by itself, creates a new BATCHPULSEEDITOR or raises the existing
%      singleton*.
%
%      H = BATCHPULSEEDITOR returns the handle to a new BATCHPULSEEDITOR or the handle to
%      the existing singleton*.
%
%      BATCHPULSEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BATCHPULSEEDITOR.M with the given input arguments.
%
%      BATCHPULSEEDITOR('Property','Value',...) creates a new BATCHPULSEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before batchPulseEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to batchPulseEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help batchPulseEditor

% Last Modified by GUIDE v2.5 15-Feb-2010 17:49:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @batchPulseEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @batchPulseEditor_OutputFcn, ...
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
return;

%--------------------------------------------------------------------------
% --- Executes just before batchPulseEditor is made visible.
function batchPulseEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to batchPulseEditor (see VARARGIN)

% Choose default command line output for batchPulseEditor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes batchPulseEditor wait for user response (see UIRESUME)
% uiwait(handles.figure1);
peObject = getGlobal(progmanager, 'hObject', 'pulseEditor', 'pulseEditor');
set(handles.number, 'String', getLocal(progmanager, peObject, 'number'));
set(handles.isi, 'String', getLocal(progmanager, peObject, 'isi'));
set(handles.width, 'String', getLocal(progmanager, peObject, 'width'));
set(handles.amplitude, 'String', getLocal(progmanager, peObject, 'amplitude'));
set(handles.delay, 'String', getLocal(progmanager, peObject, 'delay'));
set(handles.additive, 'String', getLocal(progmanager, peObject, 'additive'));

%TO031010H - Make sure this gui gets destroyed when everything shuts down (handled automatically by progmanager, as long as 'deleteObjectsOnClose' is true). GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
batchEditorHandle = getLocal(progmanager, peObject, 'batchEditorHandle');
if ishandle(batchEditorHandle)
    delete(batchEditorHandle);
end
setLocal(progmanager, peObject, 'batchEditorHandle', hObject);

return;

%--------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = batchPulseEditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
return;

%--------------------------------------------------------------------------
function delay_Callback(hObject, eventdata, handles)

set(handles.delayCheck, 'Value', 1);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%--------------------------------------------------------------------------
function isi_Callback(hObject, eventdata, handles)

set(handles.isiCheck, 'Value', 1);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function isi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%--------------------------------------------------------------------------
function width_Callback(hObject, eventdata, handles)

set(handles.widthCheck, 'Value', 1);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%--------------------------------------------------------------------------
function amplitude_Callback(hObject, eventdata, handles)

set(handles.amplitudeCheck, 'Value', 1);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function amplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%--------------------------------------------------------------------------
function additive_Callback(hObject, eventdata, handles)

set(handles.additiveCheck, 'Value', 1);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function additive_CreateFcn(hObject, eventdata, handles)
% hObject    handle to additive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%--------------------------------------------------------------------------
function number_Callback(hObject, eventdata, handles)

set(handles.numberCheck, 'Value', 1);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%--------------------------------------------------------------------------
% --- Executes on button press in apply.
function apply_Callback(hObject, eventdata, handles)

peObject = getGlobal(progmanager, 'hObject', 'pulseEditor', 'pulseEditor');

[pulsePath, pulseSetName] = getLocalBatch(progmanager, peObject, 'directory', 'pulseSetName');

%TO031010I - Check data types. GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
try
    number = eval(get(handles.number, 'String'));
catch
    errordlg('Invalid pulseNumber field.', 'batchPulseEditor Error');
    fprintf(2, 'batchPulseEditor - Invalid pulseNumber field: %s\n', lasterr);
    return;
end
try
    isi = eval(get(handles.isi, 'String'));
catch
    errordlg('Invalid ISI field.', 'batchPulseEditor Error');
    fprintf(2, 'batchPulseEditor - Invalid ISI field: %s\n', lasterr);
    return;
end
try
    width = eval(get(handles.width, 'String'));
catch
    errordlg('Invalid width field.', 'batchPulseEditor Error');
    fprintf(2, 'batchPulseEditor - Invalid width field: %s\n', lasterr);
    return;
end
try
    amplitude = eval(get(handles.amplitude, 'String'));
catch
    errordlg('Invalid amplitude field.', 'batchPulseEditor Error');
    fprintf(2, 'batchPulseEditor - Invalid amplitude field: %s\n', lasterr);
    return;
end
try
    delay = eval(get(handles.delay, 'String'));
catch
    errordlg('Invalid delay field.', 'batchPulseEditor Error');
    fprintf(2, 'batchPulseEditor - Invalid delay field: %s\n', lasterr);
    return;
end
% additive = str2mat(get(handles.additive, 'String'));
fprintf(1, 'Batch-modifying:\n');
signal = signalobject;
pulseFiles = dir(fullfile(pulsePath, pulseSetName, '*.signal'));%TO042010D
pulseNames = {pulseFiles(:).name};%TO042010D - Convert to a cell array of strings.
%TO031010K - Sort by pulseNumber. GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
pulseNumbers = zeros(length(pulseNames), 1);
for i = 1 : length(pulseNames)
    pulseNames{i} = pulseNames{i}(1:end-7);%TO042010D - Trim off the '.signal'.
    pulseNumbers(i) = getNumericSuffix(pulseNames{i});
end
[pulseNumbers, indices] = sort(pulseNumbers);
pulseNames = pulseNames(indices);

for i = 1 : length(pulseNames)
    fullyQualifiedName = fullfile(pulsePath, pulseSetName, pulseFiles(i).name);%TO042010D - Use the original name, with the '.signal' extension.
    s = load(fullyQualifiedName, '-mat');
    signal = s.signal;
    fprintf(1, '\t%s\n', fullyQualifiedName);
    if get(handles.numberCheck, 'Value')
        if length(number) > 1
            if length(number) ~= length(pulseNames)
                errordlg(sprintf('The supplied values for the number field do not match the number of pulses (%s) in this pulseSet.', num2str(length(pulseNames))));
                return;
            end
            set(signal, 'squarePulseTrainNumber', number(i));
        else
            set(signal, 'squarePulseTrainNumber', number);
        end
    end
    if get(handles.isiCheck, 'Value')
        if length(isi) > 1
            if length(isi) ~= length(pulseNames)
                errordlg(sprintf('The supplied values for the isi field do not match the number of pulses (%s) in this pulseSet.', num2str(length(pulseNames))));
                return;
            end
            set(signal, 'squarePulseTrainISI', isi(i) / 1000);
        else
            set(signal, 'squarePulseTrainISI', isi / 1000);
        end
    end
    if get(handles.widthCheck, 'Value')
        if length(width) > 1
            if length(width) ~= length(pulseNames)
                errordlg(sprintf('The supplied values for the width field do not match the number of pulses (%s) in this pulseSet.', num2str(length(pulseNames))));
                return;
            end
            set(signal, 'squarePulseTrainWidth', width(i) / 1000);
        else
            set(signal, 'squarePulseTrainWidth', width / 1000);
        end
    end
    if get(handles.amplitudeCheck, 'Value')
        if length(amplitude) > 1
            if length(amplitude) ~= length(pulseNames)
                errordlg(sprintf('The supplied values for the amplitude field do not match the number of pulses (%s) in this pulseSet.', num2str(length(pulseNames))));
                return;
            end
            set(signal, 'amplitude', amplitude(i));
        else
            set(signal, 'amplitude', amplitude);
        end
    end
    if get(handles.delayCheck, 'Value')
        if length(delay) > 1
            if length(delay) ~= length(pulseNames)
                errordlg(sprintf('The supplied values for the delay field do not match the number of pulses (%s) in this pulseSet.', num2str(length(pulseNames))));
                return;
            end
            set(signal, 'squarePulseTrainDelay', delay(i) / 1000);
        else
            set(signal, 'squarePulseTrainDelay', delay / 1000);
        end
    end
%     if get(handles.numberCheck, 'Value')
%         if length(number) > 1
%             set(sig, 'squarePulseTrainNumber', additive(i));
%         else
%             set(sig, 'squarePulseTrainNumber', additive);
%         end

    saveCompatible(fullyQualifiedName, 'signal', '-mat');
    
    delete(signal);
end

% pulseEditor('updateDisplayFromPulse', peObject);
pulseEditor('pulseName_Callback', peObject, [], guidata(peObject));

delete(getParent(hObject, 'figure'));

return;

%--------------------------------------------------------------------------
% --- Executes on button press in numberCheck.
function numberCheck_Callback(hObject, eventdata, handles)
return;

%--------------------------------------------------------------------------
% --- Executes on button press in isiCheck.
function isiCheck_Callback(hObject, eventdata, handles)
return;

%--------------------------------------------------------------------------
% --- Executes on button press in widthCheck.
function widthCheck_Callback(hObject, eventdata, handles)
return;

%--------------------------------------------------------------------------
% --- Executes on button press in amplitudeCheck.
function amplitudeCheck_Callback(hObject, eventdata, handles)
return;

%--------------------------------------------------------------------------
% --- Executes on button press in delayCheck.
function delayCheck_Callback(hObject, eventdata, handles)
return;

%--------------------------------------------------------------------------
% --- Executes on button press in additiveCheck.
function additiveCheck_Callback(hObject, eventdata, handles)
return;
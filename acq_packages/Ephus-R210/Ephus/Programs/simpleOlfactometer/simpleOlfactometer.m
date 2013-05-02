function varargout = simpleOlfactometer(varargin)
% SIMPLEOLFACTOMETER MATLAB code for simpleOlfactometer.fig
%      SIMPLEOLFACTOMETER, by itself, creates a new SIMPLEOLFACTOMETER or raises the existing
%      singleton*.
%
%      H = SIMPLEOLFACTOMETER returns the handle to a new SIMPLEOLFACTOMETER or the handle to
%      the existing singleton*.
%
%      SIMPLEOLFACTOMETER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMPLEOLFACTOMETER.M with the given input arguments.
%
%      SIMPLEOLFACTOMETER('Property','Value',...) creates a new SIMPLEOLFACTOMETER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before simpleOlfactometer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to simpleOlfactometer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help simpleOlfactometer

% Last Modified by GUIDE v2.5 02-May-2013 16:18:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simpleOlfactometer_OpeningFcn, ...
                   'gui_OutputFcn',  @simpleOlfactometer_OutputFcn, ...
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


% --- Executes just before simpleOlfactometer is made visible.
function simpleOlfactometer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to simpleOlfactometer (see VARARGIN)

% Choose default command line output for simpleOlfactometer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes simpleOlfactometer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = simpleOlfactometer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function valve_number_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pre_sec_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function odor_sec_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function post_sec_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function bank_number_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%%%%%%%%%%%%
function enable_Callback(hObject, eventdata, handles)

function valve_number_Callback(hObject, eventdata, handles)
makePulses(hObject)

function pre_sec_Callback(hObject, eventdata, handles)
makePulses(hObject)

function odor_sec_Callback(hObject, eventdata, handles)
makePulses(hObject)

function post_sec_Callback(hObject, eventdata, handles)
makePulses(hObject)

function bank_number_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%

function out=makeGlobalCellArray(hObject, eventdata, handles)
out = {
       'hObject', hObject, ...
       'enable', 0, 'Class', 'Numeric', 'Gui', 'enable', 'Config', 2, ...
       'valve_number', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 15,  'Gui', 'valve_number', 'Config', 3, ...
       'bank_number', 3, 'Class', 'Numeric', 'Min', 1, 'Max', 8,  'Gui', 'bank_number', 'Config', 3, ...
       'pre_sec', 10, 'Class', 'Numeric', 'Min', 0, 'Gui', 'pre_sec', 'Config', 3, ...
       'odor_sec', 2, 'Class', 'Numeric', 'Min', 0, 'Gui', 'odor_sec', 'Config', 3, ...
       'post_sec', 10, 'Class', 'Numeric', 'Min', 0, 'Gui', 'post_sec', 'Config', 3
       };
   % probably need olfactometer settings
   return;

function genericStartFcn(hObject, eventdata, handles)
% init olfactometer?

function genericUpdateFcn(hOjbect, eventdata, handles)

function out=getVersion(hObject, eventdata, handles)
out = 0.01


% --- Executes on button press in connect.
function connect_Callback(hObject, eventdata, handles)
% hObject    handle to connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('ya')

function makePulses(hObject)
    sample_rate = getGlobal(progmanager, 'sampleRate', 'ephys', 'ephys');
    pre = getLocal(progmanager, hObject, 'pre_sec') * sample_rate;
    odor = getLocal(progmanager, hObject, 'odor_sec') * sample_rate;
    post = getLocal(progmanager, hObject, 'post_sec') * sample_rate;
    valve = getLocal(progmanager, hObject, 'valve_number');

    trace_length_in_samples = (pre+odor+post);
    if trace_length_in_samples == 0
        return
    end
    
    stim_literal_pulse = zeros(1, trace_length_in_samples);
    stim_literal_pulse(pre:pre+5) = 100;
    stim_literal_pulse(pre+odor:pre+odor+5) = 100;

    state_literal_pulse = zeros(1, trace_length_in_samples);
    state_literal_pulse(pre:pre+odor) = valve;
    
    stimPulse = signalobject('Name', 'olfactoTrigPulse', 'sampleRate', 10000);
    literal(stimPulse, stim_literal_pulse);

    statePulse = signalobject('Name', 'olfactoStatePulse', 'sampleRate', 10000);
    literal(statePulse, state_literal_pulse);

    allPulses = [stimPulse, statePulse];

    destdir = 'C:\scanimage_conf\olfactoPulses\olfactoPulses';

    for signal = allPulses
        saveCompatible(fullfile(destdir, [get(signal, 'Name') '.signal']), 'signal', '-mat');
    end

    delete(allPulses)
    
    
    % set acquierer, ephys, and stim trace lengths
    ephys_setTraceLength(trace_length_in_samples/sample_rate);
    acq_setTraceLength(trace_length_in_samples/sample_rate);
    stim_setTraceLength(trace_length_in_samples/sample_rate);
    

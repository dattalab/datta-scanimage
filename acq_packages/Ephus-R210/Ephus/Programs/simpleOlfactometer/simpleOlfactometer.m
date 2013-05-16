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

% Last Modified by GUIDE v2.5 03-May-2013 10:35:59

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

function last_command_CreateFcn(hObject, eventdata, handles)

function last_response_CreateFcn(hObject, eventdata, handles)



%%%%%%%%%%%%%
function valve_number_Callback(hObject, eventdata, handles)
makePulses(hObject)
makeStates(hObject)

function pre_sec_Callback(hObject, eventdata, handles)
makePulses(hObject)
makeStates(hObject)

function odor_sec_Callback(hObject, eventdata, handles)
makePulses(hObject)
makeStates(hObject)

function post_sec_Callback(hObject, eventdata, handles)
makePulses(hObject);
makeStates(hObject);

function bank_number_Callback(hObject, eventdata, handles)
makePulses(hObject);
makeStates(hObject);

function connect_Callback(hObject, eventdata, handles)
connectToOlfactometer(hObject);
initTasks(hObject);
makePulses(hObject);
makeStates(hObject);

%%%%%%%%%%%%%

function out=makeGlobalCellArray(hObject, eventdata, handles)
out = {
    'hObject', hObject, ...
    'valve_number', '0', 'Class', 'Char', 'Gui', 'valve_number', 'Config', 3, ...
    'bank_number', 3, 'Class', 'Numeric', 'Min', 1, 'Max', 8,  'Gui', 'bank_number', 'Config', 3, ...
    'pre_sec', 10, 'Class', 'Numeric', 'Min', 0, 'Gui', 'pre_sec', 'Config', 3, ...
    'odor_sec', 2, 'Class', 'Numeric', 'Min', 0, 'Gui', 'odor_sec', 'Config', 3, ...
    'post_sec', 10, 'Class', 'Numeric', 'Min', 0, 'Gui', 'post_sec', 'Config', 3, ...
    'mfc1', 60, 'Class', 'Numeric', 'Config', 7, ...
    'mfc2', 60, 'Class', 'Numeric', 'Config', 7, ...
    'mfc3', 60, 'Class', 'Numeric', 'Config', 7, ...
    'mfc4', 65, 'Class', 'Numeric', 'Config', 7, ...
    'mfc5', 1000, 'Class', 'Numeric', 'Config', 7, ...
    'mfc6', 1000, 'Class', 'Numeric', 'Config', 7, ...
    'mfc7', 485, 'Class', 'Numeric', 'Config', 7, ...
    'mfc8', 485, 'Class', 'Numeric', 'Config', 7, ...
    'olfactometerHost', '192.168.20.85', 'Class', 'char', 'Config', 7, ...
    'olfactometerPort', 3336, 'Class', 'Numeric', 'Config', 7, ...
    'triggerBoardID', 5, 'Class', 'Numeric', 'Config', 7, ...
    'triggerLine', 'PFI2', 'Class', 'char', 'Config', 7, ...
    'lastCommand', '', 'Class', 'char', ...
    'lastResponse', '', 'Class', 'char', ...
    'triggerTask', [], ...
    'olfactometerConn', [], ...
    'valve_button', 0, 'Class', 'Numeric', ...
    'last_command', '', 'Class', 'Char', 'Gui', 'last_command', ...
    'last_response', '', 'Class', 'Char', 'Gui', 'last_response', ...
    'states', '', 'Class', 'Char', ...
    'state_index', 1, 'Class', 'numeric'
    };
return;

function genericStartFcn(hObject, eventdata, handles)
connect_Callback(hObject, eventdata, handles);
makePulses(hObject);
makeStates(hObject);

function genericUpdateFcn(hOjbect, eventdata, handles)

function out=getVersion(hObject, eventdata, handles)
out = 0.01;

function makeStates(hObject)
valve = getLocal(progmanager, hObject, 'valve_number');
setLocal(progmanager, hObject, 'states', [valve '0']);
setLocal(progmanager, hObject, 'state_index', 1);

function makePulses(hObject)
sample_rate = getGlobal(progmanager, 'sampleRate', 'ephys', 'ephys');
pre = getLocal(progmanager, hObject, 'pre_sec') * sample_rate;
odor = getLocal(progmanager, hObject, 'odor_sec') * sample_rate;
post = getLocal(progmanager, hObject, 'post_sec') * sample_rate;
valve = str2num(getLocal(progmanager, hObject, 'valve_number'));

trace_length_in_samples = (pre+odor+post);
if trace_length_in_samples == 0
    return
end

stim_literal_pulse = zeros(1, trace_length_in_samples);
stim_literal_pulse(pre:pre+5) = 10000;
stim_literal_pulse(pre+odor:pre+odor+5) = 10000;

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


% ------------------------------------------------------------------
function connectToOlfactometer(hObject)
%If the connection is persistent, we can do most of this just once.
[olfactometerHost, olfactometerPort, olfactometerConn] = getLocalBatch(progmanager, hObject, ...
    'olfactometerHost', 'olfactometerPort', 'olfactometerConn');

if ~isempty(olfactometerConn)
    pnet(olfactometerConn, 'close');
    setLocal(progmanager, hObject, 'olfactometerConn', []);
end

if isempty(olfactometerHost)
    return;
end

olfactometerConn = pnet('tcpconnect', olfactometerHost, olfactometerPort);
pnet(olfactometerConn, 'setwritetimeout', 1);
pnet(olfactometerConn, 'setreadtimeout', 3);
pnet(olfactometerConn, 'read', 256, 'view');

setLocal(progmanager, hObject, 'olfactometerConn', olfactometerConn);

updateMFCRates(hObject);
return;

% ------------------------------------------------------------------
function sendCommand(hObject, command)

olfactometerConn = getLocal(progmanager, hObject, 'olfactometerConn');

if isempty(olfactometerConn)
    connectToOlfactometer(hObject);
    olfactometerConn = getLocal(progmanager, hObject, 'olfactometerConn');
    %No connection available (maybe the host has not been set).
    if isempty(olfactometerConn)
        return;
    end
end

pnet(olfactometerConn, 'printf', [command 10]);%Terminate with '\n'
setLocal(progmanager, hObject, 'last_command', command);

% fprintf(1, 'OlfactoTrig/sendCommand: ''%s''\n', command);
try
    response = pnet(olfactometerConn, 'readline');
    setLocal(progmanager, hObject, 'last_response', response);
    if ~strcmpi(response, 'OK')
        setLocalGh(progmanager, hObject, 'last_response', 'ForegroundColor', [1, 0, 0]);
    else
        setLocalGh(progmanager, hObject, 'last_response', 'ForegroundColor', [0, 0, 0]);
    end
catch
    fprintf(2, 'Failed to read response from Olfactometer: ''%s''\n', lasterr);
end

return;

% ------------------------------------------------------------------
function updateMFCRates(hObject)

[mfc1, mfc2, mfc3, mfc4, mfc5, mfc6, mfc7, mfc8] = getLocalBatch(progmanager, hObject, ...
    'mfc1', 'mfc2', 'mfc3', 'mfc4', 'mfc5', 'mfc6', 'mfc7', 'mfc8');

sendCommand(hObject, ['write BankFlow1_Actuator ' num2str(mfc1)]);
sendCommand(hObject, ['write BankFlow2_Actuator ' num2str(mfc2)]);
sendCommand(hObject, ['write BankFlow3_Actuator ' num2str(mfc3)]);
sendCommand(hObject, ['write BankFlow4_Actuator ' num2str(mfc4)]);
%
sendCommand(hObject, ['write Carrier1_Actuator ' num2str(mfc5)]);
sendCommand(hObject, ['write Carrier2_Actuator ' num2str(mfc6)]);
sendCommand(hObject, ['write Carrier3_Actuator ' num2str(mfc7)]);
sendCommand(hObject, ['write Carrier4_Actuator ' num2str(mfc8)]);

return;

% ------------------------------------------------------------------
% function incrementOdorByTrigger(hObject, varargin)
function incrementOdorByTrigger(ai, eventdata, hObject)
[triggerTask] = getLocalBatch(progmanager, hObject, 'triggerTask');
stop(triggerTask);

[bank_number, states, state_index] = getLocalBatch(progmanager, hObject, 'bank_number', 'states', 'state_index');
valve_number = str2num(states(state_index));

disp(['switching to valve ' num2str(valve_number) ])
sendCommand(hObject, ['write Bank' num2str(bank_number) '_Valves ' num2str(valve_number)]);

state_index = state_index+1;
if state_index > length(states)
    new_state = 1;
else
    new_state = state_index;
end
setLocal(progmanager, hObject, 'state_index', new_state);

start(triggerTask);

return;

function initTasks(hObject)

[triggerTask, triggerBoardID, triggerLine] = getLocalBatch(progmanager, hObject, ...
    'triggerTask', 'triggerBoardID', 'triggerLine');

if ~isempty(triggerTask)
    try
        stop(triggerTask);
    catch
    end
    delete(triggerTask);
end

triggerTask = daqjob('olf');
set(triggerTask,'triggerDestinations', triggerLine);
addAnalogInput(triggerTask, 'trig', ['/dev' num2str(triggerBoardID) '/ai'], 0);
setTaskProperty(triggerTask, 'trig', 'samplingRate', 10000, 'sampsPerChanToAcquire', 2);
nimex_bindDoneCallback(getTaskByChannelName(triggerTask, 'trig'), {@incrementOdorByTrigger, '', '', hObject}, 'done', 0)

start(triggerTask);
setLocalBatch(progmanager, hObject, 'triggerTask', triggerTask);
return;


% --- Executes when selected object is changed in valve_buttons.
function valve_buttons_SelectionChangeFcn(hObject, eventdata, handles)
button_name = get(eventdata.NewValue, 'tag');
button_number = str2num(button_name(end));
setLocal(progmanager, hObject, 'valve_button', button_number);

bank_number = getLocal(progmanager, hObject, 'bank_number');
sendCommand(hObject, ['write Bank' num2str(bank_number) '_Valves ' num2str(button_number-1)]);



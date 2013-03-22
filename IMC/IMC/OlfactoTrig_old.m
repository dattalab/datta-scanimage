function varargout = OlfactoTrig(varargin)
% OLFACTOTRIG M-file for OlfactoTrig.fig
%      OLFACTOTRIG, by itself, creates a new OLFACTOTRIG or raises the existing
%      singleton*.
%
%      H = OLFACTOTRIG returns the handle to a new OLFACTOTRIG or the handle to
%      the existing singleton*.
%
%      OLFACTOTRIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OLFACTOTRIG.M with the given input arguments.
%
%      OLFACTOTRIG('Property','Value',...) creates a new OLFACTOTRIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OlfactoTrig_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OlfactoTrig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OlfactoTrig

% Last Modified by GUIDE v2.5 27-Jan-2011 02:52:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @OlfactoTrig_OpeningFcn, ...
    'gui_OutputFcn',  @OlfactoTrig_OutputFcn, ...
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

% ------------------------------------------------------------------
% --- Executes just before OlfactoTrig is made visible.
function OlfactoTrig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OlfactoTrig (see VARARGIN)

% Choose default command line output for OlfactoTrig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OlfactoTrig wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = OlfactoTrig_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% ------------------------------------------------------------------
function connectToOlfactometer(hObject)

%If the connection is persistent, we can do most of this just once.
[olfactometerHost, olfactometerPort, olfactometerName, olfactometerConn] = getLocalBatch(progmanager, hObject, ...
    'olfactometerHost', 'olfactometerPort', 'olfactometerName', 'olfactometerConn');

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
setLocal(progmanager, hObject, 'lastCommand', command);

% fprintf(1, 'OlfactoTrig/sendCommand: ''%s''\n', command);
try
    response = pnet(olfactometerConn, 'readline');
    setLocal(progmanager, hObject, 'lastResponse', response);
    if ~strcmpi(response, 'OK')
        setLocalGh(progmanager, hObject, 'lastResponse', 'ForegroundColor', [1, 0, 0]);
    else
        setLocalGh(progmanager, hObject, 'lastResponse', 'ForegroundColor', [0, 0, 0]);
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
function updateValvesByOdor(hObject)

[odorTable, currentOdorIndex, currentState] = getLocalBatch(progmanager, hObject, 'odorTable', 'currentOdorIndex', 'currentState');

if isempty(currentState)
    update = ones(4, 1);
else
    update = zeros(4, 1);
    for i = 1 : length(currentState)
        if (odorTable{currentOdorIndex, i + 1} ~= currentState(i)) && (odorTable{currentOdorIndex, i+1} ~= '-')
            update(i) = 1;
        else
            update(i) = 0;
        end
    end
end

for i = 1 : length(update)
    if update(i)
        if (odorTable{currentOdorIndex, i+1} ~= '-')
            sendCommand(hObject, ['write Bank' num2str(i) '_Valves ' num2str(odorTable{currentOdorIndex, i + 1})]);
        end
        currentState(i) = odorTable{currentOdorIndex, i + 1};
    end
end

setLocal(progmanager, hObject, 'currentState', currentState);

return;

% ------------------------------------------------------------------
function updateOdorIndex(hObject, odorIndex)

odorTable = getLocalBatch(progmanager, hObject, 'odorTable');

if isempty(odorTable) || odorIndex == 0
    previousOdor2 = '';
    previousOdor1 = '';
    currentOdor = '';
    nextOdor1 = '';
    nextOdor2 = '';
    return;
else
    if odorIndex > 2
        previousOdor2 = odorTable{odorIndex - 2, 1};
    else
        previousOdor2 = '';
    end
    if odorIndex > 1
        previousOdor1 = odorTable{odorIndex - 1, 1};
    else
        previousOdor1 = '';
    end
    currentOdor = odorTable{odorIndex, 1};
    if odorIndex < size(odorTable, 1)
        nextOdor1 = odorTable{odorIndex + 1, 1};
    else
        nextOdor1 = '';
    end
    if odorIndex < (size(odorTable, 1) - 1)
        nextOdor2 = odorTable{odorIndex + 2, 1};
    else
        nextOdor2 = '';
    end
end

setLocalBatch(progmanager, hObject, 'currentOdorIndex', odorIndex, ...
    'previousOdor2', previousOdor2, 'previousOdor1', previousOdor1, 'currentOdor', currentOdor, 'nextOdor1', nextOdor1, 'nextOdor2', nextOdor2);

updateValvesByOdor(hObject);

return;

% ------------------------------------------------------------------
function resetOdor(hObject)

updateOdorIndex(hObject, 1);

return;

% ------------------------------------------------------------------
function decrementOdor(hObject)

currentOdorIndex = getLocal(progmanager, hObject, 'currentOdorIndex');
if currentOdorIndex > 1
    updateOdorIndex(hObject, currentOdorIndex - 1);
end

return;

% ------------------------------------------------------------------
function incrementOdor(hObject)

[currentOdorIndex, odorTable] = getLocalBatch(progmanager, hObject, 'currentOdorIndex', 'odorTable');

if currentOdorIndex < size(odorTable, 1)
    updateOdorIndex(hObject, currentOdorIndex + 1);
    % else
    %     updateOdorIndex(hObject, 1);%Go back to the beginning?
end

return;

% ------------------------------------------------------------------
function parseOdorTableFile(hObject)

[odorTableFile] = getLocalBatch(progmanager, hObject, 'odorTableFile');

if isempty(odorTableFile)
    setLocalBatch(progmanager, hObject, 'odorTable', {});
    updateOdorIndex(hObject, 0);
    return;
end

try
    f = fopen(odorTableFile, 'r');
catch
    fprintf(2, 'olfactoTrig: Failed to open file ''%s''.\n%s\n', odorTableFile, getLastErrorStack);
    errordlg(sprintf('Failed to open file ''%s'': %s', odorTableFile, lasterr));
    setLocalBatch(progmanager, hObject, 'odorTable', {});
    updateOdorIndex(hObject, 0);
    return;
end

nextLine = fgetl(f);
odorTable = {};
tableRow = 1;
while ischar(nextLine)
    if any(nextLine(1) == '#%')
        nextLine = fgetl(f);
        continue;
    end
    
    nonWhiteSpace = find(nextLine ~= ' ');
    nextLine = nextLine(min(1, nonWhiteSpace) : end);
    
    commentIndices1 = find(nextLine == '#');
    commentIndices2 = find(nextLine == '%');
    
    if isempty(commentIndices1)
        if ~isempty(commentIndices2)
            nextLine = nextLine(1 : min(commentIndices2) - 1);
        end
    elseif isempty(commentIndices2)
        nextLine = nextLine(1 : min(commentIndices1) - 1);
    else
        nextLine = nextLine(1 : min([commentIndices1 commentIndices2]) - 1);
    end
    
    if ~isempty(nextLine)
        commaIndices = find(nextLine == ',');
        if length(commaIndices) ~= 4
            fprintf(2, 'Malformed table entry: ''%s'' in file ''%s''', nextLine, odorTableFile);
            errordlg(sprintf('Malformed table entry: ''%s''\n  In file: ''%s''', nextLine, odorTableFile));
            setLocal(progmanager, hObject, 'odorTable', {});
            updateOdorIndex(hObject, 0);
            return;
        end
        
        odorTable{tableRow, 1} = nextLine(1 : commaIndices(1) - 1);
        for i = 2 : 4
            containsDashes = find(nextLine(commaIndices(i - 1) + 1 : commaIndices(i) - 1) == '-');
            if length(containsDashes ~= 0)
                odorTable{tableRow, i} = '-';
            else
                odorTable{tableRow, i} = str2double(nextLine(commaIndices(i - 1) + 1 : commaIndices(i) - 1));
                if isempty(odorTable{tableRow, i})
                    fprintf(2, 'Error: Could not parse valve number at row %s and column %s. - ''%s''', num2str(tableRow), num2str(i), nextLine);
                elseif odorTable{tableRow, i} > 16
                    fprintf(2, 'Error: Bad value at row %s and column %s. Valves may not be numbered higher than 16. - ''%s''', num2str(tableRow), num2str(i), nextLine);
                elseif odorTable{tableRow, i} < 0
                    fprintf(2, 'Error: Bad value at row %s and column %s. Valves may not be numbered higher than 16. - ''%s''', num2str(tableRow), num2str(i), nextLine);
                end
            end
        end
        
        containsDashes = find( nextLine(commaIndices(4)+1 : length(nextLine)) == '-');
        if length(containsDashes ~= 0)
            odorTable{tableRow, 5} = '-';
        else
            odorTable{tableRow, 5} = str2double(nextLine(commaIndices(end) + 1 : end));
            if isempty(odorTable{tableRow, 5})
                fprintf(2, 'Error: Could not parse valve number at row %s and column 5. - ''%s''', num2str(tableRow), nextLine);
            elseif odorTable{tableRow, 5} > 16
                fprintf(2, 'Error: Bad value at row %s and column 5. Valves may not be numbered higher than 16. - ''%s''', num2str(tableRow), nextLine);
            elseif odorTable{tableRow, 5} < 0
                fprintf(2, 'Error: Bad value at row %s and column 5. Valves may not be numbered higher than 16. - ''%s''', num2str(tableRow), nextLine);
            end
        end
        
        tableRow = tableRow + 1;
    end
    
    nextLine = fgetl(f);
end

setLocalBatch(progmanager, hObject, 'odorTable', odorTable, 'currentState', []);
setDefaultCacheValue(progmanager, 'olfactoTrigTableDir', fileparts(odorTableFile));
resetOdor(hObject);

return;

% ------------------------------------------------------------------
function sendConfirmationPulse(hObject)

[syncTask, syncOutPulse] = getLocalBatch(progmanager, hObject, 'syncTask', 'syncOutPulse');

if ~isempty(syncTask)
    putdata(syncTask, syncOutPulse);
    start(syncTask);
end

return;

% ------------------------------------------------------------------
function incrementOdorByTimer(timerObj, event, hObject)


% if ~isempty(syncTask)
%     putsample(syncTask, 5);
% end
incrementOdor(hObject);
% if ~isempty(syncTask)
%     putsample(syncTask, 0);
% end

sendConfirmationPulse(hObject);

return;

% ------------------------------------------------------------------
% function incrementOdorByTrigger(hObject, varargin)
function incrementOdorByTrigger(ai, eventdata, hObject)
global state;

[triggerTask] = getLocalBatch(progmanager, hObject, 'triggerTask');
% fprintf(1, 'OlfactoTrig/incrementOdorByTrigger\n');

% if ~isempty(syncTask)
%     putsample(syncTask, 5);
% end
stop(triggerTask);
incrementOdor(hObject);

%% here we read in the next odor state, and build commands to send to the
% olfactometer.  olfactometer state is an 8 bit number, encoded as a
%% decimal.  this value is also sent out and recaptured by the DAQ.
% 
% valves=fliplr(dec2bin(state.olfactometer.odorStateList(state.olfactometer.odorPosition), 8));
% nextValve=fliplr(dec2bin(state.olfactometer.odorStateList(state.olfactometer.odorPosition+1), 8));
% 
% if (state.olfactometer.odorStateList(state.olfactometer.odorPosition+1) == 0)
%     disp('reset to null')
%     sendCommand(hObject, ['write Bank3_Valves ' num2str(0)]);
% else
%     for i=1:length(nextValve)
%         if (str2num(nextValve(i)))
%             disp(['writing bank3_valve' num2str(i)]);
%             sendCommand(hObject, ['write Bank3_Valves ' num2str(i)]);
%         end
%     end
% end
% state.olfactometer.odorPosition=state.olfactometer.odorPosition+1;
% 
% if (state.olfactometer.odorPosition == length(state.olfactometer.odorStateList))
%     state.olfactometer.odorPosition=1;
% end
start(triggerTask);
% if ~isempty(syncTask)
%     putsample(syncTask, 0);
% end

sendConfirmationPulse(hObject);

return;

% ------------------------------------------------------------------
function initTasks(hObject)

[triggerTask, triggerBoardID, triggerLine, syncTask, syncOutBoardID, syncOutChannelID, syncOutPulseDuration] = getLocalBatch(progmanager, hObject, ...
    'triggerTask', 'triggerBoardID', 'triggerLine', 'syncTask', 'syncOutBoardID', 'syncOutChannelID', 'syncOutPulseDuration');

if ~isempty(triggerTask)
    try
        stop(triggerTask);
    catch
    end
    delete(triggerTask);
end

if ~isempty(syncTask)
    try
        stop(syncTask);
    catch
    end
    delete(syncTask);
end

%tcp_udp_ip doesn't play well with others, use the daqtoolbox instead of nimex.
% triggerTask = analoginput('nidaq', ['dev' num2str(triggerBoardID)]);
% addchannel(triggerTask, 0);
% set(triggerTask, 'sampleRate', 10000, 'SamplesAcquiredFcn', {@incrementOdorByTrigger, hObject}, 'SamplesAcquiredFcnCount', 2, 'SamplesPerTrigger', 5000, ...
%     'TriggerType', 'HwDigital', 'HwDigitalTriggerSource', triggerLine, 'triggerRepeat', Inf, 'BufferingConfig', [10000, 2]);
% start(triggerTask);
%
% syncTask = analogoutput('nidaq', 'phys');%['dev' num2str(syncOutBoardID)]);
% addchannel(syncTask, syncOutChannelID);
% % %timeInMs / 1000 ms/s * samplesPerSecond
% syncOutPulse = 5 * ones(syncOutPulseDuration / 1000 * 10000 + 1, 1);
% syncOutPulse(end) = 0;
% set(syncTask, 'sampleRate', 10000, 'TriggerType', 'Immediate');
% putdata(syncTask, zeros(size(syncOutPulse)));
% start(syncTask);

% setLocalBatch(progmanager, hObject, 'triggerTask', triggerTask, 'syncTask', syncTask, 'syncOutPulse', syncOutPulse);
setLocalBatch(progmanager, hObject, 'triggerTask', triggerTask);
return;

% ------------------------------------------------------------------
function updateTimer(hObject)

[timerEnable, timerInterval, timerObj] = getLocalBatch(progmanager, hObject, 'timerEnable', 'timerInterval', 'timerObj');

if ~isempty(timerObj)
    stop(timerObj);
end

if ~timerEnable
    setLocalGh(progmanager, hObject, 'timerEnable', 'String', 'Enable', 'ForegroundColor', [0.2, 0.8, 0.2]);
    return;
end
setLocalGh(progmanager, hObject, 'timerEnable', 'String', 'Disable', 'ForegroundColor', [0.1, 0, 0]);

if isempty(timerObj)
    timerObj = timer;
    setLocal(progmanager, hObject, 'timerObj', timerObj);
end

set(timerObj, 'TimerFcn', {@incrementOdorByTimer, hObject}, 'Period', timerInterval, 'ExecutionMode', 'fixedRate');
start(timerObj);

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
    'hObject', hObject, ...
    'mfc1', 0.0, 'Class', 'Numeric', 'Gui', 'mfc1', 'Min', 0, 'Max', 100, 'Config', 7, ...
    'mfc2', 0.0, 'Class', 'Numeric', 'Gui', 'mfc2', 'Min', 0, 'Max', 100, 'Config', 7, ...
    'mfc3', 0.0, 'Class', 'Numeric', 'Gui', 'mfc3', 'Min', 0, 'Max', 100, 'Config', 7, ...
    'mfc4', 0.0, 'Class', 'Numeric', 'Gui', 'mfc4', 'Min', 0, 'Max', 100, 'Config', 7, ...
    'mfc5', 0.0, 'Class', 'Numeric', 'Gui', 'mfc5', 'Min', 0, 'Max', 1000, 'Config', 7, ...
    'mfc6', 0.0, 'Class', 'Numeric', 'Gui', 'mfc6', 'Min', 0, 'Max', 1000, 'Config', 7, ...
    'mfc7', 0.0, 'Class', 'Numeric', 'Gui', 'mfc7', 'Min', 0, 'Max', 1000, 'Config', 7, ...
    'mfc8', 0.0, 'Class', 'Numeric', 'Gui', 'mfc8', 'Min', 0, 'Max', 1000, 'Config', 7, ...
    'timerInterval', 1, 'Class', 'Numeric', 'Gui', 'timerInterval', 'Min', 0.001, 'Config', 7, ...
    'timerEnable', 0, 'Class', 'Numeric', 'Gui', 'timerEnable', 'Min', 0, 'Max', 1, 'Config', 7, ...
    'timerObj', [], ...
    'olfactometerHost', '', 'Class', 'char', 'Gui', 'olfactometerHost', 'Config', 7, ...
    'olfactometerPort', 3336, 'Class', 'Numeric', 'Gui', 'olfactometerPort', 'Config', 7, ...
    'olfactometerName', '', 'Class', 'char', 'Gui', 'olfactometerName', ...
    'odorTableFile', '', 'Class', 'char', 'Gui', 'odorTableFile', 'Config', 7, ...
    'triggerBoardID', 5, 'Class', 'Numeric', 'Gui', 'triggerBoardID', 'Config', 7, ...
    'triggerLine', 'PFI0', 'Class', 'char', 'Gui', 'triggerLine', 'Config', 7, ...
    'syncOutBoardID', 1, 'Class', 'Numeric', 'Gui', 'syncOutBoardID', 'Config', 7, ...
    'syncOutChannelID', 0, 'Class', 'Numeric', 'Gui', 'syncOutChannelID', 'Config', 7, ...
    'lastCommand', '', 'Class', 'char', 'Gui', 'lastCommand', ...
    'lastResponse', '', 'Class', 'char', 'Gui', 'lastResponse', ...
    'previousOdor2', '', 'Class', 'char', 'Gui', 'previousOdor2', ...
    'previousOdor1', '', 'Class', 'char', 'Gui', 'previousOdor1', ...
    'currentOdor', '', 'Class', 'char', 'Gui', 'currentOdor', ...
    'nextOdor1', '', 'Class', 'char', 'Gui', 'nextOdor1', ...
    'nextOdor2', '', 'Class', 'char', 'Gui', 'nextOdor2', ...
    'odorTable', {}, ...
    'currentOdorIndex', 0, ...
    'triggerTask', [], ...
    'syncTask', [], ...
    'syncOutPulseDuration', 10, 'Class', 'Numeric', 'Min', 0.5, 'Gui', 'syncOutPulseDuration', 'Config', 7, ...
    'syncOutPulse', [], ...
    'olfactometerConn', [], ...
    'currentState', [], ...
    };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles, varargin)

genericPostLoadSettings(hObject, eventdata, handles);

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
function genericOpen(hObject, eventdata, handles)

errordlg('Open is not supported by this gui.');

return;

% ------------------------------------------------------------------
function genericSave(hObject, eventdata, handles)

errordlg('Save is not supported by this gui.');

return;

% ------------------------------------------------------------------
function genericSaveAs(hObject, eventdata, handles)

errordlg('Save as is not supported by this gui.');

return;

% ------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostSaveSettings(hObject, ~, handles)

return;

% ------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles)

odorTableFile_Callback(hObject, eventdata, handles);
connectToOlfactometer(hObject);
updateMFCRates(hObject);
initTasks(hObject);
updateTimer(hObject);

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function odorTableFile_Callback(hObject, eventdata, handles)

odorTableFile = getLocal(progmanager, hObject, 'odorTableFile');
if exist(odorTableFile, 'file') ~= 2
    setLocalGh(progmanager, hObject, 'odorTableFile', 'ForegroundColor', [1, 0, 0]);
    return;
end

setLocalGh(progmanager, hObject, 'odorTableFile', 'ForegroundColor', [0, 0, 0]);
parseOdorTableFile(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function odorTableFile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
% --- Executes on button press in odorTableFileBrowse.
function odorTableFileBrowse_Callback(hObject, eventdata, handles)

p = getDefaultCacheDirectory(progmanager, 'olfactoTrigTableDir');
[f, p] = uigetfile(fullfile(p, '*.csv'));
if length(f) == 1
    if f == 0
        return;
    end
end
if length(p) == 1
    if p == 0
        return;
    end
end

setLocal(progmanager, hObject, 'odorTableFile', fullfile(p, f));
setLocalGh(progmanager, hObject, 'odorTableFile', 'ForegroundColor', [0, 0, 0]);
parseOdorTableFile(hObject);

return;

% ------------------------------------------------------------------
function olfactometerHost_Callback(hObject, eventdata, handles)

connectToOlfactometer(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function olfactometerHost_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function olfactometerPort_Callback(hObject, eventdata, handles)

connectToOlfactometer(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function olfactometerPort_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function timerInterval_Callback(hObject, eventdata, handles)

updateTimer(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function timerInterval_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
% --- Executes on button press in timerEnable.
function timerEnable_Callback(hObject, eventdata, handles)

updateTimer(hObject);

return;

% ------------------------------------------------------------------
function syncOutBoardID_Callback(hObject, eventdata, handles)

initTasks(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function syncOutBoardID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function syncOutChannelID_Callback(hObject, eventdata, handles)

initTasks(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function syncOutChannelID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function triggerBoardID_Callback(hObject, eventdata, handles)

initTasks(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function triggerBoardID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function triggerLine_Callback(hObject, eventdata, handles)

initTasks(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function triggerLine_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function lastCommand_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function lastCommand_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function lastResponse_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function lastResponse_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function previousOdor2_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function previousOdor2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function previousOdor1_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function previousOdor1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function currentOdor_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function currentOdor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function nextOdor1_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function nextOdor1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function nextOdor2_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function nextOdor2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
% --- Executes on button press in advanceOdor.
function advanceOdor_Callback(hObject, eventdata, handles)

incrementOdor(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in regressOdor.
function regressOdor_Callback(hObject, eventdata, handles)

decrementOdor(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in resetOdor.
function resetOdor_Callback(hObject, eventdata, handles)

resetOdor(hObject);

return;

% ------------------------------------------------------------------
function olfactometerName_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function olfactometerName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function mfc1_Callback(hObject, eventdata, handles)

updateMFCRates(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mfc1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function mfc2_Callback(hObject, eventdata, handles)

updateMFCRates(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mfc2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function mfc3_Callback(hObject, eventdata, handles)

updateMFCRates(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mfc3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function mfc4_Callback(hObject, eventdata, handles)

updateMFCRates(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mfc4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function mfc5_Callback(hObject, eventdata, handles)

updateMFCRates(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mfc5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function mfc6_Callback(hObject, eventdata, handles)

updateMFCRates(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mfc6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function mfc7_Callback(hObject, eventdata, handles)

updateMFCRates(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mfc7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function mfc8_Callback(hObject, eventdata, handles)

updateMFCRates(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mfc8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------
function syncOutPulseDuration_Callback(hObject, eventdata, handles)

initTasks(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function syncOutPulseDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

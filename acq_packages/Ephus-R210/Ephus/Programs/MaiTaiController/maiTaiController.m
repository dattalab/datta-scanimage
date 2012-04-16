function varargout = maiTaiController(varargin)
% MAITAICONTROLLER M-file for maiTaiController.fig
%      MAITAICONTROLLER, by itself, creates a new MAITAICONTROLLER or raises the existing
%      singleton*.
%
%      H = MAITAICONTROLLER returns the handle to a new MAITAICONTROLLER or the handle to
%      the existing singleton*.
%
%      MAITAICONTROLLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAITAICONTROLLER.M with the given input arguments.
%
%      MAITAICONTROLLER('Property','Value',...) creates a new MAITAICONTROLLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before maiTaiController_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to maiTaiController_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help maiTaiController

% Last Modified by GUIDE v2.5 04-Jun-2004 12:59:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @maiTaiController_OpeningFcn, ...
                   'gui_OutputFcn',  @maiTaiController_OutputFcn, ...
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

% ------------------------------------------------------------------
% --- Executes just before maiTaiController is made visible.
function maiTaiController_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maiTaiController wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = maiTaiController_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% ------------------------------------------------------------------
function cancelWavelenghtAdjustment(varargin)

hObject = getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController');
setLocal(progmanager, hObject, 'cancelWavelengthAdjustment', logical(1));

updateHardwareStatusDisplay;

delete(gcf);

return;

% ------------------------------------------------------------------
function setWavelength(hObject, eventdata, handles)

w = round(getLocal(progmanager, hObject, 'wavelength'));
setLocal(progmanager, hObject, 'wavelength', w);
lw = getLocal(progmanager, hObject, 'lastWavelength');

% sendCommand(sprintf('WAVELENGTH %s', num2str(i)));
% response = getResponse;
% 'DONE'

if w >= 710 & w <= 960
    if w < lw
        step = -1;
    elseif w > lw
        step = 1;
    else
        %They're they same.
        return;
    end
    
    range = lw - w;
    
    %Don't let the timer interfere.
    timer = getLocal(progmanager, hObject, 'timer');
    if strcmpi(timer.Running, 'On')
        stop(timer);
    end

    %Nothing else should be done, until the wavelength is adjusted.
    setlocalgh(progmanager, hObject, 'wavelengthEditBox', 'Enable', 'Off');
    setlocalgh(progmanager, hObject, 'wavelengthSlider', 'Enable', 'Off');
    setlocalgh(progmanager, hObject, 'powerToggleButton', 'Enable', 'Off');
    setlocalgh(progmanager, hObject, 'shutterToggleButton', 'Enable', 'Off');

    %It hasn't been canceled, yet.
    setLocal(progmanager, hObject, 'cancelWavelengthAdjustment', logical(0));
    
    wb = waitbar(0, 'Adjusting wavelength...', 'CreateCancelBtn', @cancelWavelenghtAdjustment);
    set(wb, 'Name', sprintf('WAVELENGTH %s', num2str(lw)));
    
    steps = abs(w - lw);
    if w < lw
        step = -1;
    elseif w > lw
        step = 1;
    else
        %They're they same.
        return;
    end
    
    try
        for i = lw + step : step : w
           %Allow the change to be aborted.
            if getLocal(progmanager, hObject, 'cancelWavelengthAdjustment', logical(1))
                updateHardwareStatusDisplay;
                break;
            end
            
% fprintf(1, 'WAVELENGTH %s\n', num2str(i))
% response = sprintf('%snm', num2str(i));
            sendCommand(sprintf('WAVELENGTH %s', num2str(i)));
            sendCommand('READ:WAVELENGTH?');
            response = getResponse;

            %Update the waitbar.
            if ishandle(wb)
                set(wb, 'Name', sprintf('WAVELENGTH %s', num2str(i)));
                waitbar(1 - (abs(w - i) / steps), wb);
            end

            if str2num(response(1 : end - 2)) ~= i - step
                fprintf(2, 'Error setting Mai-Tai wavelength to %s (%s).\n', num2str(w), response);
            end
            
            %Allow the change to be aborted.
            if getLocal(progmanager, hObject, 'cancelWavelengthAdjustment', logical(1))
                updateHardwareStatusDisplay;
                break;
            end
            
            %Wait for the laser to do its thing.
            pause(.11);
        end
    catch
        fprintf(2, 'maiTaiController: Error setting wavelength - ''%s''\n', lasterr);
    end

    %Shouldn't really call close, because that will execute the 'cancel' callback.
    if ishandle(wb)
        delete(wb);
    end
    
    if getLocal(progmanager, hObject, 'enableTimer')
        start(timer);
    end
    
    %Commence monkeying.
    setlocalgh(progmanager, hObject, 'wavelengthEditBox', 'Enable', 'On');
    setlocalgh(progmanager, hObject, 'wavelengthSlider', 'Enable', 'On');
    setlocalgh(progmanager, hObject, 'powerToggleButton', 'Enable', 'On');
    setlocalgh(progmanager, hObject, 'shutterToggleButton', 'Enable', 'On');

    setLocal(progmanager, hObject, 'lastWavelength', w);
else
    fprintf(2, 'Wavelength out of range 710-960: %s', num2str(w));
end

updateHardwareStatusDisplay;

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function wavelengthSlider_CreateFcn(hObject, eventdata, handles)

usewhitebg = 1;
if usewhitebg
    set(hObject, 'BackgroundColor', [.9 .9 .9]);
else
    set(hObject, 'BackgroundColor', get(0, 'defaultUicontrolBackgroundColor'));
end

% --- Executes on slider movement.
function wavelengthSlider_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'wavelength', round(getLocal(progmanager, hObject, 'wavelength')));
setWavelength(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function wavelengthEditBox_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function wavelengthEditBox_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'wavelength', round(getLocal(progmanager, hObject, 'wavelength')));
setWavelength(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'serialObj', [], ...
       'serialPortNumber', 1, 'Class', 'Numeric', 'Gui', 'serialPortNumber', ...
       'serialTimeout', 10, 'Class', 'Numeric', ...
       'wavelength', 810, 'Gui', 'wavelengthEditBox', 'Gui', 'wavelengthSlider', 'Class', 'double', 'Min', 710, 'Max', 960, ...
       'lastWavelength', 810, 'Min', 710, 'Max', 960, ...
       'lastCommand', '', 'Class', 'char', 'Gui', 'lastCommandText', ...
       'lastCommandTime', 0, 'Class', 'Numeric', ...
       'lastResponse', '', 'Class', 'char', 'Gui', 'lastResponseText', ...
       'shutterButton', 0, 'Class', 'double', 'Gui', 'shutterToggleButton',...
       'powerButton', 0, 'Class', 'double', 'Gui', 'powerToggleButton',...
       'pOutput', '', 'Class', 'char', 'Gui', 'pOutput', ...
       'mlEnable', '', 'Class', 'char', 'Gui', 'mlEnable', ...
       'on', 0, 'Class', 'double', 'Min', 0, 'Max', 1, ...
       'errCode', '', 'Class', 'char', 'Gui', 'errorCode', ...
       'power', '', 'Class', 'char', 'Gui', 'power', ...
       'shgs', '', 'Class', 'char', 'Gui', 'shgs', ...
       'diode1Current', '', 'Class', 'char', 'Gui', 'diode1Current', ...
       'diode2Current', '', 'Class', 'char', 'Gui', 'diode2Current', ...
       'diode1Temperature', '', 'Class', 'char', 'Gui', 'diode1Temperature', ...
       'diode2Temperature', '', 'Class', 'char', 'Gui', 'diode2Temperature', ...
       'systemErr', '', 'Class', 'char', 'Gui', 'systemErr', ...
       'idn', '', 'Class', 'char', 'Gui', 'idn', ...
       'idnReadOnly', '', ...
       'stb', '', 'Class', 'char', 'Gui', 'stb', ...
       'warmedUp', '', 'Class', 'char', 'Gui', 'warmedUp', ...
       'timerPeriod', 20, 'Class', 'Numeric' 'Gui', 'timerPeriod', ...
       'readDelay', 1, ...
       'commandDelayList', '*IDN?', ...
       'enableTimer', 0, 'Class', 'Logical', 'Gui', 'enableTimer', ...
       'wavelengthAdjustmentDelay', .01, 'Class', 'Numeric', 'Min', 0, 'Max', 1, ...
       'cancelStatusDisplayUpdate', logical(0), 'Class', 'Numeric', 'Min', 0, 'Max', 1, ...
   };

return;

% ------------------------------------------------------------------
function initializeSerialPort(hObject, eventdata, handles)

s = getlocal(progmanager, hObject, 'serialObj');
if strcmpi(class(s), 'serial')
    delete(s);
end

%<lf> = line feed.
lf = double(sprintf('\n'));

%Create the serial device object.
try
    serialPort = sprintf('COM%s', num2str(getLocal(progmanager, hObject, 'serialPortNumber')));
    s = serial(serialPort, 'BaudRate', 9600, 'Parity', 'none', 'StopBits', 1, 'DataBits', 8, 'Terminator', {lf, lf});
    fopen(s);
    setlocal(progmanager, hObject, 'serialObj', s);
catch
    error('Failed to configure COM port %s for MaiTaiController: %s', ...
        num2str(getLocal(progmanager, hObject, 'serialPortNumber')), lasterr);
end

%Set the timeout.
set(s, 'Timeout', getLocal(progmanager, hObject, 'serialTimeout'));

%Set a flag on timeouts.
set(s, 'ErrorFcn', 'setLocal(progmanager, getHandleFromName(progmanager, ''maiTaiController'', ''MaiTaiController''), ''timeOutOccured'', now);');

%Disable timeout warnings.
warning('off', 'MATLAB:serial:fscanf:unsuccessfulRead');

%Disable the watchdog.
%This is the important one, so we can save CPU cycles without the laser turning off.
sendCommand('TIMER:WATCHDOG 0');

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

setlocalgh(progmanager, hObject, 'serialPortNumber', 'String', {'COM1', 'COM2'});
initializeSerialPort(hObject, eventdata, handles);

%Create a timer object. Continually poll the hardware.
%Matlab is kind of retarded, and has all sorts of problems if 'TimerFcn' is not a function handle.
%The associated function must take varargin as an argument, too.
%The problems included the unwanted switching of window focii and unpredictible keypress function mappings.
t = timer('TimerFcn', @updateHardwareStatusDisplay, 'Period', getLocal(progmanager, hObject, 'timerPeriod'), ...
    'TasksToExecute', 3600, 'ExecutionMode', 'fixedSpacing');
setLocal(progmanager, hObject, 'timer', t);

if getLocal(progmanager, hObject, 'enableTimer')
    start(t);
end

%Sync up with the hardware immediately.
updateHardwareStatusDisplay;

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)
% updateImage(hObject);

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

return;

% ------------------------------------------------------------------
function sendCommand(command)

clearBuffer;

hObject = getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController');
serialObj = getLocal(progmanager, hObject, 'serialObj');

setLocal(progmanager, getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController'), 'lastCommand', now);
setLocal(progmanager, getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController'), 'lastCommand', command);

fprintf(serialObj, command);
%No timeout has occurred, yet.
setLocal(progmanager, getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController'), 'timeOutOccured', logical(0));
% command
return;

% ------------------------------------------------------------------
function response = getResponse

hObject = getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController');
serialObj = getLocal(progmanager, hObject, 'serialObj');

response = '';

%Some responses really seem to take a long time to come back, such as "*IDN?", so let it wait briefly.
readDelay = getLocal(progmanager, hObject, 'readDelay');
if readDelay > 0 & any(strcmpi(getLocal(progmanager, hObject, 'lastCommand'), getLocal(progmanager, hObject, 'commandDelayList')))
    pause(readDelay);
end

hObject = getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController');
serialObj = getLocal(progmanager, hObject, 'serialObj');

if ~getLocal(progmanager, getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController'), 'timeOutOccured')
    response = fscanf(serialObj, '%c');
end

%Trim the response, discard previous responses that my have arrived in the
%buffer late.
if ~isempty(response)
    terminators = get(serialObj, 'Terminator');
    lineEnds = find(response == terminators{1});
    
    if length(lineEnds) > 1
        response = response(lineEnds(end - 1) + 1 : lineEnds(end) - 1);
    end
    
    response = deblank(response);
end

timeOut = getLocal(progmanager, getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController'), 'timeOutOccured');
if timeOut | isempty(response)

%     if ~timeOut & get(serialObj, 'BytesAvailable') > 0
    %Give it another try...
    if get(serialObj, 'BytesAvailable') > 0
        response = fscanf(serialObj, '%c');
    
        %Trim the response, discard previous responses that my have arrived in the
        %buffer late.
        if ~isempty(response)
            terminators = get(serialObj, 'Terminator');
            lineEnds = find(response == terminators{1});
        
            if length(lineEnds) > 1
                response = response(lineEnds(end - 1) + 1 : lineEnds(end) - 1);
            end

            response = deblank(response);
        end
    else
        %Issue a warning.
        if ~timeOut
            timeOut = now;
        end
        warning('%s maiTaiController/getResponse - Timeout occurred for command ''%s''.', datestr(datevec(timeOut)), ...
            getLocal(progmanager, hObject, 'lastCommand'));

        %Return an empty string.
        response = '';

        %Clear the buffer.
        clearBuffer;
    end
end

%Update the display.
setLocal(progmanager, getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController'), 'lastResponse', response);

%No timeout has occurred, yet.
setLocal(progmanager, getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController'), 'timeOutOccured', logical(0));
% response
return;

% ------------------------------------------------------------------
function str = errCode2Str(errCode)

str = '';

if bitand(errCode, 1)
    if ~isempty(str)
        str = '/CMD_ERR';
    else
        str = 'CMD_ERR';
    end
end
if bitand(errCode, 2)
    if ~isempty(str)
        str = '/EXE_ERR';
    else
        str = 'EXE_ERR';
    end
end
if bitand(errCode, 4) | ...
        bitand(errCode, 8) | ...
        bitand(errCode, 16)
    if ~isempty(str)
        str = '/???';
    else
        str = '???';
    end
end
if bitand(errCode, 32)
    if ~isempty(str)
        str = '/SYS_ERR';
    else
        str = 'SYS_ERR';
    end
end
if bitand(errCode, 64)
    if ~isempty(str)
        str = '/LASER_ON';
    else
        str = 'LASER_ON';
    end
end
if bitand(errCode, 128)
    if ~isempty(str)
        str = '/ANY_ERR';
    else
        str = 'ANY_ERR';
    end
end

return;

% ------------------------------------------------------------------
function updateHardwareStatusDisplay(varargin)

try
    hObject = getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController');
    serialObj = getLocal(progmanager, hObject, 'serialObj');
    
    setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
    setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Cancel');

    sendCommand('CONTROL:MLENABLE?');
    response = getResponse;
    if strcmpi(response, '1')
        response = 'On';
    elseif strcmpi(response, '0')
        response = 'Off';
    else
        response = '???';
    end
    setLocal(progmanager, hObject, 'mlEnable', response);
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('PLASER:ERRCODE?');
    try
        response = errCode2Str(hex2dec(getResponse));
    catch
        response = '???';
    end
    if isempty(response)
        setLocal(progmanager, hObject, 'errCode', response);
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('MODE?');
    response = getResponse;
    if strcmpi(response, 'PPOW')
        sendCommand('READ:PLASER:POWER?');
        response = getResponse;
        setLocal(progmanager, hObject, 'pOutput', strcat(response, 'W'));
        setlocalgh(progmanager, hObject, 'pOutput', 'TooltipString', 'Pump laser current in watts.');
        setlocalgh(progmanager, hObject, 'pOutputLabel', 'String', 'Pump Power');
    elseif strcmpi(response, 'PCUR')
        sendCommand('READ:PLASER:CURRENT?');
        response = getResponse;
        setLocal(progmanager, hObject, 'pOutput', strcat(response, 'A'));
        setlocalgh(progmanager, hObject, 'pOutput', 'TooltipString', 'Pump laser current in amps.');
        setlocalgh(progmanager, hObject, 'pOutputLabel', 'String', 'Pump Current');
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('READ:PLASER:SHGS?');
    response = getResponse;
    if isempty(response)
        response = 'TIMEOUT';
    elseif strcmpi(response, '0S')
        response = 'stable';
    elseif strcmpi(response, '1S')
        response = 'heating';
    elseif strcmpi(response, '2S')
        response = 'cooling';
    else
        response = 'error';
    end
    setLocal(progmanager, hObject, 'shgs', response);
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('READ:PLASER:DIODE1:CURRENT');
    response = getResponse;
    if ~isempty(response)
        setLocal(progmanager, hObject, 'diode1Current', strcat(response(1 : end - 2), 'A'));
    else
        setLocal(progmanager, hObject, 'diode1Current', 'TIMEOUT');
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('READ:PLASER:DIODE2:CURRENT');
    response = getResponse;
    if ~isempty(response)
        setLocal(progmanager, hObject, 'diode2Current', strcat(response(1 : end - 2), 'A'));
    else
        setLocal(progmanager, hObject, 'diode2Current', 'TIMEOUT');
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('READ:PLASER:DIODE1:TEMPERATURE');
    response = getResponse;
    if ~isempty(response)
        setLocal(progmanager, hObject, 'diode1Temperature', strcat(response(1 : end - 2), char(176), 'C'));
    else
        setLocal(progmanager, hObject, 'diode1Temperature', 'TIMEOUT');
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('READ:PLASER:DIODE2:TEMPERATURE');
    response = getResponse;
    if ~isempty(response)
        setLocal(progmanager, hObject, 'diode2Temperature', strcat(response(1 : end - 2), char(176), 'C'));
    else
        setLocal(progmanager, hObject, 'diode2Temperature', 'TIMEOUT');
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('SYSTEM:ERR?');
    response = getResponse;
    if ~isempty(response)
        setLocal(progmanager, hObject, 'systemErr', response);
    else
        setLocal(progmanager, hObject, 'systemErr', 'TIMEOUT');
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    %Looks like this one takes a long time to get an answer, maybe it's best to
    %give up on it...
    sendCommand('*IDN?');
    response = getResponse;
    if ~isempty(response)
        setLocal(progmanager, hObject, 'idn', response);
    else
        setLocal(progmanager, hObject, 'idn', 'TIMEOUT');
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('*STB?');
    response = getResponse;
    if ~isempty(response)
        setLocal(progmanager, hObject, 'stb', response);
    else
        setLocal(progmanager, hObject, 'stb', '???');
    end
    num = str2num(response);
    if ~isempty(num)
        %Bit 1 is set if the laser is emitting (the shutter may still be closed though.
        %This bit follows the indicator light on top of the laser head.
        if bitand(1, num)
            setlocalgh(progmanager, hObject, 'emissionFrame', 'BackgroundColor', [1 0 0]);
        else
            setlocalgh(progmanager, hObject, 'emissionFrame', 'BackgroundColor', [0.8313725490196078 0.8156862745098039 0.7843137254901961]);
        end
        
        %Bit 2 is set if the laser is modelocked.
        if bitand(2, num)
            setlocalgh(progmanager, hObject, 'modeLockFrame', 'BackgroundColor', [1 0 0]);
        else
            setlocalgh(progmanager, hObject, 'modeLockFrame', 'BackgroundColor', [0.8313725490196078 0.8156862745098039 0.7843137254901961]);
        end
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('READ:WAVELENGTH?');
    response = getResponse;
    if ~isempty(response)
        setLocal(progmanager, hObject, 'wavelength', str2num(response(1 : end - 2)));
        setLocal(progmanager, hObject, 'lastWavelength', str2num(response(1 : end - 2)));        
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('SHUTTER?');
    response = getResponse;
    if strcmpi(response, '0')
        %Closed
        setlocalgh(progmanager, hObject, 'shutterFrame', 'BackgroundColor', [0.8313725490196078 0.8156862745098039 0.7843137254901961]);
        setlocalgh(progmanager, hObject, 'shutterLabel', 'BackgroundColor', [0.8313725490196078 0.8156862745098039 0.7843137254901961]);
        setlocalgh(progmanager, hObject, 'shutterToggleButton', 'String', 'Open');
        setLocal(progmanager, hObject, 'shutterButton', 0);
    elseif strcmpi(response, '1')
        %Open
        setlocalgh(progmanager, hObject, 'shutterFrame', 'BackgroundColor', [1 0 0]);
        setlocalgh(progmanager, hObject, 'shutterLabel', 'BackgroundColor', [1 0 0]);
        setlocalgh(progmanager, hObject, 'shutterToggleButton', 'String', 'Close');
        setLocal(progmanager, hObject, 'shutterButton', 1);
    else
        %farked
        warning(sprintf('Unrecognized shutter value: %s.', response));
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('READ:POWER?');
    response = getResponse;
    power = str2num(response(1 : end - 1));
    if isempty(power)
        %farked
        warning(sprintf('Unrecognized power value: %s.', response));
    elseif power < 0.001
        %Off
        setlocalgh(progmanager, hObject, 'powerFrame', 'BackgroundColor', [0.8313725490196078 0.8156862745098039 0.7843137254901961]);
        setlocalgh(progmanager, hObject, 'powerLabel', 'BackgroundColor', [0.8313725490196078 0.8156862745098039 0.7843137254901961]);
        setlocalgh(progmanager, hObject, 'powerToggleButton', 'String', 'On');    
        setLocal(progmanager, hObject, 'powerButton', 0);
    else
        %On
        setlocalgh(progmanager, hObject, 'powerFrame', 'BackgroundColor', [1 0 0]);
        setlocalgh(progmanager, hObject, 'powerLabel', 'BackgroundColor', [1 0 0]);
        setlocalgh(progmanager, hObject, 'powerToggleButton', 'String', 'Off');
        setLocal(progmanager, hObject, 'powerButton', 1);
    end
    if ~isempty(response)
        setLocal(progmanager, hObject, 'power', strcat(response, 'W'));
    else
        setLocal(progmanager, hObject, 'power', 'TIMEOUT');
    end
    
    if getLocal(progmanager, hObject, 'cancelStatusDisplayUpdate')
        setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(0));
        setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
        return;
    end
    
    sendCommand('READ:PCTWARMEDUP?');
    response = getResponse;
    setLocal(progmanager, hObject, 'warmedUp', response);
    if strcmpi(response, '100.00%') | strcmpi(response, '100.00')
        setlocalgh(progmanager, hObject, 'wavelengthEditBox', 'Enable', 'On');
        setlocalgh(progmanager, hObject, 'wavelengthSlider', 'Enable', 'On');
        setlocalgh(progmanager, hObject, 'powerToggleButton', 'Enable', 'On');
        setlocalgh(progmanager, hObject, 'shutterToggleButton', 'Enable', 'On');
    else
        setlocalgh(progmanager, hObject, 'wavelengthEditBox', 'Enable', 'Off');
        setlocalgh(progmanager, hObject, 'wavelengthSlider', 'Enable', 'Off');
        setlocalgh(progmanager, hObject, 'powerToggleButton', 'Enable', 'Off');
        setlocalgh(progmanager, hObject, 'shutterToggleButton', 'Enable', 'Off');
    end
    
    %Update the button, if necessary.
    enableTimer_Callback(getlocalgh(progmanager, hObject, 'enableTimer'));
    
    setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');
catch
    warning('%s Error executing maiTaiController/updateHardwareStatusDisplay: %s', datestr(datevec(now)), lasterr);
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in shutterToggleButton.
function shutterToggleButton_Callback(hObject, eventdata, handles)

sendCommand(sprintf('SHUTTER %s', num2str(getLocal(progmanager, hObject, 'shutterButton'))));

updateHardwareStatusDisplay;


% ------------------------------------------------------------------
% --- Executes on button press in powerToggleButton.
function powerToggleButton_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'powerButton')
    sendCommand('ON');
    %Wait for the power to change, before updating.
    pause(4);
else
    sendCommand('OFF');
end
% sendCommand(sprintf('POWER %s', num2str(getLocal(progmanager, hObject, 'powerButton'))));

updateHardwareStatusDisplay;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function timerPeriod_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ------------------------------------------------------------------
function timerPeriod_Callback(hObject, eventdata, handles)

t = getLocal(progmanager, hObject, 'timer');
stop(t);
period = getLocal(progmanager, hObject, 'timerPeriod');
if period > 0
    set(t, 'Period', getLocal(progmanager, hObject, 'timerPeriod'));
    if period < 10
        fprintf(2, 'Warning: It is recommended that the Timer Period for the MaiTaiController be set to no less than 10 seconds.\n');
    end
end
start(t);

return;

%Commands needed/used.
% CONTROL:PHASE?
% CONTROL:MLENABLE?
% ON / OFF
% MODE?
% PLASER:ERRCODE?
% PLASER:HISTORY? / PLASER:AHISTORY?
% PLASER:POUTPUTLABEL?
% PLASER:POWER?
% READ:PCTWARMEDUP?
% READ:PLASER:POWER?
% READ:PLASER:POUTPUTLABEL?
% READ:PLASER:SHGS?
% READ:PLASER:DIODE1:CURRENT?
% READ:PLSASER:DIODE2:CURRENT?
% READ:PLASER:DIODE1:TEMPERATURE?
% READ:PLASER:DIODE2:TEMPERATURE?
% READ:POWER?
% READ:WAVELENGTH?
% SAVE
% SHUTTER n
% SHUTTER?
% SYSTEM:ERR?
% TIMER:WATHCDOG n
% WAVELENGTH nnn
% WAVELENGTH?
% WAVELENGTH:MIN?
% WAVELENGTH:MAX?
% *IDN?
% *STB?

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function power_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function power_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mlEnable_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function mlEnable_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pOutput_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function pOutput_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function shgs_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function shgs_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function stb_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function stb_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function idn_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function idn_Callback(hObject, eventdata, handles)

%This is only enabled to allow scrolling.
setLocal(progmanager, hObject, 'idn', getLocal(progmanager, hObject, 'idnReadOnly'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function diode1Current_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function diode1Current_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function diode2Current_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function diode2Current_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function edit16_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function diode2Temperature_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function diode2Temperature_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function systemErr_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function systemErr_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function diode1Temperature_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function diode1Temperature_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pumpLaserPower_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function pumpLaserPower_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function lastCommandText_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function lastCommandText_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function lastResponseText_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function lastResponseText_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function warmedUp_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function warmedUp_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function outputPower_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function outputPower_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function errorCode_CreateFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function errorCode_Callback(hObject, eventdata, handles)

% --- Executes on button press in refreshDisplay.
function refreshDisplay_Callback(hObject, eventdata, handles)
h = getLocalGh(progmanager, hObject, 'refreshDisplay');
if strcmpi(get(h, 'String'), 'Refresh')
    updateHardwareStatusDisplay;
else
    setLocal(progmanager, hObject, 'cancelStatusDisplayUpdate', logical(1));
end

setlocalgh(progmanager, hObject, 'refreshDisplay', 'String', 'Refresh');

return;

% -----------------------------------------------------------------
function clearBuffer

hObject = getHandleFromName(progmanager, 'maiTaiController', 'MaiTaiController');
serialObj = getLocal(progmanager, hObject, 'serialObj');

while get(serialObj, 'BytesAvailable') > 0
    fscanf(serialObj, '%c');
end

return;

% -----------------------------------------------------------------
% --- Executes on button press in enableTimer.
function enableTimer_Callback(hObject, eventdata, handles)

timer = getLocal(progmanager, hObject, 'timer');
enable = getLocal(progmanager, hObject, 'enableTimer');

if enable & strcmpi(timer.Running, 'Off')
    start(timer);
    set(hObject, 'String', 'Disable Timer');
elseif ~enable & strcmpi(timer.Running, 'On')
    stop(timer);
    set(hObject, 'String', 'Enable Timer');
elseif enable &  strcmpi(timer.Running, 'On')
    set(hObject, 'String', 'Disable Timer');
elseif ~enable &  strcmpi(timer.Running, 'Off')
    set(hObject, 'String', 'Enable Timer');
end

return;


% --- Executes during object creation, after setting all properties.
function serialPortNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in serialPortNumber.
function serialPortNumber_Callback(hObject, eventdata, handles)

initializeSerialPort(hObject, eventdata, handles);
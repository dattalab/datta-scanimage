function varargout = acquirer(varargin)
% ACQUIRER M-file for acquirer.fig
%      ACQUIRER, by itself, creates a new ACQUIRER or raises the existing
%      singleton*.
%
%      H = ACQUIRER returns the handle to a new ACQUIRER or the handle to
%      the existing singleton*.
%
%      ACQUIRER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ACQUIRER.M with the given input arguments.
%
%      ACQUIRER('Property','Value',...) creates a new ACQUIRER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before acquirer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to acquirer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help acquirer

% Last Modified by GUIDE v2.5 20-Feb-2012 15:36:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @acquirer_OpeningFcn, ...
                   'gui_OutputFcn',  @acquirer_OutputFcn, ...
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


% --- Executes just before acquirer is made visible.
function acquirer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to acquirer (see VARARGIN)

% Choose default command line output for acquirer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes acquirer wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

%------------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = acquirer_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'startButton', 0, 'Class', 'Numeric', 'Gui', 'startButton', 'Config', 2, ...
       'sampleRate', 10000, 'Class', 'Numeric', 'Config', 7, ...
       'outputChannels', {}, ...
       'inputChannels', {}, ...
       'channelList', 1, 'Class', 'Numeric', 'Gui', 'channelList', 'Config', 2, ...
       'channels', [], 'Config', 2, ...
       'selfTrigger', 1, 'Class', 'Numeric', 'Gui', 'selfTrigger', 'Config', 3, ...
       'externalTrigger', 0, 'Class', 'Numeric', 'Gui', 'externalTrigger', 'Config', 3, ...
       'externalTriggerSource', '', 'Class', 'char', 'Gui', 'pmExtTriggerSource',... %VI102308A
       'acqOnArray', [], 'Config', 3, ...
       'acqOn', 0, 'Class', 'Numeric', 'Gui', 'acqOn', ...
       'saveBuffers', [], ...
       'scopeObject', [], ...
       'status', 'NO_CHANNEL(S)', 'Class', 'char', 'Gui', 'status', ...
       'epoch', 1, 'Class', 'Numeric', 'Gui', 'epoch', 'Config', 2, ...
       'traceLength', 1, 'Class', 'Numeric', 'Gui', 'traceLength', 'Config', 7, ...
       'acquiring', 0, 'Class', 'Numeric', ...
       'startID', 0, 'Class', 'Numeric', ...
       'scopeObjectGuiProps', [], 'Config', 1, ...
       'looping', 0, 'Class', 'Numeric', ...
       'boardBasedTimingEvent', [], ...
       'preConfigLoadExternalTrigger', 0, ...
       'traceLengthArray', [], ...
       'segmentedAcquisition', 0, ...
       'acquisitionsRemainingCounter', 0, ...
       'triggerTime', [], 'Config', 2, ...
       'pulseHijacked', 0, ...
       'amplifiers', {}, ...
       'amplifierList', [], ...
       'segmentedAcquisition', 0, ...
       'showStimArray', [], ...
       'saveBuffers', [], ...
       'scopeObject', [], ...
       'resetTaskWhenDone', 0, ...
       'stimOnArray', [], ...
       'stimOn', [], ...
       'pulseName', [], ...
       'pulseSetName', [], ...
       'pulseNameArray', [], ...
       'pulseSetNameArray', [], ...
       'pulseSetDir', [], ...
       'extraGainArray', [], ...
       'showStimArray', [], ...
       'zeroChannelsOnStop', 1, ...
       'clearBuffersWhenNotRunning', 0, ...
       'updateRate', 1, 'Class', 'Numeric', 'Min', 0.001, 'Max', 5, 'Gui', 'updateRate', 'Config', 7, ...
       'autoDisplayWidth', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, 'Gui', 'autoDisplayWidth', 'Config', 7, ...
       'displayWidth', 1, 'Class', 'Numeric', 'Gui', 'displayWidth', 'Config', 7, ...
       'continuousAcqMode', 0, ...
       'sampleCount', 0, ...
       'stopRequested', 0, ...
       'clearBuffersOnGetData', 1,  'Config', 5, ...
       'disableHandles', [], ...
       'autoUpdateRate', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, 'Gui', 'autoUpdateRate', 'Config', 7, ...
       'dataToBeSaved', 0, ...
   };

return;

% ------------------------------------------------------------------
%De facto 'constructor' for 'acquirer' program
%Constructor Arguments:
%   acqChannelArray: struct array containing fields 'channelName','boardID', and 'channelID', 
%                       which contain a string, integer, and integer, respectively, for each array element. 
%Notes
%   Channels can be added following construction: either step-wise via  acq_addChannels(), or all at once via acq_setChannels()
function genericStartFcn(hObject, eventdata, handles,varargin)

if getLocal(progmanager, hObject, 'selfTrigger')
    setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'On');
%     setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Inactive');
end

%TO021610H
if getLocal(progmanager, hObject, 'autoDisplayWidth')
    setLocalGh(progmanager, hObject, 'displayWidth', 'Enable', 'Off');
else
    setLocalGh(progmanager, hObject, 'displayWidth', 'Enable', 'On');
end
%TO042010C - Add an autoUpdateRate checkbox. -- Tim O'Connor 4/20/10
if getLocal(progmanager, hObject, 'autoUpdateRate')
    setLocalGh(progmanager, hObject, 'updateRate', 'Enable', 'Off');
else
    setLocalGh(progmanager, hObject, 'updateRate', 'Enable', 'On');
end

%TO120505B: Begin implementation of user functions (phase it in as a command-line utility then add the GUI interface). -- Tim O'Connor 12/5/05
%TO123005G - Implement various userFcn calls. -- Tim O'Connor 12/30/05
cbm = getUserFcnCBM;
if ~isEvent(cbm, 'acquirer:Start')
    addEvent(cbm, 'acquirer:Start', 'Passes the program handle as an argument.');
end
if ~isEvent(cbm, 'acquirer:Stop')
    addEvent(cbm, 'acquirer:Stop', 'Passes the program handle as an argument.');
end
if ~isEvent(cbm, 'acquirer:SamplesAcquired')
    addEvent(cbm, 'acquirer:SamplesAcquired', 'Passes the acquired samples and the buffer name as arguments.');%TO031306A: Allow access to the samplesAcquired event as a user function, for processing before completion when using board timing.
end
if ~isEvent(cbm, 'acquirer:TraceAcquired')
    addEvent(cbm, 'acquirer:TraceAcquired', 'Passes the acquired samples and the buffer name as arguments.');%TO042010A: Differentiate between "some samples" and a full trace.
end

%TO053008B - Moved common start-up script functionality into the various programs. -- Tim O'Connor 5/30/08
[lg lm] = lg_factory;
registerLoopable(lm, {@shared_loopListener, hObject}, 'acquirer');

%TO123005F
xsg_registerProgram(hObject, {@shared_getData, hObject});%TO101907C

%TO010506C - Rework triggering scheme for ease of use and simpler looping. -- Tim O'Connor 1/5/06
externalTrigger_Callback(hObject, eventdata, handles);

%VI053108A - Process newly added acqChannelArray argument -- Vijay Iyer 5/31/08
if ~isempty(varargin) 
    acq_setChannels(hObject,varargin{1});
end

%VI102308A - Handle multiple external trigger possibilities -- Vijay Iyer 10/23/08
shared_initializeExtTrigger(hObject);

%TO033110E - Disable controls that are not updated while running. -- Tim O'Connor 3/31/10
disableHandles = [getLocalGh(progmanager, hObject, 'displayWidth'), ...
    getLocalGh(progmanager, hObject, 'autoDisplayWidth'), ...
    getLocalGh(progmanager, hObject, 'updateRate'), ...
    getLocalGh(progmanager, hObject, 'autoUpdateRate'), ...
    getLocalGh(progmanager, hObject, 'acqOn'), ...
    getLocalGh(progmanager, hObject, 'traceLength'), ...
    getLocalGh(progmanager, hObject, 'pmExtTriggerSource')];
setLocal(progmanager, hObject, 'disableHandles', disableHandles);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

sc = getLocal(progmanager, hObject, 'scopeObject');
for i = 1 : length(sc)
    delete(sc(i));
end

%TO060910B - Remove the events when we're done. -- Tim O'Connor 6/9/10
cbm = getUserFcnCBM;
if ~isEvent(cbm, 'acquirer:Start')
    removeEvent(cbm, 'acquirer:Start');
end
if ~isEvent(cbm, 'acquirer:Stop')
    removeEvent(cbm, 'acquirer:Stop');
end
if ~isEvent(cbm, 'acquirer:SamplesAcquired')
    removeEvent(cbm, 'acquirer:SamplesAcquired');
end
if ~isEvent(cbm, 'acquirer:TraceAcquired')
    removeEvent(cbm, 'acquirer:TraceAcquired');
end

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.4;

return;

% ------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

props = [];
sc = getLocal(progmanager, hObject, 'scopeObject');
for i = 1 : length(sc)
    f = get(sc(i), 'figure');
    props(i).position = get(f, 'Position');
    props(i).visible = get(f, 'Visible');
end
setLocal(progmanager, hObject, 'scopeObjectGuiProps', props);

return;

% ------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)
% fprintf(1, 'acquirer.m/genericPreLoadSettings\n');
%TO031306E: Make sure it doesn't restart itself. -- Tim O'Connor 3/13/06
setLocalBatch(progmanager, hObject, 'externalTrigger', 0, 'selfTrigger', 1);

%TO083005A
%TO010606B - Make sure this is stopped, so that the externalTrigger state can be set properly afterwards. -- Tim O'Connor 1/6/06
segmentedAcquisition = getLocal(progmanager, hObject, 'segmentedAcquisition');%TO080306A
shared_Stop(hObject);
setLocal(progmanager, hObject, 'segmentedAcquisition', segmentedAcquisition);%TO080306A

return;

% ------------------------------------------------------------------
%TO062306D: Created a lightweight configuration (miniSettings), mainly for use in cycles. Only important run-time variables should get this value. -- Tim O'Connor 6/23/06
function genericPreLoadMiniSettings(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'preConfigLoadExternalTrigger', getLocal(progmanager, hObject, 'externalTrigger'));
genericPreLoadSettings(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
%TO062806F - Make the external trigger update optional. -- Tim O'Connor 6/28/06
function genericPostLoadSettings(hObject, eventdata, handles, varargin)
% fprintf(1, 'acquirer.m/genericPostLoadSettings\n');
shared_configurationUpdate(hObject);%TO121307E

shared_selectChannel(hObject, getLocal(progmanager, hObject, 'channelList'));
if getLocal(progmanager, hObject, 'selfTrigger')
    setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'On');
%     setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Inactive');
end

props = getLocal(progmanager, hObject, 'scopeObjectGuiProps');
sc = getLocal(progmanager, hObject, 'scopeObject');
if length(sc) == length(props)
    for i = 1 : length(props)
        f = get(sc(i), 'figure');
        set(f, 'Position', props(i).position);
        set(sc(i), 'Visible', props(i).visible);
    end
% else
%     fprintf('Warning (acquirer): Configuration does not contain the right amount of metadata for the current number of scope displays, ignoring display position and visibility settings.\n ScopeObjects: %s\n ScopeObject metadata: %s\n', ...
%         num2str(length(sc)), num2str(length(props)));
end

%TO021610H
if getLocal(progmanager, hObject, 'autoDisplayWidth')
    setLocalGh(progmanager, hObject, 'displayWidth', 'Enable', 'Off');
else
    setLocalGh(progmanager, hObject, 'displayWidth', 'Enable', 'On');
end
%TO042010C - Add an autoUpdateRate checkbox. -- Tim O'Connor 4/20/10
if getLocal(progmanager, hObject, 'autoUpdateRate')
    setLocalGh(progmanager, hObject, 'updateRate', 'Enable', 'Off');
else
    setLocalGh(progmanager, hObject, 'updateRate', 'Enable', 'On');
end

%TO062806F
if ~isempty(varargin)
    if ~varargin{1}
        return;
    end
end

%TO010506C - Rework triggering scheme for ease of use and simpler looping. -- Tim O'Connor 1/5/06
externalTrigger_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
%TO062306D: Created a lightweight configuration (miniSettings), mainly for use in cycles. Only important run-time variables should get this value. -- Tim O'Connor 6/23/06
function genericPostLoadMiniSettings(hObject, eventdata, handles, varargin)

externalTrigger = getLocal(progmanager, hObject, 'preConfigLoadExternalTrigger');
setLocalBatch(progmanager, hObject, 'externalTrigger', externalTrigger, 'selfTrigger', ~externalTrigger, 'scopeObjectGuiProps', []);
genericPostLoadSettings(hObject, eventdata, handles, varargin{:});%TO062806F

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

loadPulseSetItem_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

shared_saveTrace(hObject);

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

[f p] = uiputfile(fullfile(pwd, '*.acquirer'));
if length(f) == 0
    if f == 0
        return;
    end
end
shared_saveTrace(hObject, fullfile(p, f));

return;

% ------------------------------------------------------------------
function genericPreCacheSettings(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'segmentedAcquisition', 1);%TO080306A
genericPreLoadSettings(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericPreCacheMiniSettings(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'segmentedAcquisition', 1);%TO080306A
genericPreLoadMiniSettings(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericPostCacheSettings(hObject, eventdata, handles)

updateExternalTrigger = 1;
if isprogram(progmanager, 'cycler')
    %lm = loopManager;
    %if get(lm, 'preciseTimeMode')
        if getGlobal(progmanager, 'enable', 'cycler', 'cycler')
           updateExternalTrigger = 0;
       end
    %end
end 

%TO080306D - The trace length array must be appended before the regular settings update tasks are executed. -- Tim O'Connor 8/3/06
[traceLengths, currentLength] = getLocalBatch(progmanager, hObject, 'traceLengthArray', 'traceLength');
traceLengths(end + 1) = currentLength;
setLocalBatch(progmanager, hObject, 'traceLengthArray', traceLengths);
genericPostLoadSettings(hObject, eventdata, handles, updateExternalTrigger);

return;

% ------------------------------------------------------------------
function genericPostCacheMiniSettings(hObject, eventdata, handles)

updateExternalTrigger = 1;
if isprogram(progmanager, 'cycler')
    %lm = loopManager;
    %if get(lm, 'preciseTimeMode')
        if getGlobal(progmanager, 'enable', 'cycler', 'cycler')
           updateExternalTrigger = 0;
       end
    %end
end 

%TO080306D - The trace length array must be appended before the regular settings update tasks are executed. -- Tim O'Connor 8/3/06
[traceLengths, currentLength] = getLocalBatch(progmanager, hObject, 'traceLengthArray', 'traceLength');
traceLengths(end + 1) = currentLength;
setLocalBatch(progmanager, hObject, 'traceLengthArray', traceLengths);
genericPostLoadMiniSettings(hObject, eventdata, handles, updateExternalTrigger);

return;

% ------------------------------------------------------------------
%TO062806M
function genericCacheOperationBegin(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
%TO062806F - Only update the triggering once all configurations have been processed.
function genericCacheOperationComplete(hObject, eventdata, handles)
% fprintf(1, 'acq/genericCacheOperationComplete\n');
externalTrigger_Callback(hObject, eventdata, handles);

setLocalBatch(progmanager, hObject, 'traceLengthArray', []);

return

%------------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function epoch_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%------------------------------------------------------------------------------
function epoch_Callback(hObject, eventdata, handles)
return;

%------------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function epochSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundCo.lor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%------------------------------------------------------------------------------
% --- Executes on slider movement.
function epochSlider_Callback(hObject, eventdata, handles)

%TO081606E - Slider functionality changed as of Matlab 7, invalidating most slider code. -- Tim O'Connor 8/16/06
% slider = getLocal(progmanager, hObject, 'epochSlider');
% last = getLocal(progmanager, hObject, 'epochSliderLast');
% if slider > last
%     %Increment
%     setLocal(progmanager, hObject, 'epoch', getLocal(progmanager, hObject, 'epoch') + 1);
% elseif slider < last
%     %Decrement
%     setLocal(progmanager, hObject, 'epoch', getLocal(progmanager, hObject, 'epoch') - 1);
% else
%     %Slider value is minned/maxed out.
%     if slider == getLocalGh(progmanager, hObject, 'epochSlider', 'Min')
%         %Decrement
%         setLocal(progmanager, hObject, 'epoch', getLocal(progmanager, hObject, 'epoch') - 1);
%     elseif slider == getLocalGh(progmanager, hObject, 'epochSlider', 'Max')
%         %Increment
%         setLocal(progmanager, hObject, 'epoch', getLocal(progmanager, hObject, 'epoch') + 1);
%     else
%         warning('EpochSlider value out of range: %s', num2str(slider));
%     end
% end
% setLocal(progmanager, hObject, 'epochSliderLast', slider);

return;

%------------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function channelList_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%------------------------------------------------------------------------------
% --- Executes on selection change in channelList.
function channelList_Callback(hObject, eventdata, handles)

%TO060810F - Multiple channel selection shouldn't be possible, but if it is, don't let it cause mischief. -- Tim O'Connor 6/8/10
channelList = getLocal(progmanager, hObject, 'channelList');
if length(channelList) > 1
    channelList = channelList(1);
    setLocal(progmanager, hObject, 'channelList', channelList);
elseif isempty(channelList)
    channelList = 1;
    setLocal(progmanager, hObject, 'channelList', channelList);
end
shared_selectChannel(hObject, channelList);

return;

%------------------------------------------------------------------------------
% --- Executes on button press in acqOn.
function acqOn_Callback(hObject, eventdata, handles)

acqOnArray = getLocal(progmanager, hObject, 'acqOnArray');
index = getLocal(progmanager, hObject, 'channelList');
acqOnArray(index) = getLocal(progmanager, hObject, 'acqOn');
setLocal(progmanager, hObject, 'acqOnArray', acqOnArray);

return;

%---------------------------------------------------------------------------
function selfTrigger_Callback(hObject, eventdata, handles)

setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Inactive');
setLocal(progmanager, hObject, 'externalTrigger', 0);
setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');

return;

%---------------------------------------------------------------------------
function externalTrigger_Callback(hObject, eventdata, handles)
% fprintf(1, 'acquirer.m/externalTrigger_Callback\n');

%TO032406E: Watch out for errors here, make sure the button stays available, in case of an error. -- Tim O'Connor 3/24/06
try
    %TO010506C - Rework triggering scheme for ease of use and simpler looping. -- Tim O'Connor 1/5/06
    if getLocal(progmanager, hObject, 'externalTrigger')
        setLocalGh(progmanager, hObject, 'externalTrigger', 'ForegroundColor', [1 0 0]);
        setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
        setLocal(progmanager, hObject, 'selfTrigger', 0);
        if ~getLocal(progmanager, hObject, 'startButton')
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Off');
            shared_Start(hObject);
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
        end
    else
        setLocalGh(progmanager, hObject, 'externalTrigger', 'ForegroundColor', [0 0.6 0]);
        setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
        setLocal(progmanager, hObject, 'selfTrigger', 1);
        if getLocal(progmanager, hObject, 'startButton')
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Off');
            segmentedAcquisition = getLocal(progmanager, hObject, 'segmentedAcquisition');%TO080306A
            shared_Stop(hObject);
            setLocal(progmanager, hObject, 'segmentedAcquisition', segmentedAcquisition);%TO080306A
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
        end
    end
catch
    warning('An error occured while updating the externalTrigger setting for the acquirer: %s', getLastErrorStack);
    setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
end

% setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Inactive');
% setLocal(progmanager, hObject, 'selfTrigger', 0);
% setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'On');

return;

% --------------------------------------------------------------------
function startButton_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'startButton')
    %TO090506A - Clear erroneous states, if the exist. -- Tim O'Connor 9/5/06
    setLocalBatch(progmanager, hObject, 'traceLengthArray', [], 'segmentedAcquisition', 0, 'acquisitionsRemainingCounter', 0);
    shared_Start(hObject);
else
    setLocal(progmanager, hObject, 'stopRequested', 1);%TO021610J
    shared_Stop(hObject);
end

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function traceLength_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function traceLength_Callback(hObject, eventdata, handles)

%TO120905F - Clear the trace here, so that the scrolling doesn't leave some old stuff on the scope. -- Tim O'Connor 12/9/05
clearData(getLocal(progmanager, hObject, 'scopeObject'));

%TO021610B - Update the scopeObjects' xLims appropriately.
[traceLength, traceLengthArray, acqOnArray, sc] = getLocalBatch(progmanager, hObject, 'traceLength', 'traceLengthArray', 'acqOnArray', 'scopeObject');
acqOnArray = logical(acqOnArray);
if isempty(traceLengthArray)
    set(sc(acqOnArray), 'xUnitsPerDiv', traceLength / 10);
else
    set(sc(acqOnArray), 'xUnitsPerDiv', min(traceLengthArray(acqOnArray)) / 10);
end

return;

% -------------------------------------------------------------------
function pmExtTriggerSource_Callback(hObject, eventdata, handles)
shared_extTriggerSourceUpdate(hObject); %VI102408A: This shared function handles change to external trigger, by any user of the 'shared' daqjob

function updateRate_Callback(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function updateRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to updateRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function displayWidth_Callback(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function displayWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
% --- Executes on button press in autoDisplayWidth.
function autoDisplayWidth_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'autoDisplayWidth')
    setLocalGh(progmanager, hObject, 'displayWidth', 'Enable', 'Off');
else
    setLocalGh(progmanager, hObject, 'displayWidth', 'Enable', 'On');
end

return;

% --------------------------------------------------------------------
% --- Executes on button press in autoUpdateRate.
function autoUpdateRate_Callback(hObject, eventdata, handles)

%TO042010C - Add an autoUpdateRate checkbox. -- Tim O'Connor 4/20/10
if getLocal(progmanager, hObject, 'autoUpdateRate')
    setLocalGh(progmanager, hObject, 'updateRate', 'Enable', 'Off');
else
    setLocalGh(progmanager, hObject, 'updateRate', 'Enable', 'On');
end

return;

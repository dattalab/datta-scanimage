function varargout = ephys(varargin)
% EPHYS M-file for ephys.fig
%      EPHYS, by itself, creates a new EPHYS or raises the existing
%      singleton*.
%
%      H = EPHYS returns the handle to a new EPHYS or the handle to
%      the existing singleton*.
%
%      EPHYS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EPHYS.M with the given input arguments.
%
%      EPHYS('Property','Value',...) creates a new EPHYS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ephys_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ephys_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ephys

% Last Modified by GUIDE v2.5 12-Nov-2012 13:27:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ephys_OpeningFcn, ...
                   'gui_OutputFcn',  @ephys_OutputFcn, ...
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


% --- Executes just before ephys is made visible.
function ephys_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ephys (see VARARGIN)

% Choose default command line output for ephys
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ephys wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

%------------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = ephys_OutputFcn(hObject, eventdata, handles)
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
       'amplifierList', 1, 'Class', 'Numeric', 'Gui', 'amplifierList', 'Config', 2, ...
       'amplifiers', [], ...
       'channelList', [], ...
       'channels', [], ...
       'selfTrigger', 1, 'Class', 'Numeric', 'Gui', 'selfTrigger', 'Config', 3, ...
       'externalTrigger', 0, 'Class', 'Numeric', 'Gui', 'externalTrigger', 'Config', 3, ...
       'externalTriggerSource', '', 'Class', 'char', 'Gui', 'pmExtTriggerSource',... %VI102308A
       'stimOnArray', [], 'Config', 3, ...
       'stimOn', 0, 'Class', 'Numeric', 'Gui', 'stimOn', ...
       'acqOnArray', [], 'Config', 3, ...
       'acqOn', 0, 'Class', 'Numeric', 'Gui', 'acqOn', ...
       'showStimArray', [], 'Config', 1, ...
       'showStim', 0, 'Class', 'Numeric', 'Gui', 'showStimInAcq', ...
       'pulseSetName', 1, 'Class', 'char', 'Gui', 'pulseSetName', 'Config', 1, ...
       'pulseName', 1, 'Class', 'char', 'Gui', 'pulseName', 'Config', 1, ...
       'pulseSetNameArray', {}, 'Config', 7, ...
       'pulseNameArray', {}, 'Config', 7, ...
       'saveBuffers', [], ...
       'scopeObject', [], ...
       'status', 'NO_AMPLIFIER(S)', 'Class', 'char', 'Gui', 'status', ...
       'epoch', 1, 'Class', 'Numeric', 'Gui', 'epoch', 'Config', 2, ...
       'traceLength', 1, 'Class', 'Numeric', 'Gui', 'traceLength', 'Config', 7, ...
       'pulsePath', '', 'Class', 'char', 'Config', 5, ...
       'pulseFile', '', 'Class', 'char', 'Config', 3, ...
       'pulseNameMapping', {}, 'Class', 'cell', 'Config', 1, ...
       'pulseSetMapping', {}, 'Class', 'cell', 'Config', 1, ...
       'pulseSetDir', '', 'Class', 'char', 'Config', 3, ...
       'pulseSetFileLastModifiedTime', [], 'Class', 'Numeric', ...
       'pulseSelectionHasChanged', 0, 'Class', 'Numeric', ...
       'pulseTimestamps', {}, 'Class', 'cell', ...
       'pulseNumber', 0, 'Class', 'char', 'Gui', 'pulseNumber', 'Config', 2, ...
       'pulseNumberSliderDown', 1, 'Class', 'Numeric', 'Gui', 'pulseNumberSliderDown', 'Min', 0, 'Max', 1, ...
       'pulseNumberSliderUp', 0, 'Class', 'Numeric', 'Gui', 'pulseNumberSliderUp', 'Min', 0, 'Max', 1, ...
       'acquiring', 0, 'Class', 'Numeric', ...
       'scopeObjectGuiProps', [], 'Config', 1, ...
       'looping', 0, 'Class', 'Numeric', ...
       'amplifierSettings', [], 'Config', 2, ...
       'boardBasedTimingEvent', [], ...
       'pulseParameters', {}, 'Config', 2, ...
       'preConfigLoadExternalTrigger', 0, ...
       'traceLengthArray', [], ...
       'pulseSetCacheList', {}, ...
       'pulseNameCacheList', {}, ...
       'segmentedAcquisition', 0, ...
       'triggerTime', [], 'Config', 2, ...
       'pulseHijacked', 0, ...
       'extraGain', 1, 'Class', 'Numeric', 'Gui', 'extraGain', ...
       'extraGainArray', [], 'Class', 'Numeric', 'Config', 7, ...
       'resetTaskWhenDone', 0, ...
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
%De facto 'constructor' for ephys program
%Constructor Arguments:
%   amplifierArray: a cell array of @amplifier objects
function genericStartFcn(hObject, eventdata, handles, varargin)

if getLocal(progmanager, hObject, 'selfTrigger')
    setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Inactive');
end
% ephysAcc_configureAimux(hObject);
% ephysAcc_configureAomux(hObject);

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
cbm = getUserFcnCBM;
%TO060810D - Check for event existence.
if ~isEvent(cbm, 'ephys:Start')
    addEvent(cbm, 'ephys:Start', 'Passes the program handle as an argument.');%TO123005G - Implement various userFcn calls. -- Tim O'Connor 12/30/05
end
if ~isEvent(cbm, 'ephys:Stop')
    addEvent(cbm, 'ephys:Stop', 'Passes the program handle as an argument.');
end
if ~isEvent(cbm, 'ephys:SamplesAcquired')
    addEvent(cbm, 'ephys:SamplesAcquired', 'Passes the acquired samples and the buffer name as arguments.');%TO031306A: Allow access to the samplesAcquired event as a user function, for processing before completion when using board timing.
end
if ~isEvent(cbm, 'ephys:TraceAcquired')
    addEvent(cbm, 'ephys:TraceAcquired', 'Passes the acquired samples and the buffer name as arguments.');%TO042010A: Differentiate between "some samples" and a full trace.
end
if ~isEvent(cbm, 'ephys:SamplesOutput')
    addEvent(cbm, 'ephys:SamplesOutput', 'Passes the channel name being output to as an argument.');%TO082506C: Allow access to the samplesOutput event as a user function, this is intended for use by the pulseJacker gui.
end
%TO123005F
xsg_registerProgram(hObject, {@shared_getData, hObject});

%TO053008B - Moved common start-up script functionality into the various programs. -- Tim O'Connor 5/30/08
try
    if ~isprogram(progmanager, 'pulseEditor')
        pe = program('pulseEditor', 'pulseEditor', 'pulseEditor');
        openprogram(progmanager, pe);
    else
        pe = getGlobal(progmanager, 'hObject', 'pulseEditor', 'pulseEditor');
    end
    peCbm = getLocal(progmanager, pe, 'callbackManager');
    addCallback(peCbm, 'pulseCreation', {@shared_pulseCreation, hObject}, 'ephys_pulseCreation');
    addCallback(peCbm, 'pulseDeletion', {@shared_pulseCreation, hObject}, 'ephys_pulseDeletion');
    addCallback(peCbm, 'pulseSetCreation', {@shared_pulseSetCreation, hObject}, 'ephys_pulseSetCreation');
    addCallback(peCbm, 'pulseSetDeletion', {@shared_pulseSetDeletion, hObject}, 'ephys_pulseSetDeletion');
    addCallback(peCbm, 'pulseUpdate', {@shared_pulseUpdate, hObject}, 'ephys_pulseUpdate');
catch
    fprintf(2, 'Error registering callbacks for pulseEditor events.\n%s', getLastErrorStack);
end
[lg lm] = lg_factory;
registerLoopable(lm, {@shared_loopListener, hObject}, 'ephys');

%TO010506C - Rework triggering scheme for ease of use and simpler looping. -- Tim O'Connor 1/5/06
externalTrigger_Callback(hObject, eventdata, handles);

%VI053108A - Process newly added amplifierArray argument -- Vijay Iyer 5/31/08
if ~isempty(varargin)    
    ephys_setAmplifiers(hObject, varargin{1});
end

%VI102308A - Handle multiple external trigger possibilities -- Vijay Iyer 10/23/08
shared_initializeExtTrigger(hObject);

%TO033110E - Disable controls that are not updated while running. -- Tim O'Connor 3/31/10
disableHandles = [getLocalGh(progmanager, hObject, 'displayWidth'), ...
    getLocalGh(progmanager, hObject, 'autoDisplayWidth'), ...
    getLocalGh(progmanager, hObject, 'updateRate'), ...
    getLocalGh(progmanager, hObject, 'autoUpdateRate'), ...
    getLocalGh(progmanager, hObject, 'acqOn'), ...
    getLocalGh(progmanager, hObject, 'stimOn'), ...
    getLocalGh(progmanager, hObject, 'pulseSetName'), ...
    getLocalGh(progmanager, hObject, 'pulseName'), ...
    getLocalGh(progmanager, hObject, 'pulseNumber'), ...
    getLocalGh(progmanager, hObject, 'pulseNumberSliderUp'), ...
    getLocalGh(progmanager, hObject, 'pulseNumberSliderDown'), ...
    getLocalGh(progmanager, hObject, 'extraGain'), ...
    getLocalGh(progmanager, hObject, 'traceLength'), ...
    getLocalGh(progmanager, hObject, 'pmExtTriggerSource')];
setLocal(progmanager, hObject, 'disableHandles', disableHandles);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

% ephysAcc_configureAimux(hObject);
% ephysAcc_configureAomux(hObject);

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

sc = getLocal(progmanager, hObject, 'scopeObject');
for i = 1 : length(sc)
    delete(sc(i));
end

%TO060910B - Remove the events when we're done. -- Tim O'Connor 6/9/10
cbm = getUserFcnCBM;
if ~isEvent(cbm, 'ephys:Start')
    removeEvent(cbm, 'ephys:Start');
end
if ~isEvent(cbm, 'ephys:Stop')
    removeEvent(cbm, 'ephys:Stop');
end
if ~isEvent(cbm, 'ephys:SamplesAcquired')
    removeEvent(cbm, 'ephys:SamplesAcquired');
end
if ~isEvent(cbm, 'ephys:TraceAcquired')
    removeEvent(cbm, 'ephys:TraceAcquired');
end
if ~isEvent(cbm, 'ephys:SamplesOutput')
    removeEvent(cbm, 'ephys:SamplesOutput');
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
% fprintf(1, 'ephys.m/genericPreLoadSettings\n');
%TO031306E: Make sure it doesn't restart itself. -- Tim O'Connor 3/13/06
setLocalBatch(progmanager, hObject, 'externalTrigger', 0, 'selfTrigger', 1);

%TO083005A
%TO010606B - Make sure this is stopped, so that the externalTrigger state can be set properly afterwards. -- Tim O'Connor 1/6/06
segmentedAcquisition = getLocal(progmanager, hObject, 'segmentedAcquisition');%TO080306A
shared_Stop(hObject);%TO101707F
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
% fprintf(1, 'ephys.m/genericPostLoadSettings\n');

shared_configurationUpdate(hObject);%TO121307E

%TO112305B - Make sure this pop-up menu is enabled and filled, if the names exist. -- Tim O'Connor 11/23/05
[pulseSetNameArray ampIndex] = getLocalBatch(progmanager, hObject, 'pulseSetNameArray', 'amplifierList');
if ~isempty(pulseSetNameArray)
    setLocalGh(progmanager, hObject, 'pulseSetName', 'String', pulseSetNameArray{ampIndex}, 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'pulseSetName', 'String', '', 'Enable', 'Off');
end

shared_selectChannel(hObject, getLocal(progmanager, hObject, 'amplifierList'));%TO101707F
if getLocal(progmanager, hObject, 'selfTrigger')
    setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');%TO013106F This should no longer become inactive, ever.
end
setLocal(progmanager, hObject, 'pulseSelectionHasChanged', 1);

props = getLocal(progmanager, hObject, 'scopeObjectGuiProps');
sc = getLocal(progmanager, hObject, 'scopeObject');
if length(sc) == length(props)
    for i = 1 : length(props)
        f = get(sc(i), 'figure');
% fprintf(1, 'ephys/genericPostLoadSettings: display(%s) -\n Position: %s\n Visible: %s\n', num2str(i), mat2str(props(i).position), props(i).visible);
        set(f, 'Position', props(i).position);
        set(sc(i), 'visible', props(i).visible);%TO033106F
    end
% else
%     fprintf('Warning (ephys): Configuration does not contain the right amount of metadata for the current number of scope displays, ignoring display position and visibility settings.\n ScopeObjects: %s\n ScopeObject metadata: %s\n', ...
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

%TO022406D
% pause(2)
shared_pulseSetCreation(hObject);%TO101707F
% 'ephys_pulseSetCreation'
% pause(2)
shared_pulseCreation(hObject);%TO101707F
% 'ephys_pulseCreation'

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

%TO120205H: Get the amplifier's settings and cram them into the header. -- Tim O'Connor 12/2/05
amplifiers = getLocal(progmanager, hObject, 'amplifiers');
amplifierSettings = [];
for i = 1 : length(amplifiers)
    try
        %TO123105A: Can't have a '-' in a fieldname. And can not start with a number. -- Tim O'Connor 12/31/05
        ampName = strrep(get(amplifiers{i}, 'name'), '-', '_');
        if ~isempty(str2num(ampName(1)))
            ampName = ['Amp_' ampName];
        end
        amplifierSettings.(ampName) = getHeaderInfo(amplifiers{i});
    catch
        warning('Failed to retrieve header info from amplifier ''%s'': %s', get(amplifiers{i}, 'name'), lasterr);
    end
end

setLocal(progmanager, hObject, 'amplifierSettings', amplifierSettings);

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

shared_saveTrace(hObject);%TO101707F

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

[f p] = uiputfile(fullfile(pwd, '*.ephys'));
if length(f) == 0
    if f == 0
        return;
    end
end
shared_saveTrace(hObject, fullfile(p, f));%TO101707F

return;

% ------------------------------------------------------------------
function genericPreCacheSettings(hObject, eventdata, handles)

% setLocalBatch(progmanager, hObject, 'chainedPulses', 1, 'segmentedAcquisition', 1);%TO080306A %TO101707D
genericPreLoadSettings(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericPreCacheMiniSettings(hObject, eventdata, handles)

% setLocalBatch(progmanager, hObject, 'chainedPulses', 1, 'segmentedAcquisition', 1);%TO080306A %TO101707D
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
setLocal(progmanager, hObject, 'traceLengthArray', traceLengths);
genericPostLoadSettings(hObject, eventdata, handles, updateExternalTrigger);
[pulseSets, pulseNames, currentSetArray, currentNameArray, pulseSelectionHasChanged] = getLocalBatch(progmanager, hObject, ...
    'pulseSetCacheList', 'pulseNameCacheList', 'pulseSetNameArray', 'pulseNameArray', 'pulseSelectionHasChanged');
pulseSets{end + 1} = currentSetArray;
pulseNames{end + 1} = currentNameArray;
pulseSelectionHasChanged(:) = 1;
setLocalBatch(progmanager, hObject, 'pulseSetCacheList', pulseSets, 'pulseNameCacheList', pulseNames, ...
    'traceLengthArray', traceLengths, 'pulseSelectionHasChanged', pulseSelectionHasChanged);

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
setLocal(progmanager, hObject, 'traceLengthArray', traceLengths);
genericPostLoadMiniSettings(hObject, eventdata, handles, updateExternalTrigger);
[pulseSets, pulseNames, currentSetArray, currentNameArray] = getLocalBatch(progmanager, hObject, ...
    'pulseSetCacheList', 'pulseNameCacheList', 'pulseSetNameArray', 'pulseNameArray');
pulseSets{end + 1} = currentSetArray;
pulseNames{end + 1} = currentNameArray;
pulseSelectionHasChanged(:) = 1;
setLocalBatch(progmanager, hObject, 'pulseSetCacheList', pulseSets, 'pulseNameCacheList', pulseNames, ...
    'traceLengthArray', traceLengths, 'pulseSelectionHasChanged', pulseSelectionHasChanged);

return;

% ------------------------------------------------------------------
%TO062806M - Clear any old pulses, so they're not included during append operations.
function genericCacheOperationBegin(hObject, eventdata, handles)
% fprintf(1, 'ephys/genericCacheOperationBegin\n');
%clearByName(pulseMap('acquisition'), shared_getOutputChannelNames(hObject));%TO101707F

return;

% ------------------------------------------------------------------
%TO062806F - Only update the triggering once all configurations have been processed.
function genericCacheOperationComplete(hObject, eventdata, handles)
% fprintf(1, 'ephys/genericCacheOperationComplete\n');
externalTrigger_Callback(hObject, eventdata, handles);

%TO101707D
pulseSelectionHasChanged = getLocal(progmanager, hObject, 'pulseSelectionHasChanged');
pulseSelectionHasChanged(:) = 1;
setLocalBatch(progmanager, hObject, 'pulseSetCacheList', {}, 'pulseNameCacheList', {}, 'traceLengthArray', [], 'pulseSelectionHasChanged', pulseSelectionHasChanged);

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
function amplifierList_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%------------------------------------------------------------------------------
% --- Executes on selection change in amplifierList.
function amplifierList_Callback(hObject, eventdata, handles)

%TO060810F - Multiple channel selection shouldn't be possible, but if it is, don't let it cause mischief. -- Tim O'Connor 6/8/10
amplifierList = getLocal(progmanager, hObject, 'amplifierList');
if length(amplifierList) > 1
    amplifierList = amplifierList(1);
    setLocal(progmanager, hObject, 'amplifierList', amplifierList);
elseif isempty(amplifierList)
    amplifierList = 1;
    setLocal(progmanager, hObject, 'amplifierList', amplifierList);
end
shared_selectChannel(hObject, amplifierList);%TO101707F

return;

%------------------------------------------------------------------------------
% --- Executes on button press in acqOn.
function acqOn_Callback(hObject, eventdata, handles)

acqOnArray = getLocal(progmanager, hObject, 'acqOnArray');
index = getLocal(progmanager, hObject, 'amplifierList');
acqOnArray(index) = getLocal(progmanager, hObject, 'acqOn');
setLocal(progmanager, hObject, 'acqOnArray', acqOnArray);

return;

%------------------------------------------------------------------------------
% --- Executes on button press in stimOn.
function stimOn_Callback(hObject, eventdata, handles)

%TO031610D - Check for a loaded pulse set before continuing. -- Tim O'Connor 3/16/10
if exist(getLocal(progmanager, hObject, 'pulseSetDir'), 'dir') ~= 7
    loadPulseSetItem_Callback(hObject, eventdata, handles);
end

stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
index = getLocal(progmanager, hObject, 'amplifierList');
stimOnArray(index) = getLocal(progmanager, hObject, 'stimOn');
setLocal(progmanager, hObject, 'stimOnArray', stimOnArray);

return;

%------------------------------------------------------------------------------
% --- Executes on button press in showStimInAcq.
function showStimInAcq_Callback(hObject, eventdata, handles)
return;

%------------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseSetName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%------------------------------------------------------------------------------
% --- Executes on selection change in pulseSetName.
function pulseSetName_Callback(hObject, eventdata, handles)

shared_pulseSetNameCallback(hObject);

return;

%------------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%------------------------------------------------------------------------------
%TO090806A - Update the loaded signal if set to externalTrigger mode. -- Tim O'Connor 9/8/06
% --- Executes on selection change in pulseName.
function pulseName_Callback(hObject, eventdata, handles)
shared_pulseNameCallback(hObject);
return;
% [directory, pulseSetName, pulseName, pulseNameArray, ampIndex, externalTrigger, amplifiers, traceLength, pulseSetNameArray, pulseNameArray, sampleRate, pulseParameters, pulseSelectionHasChanged] = getLocalBatch(progmanager, hObject, ...
%     'pulseSetDir', 'pulseSetName', 'pulseName', 'pulseNameArray', 'amplifierList', 'externalTrigger', 'amplifiers', 'traceLength', 'pulseSetNameArray', 'pulseNameArray', 'sampleRate', 'pulseParameters', 'pulseSelectionHasChanged');%TO090806A
% 
% if isempty(directory)
%     warndlg('A pulse directory must be selected before new pulses may be accessed.');
%     error('No pulse directory selected. Can not load pulse.');
% end
% 
% if isempty(pulseSetName)
%     warndlg('A pulse set must be selected before new pulses may be accessed.');
%     error('No pulse set selected. Can not load pulse.');
% end
% 
% if ~isempty(pulseName)
%     filename = fullfile(directory, pulseSetName, [pulseName '.signal']);
%     if exist(filename) ~= 2    
%         errordlg(sprintf('Pulse ''%s:%s'' not found - %s', pulseSetName, pulseName, filename));
%         error('Pulse ''%s:%s'' not found - %s', pulseSetName, pulseName, filename);
%     end
% end
% 
% pulseNameArray{ampIndex} = pulseName;
% setLocal(progmanager, hObject, 'pulseNameArray', pulseNameArray);
% %TO092605I: Automatically enable stimulation when a valid pulse is selected.
% if ~isempty(pulseName)
%     stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
%     stimOnArray(ampIndex) = 1;
%     setLocalBatch(progmanager, hObject, 'stimOn', 1, 'stimOnArray', stimOnArray);
% else
%     stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
%     stimOnArray(ampIndex) = 0;
%     setLocalBatch(progmanager, hObject, 'stimOn', 0, 'stimOnArray', stimOnArray);    
% end
% 
% pulseSelectionHasChanged(ampIndex) = 1;%TO101707D
% setLocal(progmanager, hObject, 'pulseSelectionHasChanged', pulseSelectionHasChanged);
% 
% %TO100305A
% num = getNumericSuffix(pulseName);
% if ~isempty(num)
%     setLocal(progmanager, hObject, 'pulseNumber', num2str(num));
% else
%     setLocal(progmanager, hObject, 'pulseNumber', '');
% end
% 
% %TO090806A
% if externalTrigger
%     channelName = getVComChannelName(amplifiers{ampIndex});
%     pm = pulseMap('acquisition');
%     try
%         sig = getPulse(pm, channelName);
%         clearByName(pm, channelName);
%         delete(sig);
%     catch
%         warning('ephys - Failed to properly delete previously loaded pulse from channel ''%s'': %s', channelName, lasterr);
%     end
%     try
%         filename = fullfile(directory, pulseSetNameArray{ampIndex}, [pulseNameArray{ampIndex} '.signal']);
%         s = load(filename, '-mat');
%         set(s.signal, 'SampleRate', sampleRate, 'deleteChildrenAutomatically', 1);
%         setPulse(pm, channelName, s.signal);
%     catch
%         warning('ephys - Failed to properly bind new pulse to channel ''%s'': %s', channelName, lasterr);
%     end
%     try
%         pulseParameters{ampIndex} = toStruct(s.signal);
%         setLocal(progmanager, hObject, 'pulseParameters', pulseParameters);
%     catch
%         warning('ephys - Failed to properly insert pulse parameters for channel ''%s'' into header: %s', channelName, lasterr);
%     end
% end
% 
% return;

%---------------------------------------------------------------------------
function selfTrigger_Callback(hObject, eventdata, handles)

setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Inactive');
setLocal(progmanager, hObject, 'externalTrigger', 0);
setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');

return;

%---------------------------------------------------------------------------
function externalTrigger_Callback(hObject, eventdata, handles)
% fprintf(1, 'ephys.m/externalTrigger_Callback\n%s', getStackTraceString);

%TO031610D - Check for a loaded pulse set before continuing. -- Tim O'Connor 3/16/10
[stimOnArray, pulseSetDir] = getLocalBatch(progmanager, hObject, 'stimOnArray', 'pulseSetDir');
if any(stimOnArray)
    if exist(pulseSetDir, 'dir') ~= 7
        loadPulseSetItem_Callback(hObject, eventdata, handles);
        setLocal(progmanager, hObject, 'externalTrigger', 0);
        return;
    end
end

[startButton, externalTrigger] = getLocalBatch(progmanager, hObject, 'startButton', 'externalTrigger');
%TO032406E: Watch out for errors here, make sure the button stays available, in case of an error. -- Tim O'Connor 3/24/06
try
    %TO010506C - Rework triggering scheme for ease of use and simpler looping. -- Tim O'Connor 1/5/06
    if externalTrigger
% fprintf(1, 'ephys: externalTrigger = ''On''\n');
        if startButton
            fprintf(2, 'stimulator - Warning: Attempting to enable external trigger while already started.\n');
        end
        setLocalGh(progmanager, hObject, 'externalTrigger', 'ForegroundColor', [1 0 0]);
        setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
        setLocalBatch(progmanager, hObject, 'selfTrigger', 0);
        if ~startButton
% fprintf(1, 'ephys: externalTrigger starting task...\n');
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Off');
            shared_Start(hObject);%TO101707F
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
        end
    else
% fprintf(1, 'ephys: externalTrigger = ''Off''\n');
        setLocalGh(progmanager, hObject, 'externalTrigger', 'ForegroundColor', [0 0.6 0]);
        setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
        setLocal(progmanager, hObject, 'selfTrigger', 1);
        if startButton
% fprintf(1, 'ephys: externalTrigger stopping task...\n');
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Off');
            segmentedAcquisition = getLocal(progmanager, hObject, 'segmentedAcquisition');%TO080306A
            shared_Stop(hObject);%TO101707F
            setLocalBatch(progmanager, hObject, 'segmentedAcquisition', segmentedAcquisition);%TO080306A
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
        end
    end
catch
    warning('An error occured while updating the externalTrigger setting for ephys: %s', getLastErrorStack);
    % err = lasterror;
    % err.identifier
    % err.message
    % for i = 1 : length(err.stack)
    %     err.stack(i)
    % end
    setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
end

% setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Inactive');
% setLocal(progmanager, hObject, 'selfTrigger', 0);
% setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'On');

return;

% --------------------------------------------------------------------
%  TO031610C - Make sure default pulses exist, and map them to channels that don't have anything. -- Tim O'Connor 03/16/10
%  TO061110A - Moved TO031610C because it was happening at the wrong time.
function loadPulseSetItem_Callback(hObject, eventdata, handles)

[currentDir, stimOnArray] = getLocalBatch(progmanager, hObject, 'pulseSetDir', 'stimOnArray');%TO031306F
if isempty(currentDir) || exist(currentDir, 'dir') ~= 7
    currentDir = getDefaultCacheDirectory(progmanager, 'pulseDir');%TO120705D %TO030906A
end
%TO030906A
% if isempty(currentDir) | exist(currentDir) ~= 7
%     currentDir = pwd;
% end
pulseSetDir = uigetdir(currentDir, 'Choose a directory containing pulses.');
%TO123005L - Watch out for cancellations.
if length(pulseSetDir) == 1
    if pulseSetDir == 0
        return;
    end
end
if isempty(pulseSetDir)
    return;
end
if exist(pulseSetDir, 'dir') ~= 7
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
    return;
end
setLocal(progmanager, hObject, 'pulseSetDir', pulseSetDir);

setDefaultCacheValue(progmanager, 'pulseDir', currentDir);%TO120705D

%TO031610C %TO061110A
if exist(fullfile(pulseSetDir, 'defaultPulses'), 'dir') ~= 7
    mkdir(pulseSetDir, 'defaultPulses');
end
if exist(fullfile(pulseSetDir, 'defaultPulses', 'default-DC_0.signal'), 'file') ~= 2
    signal = signalobject('Name', 'default-DC_0', 'sampleRate', 10000);
    dc(signal, 0);
    saveCompatible(fullfile(pulseSetDir, 'defaultPulses',  'default-DC_0.signal'), 'signal', '-mat');
    set(signal, 'Name', 'default-DC_1');
    dc(signal, 1);
    saveCompatible(fullfile(pulseSetDir, 'defaultPulses',  'default-DC_1.signal'), 'signal', '-mat');
    set(signal, 'Name', 'default-DC_5');
    dc(signal, 5);
    saveCompatible(fullfile(pulseSetDir, 'defaultPulses',  'default-DC_5.signal'), 'signal', '-mat');
    delete(signal);
end

%TO022406D
shared_pulseSetCreation(hObject);%TO101707F

[pulseSetNameArray, pulseNameArray, pulseSelectionHasChanged, ampIndex] = getLocalBatch(progmanager, hObject, 'pulseNameArray', 'pulseSetNameArray', 'pulseSelectionHasChanged', 'amplifierList');
for i = 1 : length(pulseSetNameArray)
    if isempty(pulseSetNameArray{i})
        pulseSetNameArray{i} = 'defaultPulses';
        pulseSelectionHasChanged(i) = 1;
    end
end
for i = 1 : length(pulseNameArray)
    if isempty(pulseNameArray{i}) && strcmpi(pulseSetNameArray{i}, 'defaultPulses')
        pulseNameArray{i} = 'default-DC_0';
        pulseSelectionHasChanged(i) = 1;
    end
end
setLocalBatch(progmanager, hObject, 'pulseSetName', pulseSetNameArray{ampIndex}, ...
    'pulseSetNameArray', pulseSetNameArray, 'pulseSelectionHasChanged', pulseSelectionHasChanged);
pulseSetName_Callback(hObject, eventdata, handles);
setLocalBatch(progmanager, hObject, 'pulseNameArray', pulseNameArray, 'pulseName', pulseNameArray{ampIndex});
pulseName_Callback(hObject, eventdata, handles);

%TO031306F
if ~isempty(stimOnArray)
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
end

return;

% --------------------------------------------------------------------
function startButton_Callback(hObject, eventdata, handles)

%TO031610D - Check for a loaded pulse set before continuing. -- Tim O'Connor 3/16/10
[stimOnArray, pulseSetDir] = getLocalBatch(progmanager, hObject, 'stimOnArray', 'pulseSetDir');
if any(stimOnArray)
    if exist(pulseSetDir, 'dir') ~= 7
        loadPulseSetItem_Callback(hObject, eventdata, handles);
        setLocal(progmanager, hObject, 'startButton', 0);
        return;
    end
end

if getLocal(progmanager, hObject, 'startButton')
    %TO090506A - Clear erroneous states, if the exist. -- Tim O'Connor 9/5/06
    setLocalBatch(progmanager, hObject, 'traceLengthArray', [], 'segmentedAcquisition', 0, 'acquisitionsRemainingCounter', 0, 'transmissionsRemainingCounter', 0);
    shared_Start(hObject);%TO101707F
else
    setLocal(progmanager, hObject, 'stopRequested', 1);%TO021610J
    shared_Stop(hObject);%TO101707F
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

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseNumberSliderDown_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject, 'BackgroundColor', [.9 .9 .9]);
else
    set(hObject, 'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
%TO100305A - Added the pulseNumber variable.
%TO100605A - Allow auto sorting by pulse number.
% --- Executes on slider movement.
function pulseNumberSliderDown_Callback(hObject, eventdata, handles)

%TO081606E - Slider functionality changed as of Matlab 7, invalidating most slider code. -- Tim O'Connor 8/16/06
[pulseNumber] = getLocalBatch(progmanager, hObject, 'pulseNumber');

pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
if isempty(pulseNumber)
    if pulseNumberSlider < pulseNumberSliderLast | pulseNumberSlider == 0
        return;
    end
    
    num = [];
    i = 1;
    while isempty(num) & i <= length(pulseNames)
        num = getNumericSuffix(pulseNames{i});
        i = i + 1;
    end
    num = num - 1;
%     return;
%     pulseNumber = 1;
%     num = 1;
else
    num = str2num(pulseNumber);
end

if isempty(num)
    return;
end

numbers = [];
for i = 1 : length(pulseNames)
    suffix = getNumericSuffix(pulseNames{i});
    if ~isempty(suffix)
        numbers(length(numbers) + 1) = suffix;
    end
end
num = max(numbers(find(numbers < num)));


if isempty(num)
    return;
end
% if pulseNumberSliderDown < pulseNumberSliderLast | pulseNumberSliderDown == 0
%     num = num - 1;
% else
%     num = num + 1;
% end

setLocalBatch(progmanager, hObject, 'pulseNumber', num2str(num), 'pulseNumberSliderDown', 1);
pulseNumber_Callback(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
%TO100305A - Added the pulseNumber variable.
function pulseNumber_Callback(hObject, eventdata, handles)

pulseNumber = getLocal(progmanager, hObject, 'pulseNumber');
pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
for i = 1 : length(pulseNames)
    if endsWith(pulseNames{i}, pulseNumber)
        setLocal(progmanager, hObject, 'pulseName', pulseNames{i});
        pulseName_Callback(hObject, eventdata, handles);
        return;
    end
end

setLocal(progmanager, hObject, 'pulseNumber', '');

return;

% --------------------------------------------------------------------
%TO100605A - Allow auto sorting by pulse number.
function autoSortPulseNames(hObject)

pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
for i = 1 : length(pulseNames)
    if isempty(pulseNames{i})
        pulseNames = {pulseNames{find((1:length(pulseNames)) ~= i)}};
    end
end

nums = [];
for i = 1 : length(pulseNames)
    num = getNumericSuffix(pulseNames{i});
    if isempty(num)
        nums(i) = Inf;
    else
        nums(i) = num;
    end
end
[sorted indices] = sort(nums);

setLocalGh(progmanager, hObject, 'pulseName', 'String', {'', pulseNames{indices}});

return;


% --- Executes on slider movement.
%TO081606E - This function was cut & pasted from pulseNumberSliderDown_Callback, with some editting as needed.
function pulseNumberSliderUp_Callback(hObject, eventdata, handles)

%TO081606E - Slider functionality changed as of Matlab 7, invalidating most slider code. -- Tim O'Connor 8/16/06
[pulseNumber] = getLocalBatch(progmanager, hObject, 'pulseNumber');

pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
if isempty(pulseNumber)
    if pulseNumberSlider < pulseNumberSliderLast | pulseNumberSlider == 0
        return;
    end
    
    num = [];
    i = 1;
    while isempty(num) & i <= length(pulseNames)
        num = getNumericSuffix(pulseNames{i});
        i = i + 1;
    end
    num = num - 1;
%     return;
%     pulseNumber = 1;
%     num = 1;
else
    num = str2num(pulseNumber);
end

if isempty(num)
    return;
end

numbers = [];
for i = 1 : length(pulseNames)
    suffix = getNumericSuffix(pulseNames{i});
    if ~isempty(suffix)
        numbers(length(numbers) + 1) = suffix;
    end
end
num = min(numbers(find(numbers > num)));

if isempty(num)
    return;
end
% if pulseNumberSliderDown < pulseNumberSliderLast | pulseNumberSliderDown == 0
%     num = num - 1;
% else
%     num = num + 1;
% end

setLocalBatch(progmanager, hObject, 'pulseNumber', num2str(num), 'pulseNumberSliderUp', 0);
pulseNumber_Callback(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function pulseNumberSliderUp_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

return;


% -------------------------------------------------------------------
function pmExtTriggerSource_Callback(hObject, eventdata, handles)
shared_extTriggerSourceUpdate(hObject); %VI102408A: This shared function handles change to external trigger, by any user of the 'shared' daqjob

return;

% --------------------------------------------------------------------
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
return;

% --------------------------------------------------------------------
%TO021610H - Put the extraGain feature back into Ephys. -- Tim O'Connor 2/16/10
% --- Executes during object creation, after setting all properties.
function extraGain_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
%TO021610H - Put the extraGain feature back into Ephys. -- Tim O'Connor 2/16/10
function extraGain_Callback(hObject, eventdata, handles)

extraGainArray = getLocal(progmanager, hObject, 'extraGainArray');
index = getLocal(progmanager, hObject, 'amplifierList');
extraGainArray(index) = getLocal(progmanager, hObject, 'extraGain');
setLocal(progmanager, hObject, 'extraGainArray', extraGainArray);

return;

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

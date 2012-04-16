function varargout = stimulator(varargin)
% STIMULATOR M-file for stimulator.fig
%      STIMULATOR, by itself, creates a new STIMULATOR or raises the existing
%      singleton*.
%
%      H = STIMULATOR returns the handle to a new STIMULATOR or the handle to
%      the existing singleton*.
%
%      STIMULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMULATOR.M with the given input arguments.
%
%      STIMULATOR('Property','Value',...) creates a new STIMULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stimulator_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stimulator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stimulator

% Last Modified by GUIDE v2.5 24-Oct-2008 08:03:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimulator_OpeningFcn, ...
                   'gui_OutputFcn',  @stimulator_OutputFcn, ...
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

% --------------------------------------------------------------------
% --- Executes just before stimulator is made visible.
function stimulator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stimulator (see VARARGIN)

% Choose default command line output for stimulator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stimulator wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = stimulator_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
return;

% ------------------------------------------------------------------
%TO112105A - This function was cut & pasted from ephys.m, with some editting as needed.
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'startButton', 0, 'Class', 'Numeric', 'Gui', 'startButton', 'Config', 2 ...
       'sampleRate', 10000, 'Class', 'Numeric', 'Config', 7, ...
       'outputChannels', {}, ...
       'channelList', 1, 'Class', 'Numeric', 'Gui', 'channelList', 'Config', 2, ...
       'channels', [], 'Config', 2, ...
       'selfTrigger', 1, 'Class', 'Numeric', 'Gui', 'selfTrigger', 'Config', 3, ...
       'externalTrigger', 0, 'Class', 'Numeric', 'Gui', 'externalTrigger', 'Config', 3, ...
       'externalTriggerSource', '', 'Class', 'char', 'Gui', 'pmExtTriggerSource', ... %VI102308A
       'stimOnArray', [], 'Config', 3, ...
       'stimOn', 0, 'Class', 'Numeric', 'Gui', 'stimOn', ...
       'extraGain', 1, 'Class', 'Numeric', 'Gui', 'extraGain', ...
       'extraGainArray', [], 'Class', 'Numeric', 'Config', 7, ...
       'pulseSetName', 1, 'Class', 'char', 'Gui', 'pulseSetName', 'Config', 1, ...
       'pulseName', 1, 'Class', 'char', 'Gui', 'pulseName', 'Config', 1, ...
       'pulseSetNameArray', {}, 'Config', 7, ...
       'pulseNameArray', {}, 'Config', 7, ...
       'status', 'NO_CHANNEL(S)', 'Class', 'char', 'Gui', 'status', ...
       'traceLength', 1, 'Class', 'Numeric', 'Gui', 'traceLength', 'Config', 7, ...
       'pulsePath', '', 'Class', 'char', 'Config', 5, ...
       'pulseNameMapping', {}, 'Class', 'cell', 'Config', 1, ...
       'pulseSetMapping', {}, 'Class', 'cell', 'Config', 1, ...
       'pulseSetDir', '', 'Class', 'char', 'Config', 3, ...
       'pulseSetFileLastModifiedTime', [], 'Class', 'Numeric', ...
       'pulseSelectionHasChanged', [], 'Class', 'Numeric', ...
       'pulseTimestamps', {}, 'Class', 'cell', ...
       'pulseNumber', 0, 'Class', 'char', 'Gui', 'pulseNumber', ...
       'pulseNumberSliderDown', 1, 'Class', 'Numeric', 'Gui', 'pulseNumberSliderDown', 'Min', 0, 'Max', 1, ...
       'pulseNumberSliderUp', 0, 'Class', 'Numeric', 'Gui', 'pulseNumberSliderUp', 'Min', 0, 'Max', 1, ...
       'acquiring', 0, 'Class', 'Numeric', ...
       'startID', 0, 'Class', 'Numeric', ...
       'looping', 0, 'Class', 'Numeric', ...
       'boardBasedTimingEvent', [], ...
       'pulseParameters', {}, 'Config', 2, ...
       'preConfigLoadExternalTrigger', 0, ...
       'traceLengthArray', [], ...
       'pulseSetCacheList', {}, ...
       'pulseNameCacheList', {}, ...
       'triggerTime', [], 'Config', 2, ...
       'pulseHijacked', 0, ...
       'amplifiers', {}, ...
       'amplifierList', [], ...
       'acqOnArray', [], ...
       'acqOn', [], ...
       'segmentedAcquisition', 0, ...
       'showStimArray', [], ...
       'saveBuffers', [], ...
       'scopeObject', [], ...
       'resetTaskWhenDone', 0, ...
       'zeroChannelsOnStop', 1, ...
       'clearBuffersWhenNotRunning', 0, ...
       'updateRate', 1, ...
       'autoDisplayWidth', 0, ...
       'displayWidth', 0, ...
       'continuousAcqMode', 0, ...
       'sampleCount', 0, ...
       'stopRequested', 0, ...
       'clearBuffersOnGetData', 1,  'Config', 5, ...
       'disableHandles', [], ...
       'updateRate', [], ...
       'autoUpdateRate', [], ...
       'displayWidth', [], ...
       'autoDisplayWidth', [], ...
       'dataToBeSaved', 0, ...
   };

return;

% ------------------------------------------------------------------
%De facto 'constructor' for 'stimulator' program
%Constructor Arguments:
%   stimChannelArray: struct array containing fields 'channelName','boardID', and 'channelID', 
%                       which contain a string, integer, and integer, respectively, for each array element. 
   
%Notes
%   Channels can be added following construction: either step-wise via  stim_addChannels(), or all at once via stim_setChannels()
function genericStartFcn(hObject, eventdata, handles, varargin)

% if getLocal(progmanager, hObject, 'selfTrigger')
%     setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Inactive');
%     setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
% else
%     setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'On');
%     setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Inactive');
% end

%TO123005G - Implement various userFcn calls. -- Tim O'Connor 12/30/05
cbm = getUserFcnCBM;
%TO060810D - Check for event existence.
if ~isEvent(cbm, 'stimulator:Start')
    addEvent(cbm, 'stimulator:Start', 'Passes the program handle as an argument.');
end
if ~isEvent(cbm, 'stimulator:Stop')
    addEvent(cbm, 'stimulator:Stop', 'Passes the program handle as an argument.');
end
if ~isEvent(cbm, 'stimulator:SamplesOutput')
    addEvent(cbm, 'stimulator:SamplesOutput', 'Passes the channel name being output to as an argument.');%TO082506C: Allow access to the samplesOutput event as a user function, this is intended for use by the pulseJacker gui.
end

%TO053008B - Moved common start-up script functionality into the various programs. -- Tim O'Connor 5/30/08
try
    if ~isprogram(progmanager, 'pulseEditor')
        pe = program('pulseEditor', 'pulseEditor', 'pulseEditor');
        openprogram(progmanager, pe);
    else
        pe = getGlobal(progmanager, 'hObject', 'pulseEditor', 'pulseEditor');
    end
    peCbm = getLocal(progmanager, pe, 'callbackManager');
    addCallback(peCbm, 'pulseCreation', {@shared_pulseCreation, hObject}, 'stim_pulseCreation');
    addCallback(peCbm, 'pulseDeletion', {@shared_pulseCreation, hObject}, 'stim_pulseDeletion');
    addCallback(peCbm, 'pulseSetCreation', {@shared_pulseSetCreation, hObject}, 'stim_pulseSetCreation');
    addCallback(peCbm, 'pulseSetDeletion', {@shared_pulseSetDeletion, hObject}, 'stim_pulseSetDeletion');
    addCallback(peCbm, 'pulseUpdate', {@shared_pulseUpdate, hObject}, 'stim_pulseUpdate');
catch
    fprintf(2, 'Error registering callbacks for pulseEditor events.\n%s', getLastErrorStack);
end
[lg lm] = lg_factory;
registerLoopable(lm, {@shared_loopListener, hObject}, 'stimulator');

%TO010506C - Rework triggering scheme for ease of use and simpler looping. -- Tim O'Connor 1/5/06
externalTrigger_Callback(hObject, eventdata, handles);

%VI053108A - Process newly added stimChannelArray argument -- Vijay Iyer 5/31/08
if ~isempty(varargin) 
    stim_setChannels(hObject, varargin{1});
end

%VI102308A - Handle multiple external trigger possibilities -- Vijay Iyer 10/23/08
shared_initializeExtTrigger(hObject);

%TO033110E - Disable controls that are not updated while running. -- Tim O'Connor 3/31/10
disableHandles = [getLocalGh(progmanager, hObject, 'stimOn'), ...
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

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

%TO060910B - Remove the events when we're done. -- Tim O'Connor 6/9/10
cbm = getUserFcnCBM;
if ~isEvent(cbm, 'stimulator:Start')
    removeEvent(cbm, 'stimulator:Start');
end
if ~isEvent(cbm, 'stimulator:Stop')
    removeEvent(cbm, 'stimulator:Stop');
end
if ~isEvent(cbm, 'stimulator:SamplesOutput')
    removeEvent(cbm, 'stimulator:SamplesOutput');
end

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.4;

return;

% ------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)
% fprintf(1, 'stimulator.m/genericPreLoadSettings\n');
%TO031306E: Make sure it doesn't restart itself. -- Tim O'Connor 3/13/06
setLocalBatch(progmanager, hObject, 'externalTrigger', 0, 'selfTrigger', 1);

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
% fprintf(1, 'stimulator.m/genericPostLoadSettings\n');
shared_configurationUpdate(hObject);%TO121307E

%TO112305B - Make sure this pop-up menu is enabled and filled, if the names exist. -- Tim O'Connor 11/23/05
[pulseSetNameArray, chIndex] = getLocalBatch(progmanager, hObject, 'pulseSetNameArray', 'channelList');
if ~isempty(pulseSetNameArray)
    setLocalGh(progmanager, hObject, 'pulseSetName', 'String', pulseSetNameArray{chIndex}, 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'pulseSetName', 'String', '', 'Enable', 'Off');
end

shared_selectChannel(hObject, chIndex);%TO101707F
% if getLocal(progmanager, hObject, 'selfTrigger')
%     setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Inactive');
%     setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
% else
%     setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'On');
%     setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Inactive');
% end
setLocal(progmanager, hObject, 'pulseSelectionHasChanged', 1);

%TO022406D
shared_pulseCreation(hObject);%TO101707F

shared_pulseSetCreation(hObject);%TO101707F

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

warndlg('This program has no data to be saved.');

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

warndlg('This program has no data to be saved.');

return;

% ------------------------------------------------------------------
function genericPreCacheSettings(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'chainedPulses', 1, 'segmentedAcquisition', 1);%TO080306A
genericPreLoadSettings(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericPreCacheMiniSettings(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'chainedPulses', 1, 'segmentedAcquisition', 1);%TO080306A
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
[pulseSets, pulseNames, traceLengths, currentSetArray, currentNameArray, currentLength] = getLocalBatch(progmanager, hObject, ...
    'pulseSetCacheList', 'pulseNameCacheList', 'traceLengthArray', 'pulseSetNameArray', 'pulseNameArray', 'traceLength');
pulseSets{end + 1} = currentSetArray;
pulseNames{end + 1} = currentNameArray;
traceLengths(end + 1) = currentLength;
setLocalBatch(progmanager, hObject, 'pulseSetCacheList', pulseSets, 'pulseNameCacheList', pulseNames, ...
    'traceLengthArray', traceLengths, 'pulseSelectionHasChanged', 1);
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
[pulseSets, pulseNames, traceLengths, currentSetArray, currentNameArray, currentLength] = getLocalBatch(progmanager, hObject, ...
    'pulseSetCacheList', 'pulseNameCacheList', 'traceLengthArray', 'pulseSetNameArray', 'pulseNameArray', 'traceLength');
pulseSets{end + 1} = currentSetArray;
pulseNames{end + 1} = currentNameArray;
traceLengths(end + 1) = currentLength;
setLocalBatch(progmanager, hObject, 'pulseSetCacheList', pulseSets, 'pulseNameCacheList', pulseNames, ...
    'traceLengthArray', traceLengths, 'pulseSelectionHasChanged', 1);
genericPostLoadMiniSettings(hObject, eventdata, handles, updateExternalTrigger);

return;

% ------------------------------------------------------------------
%TO062806M - Clear any old pulses, so they're not included during append operations.
function genericCacheOperationBegin(hObject, eventdata, handles)
% fprintf(1, 'stimulator/genericCacheOperationBegin\n');
[channels, aom] = getLocalBatch(progmanager, hObject, 'channels', 'aomux');
dm = getDaqmanager;
for i = 1 : length(channels)
    if hasChannel(dm, channels(i).channelName)
        sig = getSignal(aom, channels(i).channelName);
        if ~isempty(sig)
            try
                delete(sig);
            catch
                %Might've been deleted elsewhere, it's probably not a memory leak, I'm just being overaggressive with deletion. -- Tim O'Connor 6/28/06
            end
        end
        bind(aom, channels(i).channelName, []);%TO070306A
    end
end

return;

% ------------------------------------------------------------------
%TO062806F - Only update the triggering once all configurations have been processed.
function genericCacheOperationComplete(hObject, eventdata, handles)
% fprintf(1, 'stimulator/genericCacheOperationComplete\n');
externalTrigger_Callback(hObject, eventdata, handles);

setLocalBatch(progmanager, hObject, 'pulseSetCacheList', {}, 'pulseNameCacheList', {}, 'traceLengthArray', [], 'pulseSelectionHasChanged', 1);

return

% --------------------------------------------------------------------
% --- Executes on button press in startButton.
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
    setLocalBatch(progmanager, hObject, 'traceLengthArray', [], 'segmentedAcquisition', 0, 'transmissionsRemainingCounter', 0);
    shared_Start(hObject);%TO101707F
else
    setLocal(progmanager, hObject, 'stopRequested', 1);%TO021610J
    shared_Stop(hObject);%TO101707F
end

return;

%---------------------------------------------------------------------------
function selfTrigger_Callback(hObject, eventdata, handles)

setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Inactive');
setLocal(progmanager, hObject, 'externalTrigger', 0);
setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');

return;

%---------------------------------------------------------------------------
%TO022010B - Removed the pulseName condition (`if ~startButton && ~isempty(pulseName)`). -- Tim O'Connor 2/20/10
function externalTrigger_Callback(hObject, eventdata, handles)
% fprintf(1, 'stimulator.m/externalTrigger_Callback\n');

%TO031610D - Check for a loaded pulse set before continuing. -- Tim O'Connor 3/16/10
[stimOnArray, pulseSetDir] = getLocalBatch(progmanager, hObject, 'stimOnArray', 'pulseSetDir');
if any(stimOnArray)
    if exist(pulseSetDir, 'dir') ~= 7
        loadPulseSetItem_Callback(hObject, eventdata, handles);
        setLocal(progmanager, hObject, 'externalTrigger', 0);
        return;
    end
end

%TO032406E: Watch out for errors here, make sure the button stays available, in case of an error. -- Tim O'Connor 3/24/06
try
    %TO010506C - Rework triggering scheme for ease of use and simpler looping. -- Tim O'Connor 1/5/06
    [startButton, pulseName, externalTrigger] = getLocalBatch(progmanager, hObject, 'startButton', 'pulseName', 'externalTrigger');
    if externalTrigger
% fprintf(1, 'stim: externalTrigger = ''On''\n');
        setLocalGh(progmanager, hObject, 'externalTrigger', 'ForegroundColor', [1 0 0]);
        setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
        setLocal(progmanager, hObject, 'selfTrigger', 0);
        if ~startButton
% fprintf(1, 'stim: externalTrigger starting task...\n');
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Off');
            shared_Start(hObject);%TO101707F
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
        end
    else
% fprintf(1, 'stim: externalTrigger = ''Off''\n');
        setLocalGh(progmanager, hObject, 'externalTrigger', 'ForegroundColor', [0 0.6 0]);
        if ~isempty(pulseName)
            setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
        else
            setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
        end
        setLocal(progmanager, hObject, 'selfTrigger', 1);
        if startButton
% fprintf(1, 'stim: externalTrigger stopping task...\n');
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Off');
            segmentedAcquisition = getLocal(progmanager, hObject, 'segmentedAcquisition');%TO080306A
            shared_Stop(hObject);%TO101707F
            setLocal(progmanager, hObject, 'segmentedAcquisition', segmentedAcquisition);%TO080306A
            setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
        end
    end
catch
    warning('An error occured while updating the externalTrigger setting for the stimulator: %s', getLastErrorStack);
    setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
end
% setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Inactive');
% setLocal(progmanager, hObject, 'selfTrigger', 0);
% setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'On');

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseSetName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
%TO112105A - This function was cut & pasted from ephys.m, with some editting as needed.
% --- Executes on selection change in pulseSetName.
function pulseSetName_Callback(hObject, eventdata, handles)
shared_pulseSetNameCallback(hObject);%TO101707F
return;
% [currentDir pulseSetName ampIndex pulseSetNameArray pulseNameArray stimOnArray] = ...
%     getLocalBatch(progmanager, hObject, 'pulseSetDir', 'pulseSetName', 'channelList', 'pulseSetNameArray', 'pulseNameArray', 'stimOnArray');
% 
% if isempty(currentDir) | exist(currentDir) ~= 7
%     warndlg('A pulse directory must be selected before new pulses may be accessed.');
%     error('No pulse directory selected. Can not load pulse.');
% end
% 
% pulseNameArray{ampIndex} = '';
% pulseSetNameArray{ampIndex} = pulseSetName;
% setLocalBatch(progmanager, hObject, 'pulseSetNameArray', pulseSetNameArray, 'pulseNameArray', pulseNameArray);
% 
% %TO022406D
% shared_pulseCreation(hObject);%TO101707F
% % pulseNames = {''};
% % if ~isempty(pulseSetName)
% %     signalList = dir(fullfile(currentDir, pulseSetName, '*.signal'));
% %     for i = 1 : length(signalList)
% %         if ~signalList(i).isdir
% %             pulseNames{length(pulseNames) + 1} = signalList(i).name(1 : length(signalList(i).name) - 7);
% %         end
% %     end
% % end
% % 
% % if length(pulseNames) > 1
% %     setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);
% %     setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'On');
% %     %TO100305A
% %     setLocal(progmanager, hObject, 'pulseNumber', '');
% %     setLocalGh(progmanager, hObject, 'pulseNumber', 'Enable', 'On');
% %     setLocalGh(progmanager, hObject, 'pulseNumberSliderDown', 'Enable', 'On');
% % else
% %     setLocalGh(progmanager, hObject, 'pulseName', 'String', {''});
% %     setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'Off');
% %     %TO100305A
% %     setLocal(progmanager, hObject, 'pulseNumber', '');
% %     setLocalGh(progmanager, hObject, 'pulseNumber', 'Enable', 'Off');
% %     setLocalGh(progmanager, hObject, 'pulseNumberSliderDown', 'Enable', 'Off');
% % end
% 
% %TO100605C (see TO092605I): Automatically disable stimulation when no valid pulse is selected.
% % stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
% stimOnArray(ampIndex) = 0;
% 
% setLocalBatch(progmanager, hObject, 'pulseSelectionHasChanged', 1, 'pulseName', '', 'stimOn', 0, 'stimOnArray', stimOnArray);%TO100605C
% 
% return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
%TO112105A - This function was cut & pasted from ephys.m, with some editting as needed.
%TO090806A - Update the loaded signal if set to externalTrigger mode. -- Tim O'Connor 9/8/06
% --- Executes on selection change in pulseName.
function pulseName_Callback(hObject, eventdata, handles)
shared_pulseNameCallback(hObject);
return;
% [directory, pulseSetName, pulseName, pulseNameArray, chanIndex, externalTrigger, channels, traceLength, pulseSetNameArray, pulseNameArray, sampleRate, pulseParameters] = getLocalBatch(progmanager, hObject, ...
%     'pulseSetDir', 'pulseSetName', 'pulseName', 'pulseNameArray', 'channelList', 'externalTrigger', 'channels', 'traceLength', 'pulseSetNameArray', 'pulseNameArray', 'sampleRate', 'pulseParameters');%TO090806A
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
% pulseNameArray{chanIndex} = pulseName;
% setLocal(progmanager, hObject, 'pulseNameArray', pulseNameArray);
% %TO092605I: Automatically enable stimulation when a valid pulse is selected.
% if ~isempty(pulseName)
%     stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
%     stimOnArray(chanIndex) = 1;
%     setLocalBatch(progmanager, hObject, 'stimOn', 1, 'stimOnArray', stimOnArray);
% else
%     stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
%     stimOnArray(chanIndex) = 0;
%     setLocalBatch(progmanager, hObject, 'stimOn', 0, 'stimOnArray', stimOnArray);    
% end
% 
% setLocal(progmanager, hObject, 'pulseSelectionHasChanged', 1);
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
%         sig = getPulse(pm, channels(chanIndex).channelName);
%         clearByName(pm, channels(chanIndex).channelName);
%         delete(sig);
%     catch
%         warning('stimulator - Failed to properly delete previously loaded pulse from channel ''%s'': %s', channels(chanIndex).channelName, lasterr);
%     end
%     try
%         filename = fullfile(directory, pulseSetNameArray{chanIndex}, [pulseNameArray{chanIndex} '.signal']);
%         s = load(filename, '-mat');
%         set(s.signal, 'SampleRate', sampleRate, 'deleteChildrenAutomatically', 1);
%         setPulse(pm, channelName, s.signal);
%     catch
%         warning('stimulator - Failed to properly bind new pulse to channel ''%s'': %s', channelName, lasterr);
%     end
%     try
%         pulseParameters{ampIndex} = toStruct(s.signal);
%         setLocal(progmanager, hObject, 'pulseParameters', pulseParameters);
%     catch
%         warning('stimulator - Failed to properly insert pulse parameters for channel ''%s'' into header: %s', channels(chanIndex).channelName, lasterr);
%     end
%     try
%         d = getdata(s.signal, traceLength);
%         data = applyPreprocessor(aom, channels(chanIndex).channelName, d);
%         %figure, plot(d);
%         putDaqDataRetriggered(getDaqmanager, channels(chanIndex).channelName, data);
%     catch
%         warning('stimulator - Failed to online update pulse for channel ''%s'': %s', channels(chanIndex).channelName, lasterr);
%     end
% end

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function channelList_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
%TO112105A - This function was cut & pasted from ephys.m, with some editting as needed.
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
shared_selectChannel(hObject, channelList);%TO101707F

return;

% --------------------------------------------------------------------
%TO112105A - This function was cut & pasted from ephys.m, with some editting as needed.
% --- Executes on button press in stimOn.
function stimOn_Callback(hObject, eventdata, handles)

%TO031610D - Check for a loaded pulse set before continuing. -- Tim O'Connor 3/16/10
if exist(getLocal(progmanager, hObject, 'pulseSetDir'), 'dir') ~= 7
    loadPulseSetItem_Callback(hObject, eventdata, handles);
end

stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
index = getLocal(progmanager, hObject, 'channelList');
stimOnArray(index) = getLocal(progmanager, hObject, 'stimOn');

%TO080108H - For now, when digital channels are on the same port, they all have to be on or all off, no mixing and matching.
channelNames = getLocalGh(progmanager, hObject, 'channelList', 'String');
physicalChannel = getDeviceNameByChannelName(daqjob('acquisition'), channelNames{index});
if ~isempty(findstr(physicalChannel, 'port'))
    %It's a digital channel.
    actualChannel = getChannelNameByDeviceName(daqjob('acquisition'), physicalChannel);
    if ~strcmpi(actualChannel, channelNames{index})
        %We are using a pseudochannel, so there may be other lines mapped to this channel.
        pseudoNames = getPseudoNamesByChannelName(daqjob('acquisition'), actualChannel);
        for i = 1 : length(pseudoNames)
            idx = find(strcmpi(channelNames, pseudoNames{i}));
            if ~isempty(idx)
                stimOnArray(idx) = stimOnArray(index);
            end
        end
    end
end

setLocal(progmanager, hObject, 'stimOnArray', stimOnArray);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function extraGain_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
function extraGain_Callback(hObject, eventdata, handles)

extraGainArray = getLocal(progmanager, hObject, 'extraGainArray');
index = getLocal(progmanager, hObject, 'channelList');
extraGainArray(index) = getLocal(progmanager, hObject, 'extraGain');
setLocal(progmanager, hObject, 'extraGainArray', extraGainArray);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function traceLength_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
function traceLength_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseNumberSliderDown_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
%TO112105A - This function was cut & pasted from ephys.m, with some editting as needed.
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
%TO112105A - This function was cut & pasted from ephys.m, with some editting as needed.
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
%TO112105A - This function was cut & pasted from ephys.m, with some editting as needed.
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

% --------------------------------------------------------------------
%TO112105A - This function was cut & pasted from ephys.m, with some editting as needed.
%  TO031610C - Make sure default pulses exist, and map them to channels that don't have anything. -- Tim O'Connor 03/16/10
%  TO061110A - Moved TO031610C because it was happening at the wrong time.
function loadPulseSetItem_Callback(hObject, eventdata, handles)

[currentDir, stimOnArray] = getLocalBatch(progmanager, hObject, 'pulseSetDir', 'stimOnArray');%TO031306F
if isempty(currentDir) || exist(currentDir, 'dir') ~= 7
    currentDir = getDefaultCacheDirectory(progmanager, 'pulseDir');%TO120705D %TO030906
end
%TO030906A
% if isempty(currentDir) | exist(currentDir) ~= 7
%     currentDir = pwd;
% end
pulseSetDir = uigetdir(currentDir, 'Choose a directory containing pulses.');
%TO090706G - Watch out for cancellations. TO123005L
if length(pulseSetDir) == 1
    if pulseSetDir == 0
        if exist(currentDir, 'dir') ~= 7
            setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
        end
        return;
    end
end
if exist(pulseSetDir, 'dir') ~= 7
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
    return;
end
setLocal(progmanager, hObject, 'pulseSetDir', pulseSetDir);

setDefaultCacheValue(progmanager, 'pulseDir', pulseSetDir);%TO120705D

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

[pulseSetNameArray, pulseNameArray, pulseSelectionHasChanged, channelIndex] = getLocalBatch(progmanager, hObject, ...
    'pulseNameArray', 'pulseSetNameArray', 'pulseSelectionHasChanged', 'channelList');
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
setLocalBatch(progmanager, hObject, 'pulseSetName', pulseSetNameArray{channelIndex}, ...
    'pulseSetNameArray', pulseSetNameArray, 'pulseSelectionHasChanged', pulseSelectionHasChanged);
pulseSetName_Callback(hObject, eventdata, handles);
setLocalBatch(progmanager, hObject, 'pulseNameArray', pulseNameArray, 'pulseName', pulseNameArray{channelIndex});
pulseName_Callback(hObject, eventdata, handles);

%TO031306F
if ~isempty(stimOnArray)
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
end

return;

% --- Executes on slider movement.
%TO081606E - This function was cut & pasted from pulseNumberSliderDown_Callback, with some editting as needed.
function pulseNumberSliderUp_Callback(hObject, eventdata, handles)

%TO081606E - Slider functionality changed as of Matlab 7, invalidating most slider code. -- Tim O'Connor 8/16/06
[pulseNumber] = getLocalBatch(progmanager, hObject, 'pulseNumber');

pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
if isempty(pulseNumber)
    if pulseNumberSlider < pulseNumberSliderLast || pulseNumberSlider == 0
        return;
    end
    
    num = [];
    i = 1;
    while isempty(num) && i <= length(pulseNames)
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
% hObject    handle to pulseNumberSliderUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% -------------------------------------------------------------------
function pmExtTriggerSource_Callback(hObject, eventdata, handles)
shared_extTriggerSourceUpdate(hObject); %VI102408A: This shared function handles change to external trigger, by any user of the 'shared' daqjob



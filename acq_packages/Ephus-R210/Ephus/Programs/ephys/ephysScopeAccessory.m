% ephysScopeAccessory - An add-on GUI for adding physiology scope functionality to a scopeGui.
%
% SYNTAX
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 2/9/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = ephysScopeAccessory(varargin)
% EPHYSSCOPEACCESSORY M-file for ephysScopeAccessory.fig
%      EPHYSSCOPEACCESSORY, by itself, creates a new EPHYSSCOPEACCESSORY or raises the existing
%      singleton*.
%
%      H = EPHYSSCOPEACCESSORY returns the handle to a new EPHYSSCOPEACCESSORY or the handle to
%      the existing singleton*.
%
%      EPHYSSCOPEACCESSORY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EPHYSSCOPEACCESSORY.M with the given input arguments.
%
%      EPHYSSCOPEACCESSORY('Property','Value',...) creates a new EPHYSSCOPEACCESSORY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ephysScopeAccessory_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ephysScopeAccessory_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ephysScopeAccessory

% Last Modified by GUIDE v2.5 03-Apr-2013 16:15:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ephysScopeAccessory_OpeningFcn, ...
                   'gui_OutputFcn',  @ephysScopeAccessory_OutputFcn, ...
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
% --- Executes just before ephysScopeAccessory is made visible.
function ephysScopeAccessory_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

return;

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = ephysScopeAccessory_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'scopeObject', [], ... %VI060108A
       'startButton', 0, 'Class', 'Numeric', 'Gui', 'startButton', ...
       'sampleRate', 10000, 'Class', 'Numeric', 'Gui', 'sampleRate', ...
       'testPulses', [], ...
       'outputChannels', {}, ...
       'inputChannels', {}, ...
       'expandWindow', 0, 'Class', 'Numeric', 'Gui', 'expandWindow', ...
       'vClampAmplitude', -5, 'Class', 'Numeric', 'Gui', 'vClampAmplitude', ...
       'vClampAmplitudeArray', [], 'Class', 'Numeric', 'Config', 1, ...
       'iClampAmplitude', 100, 'Class', 'Numeric', 'Gui', 'iClampAmplitude', ...
       'iClampAmplitudeArray', [], 'Class', 'Numeric', 'Config', 1, ...
       'vClampDuration', 0.05, 'Class', 'Numeric', 'Gui', 'vClampDuration', ...
       'vClampDurationArray', [], 'Class', 'Numeric', 'Config', 1, ...
       'iClampDuration', 0.01, 'Class', 'Numeric', 'Gui', 'iClampDuration', ...
       'iClampDurationArray', [], 'Class', 'Numeric', 'Config', 1, ...
       'amplifierList', 1, 'Class', 'Numeric', 'Gui', 'amplifierList', ...
       'amplitudes', [], ...
       'durations', [], ...
       'amplifiers', [], ...
       'selfTrigger', 1, 'Class', 'Numeric', 'Gui', 'selfTrigger', ...
       'externalTrigger', 0, 'Class', 'Numeric', 'Gui', 'externalTrigger', ...
       'stimOnArray', [], 'Config', 1, ...
       'stimOn', 0, 'Class', 'Numeric', 'Gui', 'stimOn', ...
       'acqOnArray', [], 'Config', 1, ...
       'acqOn', 0, 'Class', 'Numeric', 'Gui', 'acqOn', ...
       'averageArray', [], ...
       'averageOn', 0, 'Class', 'Numeric', 'Gui', 'averageOn', ...
       'pulseTime', -1, ...
       'sweepRate', 5, 'Class', 'Numeric', 'Min', 0, 'Gui', 'sweepRate', 'Config', 5, ...
       'mode', 'V-Clamp', 'Class', 'Char', 'Gui', 'mode', ...
       'stopPending', 0, 'Class', 'Numeric', ...
       'seriesResistance', NaN, 'Class', 'Numeric', 'Gui', 'seriesResistance', ...
       'membraneResistance', NaN, 'Class', 'Numeric', 'Gui', 'membraneResistance', ...
       'membraneCapacitance', NaN, 'Class', 'Numeric', 'Gui', 'membraneCapacitance', ...
       'accessResistance', NaN, 'Class', 'Numeric', 'Gui', 'accessResistance', ...
       'lastCalcCellParamsTime', clock, 'Class', 'Numeric', ...
       'calcCellParams', 1, 'Class', 'Numeric', 'Gui', 'calcCellParams', ...
       'scopeObjectGuiProps', [], 'Config', 1, ...
       'breakInTime', [], 'Class', 'Numeric', 'Config', 2, ...
       'breakIn', 0, 'Class', 'Numeric', 'Gui', 'breakIn', ...
       'startID', 0, 'Class', 'Numeric', ...
       'restarting', 0, 'Class', 'Numeric', ...
       'restart', 0, 'Class', 'Numeric', ...
       'channels', [], ...
       'channelList', [], ...
       'showStimArray', [], ...
       'pulseNameArray', {}, ...
       'pulseSetNameArray', {}, ...
       'pulseName', '', ...
       'pulseSetName', '', ...
       'extraGainArray', [], ...
       'showStimArray', [], ...
       'zeroChannelsOnStop', 1, ...
       'clearBuffersWhenNotRunning', 0, ...
       'updateRate', 1, ...
       'autoDisplayWidth', 0, ...
       'displayWidth', 0, ...
       'continuousAcqMode', 0, ...
       'sampleCount', 0, ...
       'stopRequested', 0, ...
       'vClampPresets', [-5, 0], 'Config', 5, ...
       'iClampPresets', [100, 250], 'Config', 5, ...
       'clearBuffersOnGetData', 1,  'Config', 5, ...
       'disableHandles', [], ...
       'updateRate', [], ...
       'autoUpdateRate', [], ...
       'displayWidth', [], ...
       'autoDisplayWidth', [], ...
       'dataToBeSaved', 0, ...
       'freezeButton', 0, 'Class', 'Numeric', 'Gui', 'freezeButton', ...        % added by AJG 04.03.2013
   };

return;

% ------------------------------------------------------------------
%De facto 'constructor' for ephysScopeAccessory program
%Constructor Arguments:
%   amplifierArray: a cell array of @amplifier objects
function genericStartFcn(hObject, eventdata, handles, varargin)

%TO093005A - Allow visibility toggling of all windows.
% set(getParent(hObject, 'figure'), 'CloseRequestFcn', 'ephysScopeAccessory(''closeWindow_Callback'', gcbo, [], guidata(gcbo))');
% set(getMain(progmanager, hObject, 'hObject'), 'CloseRequestFcn', 'set(gcbo, ''Visible'', ''Off'');');
set(getMain(progmanager, hObject, 'hObject'), 'Visible', 'Off');
setWindowsMenuItems(progmanager, 'toggle');

% ephysAcc_configureAimux(hObject);
% ephysAcc_configureAomux(hObject);

%VI060108A -- Handle initialization via a constructor argument
if ~isempty(varargin)
    ephysAcc_setAmplifiers(hObject, varargin{1});
end

%VI060108A -- Commented out, pushed to ephysAcc_setAmplifiers
% sc = getMain(progmanager, hObject, 'scopeObject');
% set(sc, 'Name', 'Oscilloscope', 'autoRangeUseWaveScaling', 1);%TO120205A, TO121405B, TO121905A
% % set(sc, 'Name', 'Oscilloscope');
% updateDisplayOptions(sc);
%%%END VI060108A

%TO010506C - Rework triggering scheme for ease of use and simpler looping. -- Tim O'Connor 1/5/06
externalTrigger_Callback(hObject, eventdata, handles);


return;

% ------------------------------------------------------------------
function closeWindow_Callback(hObject, eventdata, handles)

%Switch the closing control to this GUI, instead of the scopeGui's main window.
closeprogram(progmanager, getMain(progmanager, hObject, 'hObject'));

return;

% ------------------------------------------------------------------
%TO021610K - Allow the presets to be programmable.
function genericUpdateFcn(hObject, eventdata, handles)

% ephysAcc_configureAimux(hObject);
% ephysAcc_configureAomux(hObject);
[vClampPresets, iClampPresets] = getLocalBatch(progmanager, hObject, 'vClampPresets', 'iClampPresets');
setLocalGh(progmanager, hObject, 'vClampPreset1', 'String', num2str(vClampPresets(1)));
setLocalGh(progmanager, hObject, 'vClampPreset2', 'String', num2str(vClampPresets(2)));
setLocalGh(progmanager, hObject, 'iClampPreset1', 'String', num2str(iClampPresets(1)));
setLocalGh(progmanager, hObject, 'iClampPreset2', 'String', num2str(iClampPresets(2)));

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.4;

return;

%------------------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

props = [];
sc = getMain(progmanager, hObject, 'scopeObject');
for i = 1 : length(sc)
    f = get(sc(i), 'figure');
    props(i).position = get(f, 'Position');
    props(i).visible = get(f, 'Visible');
end
setLocal(progmanager, hObject, 'scopeObjectGuiProps', props);

return;

%------------------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

return;

%------------------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

%TO040706D - Make sure the scope is stopped before changing settings. -- Tim O'Connor 4/7/06
ephysAcc_stop(hObject);%TO071906A: Case-sensitivity for Matlab 7.2

return;

%------------------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles)

%TO121307E
shared_configurationUpdate(hObject);
[vClampAmplitudeArray, iClampAmplitudeArray, vClampDurationArray, iClampDurationArray, averageArray, amplifiers] = getLocalBatch(progmanager, hObject, ...
    'vClampAmplitudeArray', 'iClampAmplitudeArray', 'vClampDurationArray', 'iClampDurationArray', 'averageArray', 'amplifiers');
if length(vClampAmplitudeArray) < length(amplifiers)
    vClampAmplitudeArray(end+1 : length(amplifiers)) = 0;
elseif length(vClampAmplitudeArray) > length(amplifiers)
    vClampAmplitudeArray = vClampAmplitudeArray(1 : length(amplifiers));
end
if length(iClampAmplitudeArray) < length(amplifiers)
    iClampAmplitudeArray(end+1 : length(amplifiers)) = 0;
elseif length(iClampAmplitudeArray) > length(amplifiers)
    iClampAmplitudeArray = iClampAmplitudeArray(1 : length(amplifiers));
end
if length(vClampDurationArray) < length(amplifiers)
    vClampDurationArray(end+1 : length(amplifiers)) = 0;
elseif length(vClampDurationArray) > length(amplifiers)
    vClampDurationArray = vClampDurationArray(1 : length(amplifiers));
end
if length(iClampDurationArray) < length(amplifiers)
    iClampDurationArray(end+1 : length(amplifiers)) = 0;
elseif length(iClampDurationArray) > length(amplifiers)
    iClampDurationArray = iClampDurationArray(1 : length(amplifiers));
end
if length(averageArray) < length(amplifiers)
    averageArray(end+1 : length(amplifiers)) = 0;
elseif length(averageArray) > length(amplifiers)
    averageArray = averageArray(1 : length(amplifiers));
end
setLocalBatch(progmanager, hObject, 'vClampAmplitudeArray', vClampAmplitudeArray, 'iClampAmplitudeArray', iClampAmplitudeArray, ...
    'vClampDurationArray', vClampDurationArray, 'iClampDurationArray', iClampDurationArray, 'averageArray', averageArray, 'amplifiers', amplifiers);

props = getLocal(progmanager, hObject, 'scopeObjectGuiProps');
sc = getMain(progmanager, hObject, 'scopeObject');
if length(sc) == length(props)
    for i = 1 : length(props)
        f = get(sc(i), 'figure');
        set(f, 'Position', props(i).position);
        set(sc(i), 'Visible', props(i).visible);
    end
else
    fprintf('Warning (ephysScopeAccessory): Configuration does not contain the right amount of metadata for the current number of scope displays, ignoring display position and visibility settings.\n ScopeObjects: %s\n ScopeObject metadata: %s\n', ...
        num2str(length(sc)), num2str(length(props)));
end

%TO010506C - Rework triggering scheme for ease of use and simpler looping. -- Tim O'Connor 1/5/06
externalTrigger_Callback(hObject, eventdata, handles);

amplifierList_Callback(hObject, eventdata, handles);%TO050806E

genericUpdateFcn(hObject, [], []);%TO021610K - Allow the presets to be programmable.

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

errordlg('Open is not supported by this GUI.');

return;

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

errordlg('Save is not supported by this GUI.');

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

errordlg('Save As is not supported by this GUI.');

return;

% ------------------------------------------------------------------
% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)

% ephysAcc_updateInput(hObject);
% ephysAcc_updateOutput(hObject);

if getLocal(progmanager, hObject, 'startButton')
    ephysAcc_start(hObject);
else
    ephysAcc_stop(hObject);
end

return;

%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function sampleRate_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%---------------------------------------------------------------------------
function sampleRate_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'startButton')
    ephysAcc_stop(hObject);

    ephysAcc_updateOutput(hObject, getLocal(progmanager, hObject, 'amplifierList'));
    ephysAcc_updateInput(hObject, getLocal(progmanager, hObject, 'amplifierList'));

    ephysAcc_start(hObject);
else
    ephysAcc_updateOutput(hObject, getLocal(progmanager, hObject, 'amplifierList'));
    ephysAcc_updateInput(hObject, getLocal(progmanager, hObject, 'amplifierList'));
end

if getLocal(progmanager, hObject, 'startButton')
    ephysAcc_stop(hObject);
    ephysAcc_start(hObject);
end

return;

%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function vClampDuration_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%---------------------------------------------------------------------------
function vClampDuration_Callback(hObject, eventdata, handles)

index = getLocal(progmanager, hObject, 'amplifierList');
array = getLocal(progmanager, hObject, 'vClampDurationArray');
array(index) = getLocal(progmanager, hObject, 'vClampDuration');
setLocal(progmanager, hObject, 'vClampDurationArray', array);
% ephysAcc_updateOutput(hObject, getLocal(progmanager, hObject, 'amplifierList'));

amplifiers = getLocal(progmanager, hObject, 'amplifiers');
stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
ampIndex = getLocal(progmanager, hObject, 'amplifierList');

%TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
if getLocal(progmanager, hObject, 'startButton') && ~get(amplifiers{ampIndex}, 'current_clamp') && ...
        stimOnArray(ampIndex)
    ephysAcc_stop(hObject);
    ephysAcc_start(hObject);
end

return;

%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function vClampAmplitude_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%---------------------------------------------------------------------------
function vClampAmplitude_Callback(hObject, eventdata, handles)

index = getLocal(progmanager, hObject, 'amplifierList');
array = getLocal(progmanager, hObject, 'vClampAmplitudeArray');
array(index) = getLocal(progmanager, hObject, 'vClampAmplitude');
setLocal(progmanager, hObject, 'vClampAmplitudeArray', array);

% ephysAcc_updateOutput(hObject, getLocal(progmanager, hObject, 'amplifierList'));

amplifiers = getLocal(progmanager, hObject, 'amplifiers');
stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
ampIndex = getLocal(progmanager, hObject, 'amplifierList');

%TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
if getLocal(progmanager, hObject, 'startButton') && ~get(amplifiers{ampIndex}, 'current_clamp') && ...
        stimOnArray(ampIndex)
    ephysAcc_stop(hObject);
    ephysAcc_start(hObject);
end

return;

%---------------------------------------------------------------------------
% --- Executes on button press in expandWindow.
function expandWindow_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'expandWindow')
    setLocalGh(progmanager, hObject, 'expandWindow', 'String', '<<');
    f = getParent(hObject, 'figure');
    pos = get(f, 'Position');
    pos(3) = 51.2;
    set(f, 'Position', pos);
else
    setLocalGh(progmanager, hObject, 'expandWindow', 'String', '>>');
    f = getParent(hObject, 'figure');
    pos = get(f, 'Position');
    pos(3) = 21.2;
    set(f, 'Position', pos);
end

return;

%---------------------------------------------------------------------------
% --- Executes on button press in vClampPreset1.
%TO021610K - Allow the presets to be programmable.
function vClampPreset1_Callback(hObject, eventdata, handles)

vClampPresets = getLocal(progmanager, hObject, 'vClampPresets');
setLocal(progmanager, hObject, 'vClampAmplitude', vClampPresets(1));
vClampAmplitude_Callback(hObject, eventdata, handles);

% if getLocal(progmanager, hObject, 'startButton')
%     ephysAcc_stop(hObject);
%     ephysAcc_start(hObject);
% end

return;

%---------------------------------------------------------------------------
% --- Executes on button press in vClampPreset2.
%TO021610K - Allow the presets to be programmable.
function vClampPreset2_Callback(hObject, eventdata, handles)

vClampPresets = getLocal(progmanager, hObject, 'vClampPresets');
setLocal(progmanager, hObject, 'vClampAmplitude', vClampPresets(2));
vClampAmplitude_Callback(hObject, eventdata, handles);

% if getLocal(progmanager, hObject, 'startButton')
%     ephysAcc_stop(hObject);
%     ephysAcc_start(hObject);
% end

return;

%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function iClampDuration_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%---------------------------------------------------------------------------
function iClampDuration_Callback(hObject, eventdata, handles)

index = getLocal(progmanager, hObject, 'amplifierList');
array = getLocal(progmanager, hObject, 'iClampDurationArray');
array(index) = getLocal(progmanager, hObject, 'iClampDuration');
setLocal(progmanager, hObject, 'iClampDurationArray', array);

% ephysAcc_updateOutput(hObject, getLocal(progmanager, hObject, 'amplifierList'));

amplifiers = getLocal(progmanager, hObject, 'amplifiers');
stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
ampIndex = getLocal(progmanager, hObject, 'amplifierList');

%TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
if getLocal(progmanager, hObject, 'startButton') && get(amplifiers{ampIndex}, 'current_clamp') && ...
        stimOnArray(ampIndex)
    ephysAcc_stop(hObject);
    ephysAcc_start(hObject);
end

return;

%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function iClampAmplitude_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%---------------------------------------------------------------------------
function iClampAmplitude_Callback(hObject, eventdata, handles)

index = getLocal(progmanager, hObject, 'amplifierList');
array = getLocal(progmanager, hObject, 'iClampAmplitudeArray');
array(index) = getLocal(progmanager, hObject, 'iClampAmplitude');
setLocal(progmanager, hObject, 'iClampAmplitudeArray', array);

% ephysAcc_updateOutput(hObject, getLocal(progmanager, hObject, 'amplifierList'));
amplifiers = getLocal(progmanager, hObject, 'amplifiers');
stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
ampIndex = getLocal(progmanager, hObject, 'amplifierList');

%TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
if getLocal(progmanager, hObject, 'startButton') && get(amplifiers{ampIndex}, 'current_clamp') && ...
        stimOnArray(ampIndex)
    ephysAcc_stop(hObject);
    ephysAcc_start(hObject);
end

return;

%---------------------------------------------------------------------------
% --- Executes on button press in iClampPreset1.
%TO021610K - Allow the presets to be programmable.
function iClampPreset1_Callback(hObject, eventdata, handles)

iClampPresets = getLocal(progmanager, hObject, 'iClampPresets');
setLocal(progmanager, hObject, 'iClampAmplitude', iClampPresets(1));
iClampAmplitude_Callback(hObject, eventdata, handles);

return;

%---------------------------------------------------------------------------
% --- Executes on button press in iClampPreset2.
%TO021610K - Allow the presets to be programmable.
function iClampPreset2_Callback(hObject, eventdata, handles)

iClampPresets = getLocal(progmanager, hObject, 'iClampPresets');
setLocal(progmanager, hObject, 'iClampAmplitude', iClampPresets(2));
iClampAmplitude_Callback(hObject, eventdata, handles);

return;

%---------------------------------------------------------------------------
function triggerButtonGroup_CreateFcn(hObject, eventdata, handles)

set(hObject, 'SelectionChangeFcn', 'ephysScopeAccessory(''triggerButtonGroup_Callback'', gcbo, [], guidata(gcbo))');

return;

%---------------------------------------------------------------------------
% --- Executes on button press in iClampPreset2.
function triggerButtonGroup_Callback(hObject, eventdata, handles)
return;

%---------------------------------------------------------------------------
% --- Executes on selection change in amplifierList.
function amplifierList_Callback(hObject, eventdata, handles)
    ephysAcc_selectAmplifier(hObject, getLocal(progmanager, hObject, 'amplifierList'));
return;

%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function amplifierList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%---------------------------------------------------------------------------
% --- Executes on button press in stimOn.
function stimOn_Callback(hObject, eventdata, handles)

index = getLocal(progmanager, hObject, 'amplifierList');
stimOnArray = getLocal(progmanager, hObject, 'stimOnArray');
stimOnArray(index) = getLocal(progmanager, hObject, 'stimOn');
setLocal(progmanager, hObject, 'stimOnArray', stimOnArray);

if getLocal(progmanager, hObject, 'startButton')
    ephysAcc_stop(hObject);
    ephysAcc_updateOutput(hObject, index);
    ephysAcc_start(hObject);
end

return;

%---------------------------------------------------------------------------
% --- Executes on button press in acqOn.
function acqOn_Callback(hObject, eventdata, handles)

index = getLocal(progmanager, hObject, 'amplifierList');
acqOnArray = getLocal(progmanager, hObject, 'acqOnArray');
acqOnArray(index) = getLocal(progmanager, hObject, 'acqOn');
setLocal(progmanager, hObject, 'acqOnArray', acqOnArray);

if getLocal(progmanager, hObject, 'startButton')
    ephysAcc_stop(hObject);
    ephysAcc_updateInput(hObject, index);    
    ephysAcc_start(hObject);
end

return;

%---------------------------------------------------------------------------
% --- Executes on button press in averageOn.
function averageOn_Callback(hObject, eventdata, handles)

warndlg('FEATURE_NOT_YET_IMPLEMENTED_IN_GUI');

return;

%---------------------------------------------------------------------------
function configurationMenu_Callback(hObject, eventdata, handles)

return;

%---------------------------------------------------------------------------
function configureAmplifier_Callback(hObject, eventdata, handles)

index = getLocal(progmanager, hObject, 'amplifierList');
amplifiers = getLocal(progmanager, hObject, 'amplifiers');
configureAmplifier(amplifiers{index});%TO120205A

return;

%---------------------------------------------------------------------------
function sweepRate_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%---------------------------------------------------------------------------
function sweepRate_Callback(hObject, eventdata, handles)

%TO092805B: Update input only when not running. -- Tim O'Connor 9/28/05
setLocal(progmanager, hObject, 'sweepRate', min(10, roundTo(getLocal(progmanager, hObject, 'sweepRate'), 4)));

if getLocal(progmanager, hObject, 'startButton')
    ephysAcc_stop(hObject);
    ephysAcc_updateInput(hObject);
    ephysAcc_start(hObject);
else
    ephysAcc_updateInput(hObject);
end

return;

%---------------------------------------------------------------------------
function selfTrigger_Callback(hObject, eventdata, handles)

setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'On');
setLocal(progmanager, hObject, 'externalTrigger', 0);

return;

%---------------------------------------------------------------------------
function externalTrigger_Callback(hObject, eventdata, handles)

%TO040706E: Remove external trigger functionality from the scope entirely. -- Tim O'Connor 4/7/06
setLocal(progmanager, hObject, 'externalTrigger', 0);
setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Off', 'Visible', 'Off');
return;

%TO010506C - Rework triggering scheme for ease of use and simpler looping. -- Tim O'Connor 1/5/06
if getLocal(progmanager, hObject, 'externalTrigger')
    setLocalGh(progmanager, hObject, 'externalTrigger', 'ForegroundColor', [1 0 0]);
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'Off');
    setLocal(progmanager, hObject, 'selfTrigger', 0);
    if ~getLocal(progmanager, hObject, 'startButton')
        ephysAcc_start(hObject);%TO071906A: Case-sensitivity for Matlab 7.2
    end
else
    setLocalGh(progmanager, hObject, 'externalTrigger', 'ForegroundColor', [0 0.6 0]);
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
    setLocal(progmanager, hObject, 'selfTrigger', 1);
    if getLocal(progmanager, hObject, 'startButton')
        ephysAcc_stop(hObject);%TO071906A: Case-sensitivity for Matlab 7.2
    end
end
% setLocalGh(progmanager, hObject, 'externalTrigger', 'Enable', 'Inactive');
% setLocalGh(progmanager, hObject, 'selfTrigger', 'Enable', 'On');
% setLocal(progmanager, hObject, 'selfTrigger', 0);

return;

%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mode_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%---------------------------------------------------------------------------
function mode_Callback(hObject, eventdata, handles)

return;

%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function seriesResistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seriesResistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%---------------------------------------------------------------------------
function seriesResistance_Callback(hObject, eventdata, handles)
return;

%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function membraneResistance_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%---------------------------------------------------------------------------
function membraneResistance_Callback(hObject, eventdata, handles)
return;

%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function membraneCapacitance_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%---------------------------------------------------------------------------
function membraneCapacitance_Callback(hObject, eventdata, handles)
return;

%---------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function accessResistance_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%---------------------------------------------------------------------------
function accessResistance_Callback(hObject, eventdata, handles)

return;

%---------------------------------------------------------------------------
% --- Executes on button press in calcCellParams.
function calcCellParams_Callback(hObject, eventdata, handles)
return;

%---------------------------------------------------------------------------
% --- Executes on button press in breakIn.
function breakIn_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'breakIn')
    %TO042106E: Make the button red when not logging time. -- Tim O'Connor 4/21/06
    setLocalGh(progmanager, hObject, 'breakIn', 'String', datestr(now, 13), 'BackgroundColor',[0.8313725490196078 0.8156862745098039 0.7843137254901961]);
    setLocal(progmanager, hObject, 'breakInTime', clock);
    autonotes_addNote('BREAK_IN');%TO120905K - Insert a note upon break-in.
else
    setLocal(progmanager, hObject, 'breakInTime', []);
    %TO042106E: Make the button red when not logging time. -- Tim O'Connor 4/21/06
    setLocalGh(progmanager, hObject, 'breakIn', 'String', 'Break-In', 'BackgroundColor', [1 0 0]);
end

return;


% --- Executes on button press in freezeButton.
function freezeButton_Callback(hObject, eventdata, handles)
% hObject    handle to freezeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sc = getGlobal(progmanager, 'scopeObject', 'scopeGui', 'scopeGui');

if getLocal(progmanager, hObject, 'freezeButton')
    set(handles.freezeButton, 'String', 'Frozen')
    if getLocal(progmanager, hObject, 'startButton')
        ephysAcc_stop(hObject);
        set(get(get(sc, 'figure'), 'CurrentAxes'), 'YLimMode', 'manual')
        ephysAcc_start(hObject);
    else
        set(get(get(sc, 'figure'), 'CurrentAxes'), 'YLimMode', 'manual')
    end
else
    set(handles.freezeButton, 'String', 'Freeze')
    if getLocal(progmanager, hObject, 'startButton')
        ephysAcc_stop(hObject);
        set(get(get(sc, 'figure'), 'CurrentAxes'), 'YLimMode', 'auto')
        ephysAcc_start(hObject);
    else
        set(get(get(sc, 'figure'), 'CurrentAxes'), 'YLimMode', 'auto')
    end
end

return;
% Hint: get(hObject,'Value') returns toggle state of freezeButton


% --- Executes on button press in expandButton.
function expandButton_Callback(hObject, eventdata, handles)
% hObject    handle to expandButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sc = getGlobal(progmanager, 'scopeObject', 'scopeGui', 'scopeGui');
ylim = get(get(get(sc, 'figure'), 'CurrentAxes'), 'YLim');

yrange = ylim(2) - ylim(1);
amount_to_expand = (yrange * 0.05);

if getLocal(progmanager, hObject, 'freezeButton')
    if getLocal(progmanager, hObject, 'startButton')
        ephysAcc_stop(hObject);
        set(get(get(sc, 'figure'), 'CurrentAxes'), 'Ylim', [ylim(1)-amount_to_expand ylim(2)+amount_to_expand]);
        ephysAcc_start(hObject);
    else
        set(get(get(sc, 'figure'), 'CurrentAxes'), 'Ylim', [ylim(1)-amount_to_expand ylim(2)+amount_to_expand]);
    end
else
    parentFigureHandles = get(get(hObject, 'Parent'), 'Children');
    freezeButtonHandle = parentFigureHandles(2);  % shitty magic number here...
    set(freezeButtonHandle, 'String', 'Frozen')
    if getLocal(progmanager, hObject, 'startButton')
        ephysAcc_stop(hObject);
        setLocal(progmanager, hObject, 'freezeButton', 1);
        set(get(get(sc, 'figure'), 'CurrentAxes'), 'YLimMode', 'manual');
        set(get(get(sc, 'figure'), 'CurrentAxes'), 'Ylim', [ylim(1)-amount_to_expand ylim(2)+amount_to_expand]);
        ephysAcc_start(hObject);
    else
        setLocal(progmanager, hObject, 'freezeButton', 1);
        set(get(get(sc, 'figure'), 'CurrentAxes'), 'YLimMode', 'manual');
        set(get(get(sc, 'figure'), 'CurrentAxes'), 'Ylim', [ylim(1)-amount_to_expand ylim(2)+amount_to_expand]);
    end
end

return;

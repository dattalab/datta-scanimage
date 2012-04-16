function varargout = pulseEditor(varargin)
% PULSEEDITOR M-file for pulseEditor.fig
%      PULSEEDITOR, by itself, creates a new PULSEEDITOR or raises the existing
%      singleton*.
%
%      H = PULSEEDITOR returns the handle to a new PULSEEDITOR or the handle to
%      the existing singleton*.
%
%      PULSEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PULSEEDITOR.M with the given input arguments.
%
%      PULSEEDITOR('Property','Value',...) creates a new PULSEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pulseEditor_OpeningFunction gets called.  An
%      unrecognized property pulseName or invalid value makes property application
%      stop.  All inputs are passed to pulseEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pulseEditor

% Last Modified by GUIDE v2.5 15-Feb-2010 17:49:39

% JL112907A reset slider value to 0.5 for Matlab 7
% JL112907B reset slider value to 0.5 for Matlab 7
% JL112907C reset slider value to 0.5 for Matlab 7
% JL112907D reset slider value to 0.5 for Matlab 7
% JL112907E reset slider value to 0.5 for Matlab 7

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pulseEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @pulseEditor_OutputFcn, ...
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


% --- Executes just before pulseEditor is made visible.
function pulseEditor_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = pulseEditor_OutputFcn(hObject, eventdata, handles)
Intvarargout{1} = handles.output;

return;

%--------------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'displayFigure', [], ...
       'displayAxes', [], ...
       'displayPlot', [], ...
       'pulseSetName', {}, 'Class', 'Char', 'Gui', 'pulseSetName', 'Config', 1, ...
       'pulseName', {}, 'Class', 'Char', 'Gui', 'pulseName', 'Config', 1, ...
       'number', 0, 'Class', 'Numeric', 'Gui', 'number', 'Min', 0, ...
       'numberSlider', 0.5, 'Class', 'Numeric', 'Gui', 'numberSlider', 'Min', 0, 'Max', 1, ...
       'numberSliderLast', 0, ...
       'isi', 0, 'Class', 'Numeric', 'Gui', 'isi', 'Min', 0, ...
       'isiSlider', 0.5, 'Class', 'Numeric', 'Gui', 'isiSlider', 'Min', 0, 'Max', 1, ...
       'isiSliderLast', 0, ...
       'width', 0, 'Class', 'Numeric', 'Gui', 'width', 'Min', 0, ...
       'widthSlider', 0.5, 'Class', 'Numeric', 'Gui', 'widthSlider', 'Min', 0, 'Max', 1, ...
       'widthSliderLast', 0, ...
       'amplitude', 0, 'Class', 'Numeric', 'Gui', 'amplitude', ...
       'amplitudeSlider', 0.5, 'Class', 'Numeric', 'Gui', 'amplitudeSlider', 'Min', 0, 'Max', 1, ...
       'amplitudeSliderLast', 0, ...
       'delay', 0, 'Class', 'Numeric', 'Gui', 'delay', 'Min', 0, ...
       'delaySlider', 0.5, 'Class', 'Numeric', 'Gui', 'delaySlider', 'Min', 0, 'Max', 1, ...
       'delaySliderLast', 0, ...
       'showPlot', 0, 'Class', 'Numeric', 'Gui', 'showPlot', 'Min', 0, 'Max', 1, 'Config', 1, ...
       'directory', '', 'Class', 'Char', 'Config', 1, ...
       'autosave', 1, 'Class', 'Numeric', 'Gui', 'autosave', 'Min', 0, 'Max', 1, ...
       'currentSignal', [], ...
       'pulseNumber', 0, 'Class', 'char', 'Gui', 'pulseNumber', ...
       'pulseNumberSliderDown', 1, 'Class', 'Numeric', 'Gui', 'pulseNumberSliderDown', 'Min', 0, 'Max', 1, ...
       'pulseNumberSliderUp', 0, 'Class', 'Numeric', 'Gui', 'pulseNumberSliderUp', 'Min', 0, 'Max', 1, ...
       'autoSortPulseNames', 1, 'Class', 'Numeric', 'Gui', 'autoSortPulseNames', ...
       'childPulseSetName', {}, 'Class', 'char', 'Gui', 'childPulseSetName', ...
       'childPulseName', {}, 'Class', 'char', 'Gui', 'childPulseName', ...
       'children', {}, 'Class', 'char', 'Gui', 'children', ...
       'childPulseNumber', '', 'Class', 'char', 'Gui', 'childPulseNumber', ...
       'childPulseNumberSlider', 0, 'Class', 'Numeric', 'Gui', 'childPulseNumberSlider', ...
       'childPulseNumberSliderLast', 0, 'Class', 'Numeric', ...
       'method', '+', 'Class', 'char', 'Gui', 'method', ...
       'advancedInterface', 0, 'Class', 'Numeric', 'Gui', 'advancedInterface', ...
       'handicappedInterface', 1, 'Class', 'Numeric', 'Gui', 'handicappedInterface', ...
       'additive', 0, 'Class', 'Numeric', 'Gui', 'additive', ...
       'displayTimeWidth', 500, 'Class', 'Numeric', 'Gui', 'displayTimeWidth', 'Min', 0, 'Config', 1, ...
       'callbackManager', [], ...
       'displayFigureProps', [], ...
       'batchEditorHandle', [], ...
   };

return;

%--------------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

cbm = callbackmanager;
setLocal(progmanager, hObject, 'callbackManager', cbm);
addEvent(cbm, 'pulseCreation');
addEvent(cbm, 'pulseSetCreation');
addEvent(cbm, 'pulseDeletion');
addEvent(cbm, 'pulseSetDeletion');
addEvent(cbm, 'pulseUpdate');

upCdata = imread('up_arrow_blue-16_16.bmp');
downCdata = imread('down_arrow_blue-16_16.bmp');
setLocalGh(progmanager, hObject, 'pulseUp', 'CData', upCdata);
setLocalGh(progmanager, hObject, 'pulseDown', 'CData', downCdata);

%FIXME!!!
% setLocalGh(progmanager, hObject, 'pulseName', 'ListboxTop', 1);
% setLocalGh(progmanager, hObject, 'pulseSetName', 'ListboxTop', 1);

%  Tim O'Connor 12/16/05 TO121605A: Turn off all 'HandleVisibility' properties to keep the display from getting corrupted by people doing stupid things on the command line.
if ~getLocal(progmanager, hObject, 'showPlot')
    f = figure('CloseRequestFcn', {@displayFigureCloseFcn, hObject}, 'Name', 'PulseEditor', 'Visible', 'Off', 'Tag', 'PulseEditorDisplay', 'HandleVisibility', 'On');%TO121605A
else
    f = figure('CloseRequestFcn', {@displayFigureCloseFcn, hObject}, 'Name', 'PulseEditor', 'Visible', 'On', 'Tag', 'PulseEditorDisplay', 'HandleVisibility', 'On');%TO121605A
end

setLocal(progmanager, hObject, 'displayFigure', f);

a = axes('HandleVisibility', 'On', 'Parent', f);%TO121605A
setLocal(progmanager, hObject, 'displayAxes', a);
xlabel('Time [s]', 'Parent', a, 'HandleVisibility', 'On');
ylabel('Amplitude [mV | pA]', 'Parent', a, 'HandleVisibility', 'On');

set(f, 'HandleVisibility', 'Off');

updateDisplayFromPulse(hObject);

enableGuiElements(hObject);

% addEvent(getLocal(progmanager, hObject, 'listeners'), 'pulsesUpdated');

return;

%--------------------------------------------------------------------------
function displayFigureCloseFcn(hObject, eventdata, mainGuiHObject)

setLocal(progmanager, mainGuiHObject, 'showPlot', 0);
set(hObject, 'Visible', 'Off');

return;

%--------------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

%--------------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

%TO100505D: Clean up.
%TO121605A: Don't use `getParent` because with the 'HandleVisibility' set to 'off' it won't work.
f = getLocal(progmanager, hObject, 'displayFigure');
set(f, 'HandleVisibility', 'On');
delete(f);

return;

%--------------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

browse_Callback(hObject, eventdata, handles);

return;

%--------------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.3;

return;

%------------------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

f = getLocal(progmanager, hObject, 'displayFigure');

props = [];
set(f, 'HandleVisibility', 'On');
props.position = get(f, 'Position');
props.visible = get(f, 'Visible');
set(f, 'HandleVisibility', 'Off');

setLocal(progmanager, hObject, 'displayFigureProps', props);

return;

%------------------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

return;

%------------------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

return;

%------------------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
if strcmpi(directory, matlabroot)
    pulseDir = getDefaultCacheDirectory(progmanager, 'pulseDir');%TO030906A
    %TO030906A
    %if ~isempty(pulseDir) & exist(pulseDir) == 7
    %    setLocal(progmanager, hObject, 'directory', pulseDir);
    %end
end

[pulseSetName, pulseName] = getLocalBatch(progmanager, hObject, 'pulseSetName', 'pulseName');

%TO120905D - Allow the last pulse being editted to be remembered in the configuration. -- Tim O'Connor 12/9/05
if ~isempty(directory)
    loadPulseSetsFromDirectory(hObject);
end

if ~isempty(pulseSetName)
    setLocal(progmanager, hObject, 'pulseSetName', pulseSetName);
    pulseSetName_Callback(hObject, eventdata, handles);
end

if ~isempty(pulseName)
    setLocal(progmanager, hObject, 'pulseName', pulseName);
    pulseName_Callback(hObject, eventdata, handles);
end

showPlot_Callback(hObject, eventdata, handles);


f = getLocal(progmanager, hObject, 'displayFigure');

props = getLocal(progmanager, hObject, 'displayFigureProps');
if isfield(props, 'position') & isfield(props, 'visible')
    set(f, 'HandleVisibility', 'On');
    set(f, 'Position', props.position, 'Visible', props.visible);
    set(f, 'HandleVisibility', 'Off');
end

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

errordlg('Save is not supported by this GUI.');

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

errordlg('Save As is not supported by this GUI.');

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function number_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
function number_Callback(hObject, eventdata, handles)

updatePulseFromDisplay(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function delay_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
function delay_Callback(hObject, eventdata, handles)

updatePulseFromDisplay(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function isi_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
function isi_Callback(hObject, eventdata, handles)

updatePulseFromDisplay(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function width_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
function width_Callback(hObject, eventdata, handles)

updatePulseFromDisplay(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function amplitude_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
function amplitude_Callback(hObject, eventdata, handles)

updatePulseFromDisplay(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function numberSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
% --- Executes on slider movement.
function numberSlider_Callback(hObject, eventdata, handles)

slider = getLocal(progmanager, hObject, 'numberSlider');
% JL112907A reset slider value to 0.5 for Matlab 7
if slider < 0.5
    setLocalBatch(progmanager, hObject, 'number', max(0, getLocal(progmanager, hObject, 'number') - 1),'numberSlider', 0.5);%TO072105D, don't let it drop below 0.
else
    setLocalBatch(progmanager, hObject, 'number', getLocal(progmanager, hObject, 'number') + 1,'numberSlider', 0.5);
end

updatePulseFromDisplay(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function isiSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
% --- Executes on slider movement.
function isiSlider_Callback(hObject, eventdata, handles)

slider = getLocal(progmanager, hObject, 'isiSlider');
% JL112907B reset slider value to 0.5 for Matlab 7
if slider < 0.5
    setLocalBatch(progmanager, hObject, 'isi', getLocal(progmanager, hObject, 'isi') - 5, 'isiSlider', 0.5);
else
    setLocalBatch(progmanager, hObject, 'isi', getLocal(progmanager, hObject, 'isi') + 5, 'isiSlider', 0.5);
end

updatePulseFromDisplay(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function widthSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
% --- Executes on slider movement.
function widthSlider_Callback(hObject, eventdata, handles)

slider = getLocal(progmanager, hObject, 'widthSlider');
% JL112907C reset slider value to 0.5 for Matlab 7
if slider < 0.5
    setLocalBatch(progmanager, hObject, 'width', max(0, getLocal(progmanager, hObject, 'width') - 5), 'widthSlider', 0.5);%TO072105D, don't let it drop below 0.
else
    setLocalBatch(progmanager, hObject, 'width', getLocal(progmanager, hObject, 'width') + 5, 'widthSlider', 0.5);
end


updatePulseFromDisplay(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function amplitudeSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
% --- Executes on slider movement.
function amplitudeSlider_Callback(hObject, eventdata, handles)

slider = getLocal(progmanager, hObject, 'amplitudeSlider');
% JL112907D reset slider value to 0.5 for Matlab 7
if slider < 0.5
    setLocalBatch(progmanager, hObject, 'amplitude', getLocal(progmanager, hObject, 'amplitude') - 1, 'amplitudeSlider', 0.5);
else
    setLocalBatch(progmanager, hObject, 'amplitude', getLocal(progmanager, hObject, 'amplitude') + 1, 'amplitudeSlider', 0.5);
end


updatePulseFromDisplay(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function delaySlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
% --- Executes on slider movement.
function delaySlider_Callback(hObject, eventdata, handles)

slider = getLocal(progmanager, hObject, 'delaySlider');
% JL112907E reset slider value to 0.5 for Matlab 7
if slider < 0.5
    setLocalBatch(progmanager, hObject, 'delay', max(0, getLocal(progmanager, hObject, 'delay') - 5), 'delaySlider', 0.5);%TO072105D, don't let it drop below 0.
else
    setLocalBatch(progmanager, hObject, 'delay', getLocal(progmanager, hObject, 'delay') + 5, 'delaySlider', 0.5);
end

updatePulseFromDisplay(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseSetName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
function pulseSetName_Callback(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
if isempty(directory)
    warndlg('A pulse directory must be selected before new pulses may be accessed.');
    error('No pulse directory selected. Can not load pulse.');
end

pulseSetName = getLocal(progmanager, hObject, 'pulseSetName');
if exist(fullfile(directory, pulseSetName)) ~= 7
    errordlg(sprintf('Can not find directory ''%s''.', fullfile(directory, pulseSetName)));
    error('Can not find directory ''%s''.', fullfile(directory, pulseSetName));
end

%TO100505B - Allow persistently sorted pulseName lists.
%TO100605A - Default to the option of autosorting by pulseNumber.
% autosort = 0;
if getLocal(progmanager, hObject, 'autoSortPulseNames')
%     autosort = 1;
    pulseNames = getSignalList(hObject);%TO100705K
    
    if ~isempty(pulseNames)
        setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);
    else
        setLocalGh(progmanager, hObject, 'pulseName', 'String', {''});
    end
    autoSortPulseNames(hObject);
else
    if exist(fullfile(directory, pulseSetName, 'pulseSet.metadata')) == 2
        loadeddata = load(fullfile(directory, pulseSetName, 'pulseSet.metadata'), 'metadata', '-mat');
        
        setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNamesTemp);
    else
        pulseNames = getSignalList(hObject);%TO100705K
        
        if ~isempty(pulseNames)
            setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);
        else
            setLocalGh(progmanager, hObject, 'pulseName', 'String', {''});
        end
        saveMetaData(hObject);
    end
end

pulseName_Callback(hObject, eventdata, handles);

updateDisplayFromPulse(hObject);

% if autosort
%     autoSortPulseNames(hObject);
% end

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
function pulseName_Callback(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
if isempty(directory)
    warndlg('A pulse directory must be selected before new pulses may be accessed.');
    error('No pulse directory selected. Can not load pulse.');
end

pulseSetName = getLocal(progmanager, hObject, 'pulseSetName');
if isempty(pulseSetName)
    warndlg('A pulse set must be selected before new pulses may be accessed.');
    error('No pulse set selected. Can not load pulse.');
end

pulseName = getLocal(progmanager, hObject, 'pulseName');
if isempty(pulseName)
    updateDisplayFromPulse(hObject);
    return;
end

filename = fullfile(directory, pulseSetName, [pulseName '.signal']);
if exist(filename) ~= 2    
    errordlg(sprintf('Pulse ''%s:%s'' not found - %s', pulseSetName, pulseName, filename));
    error('Pulse ''%s:%s'' not found - %s', pulseSetName, pulseName, filename);
end

s = getLocal(progmanager, hObject, 'currentSignal');
if ~isempty(s)
    try
        delete(s);
    catch
[pointer, ptr] = getPointer(s)
toInternalStructure(s)
        warning(lasterr);
        setLocal(progmanager, hObject, 'currentSignal', []);
    end
end

try
    s = load(filename, '-mat');
    setLocal(progmanager, hObject, 'currentSignal', s.signal);
    updateDisplayFromPulse(hObject);
catch
    fprintf(2, 'Failed to load pulse from ''%s'':\n%s\n', filename, getLastErrorStack);
    setLocal(progmanager, hObject, 'currentSignal', []);
end

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseSetSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
% --- Executes on slider movement.
function pulseSetSlider_Callback(hObject, eventdata, handles)

slider = getLocal(progmanager, hObject, 'pulseSetSlider');
last = getLocal(progmanager, hObject, 'pulseSetSliderLast');
if slider < last | slider == 0
    setLocal(progmanager, hObject, 'pulseSetIndex', getLocal(progmanager, hObject, 'pulseSetIndex') - 1);
else
    setLocal(progmanager, hObject, 'pulseSetIndex', getLocal(progmanager, hObject, 'pulseSetIndex') + 1);
end
setLocal(progmanager, hObject, 'pulseSetSliderLast', slider);
updateDisplayFromPulse(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function nameSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%--------------------------------------------------------------------------
% --- Executes on slider movement.
function nameSlider_Callback(hObject, eventdata, handles)

slider = getLocal(progmanager, hObject, 'nameSlider');
last = getLocal(progmanager, hObject, 'nameSliderLast');
if slider < last | slider == 0
    setLocal(progmanager, hObject, 'signalIndex', getLocal(progmanager, hObject, 'signalIndex') - 1);
else
    setLocal(progmanager, hObject, 'signalIndex', getLocal(progmanager, hObject, 'signalIndex') + 1);
end
setLocal(progmanager, hObject, 'nameSliderLast', slider);
updateDisplayFromPulse(hObject);

return;

%--------------------------------------------------------------------------
% --- Executes on button press in showPlot.
function showPlot_Callback(hObject, eventdata, handles)

%TO121605A
f = getLocal(progmanager, hObject, 'displayFigure');
set(f, 'HandleVisibility', 'On');

if getLocal(progmanager, hObject, 'showPlot')
    set(f, 'Visible', 'On');
else
    set(f, 'Visible', 'Off');
end

set(f, 'HandleVisibility', 'Off');

return;

%--------------------------------------------------------------------------
% function s = getCurrentSignal(hObject)
% 
% s = [];
% 
% pulseSetIndex = getLocal(progmanager, hObject, 'pulseSetIndex');
% if pulseSetIndex < 1
%     return;
% end
% 
% sIndex = getLocal(progmanager, hObject, 'signalIndex');
% if sIndex < 1
%     return;
% end
% 
% collection = getLocal(progmanager, hObject, 'signalCollection');
% ss = collection{pulseSetIndex, 2};
% 
% if sIndex > length(ss)
%     warning('Signal index out of range for pulse set ''%s'': %s', getLocal(progmanager, hObject, 'pulseSet'), num2str(sIndex));
% %     errordlg(sprintf('Signal index out of range for pulse set ''%s'': %s', getLocal(progmanager, hObject, 'pulseSetName'), num2str(sIndex)));
%     return;
% end
% 
% s = ss(sIndex);
% 
% return;

%--------------------------------------------------------------------------
function updatePlot(hObject)
% fprintf(1, 'pulseEditor/updatePlot - genericStartFcn called for testing purposes, remove the call later.\n');
% genericStartFcn(hObject, [], []);
[f, a, s, p] = getLocalBatch(progmanager, hObject, 'displayFigure', 'displayAxes', 'currentSignal', 'displayPlot');

if isempty(s) & ~isempty(p)
    set(p, 'XData', [], 'YData', []);
    return;
elseif isempty(s)
    return;
end

%TO102605A - Make sure the time is long enough, for additive pulses.
% time = 0;
% if strcmpi(get(s, 'Type'), 'squarePulseTrain')
%     time = (getLocal(progmanager, hObject, 'delay') + (getLocal(progmanager, hObject, 'isi') + ...
%         getLocal(progmanager, hObject, 'width')) * getLocal(progmanager, hObject, 'number')) / 1000;
% else
%     kids = get(s, 'Children');
%     for i = 1 : length(kids)
%         s2 = load(kids{i}, '-mat');
%         s2 = s2.signal;
%         if strcmpi(get(s2, 'Type'), 'squarePulseTrain')
%             time = max(time, (((get(s2, 'squarePulseTrainDelay') + get(s2, 'squarePulseTrainISI') + ...
%                 get(s2, 'squarePulseTrainWidth')) * get(s2, 'squarePulseTrainNumber'))));
%         end
%         delete(s2);
%     end
% end
time = getLocal(progmanager, hObject, 'displayTimeWidth') / 1000;%TO120905D - Don't bother checking additive pulses, just let the user set the time.

%TO092605F - Enforce a minimum sample rate in the display.
if get(s, 'SampleRate') < 10000
    set(s, 'SampleRate', 10000);
end

set([f a], 'HandleVisibility', 'On');%TO121605A

%TO072105C - Watch out for negative times.
if time <= 0
    if ~isempty(p)
        %set(p, 'XData', [0], 'YData', [0]);
        %TO092805G - Show a 1ms DC signal, if there is no clear time. -- Tim O'Connor 9/28/05
        sRate = get(s, 'SampleRate');
        len = 100;%TO120105G - This was displaying 0 datapoints, even after TO092805G (due to later changes, I assume). -- Tim O'Connor 12/1/05
        set(p, 'XData', 1:len, 'YData', zeros(len, 1));
        set(get(a, 'Title'), 'Interpreter', 'None', 'String', sprintf('@signalobject: ''%s''', get(s, 'Name')));
    end
else
    p = plot(s, a, time);
end
setLocal(progmanager, hObject, 'displayPlot', p);

%TO092605L - As requested, plot without markers. -- Tim O'Connor 9/26/05
set(p, 'Marker', 'None');

yData = get(p, 'YData');
if ~isempty(yData)
    mn = min(yData);
    mx = max(yData);
    if mn ~= mx
        buffer = 0.1 * abs(mx - mn);
        set(a, 'YLim', [(mn - buffer) (mx + buffer)]);
    end
end

xLim = get(a, 'XLim');
if xLim(1) < 0
    xLim(1) = 0;
end
set(a, 'XLim', xLim);

xlabel('Time [s]', 'Parent', a);
ylabel('Amplitude [mV | pA]', 'Parent', a);
%TO100505C: Make sure the tex interpreter is off, since the underscores won't play nice, and non English characters
%           shouldn't be showing up here anyway.
set(get(a, 'Title'), 'Interpreter', 'None');

set([f a], 'HandleVisibility', 'Off');%TO121605A

return;

%--------------------------------------------------------------------------
% --- Executes on button press in newPulseSet.
function newPulseSet_Callback(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
if isempty(directory)
    warndlg('A pulse directory must be selected before pulse sets may be created.');
    error('No pulse directory selected. Can not create new pulse set.');
end

pulseSetName = inputdlg('New Pulse Set Name', 'Create new pulse set...', 1);
if isempty(pulseSetName)
    return;
elseif strcmpi(class(pulseSetName), 'cell')
    pulseSetName = pulseSetName{1};
end

if exist(fullfile(directory, pulseSetName)) == 7
    warndlg(sprintf('Directory ''%s'' already exists.', fullfile(directory, pulseSetName)));
end

[success, message, messageId] = mkdir(directory, pulseSetName);
if ~success
    errordlg(message);
    error('Failed to create directory ''%s''. %s: %s', fullfile(directory, pulseSetName), num2str(messageId), message);
end
%TO120105E: Make a directory for "hidden" subpulses. - Tim O'Connor 12/5/05
[success, message, messageId] = mkdir(fullfile(directory, pulseSetName), '_subpulses');
if ~success
    errordlg(message);
    error('Failed to create directory ''%s''. %s: %s', fullfile(directory, pulseSetName), num2str(messageId), message);
end

pulseSetNames = getLocalGh(progmanager, hObject, 'pulseSetName', 'String');
%TO100605B: Remove unnecessary empty values.
if length(pulseSetNames) == 1
    if isempty(pulseSetNames{1})
        pulseSetNames = {};
    end
end
pulseSetNames{length(pulseSetNames) + 1} = pulseSetName;
setLocalGh(progmanager, hObject, 'pulseSetName', 'String', pulseSetNames);
setLocalGh(progmanager, hObject, 'childPulseSetName', 'String', pulseSetNames);%TO1200505A: Forgot to do this. -- Tim O'Connor 12/5/05

setLocal(progmanager, hObject, 'pulseSetName', pulseSetName);
setLocalGh(progmanager, hObject, 'pulseName', 'String', {''});
setLocal(progmanager, hObject, 'currentSignal', []);

updateDisplayFromPulse(hObject);

fireEvent(getLocal(progmanager, hObject, 'callbackManager'), 'pulseSetCreation');

return;

%--------------------------------------------------------------------------
% --- Executes on button press in newPulse.
function newPulse_Callback(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
if isempty(directory)
    warndlg('A pulse directory must be selected before new pulses may be created.');
    error('No pulse directory selected. Can not create new pulse.');
end

pulseSetName = getLocal(progmanager, hObject, 'pulseSetName');
if isempty(pulseSetName)
    warndlg('A pulse set must be selected before new pulses may be created.');
    error('No pulse set selected. Can not create new pulse.');
end

%TO100405B: Force the name to end with a computer generated pulse number.
pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
mx = 0;
numArray = [];
for i = 1 : length(pulseNames)
    num = getNumericSuffix(pulseNames{i});
    if ~isempty(num)
        mx = max(mx, num);
        numArray(i) = num;
    end
end

%TO102505A: Allow creation of additive pulses. -- Tim O'Connor 10/25/05
pulseType = questdlg('Which type of pulse will this be?', 'Pulse Type', 'Normal', 'Additive', 'Cancel', 'Normal');
if strcmpi(pulseType, 'Cancel')
    return;
end

%TO100505A: Don't use the standard single field inputdlg, instead use one that allows the pulseNumber to be specified.
%pulseName = inputdlg('New Pulse Name', 'Create new pulse...', 1);
input = inputdlg({'Pulse Name', 'Pulse Number'}, 'Create new pulse...', 1, {'', num2str(mx + 1)});
if isempty(input)
    return;
end
pulseName = input{1};
pulseNumber = input{2};
if ~isempty(find(str2num(pulseNumber) == numArray))
    errordlg(sprintf('Pulse number %s is already being used.', pulseNumber));
    error('Pulse number %s is already being used.', pulseNumber);
end
if isempty(pulseName)
    pulseName = pulseNumber;
else
    pulseName = [pulseName '_' pulseNumber];
% elseif strcmpi(class(pulseName), 'cell')
%     pulseName = pulseName{1};
end

if exist(fullfile(directory, pulseSetName, [pulseName '.signal'])) == 2
    errordlg(sprintf('Pulse ''%s'' already exists.', pulseName));
    error('Can not create new pulse with name ''%s'', because a pulse with that name already exists in pulse set ''%s''.', pulseName, pulseSetName);
end

%TO102605B - Delete signalobjects when they're no longer in use. -- Tim O'Connor 10/26/05
signal = getLocal(progmanager, hObject, 'currentSignal');
if ~isempty(signal)
    try
        delete(signal);
    catch
        warning(lasterr);
    end
end
signal = signalobject('Name', pulseName);

pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
if ~isempty(pulseNames)
    if isempty(pulseNames{1})
        pulseNames = {pulseNames{2:end}};
    end
end
pulseNames{length(pulseNames) + 1} = pulseName;
setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);

%TO102505A: Allow creation of additive pulses. -- Tim O'Connor 10/25/05
switch lower(pulseType)
    case 'normal'
        %TO092605G: Have default values filled in on new pulses. -- Tim O'Connor 9/26/05
        %TO092805F: Save after the default values are defined. -- Tim O'Connor 9/28/05
        squarePulseTrain(signal, 0, 0, 0, 0.1, 0.1, 1);
    case 'additive'
        recursive(signal, 'add', []);
    otherwise
        error('Unrecognized pulse type selection.');
end
saveCompatible(fullfile(directory, pulseSetName, [pulseName '.signal']), 'signal', '-mat');%TO071906D

setLocal(progmanager, hObject, 'currentSignal', signal);

%TO100305B - Use the callback, to keep things clean.
setLocal(progmanager, hObject, 'pulseName', pulseName);
pulseName_Callback(hObject, eventdata, handles);
% updateDisplayFromPulse(hObject);

saveMetaData(hObject);%TO100505B

fireEvent(getLocal(progmanager, hObject, 'callbackManager'), 'pulseCreation');

return;

%--------------------------------------------------------------------------
%TO080606B - Finally fixed the problems with deletion and renaming of pulses. -- Tim O'Connor 8/6/06
% --- Executes on button press in deletePulse.
function deletePulse_Callback(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
pulseSetName = getLocal(progmanager, hObject, 'pulseSetName');
pulseName = getLocal(progmanager, hObject, 'pulseName');

if exist(fullfile(directory, pulseSetName)) ~= 7
    errordlg('No pulse directory specified.');
    warning('pulseEditor/deletePulse: No pulse directory specified.');
    return;
elseif isempty(pulseSetName)
    errordlg('No pulse selected for deletion.');
    warning('pulseEditor/deletePulse: No pulse selected for deletion.');
    return;
elseif isempty(pulseName)    
    errordlg('No pulse selected for deletion.');
    warning('pulseEditor/deletePulse: No pulse selected for deletion.');
    return;
elseif exist(fullfile(directory, pulseSetName, [pulseName '.signal'])) ~= 2
    errordlg('Pulse file does not exist on disk.');
    warning('pulseEditor/deletePulse: The selected pulse does not exist on disk.');
    return;
end

%TO031010E - Confirm delete. People have complained that they have accidentally deleted their pulses. -- Tim O'Connor 3/10/10
confirm = questdlg(['Are you sure you want to delete ' pulseName '?'], 'Confirm Pulse Delete', 'Yes', 'No', 'Yes');
if strcmpi(confirm, 'No')
    return;
end

pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
pulseNames = {pulseNames{find(~strcmpi(pulseNames, pulseName))}};
setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);

delete(fullfile(directory, pulseSetName, [pulseName '.signal']));
%TO080606B
if strcmpi(get(getLocal(progmanager, hObject, 'currentSignal'), 'Type'), 'Recursive')
    delete(fullfile(directory, pulseSetName, '_subpulses', [pulseName '.signal']));
end

enableGuiElements(hObject);

%TO100305B - Use the callback, just to keep things clean.
pulseName_Callback(hObject, eventdata, handles);

saveMetaData(hObject);%TO100505B

fireEvent(getLocal(progmanager, hObject, 'callbackManager'), 'pulseDeletion');

return;

%--------------------------------------------------------------------------
function enableGuiElements(hObject)

[directory pulseSetName pulseName currentSignal] = ...
    getLocalBatch(progmanager, hObject, 'directory', 'pulseSetName', 'pulseName', 'currentSignal');

if exist(directory) == 7
    %TO110705A: Added batched setting of gui properties, for optimization. -- Tim O'Connor 11/7/05
    setLocalGhBatch(progmanager, hObject, {'pulseSetName', 'newPulseSet', 'deletePulseSet', 'renamePulseSet', ...
            'pulseSetUp', 'pulseSetDown'}, 'Enable', 'On');
    if ~isempty(pulseSetName) & exist(fullfile(directory, pulseSetName)) == 7
        %TO100305A, TO100605A
        setLocalGhBatch(progmanager, hObject, {'newPulse', 'deletePulse', 'renamePulse', 'pulseName', 'pulseNumber', ...
                'pulseNumberSliderUp', 'pulseNumberSliderDown', 'autoSortPulseNames'}, 'Enable', 'On');%TO081606E
        %TO100605A - This is conditional based on the autosorting of pulsenames.
        if ~getLocal(progmanager, hObject, 'autoSortPulseNames')
            setLocalGhBatch(progmanager, hObject, {'pulseUp', 'pulseDown'}, 'Enable', 'On');
            %This might be slow, but just try it out, to see how nice it is.
            upCdata = imread('up_arrow_blue-16_16.bmp');
            downCdata = imread('down_arrow_blue-16_16.bmp');
            setLocalGh(progmanager, hObject, 'pulseUp', 'CData', upCdata);
            setLocalGh(progmanager, hObject, 'pulseDown', 'CData', downCdata);
        else
            setLocalGhBatch(progmanager, hObject, {'pulseUp', 'pulseDown'}, 'Enable', 'Inactive');%TO081606G
            %This might be slow, but just try it out, to see how nice it is.
            upCdata = imread('up_arrow_embossed-16_16.bmp');
            downCdata = imread('down_arrow_embossed-16_16.bmp');
            setLocalGh(progmanager, hObject, 'pulseUp', 'CData', upCdata);
            setLocalGh(progmanager, hObject, 'pulseDown', 'CData', downCdata);
        end
    else
        setLocalGhBatch(progmanager, hObject, {'newPulse', 'deletePulse', 'renamePulse', 'pulseName', 'pulseNumber', ...
                'pulseNumberSliderUp', 'pulseNumberSliderDown', 'autoSortPulseNames'}, 'Enable', 'Off');%TO081606E
    end
    
    if ~isempty(currentSignal)
        %TO101305A - Allow additive components (set Visible as well as Enable).
        if strcmpi(get(currentSignal, 'Type'), 'squarePulseTrain')
            setLocalGhBatch(progmanager, hObject, {'number', 'numberLabel', 'numberSlider', 'isi', 'isiLabel', 'isiSlider', ...
                    'width', 'widthLabel', 'widthSlider', 'amplitude', 'amplitudeLabel', 'amplitudeSlider', 'delay', 'delayLabel', 'delaySlider', ...
                    'additiveLabel', 'additive'}, 'Enable', 'On', 'Visible', 'On');
        else
            setLocalGhBatch(progmanager, hObject, {'number', 'numberLabel', 'numberSlider', 'isi', 'isiLabel', 'isiSlider', ...
                    'width', 'widthLabel', 'widthSlider', 'amplitude', 'amplitudeLabel', 'amplitudeSlider', 'delay', 'delayLabel', 'delaySlider'...
                    'additiveLabel', 'additive'}, 'Enable', 'Off', 'Visible', 'Off');
        end
        %TO120105E: Temporarily remove this interface (which is far superior), until Aleks can learn how to cope with the change. -- Tim O'Connor 12/01/05
        if strcmpi(get(currentSignal, 'Type'), 'recursive')
            if getLocal(progmanager, hObject, 'advancedInterface')
                setLocalGhBatch(progmanager, hObject, {'children', 'method', 'deleteChildPulse', 'childPulseSetName', 'addPulse', ...
                        'childPulseNumber', 'childPulseNumberSlider', 'childPulseName', 'recursiveSignalSubframe'}, 'Enable', 'On', 'Visible', 'On');
                if isempty(getLocal(progmanager, hObject, 'childPulseSetName'))
                    setLocalGhBatch(progmanager, hObject, {'childPulseNumber, childPulseNumberSlider', 'childPulseName'}, 'Enable', 'Off');
                end
                setLocalGhBatch(progmanager, hObject, {'additive', 'additiveLabel'}, 'Enable', 'Off', 'Visible', 'Off');
            else
                setLocalGhBatch(progmanager, hObject, {'number', 'numberLabel', 'numberSlider', 'isi', 'isiLabel', 'isiSlider', ...
                        'width', 'widthLabel', 'widthSlider', 'amplitude', 'amplitudeLabel', 'amplitudeSlider', 'delay', 'delayLabel', 'delaySlider', ...
                        'additiveLabel', 'additive'}, 'Enable', 'On', 'Visible', 'On');
                setLocalGhBatch(progmanager, hObject, {'children', 'method', 'deleteChildPulse', 'childPulseSetName', 'addPulse', ...
                        'childPulseNumber', 'childPulseNumberSlider', 'childPulseName', 'recursiveSignalSubframe'}, 'Enable', 'Off', 'Visible', 'Off');
            end
        else
            if getLocal(progmanager, hObject, 'advancedInterface')
                setLocalGhBatch(progmanager, hObject, {'children', 'method', 'deleteChildPulse', 'childPulseSetName', 'addPulse', ...
                        'childPulseNumber', 'childPulseNumberSlider', 'childPulseName', 'recursiveSignalSubframe'}, 'Enable', 'Off', 'Visible', 'Off');
                setLocalGhBatch(progmanager, hObject, {'additive', 'additiveLabel'}, 'Enable', 'Off', 'Visible', 'Off');
            else
%                 setLocalGhBatch(progmanager, hObject, {'number', 'numberLabel', 'numberSlider', 'isi', 'isiLabel', 'isiSlider', ...
%                         'width', 'widthLabel', 'widthSlider', 'amplitude', 'amplitudeLabel', 'amplitudeSlider', 'delay', 'delayLabel', 'delaySlider'...
%                         'additiveLabel', 'additive'}, 'Enable', 'Off', 'Visible', 'Off');
            end
        end
    else
        %TO101305A - Allow additive components (set Visible as well as Enable).
        setLocalGhBatch(progmanager, hObject, {'number', 'numberLabel', 'numberSlider', 'isi', 'isiLabel', 'isiSlider', ...
                    'width', 'widthLabel', 'widthSlider', 'amplitude', 'amplitudeLabel', 'amplitudeSlider', 'delay', 'delayLabel', 'delaySlider', ...
                    'additiveLabel', 'additive', 'children', 'method', 'deleteChildPulse', 'childPulseSetName', 'addPulse', ...
                    'childPulseNumber', 'childPulseNumberSlider', 'childPulseName', 'recursiveSignalSubframe'}, 'Enable', 'Off', 'Visible', 'Off');
    end
else
    setLocalGhBatch(progmanager, hObject, {'pulseSetName', 'newPulseSet', 'deletePulseSet', 'renamePulseSet', ...
            'pulseSetUp', 'pulseSetDown', 'newPulse', 'deletePulse', 'renamePulse', 'pulseName', 'pulseNumber', ...
            'pulseNumberSliderUp', 'pulseNumberSliderDown', 'autoSortPulseNames', 'number', 'numberLabel', 'numberSlider', 'isi', 'isiLabel', 'isiSlider', ...
            'width', 'widthLabel', 'widthSlider', 'amplitude', 'amplitudeLabel', 'amplitudeSlider', 'delay', 'delayLabel', 'delaySlider'...
            'additiveLabel', 'additive'}, 'Enable', 'Off');%TO081606E
    setLocalGhBatch(progmanager, hObject, {'children', 'method', 'deleteChildPulse', 'childPulseSetName', 'addPulse', ...
            'childPulseNumber', 'childPulseNumberSlider', 'childPulseName'}, 'Enable', 'Off', 'Visible', 'Off');
end

return;
%     setLocalGh(progmanager, hObject, 'pulseSetName', 'Enable', 'On');
%     setLocalGh(progmanager, hObject, 'newPulseSet', 'Enable', 'On');
%     setLocalGh(progmanager, hObject, 'deletePulseSet', 'Enable', 'On');
%     setLocalGh(progmanager, hObject, 'renamePulseSet', 'Enable', 'On');
%     setLocalGh(progmanager, hObject, 'pulseSetUp', 'Enable', 'On');
%     setLocalGh(progmanager, hObject, 'pulseSetDown', 'Enable', 'On');
%     if ~isempty(pulseSetName) & exist(fullfile(directory, pulseSetName)) == 7
%         setLocalGh(progmanager, hObject, 'newPulse', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'deletePulse', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'renamePulse', 'Enable', 'On');
%         %TO100605A - This is conditional based on the autosorting of pulsenames.
%         if ~getLocal(progmanager, hObject, 'autoSortPulseNames')
%             setLocalGh(progmanager, hObject, 'pulseUp', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'pulseDown', 'Enable', 'On');
%             %This might be slow, but just try it out, to see how nice it is.
%             upCdata = imread('up_arrow_blue-16_16.bmp');
%             downCdata = imread('down_arrow_blue-16_16.bmp');
%             setLocalGh(progmanager, hObject, 'pulseUp', 'CData', upCdata);
%             setLocalGh(progmanager, hObject, 'pulseDown', 'CData', downCdata);
%         else
%             setLocalGh(progmanager, hObject, 'pulseUp', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'pulseDown', 'Enable', 'Off');
%             %This might be slow, but just try it out, to see how nice it is.
%             upCdata = imread('up_arrow_embossed-16_16.bmp');
%             downCdata = imread('down_arrow_embossed-16_16.bmp');
%             setLocalGh(progmanager, hObject, 'pulseUp', 'CData', upCdata);
%             setLocalGh(progmanager, hObject, 'pulseDown', 'CData', downCdata);            
%         end
%         setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'On');
%         %TO100305A
%         setLocalGh(progmanager, hObject, 'pulseNumber', 'Enable', 'On');
%         setLocalGh(progmanager, hObject, 'pulseNumberSliderDown', 'Enable', 'On');
%         %TO100605A
%         setLocalGh(progmanager, hObject, 'autoSortPulseNames', 'Enable', 'On');
%     else
%         setLocalGh(progmanager, hObject, 'newPulse', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'deletePulse', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'renamePulse', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'pulseUp', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'pulseDown', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'Off');
%         %TO100305A
%         setLocalGh(progmanager, hObject, 'pulseNumber', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'pulseNumberSliderDown', 'Enable', 'Off');
%         %TO100605A
%         setLocalGh(progmanager, hObject, 'autoSortPulseNames', 'Enable', 'Off');
%     end
%     
% %     if ~isempty(pulseName) & exist(fullfile(directory, pulseSetName, [pulseName '.signal'])) == 2
%     if ~isempty(currentSignal)
%         if strcmpi(get(currentSignal, 'Type'), 'squarePulseTrain')
%             setLocalGh(progmanager, hObject, 'number', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'numberSlider', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'isi', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'isiSlider', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'width', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'widthSlider', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'amplitude', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'amplitudeSlider', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'delay', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'delaySlider', 'Enable', 'On');
%             %TO101305A - Allow additive components.
%             setLocalGh(progmanager, hObject, 'number', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'numberLabel', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'numberSlider', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'isi', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'isiLabel', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'isiSlider', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'width', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'widthLabel', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'widthSlider', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'amplitude', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'amplitudeLabel', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'amplitudeSlider', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'delay', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'delayLabel', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'delaySlider', 'Visible', 'On');
%         else
%             %TO101305A - Allow additive components.
%             setLocalGh(progmanager, hObject, 'number', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'numberSlider', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'isi', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'isiSlider', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'width', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'widthSlider', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'amplitude', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'amplitudeSlider', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'delay', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'delaySlider', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'number', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'numberLabel', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'numberSlider', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'isi', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'isiLabel', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'isiSlider', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'width', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'widthLabel', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'widthSlider', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'amplitude', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'amplitudeLabel', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'amplitudeSlider', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'delay', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'delayLabel', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'delaySlider', 'Visible', 'Off');
%         end
%         if strcmpi(get(currentSignal, 'Type'), 'recursive')
%             %TO101305A - Allow additive components.
%             setLocalGh(progmanager, hObject, 'children', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'method', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'deleteChildPulse', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'childPulseSetName', 'Enable', 'On');
%             setLocalGh(progmanager, hObject, 'addPulse', 'Enable', 'On');
%             if ~isempty(getLocal(progmanager, hObject, 'childPulseSetName'))
%                 setLocalGh(progmanager, hObject, 'childPulseNumber', 'Enable', 'On');
%                 setLocalGh(progmanager, hObject, 'childPulseNumberSlider', 'Enable', 'On');
%                 setLocalGh(progmanager, hObject, 'childPulseName', 'Enable', 'On');
%             else
%                 setLocalGh(progmanager, hObject, 'childPulseNumber', 'Enable', 'Off');
%                 setLocalGh(progmanager, hObject, 'childPulseNumberSlider', 'Enable', 'Off');
%                 setLocalGh(progmanager, hObject, 'childPulseName', 'Enable', 'Off');
%             end
%             setLocalGh(progmanager, hObject, 'children', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'method', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'deleteChildPulse', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'childPulseSetName', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'childPulseNumber', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'childPulseNumberSlider', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'addPulse', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'childPulseName', 'Visible', 'On');
%             setLocalGh(progmanager, hObject, 'recursiveSignalSubframe', 'Visible', 'On');
%         else
%             %TO101305A - Allow additive components.
%             setLocalGh(progmanager, hObject, 'children', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'method', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'deleteChildPulse', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'childPulseSetName', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'childPulseNumber', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'childPulseNumberSlider', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'addPulse', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'childPulseName', 'Enable', 'Off');
%             setLocalGh(progmanager, hObject, 'children', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'method', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'deleteChildPulse', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'childPulseSetName', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'childPulseNumber', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'childPulseNumberSlider', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'addPulse', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'childPulseName', 'Visible', 'Off');
%             setLocalGh(progmanager, hObject, 'recursiveSignalSubframe', 'Visible', 'Off');
%         end
%     else
%         setLocalGh(progmanager, hObject, 'number', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'numberSlider', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'isi', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'isiSlider', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'width', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'widthSlider', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'amplitude', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'amplitudeSlider', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'delay', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'delaySlider', 'Enable', 'Off');
%         
%         %TO101305A - Allow additive components.     
%         setLocalGh(progmanager, hObject, 'number', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'numberLabel', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'numberSlider', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'isi', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'isiLabel', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'isiSlider', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'width', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'widthLabel', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'widthSlider', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'amplitude', 'Visible', 'On');
%         setLocalGh(progmanager, hObject, 'amplitudeLabel', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'amplitudeSlider', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'delay', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'delayLabel', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'delaySlider', 'Visible', 'Off');
% 
%         %TO101305A - Allow additive components.
%         setLocalGh(progmanager, hObject, 'children', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'method', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'deleteChildPulse', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'childPulseSetName', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'childPulseNumber', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'childPulseNumberSlider', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'addPulse', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'childPulseName', 'Enable', 'Off');
%         setLocalGh(progmanager, hObject, 'children', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'method', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'deleteChildPulse', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'childPulseSetName', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'childPulseNumber', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'childPulseNumberSlider', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'addPulse', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'childPulseName', 'Visible', 'Off');
%         setLocalGh(progmanager, hObject, 'recursiveSignalSubframe', 'Visible', 'Off');
%     end
% else
%     setLocalGh(progmanager, hObject, 'pulseSetName', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'newPulseSet', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'deletePulseSet', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'renamePulseSet', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'pulseSetUp', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'pulseSetDown', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'newPulse', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'deletePulse', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'renamePulse', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'pulseUp', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'pulseDown', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'pulseName', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'number', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'numberSlider', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'isi', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'isiSlider', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'width', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'widthSlider', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'amplitude', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'amplitudeSlider', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'delay', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'delaySlider', 'Enable', 'Off');
%     
%     %TO101305A - Allow additive components.
%     setLocalGh(progmanager, hObject, 'children', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'method', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'deleteChildPulse', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'childPulseSetName', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'childPulseNumber', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'childPulseNumberSlider', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'addPulse', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'childPulseName', 'Enable', 'Off');
%     %TO101305A - Allow additive components.
%     setLocalGh(progmanager, hObject, 'children', 'Visible', 'Off');
%     setLocalGh(progmanager, hObject, 'method', 'Visible', 'Off');
%     setLocalGh(progmanager, hObject, 'deleteChildPulse', 'Visible', 'Off');
%     setLocalGh(progmanager, hObject, 'childPulseSetName', 'Visible', 'Off');
%     setLocalGh(progmanager, hObject, 'childPulseNumber', 'Visible', 'Off');
%     setLocalGh(progmanager, hObject, 'childPulseNumberSlider', 'Visible', 'Off');
%     setLocalGh(progmanager, hObject, 'addPulse', 'Visible', 'Off');
%     setLocalGh(progmanager, hObject, 'childPulseName', 'Visible', 'Off');
%     setLocalGh(progmanager, hObject, 'recursiveSignalSubframe', 'Visible', 'Off');
%     
%     %TO100305A
%     setLocalGh(progmanager, hObject, 'pulseNumber', 'Enable', 'Off');
%     setLocalGh(progmanager, hObject, 'pulseNumberSliderDown', 'Enable', 'Off');
%     %TO100605A
%     setLocalGh(progmanager, hObject, 'autoSortPulseNames', 'Enable', 'Off');
% end

%--------------------------------------------------------------------------
function updateDisplayFromPulse(hObject)

enableGuiElements(hObject);

s = getLocalBatch(progmanager, hObject, 'currentSignal');
if  isempty(s)
%     setLocal(progmanager, hObject, 'pulseName', '');
    setLocal(progmanager, hObject, 'number', 0);
    setLocal(progmanager, hObject, 'isi', 0);
    setLocal(progmanager, hObject, 'width', 0);
    setLocal(progmanager, hObject, 'amplitude', 0);
    setLocal(progmanager, hObject, 'delay', 0);
    setLocal(progmanager, hObject, 'additive', 0);%TO120905F
    setLocalGh(progmanager, hObject, 'children', 'String', {''});%TO101305A
elseif strcmpi(get(s, 'Type'), 'squarepulsetrain')
%     setLocal(progmanager, hObject, 'pulseName', get(s, 'Name'));
    setLocal(progmanager, hObject, 'number', get(s, 'squarePulseTrainNumber'));
    setLocal(progmanager, hObject, 'isi', 1000 * get(s, 'squarePulseTrainISI'));
    setLocal(progmanager, hObject, 'width', 1000 * get(s, 'squarePulseTrainWidth'));
    setLocal(progmanager, hObject, 'amplitude', get(s, 'amplitude'));
    setLocal(progmanager, hObject, 'delay', 1000 * get(s, 'squarePulseTrainDelay'));
    setLocal(progmanager, hObject, 'additive', 0);%TO120905F
elseif strcmpi(get(s, 'Type'), 'recursive')
    %TO120105D: The (superior) recursive interface has been removed, because Aleks can't get his head around it. -- Tim O'Connor 12/1/05
    if getLocal(progmanager, hObject, 'handicappedInterface')
        kids = get(s, 'Children');
        if length(kids) ~= 2
            warndlg(sprintf('An advanced pulse has been loaded, these are not supported by the handicapped interface.\nInterface type is being switched to accomodate.'));
            warning('Handicapped pulse interface requires recursive pulses to have exactly 2 children.');
            setLocalBatch(progmanager, hObject, 'advancedInterface', 1, 'handicappedInterface', 0);
            advancedInterface_Callback(hObject, [], []);
            return;
        end
        
        %Load the sub pulse.
        [directory, pulseSetName, pulseName] = getLocalBatch(progmanager, hObject, 'directory', 'pulseSetName', 'pulseName');
        %TO110906E - More graceful error handling/tolerance. -- Tim O'Connor 11/9/06
        if exist(fullfile(directory, pulseSetName, '_subpulses')) ~= 7
            fprintf(2, 'Warning: PulseEditor - Subpulse file not found for additive pulse %s:%s. Expected: ''%s''', pulseSetName, pulseName, fullfile(directory, pulseSetName, '_subpulses', [pulseName '.signal']));
        elseif exist(fullfile(directory, pulseSetName, '_subpulses', [pulseName '.signal'])) ~= 2
            fprintf(2, 'Warning: PulseEditor - Subpulse file not found for additive pulse - ''%s:%s''. Expected: ''%s''\n', pulseSetName, pulseName, fullfile(directory, pulseSetName, '_subpulses', [pulseName '.signal']));
        else            
            s1 = load(fullfile(directory, pulseSetName, '_subpulses', [pulseName '.signal']), '-mat');
            s1 = s1.signal;

            setLocal(progmanager, hObject, 'number', get(s1, 'squarePulseTrainNumber'));
            setLocal(progmanager, hObject, 'isi', 1000 * get(s1, 'squarePulseTrainISI'));
            setLocal(progmanager, hObject, 'width', 1000 * get(s1, 'squarePulseTrainWidth'));
            setLocal(progmanager, hObject, 'amplitude', get(s1, 'amplitude'));
            setLocal(progmanager, hObject, 'delay', 1000 * get(s1, 'squarePulseTrainDelay'));

            setLocal(progmanager, hObject, 'additive', getNumericSuffix(kids{2}(1:end-7)));
            delete(s1);
        end
    else
        %TO101305A
        kids = get(s, 'Children');
        kidsList = {};
        if strcmpi(class(kids), 'cell')
            for i = 1 : length(kids)
                [pathstr kidName] = fileparts(kids{i});
                kidsList{i} = kidName;
            end
        else
            for i = 1 : length(kids)
                kidsList{i} = get(kids(i), 'Name');
            end
        end
        setLocalGh(progmanager, hObject, 'children', 'String', kidsList);
        childPulseSetName_Callback(hObject);
    end
end

%TO100305A
num = getNumericSuffix(getLocal(progmanager, hObject, 'pulseName'));
if ~isempty(num)
    setLocal(progmanager, hObject, 'pulseNumber', num2str(num));
else
    setLocal(progmanager, hObject, 'pulseNumber', '');
end

updatePlot(hObject);

return;

%--------------------------------------------------------------------------
function updatePulseFromDisplay(hObject)

s = getLocal(progmanager, hObject, 'currentSignal');

if isempty(s)
    warning('No signal found ''%s:%s''', getLocal(progmanager, hObject, 'pulseSetName'), ...
        getLocal(progmanager, hObject, 'pulseName'));
    return;
end
%Make the sample rate high enough to see the plot in decent detail.
%TO092605F - Enforce a minimum sample rate of 10kHz.
%TO120105D: The (superior) recursive interface has been made optional, because Aleks can't get his head around it. -- Tim O'Connor 12/1/05
if getLocal(progmanager, hObject, 'advancedInterface')
    if getLocal(progmanager, hObject, 'width') + getLocal(progmanager, hObject, 'isi') > 0
        sampleRate = max(10000, 20000 / (getLocal(progmanager, hObject, 'width') + getLocal(progmanager, hObject, 'isi')));
    else
        sampleRate = 20000;
    end
    set(s, 'sampleRate', sampleRate);
    squarePulseTrain(s, getLocal(progmanager, hObject, 'amplitude'), 0, getLocal(progmanager, hObject, 'delay') / 1000, ...
        getLocal(progmanager, hObject, 'width') / 1000, getLocal(progmanager, hObject, 'isi') / 1000, getLocal(progmanager, hObject, 'number'));
else
    %TO120105D: The (superior) recursive interface has been made optional, because Aleks can't get his head around it. -- Tim O'Connor 12/1/05
    additive = getLocal(progmanager, hObject, 'additive');
    if additive > 0
%         if pulseNumber == str2num(getLocal(progmanager, hObject, 'pulseNumber'))
%             errordlg('A pulse may not be added to itself.');
%             updateDisplayFromPulse(hObject);
%             return;
%         end
        [pulseName, pulseSetName, directory] = getLocalBatch(progmanager, hObject, 'pulseName', 'pulseSetName', 'directory');
        if strcmpi(get(s, 'Type'), 'recursive')
            kids = get(s, 'Children');
            signal = load(kids{1}, '-mat');
            signal = signal.signal;
            squarePulseTrain(signal, getLocal(progmanager, hObject, 'amplitude'), 0, getLocal(progmanager, hObject, 'delay') / 1000, ...
                getLocal(progmanager, hObject, 'width') / 1000, getLocal(progmanager, hObject, 'isi') / 1000, getLocal(progmanager, hObject, 'number'));
            saveCompatible(fullfile(directory, pulseSetName, '_subpulses', [pulseName '.signal']), 'signal', '-mat');%TO071906D
            
            if getNumericSuffix(kids{2}(1:end-7)) ~= additive
                secondaryPulseName = '';
                pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
                for i = 1 : length(pulseNames)
                    if additive == getNumericSuffix(pulseNames{i})
                        secondaryPulseName = pulseNames{i};
                        break;
                    end
                end
                if isempty(secondaryPulseName)
                    errordlg('Invalid additive pulse number');
                end
                [directory, pulseSetName] = getLocalBatch(progmanager, hObject, 'directory', 'pulseSetName');
                kids{2} = fullfile(directory, pulseSetName, [secondaryPulseName '.signal']);
                recursive(s, 'add', kids);
            end
        else
            %Must be converted into a recursive pulse.            
            signal = signalobject('Name', pulseName, 'SampleRate', get(s, 'SampleRate'));
            squarePulseTrain(signal, getLocal(progmanager, hObject, 'amplitude'), 0, getLocal(progmanager, hObject, 'delay') / 1000, ...
                getLocal(progmanager, hObject, 'width') / 1000, getLocal(progmanager, hObject, 'isi') / 1000, getLocal(progmanager, hObject, 'number'));
            saveCompatible(fullfile(directory, pulseSetName, '_subpulses', [pulseName '.signal']), 'signal', '-mat');%TO071906D

            %Now convert this one into a wrapper.
            secondaryPulseName = '';
            pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
            for i = 1 : length(pulseNames)
                if additive == getNumericSuffix(pulseNames{i})
                    secondaryPulseName = pulseNames{i};
                    break;
                end
            end
            if isempty(secondaryPulseName)
                errordlg('Invalid additive pulse number');
            end
            kids{1} = fullfile(directory, pulseSetName, '_subpulses', [pulseName '.signal']);
            kids{2} = fullfile(directory, pulseSetName, [secondaryPulseName '.signal']);
            recursive(s, 'add', kids);
        end
    else %No additive component.
        if strcmpi(get(s, 'Type'), 'recursive') %Remove any additive components.
            kids = get(s, 'Children');
            delete(kids{1});
        end
        
        %Now just set everything, like on a normal pulse.
        if getLocal(progmanager, hObject, 'width') + getLocal(progmanager, hObject, 'isi') > 0
            sampleRate = max(10000, 20000 / (getLocal(progmanager, hObject, 'width') + getLocal(progmanager, hObject, 'isi')));
        else
            sampleRate = 20000;
        end
        set(s, 'sampleRate', sampleRate);
        squarePulseTrain(s, getLocal(progmanager, hObject, 'amplitude'), 0, getLocal(progmanager, hObject, 'delay') / 1000, ...
            getLocal(progmanager, hObject, 'width') / 1000, getLocal(progmanager, hObject, 'isi') / 1000, getLocal(progmanager, hObject, 'number'));
    end
end

updatePlot(hObject);

if getLocal(progmanager, hObject, 'autosave')
    saveMenuItem_Callback(hObject, [], []);
end

fireEvent(getLocal(progmanager, hObject, 'callbackManager'), 'pulseUpdate');

return;

% --------------------------------------------------------------------
function saveMenuItem_Callback(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
if isempty(directory)
    warndlg('A pulse directory must be selected before new pulses may be created.');
    error('No pulse directory selected. Can not create new pulse.');
end

pulseSetName = getLocal(progmanager, hObject, 'pulseSetName');
if isempty(pulseSetName)
    warndlg('A pulse set must be selected before new pulses may be created.');
    error('No pulse set selected. Can not create new pulse.');
end

%Overwrite, don't prompt.
% if exist(fullfile(directory, pulseSetName, [pulseName '.signal'])) == 2
% end

signal = getLocal(progmanager, hObject, 'currentSignal');
saveCompatible(fullfile(directory, pulseSetName, [get(signal, 'Name') '.signal']), 'signal', '-mat');%TO071906D

return;

% --------------------------------------------------------------------
function loadMenuItem_Callback(hObject, eventdata, handles)

[filename pathname] = uigetfile('*.pulseset', 'Choose a pulse set to load.');
if isempty(filename) | filename == 0
    return;%Cancel
end
data = load(fullfile(pathname, filename), '-mat');
if data.version ~= 0.1
    error('File format version not supported: %s', num2str(data.version));
end

setLocal(progmanager, hObject, 'signalCollection', data.signalobjects);

if isempty(data.signalobjects)
    setLocal(progmanager, hObject, 'pulseSetIndex', -1);
    setLocal(progmanager, hObject, 'signalIndex', -1);
else
    setLocal(progmanager, hObject, 'pulseSetIndex', 1);
    if isempty(data.signalobjects{1, 2})
        setLocal(progmanager, hObject, 'signalIndex', -1);
    else
        setLocal(progmanager, hObject, 'signalIndex', 1);
    end
end
updateDisplayFromPulse(hObject);

% data.signalobjects
% for i = 1 : length(data.signalobjects)
%     data.signalobjects{i, 2}
% end

return;

% --------------------------------------------------------------------
function saveAsMenuItem_Callback(hObject, eventdata, handles)

[filename pathname] = uiputfile('*.pulseset', 'Choose a file to save pulses.');

if isempty(filename) | filename == 0
    return;%Cancel
end

filename = fullfile(pathname, filename);%TO072105E - Take the path into account.

if ~endsWithIgnoreCase(filename, '.pulseset')
    filename = [filename '.pulseset'];
end

setLocal(progmanager, hObject, 'filename', filename);
saveMenuItem_Callback(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
% --- Executes on button press in autosave.
function autosave_Callback(hObject, eventdata, handles)

return;

% --------------------------------------------------------------------
%TO080606B - Finally fixed the problems with deletion and renaming of pulses. -- Tim O'Connor 8/6/06
% --- Executes on button press in renamePulse.
function renamePulse_Callback(hObject, eventdata, handles)

[pulse pulseSetName directory] = getLocalBatch(progmanager, hObject, 'currentSignal', 'pulseSetName', 'directory');%TO022106B
originalPulseName = get(pulse, 'Name');%TO080606B

pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
index = find(strcmpi(pulseNames, originalPulseName));%TO080606B
if isempty(index)
    error('Can not find original pulse name in gui.');
elseif length(index) > 1
    error('Too many matches for original pulse name in gui.');
end

%TO100505A: Don't use the standard single field inputdlg, instead use one that allows the pulseNumber to be specified.
%pulseName = inputdlg('Pulse Name', 'Rename a pulse...', 1, pulseName);
pulseNumber = getNumericSuffix(originalPulseName);%TO080606B
len = length(num2str(pulseNumber));
if length(originalPulseName) == len
    originalPulseName = '';
else
    originalPulseName = originalPulseName(1 : end - (len + 1));%Cut off the underscore and number.
    
end
numArray = [];
if isempty(pulseNumber)
    mx = 0;
    for i = 1 : length(originalPulseNames)
        num = getNumericSuffix(pulseNames{i});
        if ~isempty(num)
            mx = max(mx, num);
            numArray(i) = num;
        end
    end
    pulseNumber = mx + 1;
else
    for i = 1 : length(pulseNames)
        num = getNumericSuffix(pulseNames{i});
        if ~isempty(num)
            numArray(i) = num;
        end
    end
end

pulseNumber = num2str(pulseNumber);
input = inputdlg({'Pulse Name', 'Pulse Number'}, 'Rename a pulse...', 1, {originalPulseName, pulseNumber});
if isempty(input)
    return;
end
pulseName = input{1};
pulseNumber = input{2};
if isempty(pulseName)
    pulseName = pulseNumber;
else
    pulseName = [pulseName '_' pulseNumber];
end

%TO100605D: Watch out for pulseNumber-space collisions.
if ~isempty(pulseNumber)
    p = str2num(pulseNumber);
    if ~isempty(find(p == numArray)) & p ~= getNumericSuffix(get(pulse, 'Name'))
        errordlg(sprintf('Pulse number already in use: %s', pulseNumber));
        return;
    end
end

if strcmpi(get(pulse, 'Name'), pulseName)
    %No change.
    return;
end

set(pulse, 'Name', pulseName);
saveMenuItem_Callback(hObject, eventdata, handles);

delete(fullfile(directory, pulseSetName, [originalPulseName '_' pulseNumber '.signal']));%TO022106B: Remove the old file.

pulseNames{index} = pulseName;
setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);

%TO100605A
if getLocal(progmanager, hObject, 'autoSortPulseNames')
    autoSortPulseNames(hObject);
else
    saveMetaData(hObject);%TO100505B
end

%TO100305B - Use the callback, to keep things clean.
setLocal(progmanager, hObject, 'pulseName', pulseName);%TO022706B: Forgot to update the pulseName to reflect the new value. -- Tim O'Connor 2/27/06
pulseName_Callback(hObject, eventdata, handles);

fireEvent(getLocal(progmanager, hObject, 'callbackManager'), 'pulseDeletion');
fireEvent(getLocal(progmanager, hObject, 'callbackManager'), 'pulseCreation');

return;

% --------------------------------------------------------------------
% --- Executes on button press in pulseSetUp.
function pulseSetUp_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
% --- Executes on button press in pulseSetDown.
function pulseSetDown_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
%TO080606B - Finally fixed the problems with deletion and renaming of pulses. -- Tim O'Connor 8/6/06
% --- Executes on button press in renamePulseSet.
function renamePulseSet_Callback(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
if isempty(directory)
    warndlg('A pulse directory must be selected before pulse sets may be renamed.');
    error('No pulse directory selected. Can not rename pulse set.');
end

%TO011306A - This was being grabbed after the subsequent `if` statement, which of course choked. -- Tim O'Connor 1/13/06
pulseSetName = getLocal(progmanager, hObject, 'pulseSetName');
if exist(fullfile(directory, pulseSetName)) ~= 7
    errordlg(sprintf('Failed to rename pulse set, because the pulse set could not be found on disk - ''%s''', fullfile(directory, pulseSetName)));
    error('Failed to rename pulse set. The pulse set could not be found on disk - ''%s''', fullfile(directory, pulseSetName));
end

pulseSetNames = getLocalGh(progmanager, hObject, 'pulseSetName', 'String');
index = find(strcmpi(pulseSetNames, pulseSetName));
if isempty(index)
    error('Can not find original pulse set name in gui.');
elseif length(index) > 1
    error('Too many matches for original pulse set name in gui.');
end

%TO080606B
source = fullfile(directory, pulseSetName);
pulseSetName = inputdlg('Pulse Set Name', 'Rename a pulse set...', 1, {pulseSetName});
pulseSetName = pulseSetName{1};

%TO080606B
[success, message, messageId] = movefile(source, fullfile(directory, pulseSetName));
if ~success
    errordlg(['Failed to delete pulse set ''' pulseSetNames{index} ''' to ''' pulseSetName ''': ' message]);
    error('Failed to move directory ''%s''. %s: %s', fullfile(directory, pulseSetName), num2str(messageId), message);
end

pulseSetNames{index} = pulseSetName;%TO080606B
setLocalGh(progmanager, hObject, 'pulseSetName', 'String', pulseSetNames);

%TO080606B
if getLocal(progmanager, hObject, 'autoSortPulseNames')
    autoSortPulseNames(hObject);
else
    saveMetaData(hObject);
end

enableGuiElements(hObject);

fireEvent(getLocal(progmanager, hObject, 'callbackManager'), 'pulseSetDeletion');
fireEvent(getLocal(progmanager, hObject, 'callbackManager'), 'pulseSetCreation');

return;

% --------------------------------------------------------------------
%TO080606B - Finally fixed the problems with deletion and renaming of pulses. -- Tim O'Connor 8/6/06
% --- Executes on button press in deletePulseSet.
function deletePulseSet_Callback(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
if isempty(directory)
    warndlg('A pulse directory must be selected before pulse sets may be renamed.');
    error('No pulse directory selected. Can not rename pulse set.');
end

%TO011306A - This was being grabbed after the subsequent `if` statement, which of course choked. -- Tim O'Connor 1/13/06
pulseSetName = getLocal(progmanager, hObject, 'pulseSetName');
if exist(fullfile(directory, pulseSetName)) ~= 7
    errordlg(sprintf('Failed to rename pulse set, because the pulse set could not be found on disk - ''%s''', fullfile(directory, pulseSetName)));
    error('Failed to rename pulse set. The pulse set could not be found on disk - ''%s''', fullfile(directory, pulseSetName));
end

pulseSetNames = getLocalGh(progmanager, hObject, 'pulseSetName', 'String');
index = find(strcmpi(pulseSetNames, pulseSetName));
if isempty(index)
    error('Can not find original pulse set name in gui.');
elseif length(index) > 1
    error('Too many matches for original pulse set name in gui.');
end

%TO031010E - Confirm delete. People have complained that they have accidentally deleted their pulses. -- Tim O'Connor 3/10/10
confirm = questdlg(['Are you sure you want to delete ' pulseSetName ' (and all its pulses)?'], 'Confirm PulseSet Delete', 'Yes', 'No', 'Yes');
if strcmpi(confirm, 'No')
    return;
end

%TO080606B
if exist(fullfile(directory, pulseSetNames{index}, '_subpulses')) == 7
    delete(fullfile(directory, pulseSetNames{index}, '_subpulses', '*'));
    [success, message, messageId] = rmdir(fullfile(directory, pulseSetNames{index}, '_subpulses'));
    if ~success
        errordlg(['Failed to delete pulse set subpulses directory ''' pulseSetNames{index} ''': ' message]);
        error('Failed to delete directory ''%s''. %s: %s', fullfile(directory, pulseSetNames{index}, '_subpulses'), num2str(messageId), message);
    end
end
delete(fullfile(directory, pulseSetNames{index}, '*'));
[success, message, messageId] = rmdir(fullfile(directory, pulseSetNames{index}));
if ~success
    errordlg(['Failed to delete pulse set ''' pulseSetNames{index} ''': ' message]);
    error('Failed to delete directory ''%s''. %s: %s', fullfile(directory, pulseSetNames{index}), num2str(messageId), message);
end

%%TO080606B
if index < length(pulseSetNames)
    pulseSetNames{index : end - 1} = pulseSetNames{index + 1 : end};
end
pulseSetNames = pulseSetNames(1 : end - 1);
setLocalGh(progmanager, hObject, 'pulseSetName', 'String', pulseSetNames);

enableGuiElements(hObject);

%TO080606B
if getLocal(progmanager, hObject, 'autoSortPulseNames')
    autoSortPulseNames(hObject);
else
    saveMetaData(hObject);
end

fireEvent(getLocal(progmanager, hObject, 'callbackManager'), 'pulseSetDeletion');
pulseSetName_Callback(hObject, eventdata, handles);%TO111908D - Make sure we properly refresh the pulse set selection. -- Tim O'Connor 11/19/08

return;

% --------------------------------------------------------------------
% --- Executes on button press in pulseUp.
function pulseUp_Callback(hObject, eventdata, handles)
%TO100505B - Implement this functionality, finally.

pos = getLocalGh(progmanager, hObject, 'pulseName', 'Value');
if pos == 1
    return;
end

pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
if length(pulseNames) == 1
    return;
end
temp = pulseNames{pos};
pulseNames{pos} = pulseNames{pos - 1};
pulseNames{pos - 1} = temp;

setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);

setLocal(progmanager, hObject, 'autoSortPulseNames', 0);
saveMetaData(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in pulseDown.
function pulseDown_Callback(hObject, eventdata, handles)
%TO100505B - Implement this functionality, finally.

pos = getLocalGh(progmanager, hObject, 'pulseName', 'Value');
pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
if pos >= length(pulseNames) | length(pulseNames) == 1
    return;
end

temp = pulseNames{pos};
pulseNames{pos} = pulseNames{pos + 1};
pulseNames{pos + 1} = temp;

setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);

setLocal(progmanager, hObject, 'autoSortPulseNames', 0);
saveMetaData(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
if isempty(directory)
    directory = getDefaultCacheDirectory(progmanager, 'pulseDir');%TO030906A
end
%TO030906A
% if isempty(directory)
%     directory = pwd;
% end
directory = uigetdir(directory, 'Choose a directory for signal storage...');
%TO092605H: Enhanced cancellation detection. -- Tim O'Connor 9/26/05
if length(directory) == 1 & isnumeric(directory)
    if directory == 0
        return;
    end
end    
if isempty(directory) | exist(directory) ~= 7
    return;
end

setLocal(progmanager, hObject, 'directory', directory);

setDefaultCacheValue(progmanager, 'pulseDir', directory);%TO120705D

loadPulseSetsFromDirectory(hObject);%TO120905D

return;

% --------------------------------------------------------------------
%TO120905D - Allow the last pulse being editted to be remembered in the configuration. -- Tim O'Connor 12/9/05
%TO062906C: Calling `dir` on an empty string acts as if `pwd` was the directory, this is bad news for searching directories, watch out. -- Tim O'Connor 6/29/06
function loadPulseSetsFromDirectory(hObject)

directory = getLocal(progmanager, hObject, 'directory');
%TO062906C
if ~isempty(directory)
    contents = dir(directory);
else
    contents = [];
end
pulseSetNames = {};
for i = 1 : length(contents)
    if contents(i).isdir & ~(strcmpi(contents(i).name, '..') | strcmpi(contents(i).name, '.'))
        pulseSetNames{length(pulseSetNames) + 1} = contents(i).name;
    end
end

%TO101305A
if ~isempty(pulseSetNames)
    setLocalGh(progmanager, hObject, 'pulseSetName', 'String', pulseSetNames);
    setLocalGh(progmanager, hObject, 'childPulseSetName', 'String', pulseSetNames);
    setLocalBatch(progmanager, hObject, 'pulseSetName', pulseSetNames{1}, 'childPulseSetName', pulseSetNames{1});
    pulseSetName_Callback(hObject, [], []);
else
    setLocalGh(progmanager, hObject, 'pulseSetName', 'String', {''});
    setLocalGh(progmanager, hObject, 'pulseName', 'String', {''});
    setLocalGh(progmanager, hObject, 'childPulseSetName', 'String', {''});
    setLocalGh(progmanager, hObject, 'childPulseName', 'String', {''});
end

updateDisplayFromPulse(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
%TO100305A
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
% --- Executes on slider movement.
%TO100305A
function pulseNumberSliderDown_Callback(hObject, eventdata, handles)

%TO081606E - Slider functionality changed as of Matlab 7, invalidating most slider code. -- Tim O'Connor 8/16/06
[pulseNumber] = getLocalBatch(progmanager, hObject, 'pulseNumber');

if isempty(pulseNumber)
    return;
%     pulseNumber = 1;
%     num = 1;
else
    num = str2num(pulseNumber);
end

if isempty(num)
    return;
end

pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
numbers = [];
for i = 1 : length(pulseNames)
    suffix = getNumericSuffix(pulseNames{i});
    if ~isempty(suffix)
        numbers(length(numbers) + 1) = suffix;
    end
end
num = max(numbers(find(numbers < num)));
% num = min(numbers(find(numbers > num)));

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
%TO100505B - Allow the order in the listbox to be user defined and persistent.
function saveMetaData(hObject)

if getLocal(progmanager, hObject, 'autoSortPulseNames')
    return;
end

[directory pulseSetName] = getLocalBatch(progmanager, hObject, 'directory', 'pulseSetName');
if isempty(directory) | isempty(pulseSetName)
    return;
end

metadata.pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
saveCompatible(fullfile(directory, pulseSetName, 'pulseSet.metadata'), 'metadata', '-mat');%TO071906D

return;

% --------------------------------------------------------------------
% --- Executes on button press in autoSortPulseNames.
function autoSortPulseNames_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'autoSortPulseNames')
    autoSortPulseNames(hObject);
end

enableGuiElements(hObject);

return;

% --------------------------------------------------------------------
%TO100605A - Allow auto sorting by pulse number.
function autoSortPulseNames(hObject)

pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
if isempty(pulseNames)
    return;
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

setLocalGh(progmanager, hObject, 'pulseName', 'String', {pulseNames{indices}});

return;

% --------------------------------------------------------------------
%TO100705K - Factored out into a separate function.
function list = getSignalList(hObject)

[directory, pulseSetName] = getLocalBatch(progmanager, hObject, 'directory', 'pulseSetName');

signalList = dir(fullfile(directory, pulseSetName, '*.signal'));
list = {};
for i = 1 : length(signalList)
    if ~signalList(i).isdir
        list{length(list) + 1} = signalList(i).name(1 : length(signalList(i).name) - 7);
    end
end

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function method_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
% --- Executes on selection change in method.
function method_Callback(hObject, eventdata, handles)

[currentSignal method] = getLocalBatch(progmanager, hObject, 'currentSignal', 'method');

switch lower(method)
    case '+'
        set(currentSignal, 'method', 'add');
    case '-'
        set(currentSignal, 'method', 'subtract');
    case '*'
        set(currentSignal, 'method', 'multiply');
    case '/'
        set(currentSignal, 'method', 'divide');
    case {'cat', 'concat'}
        warndlg('Signal concatenation is not yet implemented in the GUI. You may do it via the command line, if necessary.', 'Feature Not Implemented');
        set(currentSignal, 'method', 'concatenate');
    otherwise
        error('Unrecognized method: %s', method);
end

updatePlot(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function children_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
% --- Executes on selection change in children.
function children_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function childPulseSetName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
%TO101305A
% --- Executes on selection change in childPulseSetName.
function childPulseSetName_Callback(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
if isempty(directory)
    warndlg('A pulse directory must be selected before new pulses may be accessed.');
    error('No pulse directory selected. Can not load pulse.');
end

childPulseSetName = getLocal(progmanager, hObject, 'childPulseSetName');
if exist(fullfile(directory, childPulseSetName)) ~= 7
    errordlg(sprintf('Can not find directory ''%s''.', fullfile(directory, childPulseSetName)));
    error('Can not find directory ''%s''.', fullfile(directory, childPulseSetName));
end

%TO100505B - Allow persistently sorted pulseName lists.
%TO100605A - Default to the option of autosorting by pulseNumber.
if getLocal(progmanager, hObject, 'autoSortPulseNames')
    signalList = dir(fullfile(directory, childPulseSetName, '*.signal'));
    childPulseNames = {};
    for i = 1 : length(signalList)
        childPulseNames{length(childPulseNames) + 1} = signalList(i).name(1 : length(signalList(i).name) - 7);
    end

    if ~isempty(childPulseNames)
        setLocalGh(progmanager, hObject, 'childPulseName', 'String', childPulseNames);
    else
        setLocalGh(progmanager, hObject, 'childPulseName', 'String', {''});
    end
else
    if exist(fullfile(directory, childPulseSetName, 'pulseSet.metadata')) == 2
        loadeddata = load(fullfile(directory, childPulseSetName, 'pulseSet.metadata'), 'metadata', '-mat');
        setLocalGh(progmanager, hObject, 'childPulseName', 'String', loadeddata.metadata.pulseNames);
    else
        signalList = dir(fullfile(directory, childPulseSetName, '*.signal'));
        childPulseNames = {};
        for i = 1 : length(signalList)
            childPulseNames{length(childPulseNames) + 1} = signalList(i).name(1 : length(signalList(i).name) - 7);
        end
        
        if ~isempty(pulseNames)
            setLocalGh(progmanager, hObject, 'childPulseName', 'String', childPulseNames);
        else
            setLocalGh(progmanager, hObject, 'childPulseName', 'String', {''});
        end
        saveMetaData(hObject);
    end
end

childPulseName_Callback(hObject);
enableGuiElements(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function childPulseName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
%TO101305A
% --- Executes on selection change in childPulseName.
function childPulseName_Callback(hObject, eventdata, handles)

num = getNumericSuffix(getLocal(progmanager, hObject, 'childPulseName'));
if ~isempty(num)
    setLocal(progmanager, hObject, 'childPulseNumber', num2str(num));
else
    setLocal(progmanager, hObject, 'childPulseNumber', '');
end

return;

% --------------------------------------------------------------------
%TO101305A
% --- Executes on button press in addPulse.
function addPulse_Callback(hObject, eventdata, handles)

[directory, childPulseSetName, childPulseName, currentSignal, method, pulseName, pulseSetName] = getLocalBatch(progmanager, hObject, ...
    'directory', 'childPulseSetName', 'childPulseName', 'currentSignal', 'method', 'pulseName', 'pulseSetName');

if isempty(childPulseSetName) | isempty(childPulseName)
    return;
end

kids = get(currentSignal, 'Children');

switch lower(method)
    case '+'
        method = 'add';
    case '-'
        method = 'subtract';
    case '*'
        method = 'multiply';
    case '/'
        method = 'divide';
    case {'cat', 'concat'}
        warndlg('Signal concatenation is not yet implemented in the GUI. You may do it via the command line, if necessary.', 'Feature Not Implemented');
        method = 'concatenate';
    otherwise
        error('Unrecognized method: %s', method);
end

if strcmpi(childPulseName, pulseName) & strcmpi(childPulseSetName, pulseSetName)
    errordlg('A pulse may not be added to itself.');
    return;
end

kidList = getLocalGh(progmanager, hObject, 'children', 'String');
if ismember(lower(kidList), lower(childPulseName))
    warndlg(sprintf('Pulse ''%s'' is already added.', childPulseName));
    return;
end

kids{length(kids) + 1} = fullfile(directory, childPulseSetName, [childPulseName '.signal']);

recursive(currentSignal, method, kids);

kidList{length(kidList) + 1} = childPulseName;
setLocalGh(progmanager, hObject, 'children', 'String', kidList);

if getLocal(progmanager, hObject, 'autosave')
    saveMenuItem_Callback(hObject, [], []);
end
updatePlot(hObject);

return;

% --------------------------------------------------------------------
%TO101305A
% --- Executes on button press in deleteChildPulse.
function deleteChildPulse_Callback(hObject, eventdata, handles)

[directory, childPulseSetName, childPulseName, currentSignal, method, childName] = getLocalBatch(progmanager, hObject, ...
    'directory', 'childPulseSetName', 'childPulseName', 'currentSignal', 'method', 'children');

kids = get(currentSignal, 'Children');
if isempty(kids)
    return;
end
switch lower(method)
    case '+'
        method = 'add';
    case '-'
        method = 'subtract';
    case '*'
        method = 'multiply';
    case '/'
        method = 'divide';
    case {'cat', 'concat'}
        warndlg('Signal concatenation is not yet implemented in the GUI. You may do it via the command line, if necessary.', 'Feature Not Implemented');
        method = 'concatenate';
    otherwise
        error('Unrecognized method: %s', method);
end

kidList = {};
if strcmpi(class(kids), 'cell')
    kids2 = {};
    for i = 1 : length(kids)
        [pathstr kidName] = fileparts(kids{i});
        if ~strcmpi(childName, kidName)
            kidList{length(kidList) + 1} = kidName;
            kids2{length(kids2) + 1} = kids{i};
        end
    end
else
    kids2 = [];
    for i = 1 : length(kids)
        kidName = get(kids(i), 'Name');
        if ~strcmpi(childName, get(kids(i), 'Name'))
            kidList{length(kidList) + 1} = kidName;
            kids2(length(kids2) + 1) = kids(i);
        end
    end
end

set(currentSignal, 'children', kids2);
setLocalGh(progmanager, hObject, 'children', 'String', kidList);

if getLocal(progmanager, hObject, 'autosave')
    saveMenuItem_Callback(hObject, [], []);
end
updatePlot(hObject);

return;

% --------------------------------------------------------------------
%TO101305A
% --- Executes during object creation, after setting all properties.
function childPulseNumberSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
%TO101305A
% --- Executes on slider movement.
function childPulseNumberSlider_Callback(hObject, eventdata, handles)

[childPulseNumber childPulseNumberSlider childPulseNumberSliderLast] = getLocalBatch(progmanager, hObject, ...
    'childPulseNumber', 'childPulseNumberSlider', 'childPulseNumberSliderLast');

if isempty(childPulseNumber)
    return;
else
    num = str2num(childPulseNumber);
end

if isempty(num)
    return;
end

childPulseNames = getLocalGh(progmanager, hObject, 'childPulseName', 'String');
numbers = [];
for i = 1 : length(childPulseNames)
    suffix = getNumericSuffix(childPulseNames{i});
    if ~isempty(suffix)
        numbers(length(numbers) + 1) = suffix;
    end
end
if childPulseNumberSlider < childPulseNumberSliderLast | childPulseNumberSlider == 0
    num = max(numbers(find(numbers < num)));
else
    num = min(numbers(find(numbers > num)));
end

if isempty(num)
    return;
end
% if pulseNumberSliderDown < pulseNumberSliderLast | pulseNumberSliderDown == 0
%     num = num - 1;
% else
%     num = num + 1;
% end

setLocalBatch(progmanager, hObject, 'childPulseNumber', num2str(num), 'childPulseNumberSliderLast', childPulseNumberSlider);
childPulseNumber_Callback(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function childPulseNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
%TO101305A
function childPulseNumber_Callback(hObject, eventdata, handles)

pulseNumber = getLocal(progmanager, hObject, 'childPulseNumber');
pulseNames = getLocalGh(progmanager, hObject, 'childPulseName', 'String');
for i = 1 : length(pulseNames)
    if endsWith(pulseNames{i}, pulseNumber)
        setLocal(progmanager, hObject, 'childPulseName', pulseNames{i});
        childPulseName_Callback(hObject, eventdata, handles);
        return;
    end
end

setLocal(progmanager, hObject, 'childPulseNumber', '');

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function additive_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
function additive_Callback(hObject, eventdata, handles)

%TO080606D: Block immediate recursion. -- Tim O'Connor 8/6/06
[pulseName, additive] = getLocalBatch(progmanager, hObject, 'pulseName', 'additive');
if endsWith(pulseName, num2str(additive))
    setLocal(progmanager, hObject, 'additive', 0);
    errordlg('A pulse may not be added to itself.', 'Impending Infinite Recursion');
end
if additive < 0
    setLocal(progmanager, hObject, 'additive', 0);
end

updatePulseFromDisplay(hObject);

return;

% --- Executes on button press in handicappedInterface.
function handicappedInterface_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'handicappedInterface')
    setLocal(progmanager, hObject, 'advancedInterface', 0);
    setLocalGh(progmanager, hObject, 'handicappedInterface', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'advancedInterface', 'Enable', 'On');
else
    setLocal(progmanager, hObject, 'advancedInterface', 1);
    setLocalGh(progmanager, hObject, 'advancedInterface', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'handicappedInterface', 'Enable', 'On');
end

updateDisplayFromPulse(hObject);

return;

% --------------------------------------------------------------------
% --- Executes on button press in advancedInterface.
function advancedInterface_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'advancedInterface')
    setLocal(progmanager, hObject, 'handicappedInterface', 0);
    setLocalGh(progmanager, hObject, 'advancedInterface', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'handicappedInterface', 'Enable', 'On');
else
    setLocal(progmanager, hObject, 'handicappedInterface', 1);
    setLocalGh(progmanager, hObject, 'handicappedInterface', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'advancedInterface', 'Enable', 'On');
end

updateDisplayFromPulse(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function displayTimeWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayTimeWidth (see GCBO)
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

% --------------------------------------------------------------------
function displayTimeWidth_Callback(hObject, eventdata, handles)

updatePlot(hObject);

return;

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseNumberSliderUp_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% --------------------------------------------------------------------
% --- Executes on slider movement.
function pulseNumberSliderUp_Callback(hObject, eventdata, handles)

%TO081606E - Slider functionality changed as of Matlab 7, invalidating most slider code. -- Tim O'Connor 8/16/06
[pulseNumber] = getLocalBatch(progmanager, hObject, 'pulseNumber');

if isempty(pulseNumber)
    return;
%     pulseNumber = 1;
%     num = 1;
else
    num = str2num(pulseNumber);
end

if isempty(num)
    return;
end

pulseNames = getLocalGh(progmanager, hObject, 'pulseName', 'String');
numbers = [];
for i = 1 : length(pulseNames)
    suffix = getNumericSuffix(pulseNames{i});
    if ~isempty(suffix)
        numbers(length(numbers) + 1) = suffix;
    end
end
% num = max(numbers(find(numbers < num)));
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

%-------------------------------------------------------------------
%TO021510D - Created the batchPulseEditor gui. -- Tim O'Connor 2/15/10
% --- Executes on button press in batchEdit.
function batchEdit_Callback(hObject, eventdata, handles)

batchPulseEditor;

return;
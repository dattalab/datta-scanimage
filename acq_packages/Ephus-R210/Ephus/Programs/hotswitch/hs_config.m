function varargout = hs_config(varargin)
% HS_CONFIG M-file for hs_config.fig
%      HS_CONFIG, by itself, creates a new HS_CONFIG or raises the existing
%      singleton*.
%
%      H = HS_CONFIG returns the handle to a new HS_CONFIG or the handle to
%      the existing singleton*.
%
%      HS_CONFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HS_CONFIG.M with the given input arguments.
%
%      HS_CONFIG('Property','Value',...) creates a new HS_CONFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hs_config_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hs_config_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hs_config

% Last Modified by GUIDE v2.5 07-Sep-2006 15:36:20

%JL112907A change to incrementStateNumber
%JL112907B change to decrementStateNumber

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hs_config_OpeningFcn, ...
                   'gui_OutputFcn',  @hs_config_OutputFcn, ...
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
return;

% ------------------------------------------------------------------
% --- Executes just before hs_config is made visible.
function hs_config_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for hs_config
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes hs_config wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = hs_config_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function name_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function name_Callback(hObject, eventdata, handles)

[name, stateNumber] = getLocalBatch(progmanager, hObject, 'name', 'stateNumber');
mainObj = getMain(progmanager, hObject, 'hObject');
[states, pageNumber] = getLocalBatch(progmanager, mainObj, 'states', 'pageNumber');
if length(name) > 15
    name = name(1:15);
end

states(stateNumber).name = name;
setMain(progmanager, hObject, 'states', states);
hotswitch('setPageNumber', mainObj, pageNumber);
hotswitch('updateListBox', mainObj);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function runningPrograms_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on selection change in runningPrograms.
function runningPrograms_Callback(hObject, eventdata, handles)
return;

% ------------------------------------------------------------------
% --- Executes on button press in capture.
function capture_Callback(hObject, eventdata, handles)

[directory, lightConfigurations, heavyConfigurations, runningPrograms] = getLocalBatch(progmanager, hObject, ...
    'directory', 'lightConfigurations', 'heavyConfigurations', 'runningPrograms');
if ~exist(directory) == 7
    errordlg('Invalid directory selection.', 'Invalid Directory');
    fprintf(2, 'Select a directory before trying to capture configurations for hotswitching.\n');
    return;
end

if isempty(directory)
    errordlg('A directory must be specified before capturing configurations for hot switching.', 'No Directory');
    return;
end

progObj = getFigHandle(progmanager, runningPrograms);

filename = fullfile(directory, [runningPrograms '.settings']);
if exist(filename) == 2
    overwrite = questdlg(sprintf('''%s'' already exists. Overwrite?', filename), 'Confirm Overwrite', 'Yes', 'No', 'Cancel', 'Cancel');
    if strcmpi(overwrite, 'No')
        browse_Callback(hObject, eventdata, handles);
        capture_Callback(hObject, eventdata, handles);
        return;
    elseif strcmpi(overwrite, 'Cancel')
        return;
    end
end

if lightConfigurations
    saveProgramMiniSettings(progmanager, progObj, filename);
else
    saveProgramSettings(progmanager, progObj, filename);
end

for i = 1 : length(progObj)
    saveGuiMetaData(progmanager, fullfile(directory, 'guiMetaInfo.mat'), getProgramName(progmanager, progObj));
end

fprintf(1, 'hotswitch/hs_configure: Saved settings for ''%s'' in ''%s''.\n', runningPrograms, filename);

return;

% ------------------------------------------------------------------
% --- Executes on button press in lightConfigurations.
function lightConfigurations_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'lightConfigurations')
    setLocalGh(progmanager, hObject, 'lightConfigurations', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'heavyConfigurations', 'Enable', 'On');
    setLocal(progmanager, hObject, 'heavyConfigurations', 0);
else
    setLocalGh(progmanager, hObject, 'lightConfigurations', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'heavyConfigurations', 'Enable', 'Inactive');
    setLocal(progmanager, hObject, 'heavyConfigurations', 1);
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in heavyConfigurations.
function heavyConfigurations_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'heavyConfigurations')
    setLocalGh(progmanager, hObject, 'lightConfigurations', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'heavyConfigurations', 'Enable', 'Inactive');
    setLocal(progmanager, hObject, 'lightConfigurations', 0);
else
    setLocalGh(progmanager, hObject, 'lightConfigurations', 'Enable', 'Inactive');
    setLocalGh(progmanager, hObject, 'heavyConfigurations', 'Enable', 'On');
    setLocal(progmanager, hObject, 'lightConfigurations', 1);
end
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function directory_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function directory_Callback(hObject, eventdata, handles)

[directory, stateNumber] = getLocalBatch(progmanager, hObject, 'directory', 'stateNumber');
mainObj = getMain(progmanager, hObject, 'hObject');
[states, pageNumber] = getLocalBatch(progmanager, mainObj, 'states', 'pageNumber');

if exist(directory, 'dir') == 7
    setLocalGh(progmanager, hObject, 'directory', 'ForegroundColor', [0 0 0]);
    setDefaultCacheValue(progmanager, 'hotswitchDirectory', directory);
else
    setLocalGh(progmanager, hObject, 'directory', 'ForegroundColor', [1 .2 .2]);
end

states(stateNumber).directory = directory;
setMain(progmanager, hObject, 'states', states);

hotswitch('setPageNumber', mainObj, pageNumber);
hotswitch('updateListBox', mainObj);
hotswitch('updateUserFcnCallbacks', mainObj);

return;

% ------------------------------------------------------------------
% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)

directory = getDefaultCacheDirectory(progmanager, 'hotswitchDirectory');
directory = uigetdir(directory, 'Select a configuration(s) directory for this hot state...');
if length(directory) == 1
    if directory == 0
        return;
    end
end
setLocal(progmanager, hObject, 'directory', directory);
setDefaultCacheValue(progmanager, 'hotswitchDirectory', directory);
directory_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
        'hObject', hObject, ...
        'heavyConfigurations', 1, 'Class', 'Numeric', 'Gui', 'heavyConfigurations', 'Config', 5, ...
        'lightConfigurations', 0, 'Class', 'Numeric', 'Gui', 'lightConfigurations', 'Config', 5, ...
        'runningPrograms', '', 'Class', 'char', 'Gui', 'runningPrograms', ...
        'stateNumber', 1, 'Class', 'Numeric', 'Gui', 'stateNumber', 'Config', 5, ...
        'name', 'Undefined', 'Class', 'char', 'Gui', 'name', ...
        'directory', '', 'Class', 'char', 'Gui', 'directory', ...
        'decrementStateNumber', 1, 'Class', 'char', 'Gui', 'decrementStateNumber', ...
        'incrementStateNumber', 0, 'Class', 'char', 'Gui', 'incrementStateNumber', ...
      };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

setMain(progmanager, hObject, 'configObj', hObject);
hs_configureState(hObject);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

%TO031910C - Don't allow hs_configureState to change the visibility of the gui. -- Tim O'Connor 3/19/10
f = getLocal(progmanager, hObject, 'hObject');
visibility = get(f, 'Visible');

hs_configureState(hObject);

set(f, 'Visible', visibility);

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

return;

% ------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPreLoadMiniSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles, varargin)

genericUpdateFcn(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericPostLoadMiniSettings(hObject, eventdata, handles, varargin)

genericPostLoadSettings(hObject, eventdata, handles, varargin{:});

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericNewData(hObject, eventdata, handles)

errordlg('New functionality not supported by this GUI.');

return;

% ------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

errordlg('Open functionality not supported by this GUI.');

return;

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

errordlg('Save functionality not supported by this GUI.');

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

errordlg('Save As functionality not supported by this GUI.');

% [f, p] = uiputfile(fullfile(getDefaultCacheDirectory(progmanager, 'cyclePath'), '*.pj'));
% if length(f) == 1
%     if f == 0
%         if length(p) == 1
%             if p == 0
%                 return;
%             end
%         end
%     end
% end
% if ~endsWithIgnoreCase(f, '.pj')
%     f = [f '.pj'];
% end
% pj_saveCycle(hObject, fullfile(p, f));

return;

% ------------------------------------------------------------------
function genericPreCacheSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPreCacheMiniSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostCacheSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostCacheMiniSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCacheOperationBegin(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCacheOperationComplete(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function stateNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function stateNumber_Callback(hObject, eventdata, handles)

hs_configureState(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function incrementStateNumber_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function incrementStateNumber_Callback(hObject, eventdata, handles)

stateNumber = getLocal(progmanager, hObject, 'stateNumber');
totalStates = getMain(progmanager, hObject, 'totalStates');
if stateNumber < totalStates
    stateNumber = stateNumber + 1;
else
    stateNumber = totalStates;
end

%JL112907A change to incrementStateNumber
setLocalBatch(progmanager, hObject, 'incrementStateNumber', 0, 'stateNumber', stateNumber);
stateNumber_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function decrementStateNumber_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject, 'BackgroundColor', [.9 .9 .9]);
else
    set(hObject, 'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function decrementStateNumber_Callback(hObject, eventdata, handles)

stateNumber = getLocal(progmanager, hObject, 'stateNumber');
if stateNumber > 1
    stateNumber = stateNumber - 1;
else
    stateNumber = 1;
end

%JL112907B change to decrementStateNumber
setLocalBatch(progmanager, hObject, 'decrementStateNumber', 1, 'stateNumber', stateNumber);
stateNumber_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes on button press in captureAll.
function captureAll_Callback(hObject, eventdata, handles)

directory = getLocal(progmanager, hObject, 'directory');
if ~exist(directory) == 7
    errordlg('Invalid directory selection.', 'Invalid Directory');
    fprintf(2, 'Select a directory before trying to capture configurations for hotswitching.\n');
    return;
end

saveConfigurations(progmanager, directory);
delete(fullfile(directory, 'hotswitch.settings'));%TO112907E - Don't save the hotswitch state as part of the hotswitch.

%TO032210F - Don't save the meta data for the Hotswitch config gui, since it must always be open by definition, and will likely pop up later when not wanted. -- Tim O'Connor 3/22/10
metaData = load(fullfile(directory, 'guiMetaInfo.mat'), '-mat');
metaData.progmanagerGuisConfig.hotswitch.guis = rmfield(metaData.progmanagerGuisConfig.hotswitch.guis, 'hs_config');
progmanagerGuisConfig = metaData.progmanagerGuisConfig;
saveCompatible(fullfile(directory, 'guiMetaInfo.mat'), 'progmanagerGuisConfig', '-mat');%TO071906D

return;

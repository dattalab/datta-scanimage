function varargout = cycler(varargin)
% CYCLER M-file for cycler.fig
%      CYCLER, by itself, creates a new CYCLER or raises the existing
%      singleton*.
%
%      H = CYCLER returns the handle to a new CYCLER or the handle to
%      the existing singleton*.
%
%      CYCLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CYCLER.M with the given input arguments.
%
%      CYCLER('Property','Value',...) creates a new CYCLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cycler_OpeningFunction gets called.  An
%      unrecognized property cycleName or invalid value makes property application
%      stop.  All inputs are passed to cycler_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cycler

% Last Modified by GUIDE v2.5 16-Aug-2006 18:24:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cycler_OpeningFcn, ...
                   'gui_OutputFcn',  @cycler_OutputFcn, ...
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
% --- Executes just before cycler is made visible.
function cycler_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cycler (see VARARGIN)

% Choose default command line output for cycler
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cycler wait for user response (see UIRESUME)
% uiwait(handles.figure1);

return;

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = cycler_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'compressDisplay', 0, 'Class', 'Numeric', 'Gui', 'compressDisplay', 'Config', 1, ...
       'cycleName', '', 'Class', 'char', 'Gui', 'cycleName', 'Config', 3, ...
       'selectedConfigurations', '', 'Class', 'char', 'Gui', 'selectedConfigurations', ...
       'availableConfigurations', '', 'Class', 'char', 'Gui', 'availableConfigurations', ...
       'currentProgram', '', 'Class', 'char', 'Gui', 'currentProgram', ...
       'programs', {}, 'Class', 'cell', ...
       'configurationName', '', 'Class', 'char', 'Gui', 'configurationName', ...
       'pathname', pwd, 'Class', 'char', 'Config', 3, ...
       'currentPosition', 0, 'Class', 'Numeric', 'Gui', 'currentPosition', 'Config', 3, ...
       'currentPositionSliderUp', 0, 'Class', 0, 'Min', 0, 'Max', 1, 'Gui', 'currentPositionSliderUp', ...
       'currentPositionSliderDown', 1, 'Class', 0, 'Min', 0, 'Max', 1, 'Gui', 'currentPositionSliderDown', ...
       'selectedConfigurations', '', 'Class', 'char', 'Gui', 'selectedConfigurations', ...
       'availableConfigurations', '', 'Class', 'char', 'Gui', 'availableConfigurations', ...
       'positions', {}, ...
       'positionIterations', 0, 'Class', 'Numeric', 'Gui', 'positionIterations', ...
       'positionIterationsArray', [], 'Config', 3, ...
       'iterationCounter', 0, 'Config', 2, ...
       'enable', 0, 'Class', 'Numeric', 'Gui', 'enable', ...
       'displayCompressed', 0, 'Class', 'Numeric', ...
       'configLoadedFlag', 0, 'Class', 'Numeric', ...
       'captureType', 'light', 'Config', 1, 'class', 'char', ...
       'programInitialStateCache', {}, 'Class', 'cell'...
       'refreshPosition', 0, ...
       'precacheAllCycles', 1, 'Class', 'Numeric', 'Config', 1, 'Gui', 'precacheAllCycles', ...
       'heavyConfigurations', 0, 'Class', 'Numeric', 'Config', 1, 'Gui', 'heavyConfigurations', ...
       'verboseLoading', 0, 'Class', 'Numeric', 'Config', 1, 'Gui', 'verboseLoading', ...
      };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

%TO080406B - Add user functions for cycler enable/disable and position update operations.
cbm = getUserFcnCBM;
addEvent(cbm, 'cycler:Enable');
addEvent(cbm, 'cycler:Disable');
addEvent(cbm, 'cycler:PositionUpdate');

% cycler_registerProgram(hObject, hObject);
enableControlsByCycleSelection(hObject);

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

%------------------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

return;

%------------------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

return;

%------------------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

return;

%------------------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles)

if ~isempty(getLocal(progmanager, hObject, 'cycleName'))
    cycleName_Callback(hObject, eventdata, handles);
end

setLocal(progmanager, hObject, 'configLoadedFlag', 1);
compressDisplay_Callback(hObject, eventdata, handles);
setLocal(progmanager, hObject, 'configLoadedFlag', 0);
% [cycleName pathname] = getLocalBatch(progmanager, hObject, 'cycleName', 'pathname');
% if isempty(filename) | isempty(pathname)
%     return;
% end
% if exist(pathname) ~= 7
%     error('Pathname loaded via configuration does not exist: ''%s''', pathname);
% end
% filename = [cycleName '.cycle'];
% if exist(fullfile(pathname, filename)) ~= 2
%     error('Cycle file loaded via configuration can not be found: ''%s''', filename);
% end
% 
% setPath(hObject, pathname);
% 
% loadCycleFrom(hObject, pathname, filename);
return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function currentProgram_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on selection change in currentProgram.
function currentProgram_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in captureConfig.
function captureConfig_Callback(hObject, eventdata, handles)

configurationName = getLocal(progmanager, hObject, 'configurationName');
if isempty(configurationName)
    errordlg('No configuration name specified.');
    error('No configuration name specified for cycler capture.');
end

availableConfigurations = getLocalGh(progmanager, hObject, 'availableConfigurations', 'String');
if length(availableConfigurations) == 1 & isempty(availableConfigurations{1})
    availableConfigurations = {};
end

if ismember(lower(configurationName), lower(availableConfigurations))
    yesOrNo = questdlg(sprintf('Configuration ''%s'' already exists. Overwrite?', configurationName), 'Confirm Overwrite', 'Yes', 'No', 'No');
    if strcmpi(yesOrNo, 'No')
        return;
    else
        setLocal(progmanager, hObject, 'availableConfigurations', configurationName);
        deleteAvailableConfiguration_Callback(hObject, eventdata, handles);
        availableConfigurations = {availableConfigurations{find(~strcmpi(configurationName, availableConfigurations))}};%TO022406A - Added surrounding brackets. -- Tim O'Connor 2/24/06
    end
end

currentProgram = getLocal(progmanager, hObject, 'currentProgram');
programs = getLocal(progmanager, hObject, 'programs');

index = find(strcmpi({programs{:, 1}}, currentProgram));
if isempty(index)
    errordlg('Program handle not found.');
    error('Program handle not found while capturing configuration: %s', currentProgram);
elseif length(index) > 1
    errordlg('Indeterminate program handle.');
    error('More than one program handle has been found for program: %s', currentProgram);
end

if strcmpi(getLocal(progmanager, hObject, 'captureType'), 'light')
    config.settings = getProgramMiniSettings(progmanager, programs{index, 2});
else
    config.settings = getProgramSettings(progmanager, programs{index, 2});
end
config.programName = currentProgram;
%%%%%%%%%%%%%%%%%%%%%%%%%%   TEST
% sc = get(config.settings.ephys, 'signalCollection');
% sc = sc{2, 2};
% sc = sc(1);
% save('test.signals', 'sc', '-mat')
% load('test.signals', '-mat')
% load('test.signals', '-mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%   END_TEST
saveCompatible(fullfile(getLocal(progmanager, hObject, 'pathname'), [getLocal(progmanager, hObject, 'cycleName') '_configurations'], [configurationName '.settings']), 'config', '-mat');%%TO120205F %TO071906D

if isempty(availableConfigurations)
    availableConfigurations = {};%Make sure it's a cell array.
elseif ~strcmpi(class(availableConfigurations), 'cell')
    availableConfigurations = {availableConfigurations};
end

availableConfigurations = {availableConfigurations{:} configurationName}';
setLocalGh(progmanager, hObject, 'availableConfigurations', 'String', availableConfigurations, 'Enable', 'On');
setLocal(progmanager, hObject, 'availableConfigurations', configurationName);

enableControlsByCycleSelection(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function cycleName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function cycleName_Callback(hObject, eventdata, handles)

pathname = getLocal(progmanager, hObject, 'pathname');
cycleName = getLocal(progmanager, hObject, 'cycleName');
fullname = fullfile(pathname, cycleName);

if exist([fullname '.cycle']) ~= 2 
    errordlg('Missing cycle file.');
elseif exist([fullname '_configurations']) ~= 7
    errordlg('Missing configurations directory.');
end

loadCycleFrom(hObject, pathname, [cycleName '.cycle']);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function currentPositionSliderUp_CreateFcn(hObject, eventdata, handles)

usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function currentPositionSliderUp_Callback(hObject, eventdata, handles)

%TO081606E - Slider functionality changed as of Matlab 7, invalidating most slider code. -- Tim O'Connor 8/16/06
[currentPosition, positions] = getLocalBatch(progmanager, hObject, 'currentPosition', 'positions');

if currentPosition < length(positions)
    setLocal(progmanager, hObject, 'currentPosition', currentPosition + 1);
end
setLocal(progmanager, hObject, 'currentPositionSliderUp', 0);

currentPosition_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function selectedConfigurations_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on selection change in selectedConfigurations.
function selectedConfigurations_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function availableConfigurations_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on selection change in availableConfigurations.
function availableConfigurations_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in addConfiguration.
function addConfiguration_Callback(hObject, eventdata, handles)

[positions currentPosition availableConfigurations] = getLocalBatch(progmanager, hObject, 'positions', 'currentPosition', 'availableConfigurations');
if currentPosition < 1
    return;
end
if ~isempty(positions)
    position = {positions{currentPosition}{:}};
else
    position = {};
end

if ~isempty(position)
    if ismember(availableConfigurations, position)
        fprintf(2, 'Warning (Cycler): Configuration ''%s'' already added to cycle position %s.\n', availableConfigurations, num2str(currentPosition));
        return;
    end
end
if isempty(position)
    positions{currentPosition} = {availableConfigurations};
else
    positions{currentPosition} = {position{:}, availableConfigurations};
end
setLocal(progmanager, hObject, 'positions', positions);

currentPosition_Callback(hObject, eventdata, handles);

saveInto(hObject, getLocal(progmanager, hObject, 'pathname'), getLocal(progmanager, hObject, 'cycleName'));

return;

% ------------------------------------------------------------------
% --- Executes on button press in deleteSelectedConfiguration.
function deleteSelectedConfiguration_Callback(hObject, eventdata, handles)

[positions currentPosition selectedConfigurations] = getLocalBatch(progmanager, hObject, 'positions', 'currentPosition', ...
    'selectedConfigurations');

if currentPosition < 1
    return;
end

temp = positions{currentPosition};

indices = find(~strcmp(temp, selectedConfigurations));

positions{currentPosition} = {temp{indices}};
setLocal(progmanager, hObject, 'positions', positions);

%TO120905I: This shouldn't get changed unless the entire position was deleted. -- Tim O'Connor 12/9/05
% %TO092605B
% positionIterationsArray = getLocal(progmanager, hObject, 'positionIterationsArray');%TO022106A
% setLocal(progmanager, hObject, 'positionIterationsArray', positionIterationsArray(indices));%TO120905G - Can't just pass in `positions(indices)`.%TO022106A

currentPosition_Callback(hObject, eventdata, handles);

saveInto(hObject, getLocal(progmanager, hObject, 'pathname'), getLocal(progmanager, hObject, 'cycleName'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function currentPosition_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function currentPosition_Callback(hObject, eventdata, handles)

%Broken out into its own file.
cycler_currentPosition_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function configurationName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function configurationName_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in newPosition.
function newPosition_Callback(hObject, eventdata, handles)

positions = getLocal(progmanager, hObject, 'positions');
positions{length(positions) + 1} = {};
setLocal(progmanager, hObject, 'positions', positions);

%TO092605B %TO022106A
positionIterationsArray = getLocal(progmanager, hObject, 'positionIterationsArray');
positionIterationsArray(length(positionIterationsArray) + 1) = 1;
setLocal(progmanager, hObject, 'positionIterationsArray', positionIterationsArray);

setLocal(progmanager, hObject, 'currentPosition', length(positions));
enableControlsByCycleSelection(hObject);

saveInto(hObject, getLocal(progmanager, hObject, 'pathname'), getLocal(progmanager, hObject, 'cycleName'));
currentPosition_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes on button press in newCycle.
function newCycle_Callback(hObject, eventdata, handles)

pathname = getLocal(progmanager, hObject, 'pathname');
[filename pathname] = uiputfile('*.cycle', 'Create a new cycle file', [pathname '\']);
if filename == 0 
    return;
elseif pathname == 0
    return;
end
if endsWithIgnoreCase(filename, '.cycle')
    filename = filename(1 : length(filename) - 6);
end

%TO092605B %TO022106A
setLocal(progmanager, hObject, 'positions', {});
setLocal(progmanager, hObject, 'positionIterationsArray', []);
setLocal(progmanager, hObject, 'positionIterations', 1);

saveInto(hObject, pathname, filename);

enableControlsByCycleSelection(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in loadCycle.
function loadCycle_Callback(hObject, eventdata, handles)

[filename pathname] = uigetfile('*.cycle', 'Select a directory of cycle files', [getLocal(progmanager, hObject, 'pathname') '\']);
if length(filename) == 1 & length(pathname) == 1
    if filename == 0 | pathname == 0
        return;
    end
end
setPath(hObject, pathname);

loadCycleFrom(hObject, pathname, filename);

return;

% ------------------------------------------------------------------
function loadCycleFrom(hObject, pathname, filename)

%TO092605B %TO022106A
config = load(fullfile(pathname, filename), '-mat');
setLocal(progmanager, hObject, 'positions', config.positions);
setLocal(progmanager, hObject, 'positionIterationsArray', config.positionIterationsArray);

currentPosition = getLocal(progmanager, hObject, 'currentPosition');
if currentPosition > size(config.positions, 1)
    currentPosition = size(config.positions, 1);
    setLocal(progmanager, hObject, 'currentPosition', currentPosition);%TO120905J
end

cycleName = filename(1 : length(filename) - 6);
setLocal(progmanager, hObject, 'cycleName', cycleName);

configurations = dir(fullfile(pathname, [cycleName '_configurations']));
availableConfigurations = {};
for i = 1 : length(configurations)
    if endsWithIgnoreCase(configurations(i).name, '.settings') %%TO120205F
        availableConfigurations{length(availableConfigurations) + 1} = configurations(i).name(1 : length(configurations(i).name) - 9);
    end
end

if isempty(availableConfigurations)
    availableConfigurations = {''};
    setLocalGh(progmanager, hObject, 'availableConfigurations', 'String', availableConfigurations, 'Enable', 'Off');
end
setLocalGh(progmanager, hObject, 'availableConfigurations', 'String', availableConfigurations);

enableControlsByCycleSelection(hObject);
currentPosition_Callback(hObject, [], guidata(hObject));

return;

% ------------------------------------------------------------------
function saveInto(hObject, pathname, filename)

dirName = fullfile(pathname, filename);
if exist(dirName) ~= 7
    [success message messageid] = mkdir(pathname, [filename '_configurations']);
    if ~success
        msg = sprintf('Failed to create directory ''%s''...\n%s:%s', fullfile(pathname, filename), message, messageid);
        errordlg(msg);
        error(msg);
    end
end
positions = getLocal(progmanager, hObject, 'positions');
%TO092605B %TO022106A
positionIterationsArray = getLocal(progmanager, hObject, 'positionIterationsArray');
saveCompatible(fullfile(pathname, [filename '.cycle']), 'positions', 'positionIterationsArray', '-mat');%TO071906D

setPath(hObject, pathname);
setLocal(progmanager, hObject, 'cycleName', filename);

return;

% ------------------------------------------------------------------
function setPath(hObject, pathname)

cycleName = getLocal(progmanager, hObject, 'cycleName');
setLocal(progmanager, hObject, 'pathname', pathname);
cycleFiles = dir([pathname '\*.cycle']);
cycleList = {};
for i = 1 : length(cycleFiles)
    if ~cycleFiles(i).isdir
        cycleList{length(cycleList) + 1} = cycleFiles(i).name(1 : length(cycleFiles(i).name) - 6);
        if exist(fullfile(pathname, [cycleList{length(cycleList)} '_configurations'])) ~= 7
            warning('No configurations found for cycle ''%s''.', cycleList{length(cycleList)});
        end
    end
end
setLocalGh(progmanager, hObject, 'cycleName', 'String', cycleList);
if ismember(cycleList, cycleName)
    setLocal(progmanager, hObject, 'cycleName', cycleName);
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in deletePosition.
function deletePosition_Callback(hObject, eventdata, handles)

positions = getLocal(progmanager, hObject, 'positions');
if isempty(positions)
    return;
end

currentPosition = getLocal(progmanager, hObject, 'currentPosition');

positions = {positions{find(1:length(positions) ~= currentPosition)}};

if currentPosition > length(positions)
    currentPosition = length(positions);
elseif currentPosition < 1 & ~isempty(positions)
    currentPosition = 1;
end
setLocal(progmanager, hObject, 'positions', positions);

enableControlsByCycleSelection(hObject);

saveInto(hObject, getLocal(progmanager, hObject, 'pathname'), getLocal(progmanager, hObject, 'cycleName'));
currentPosition_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes on button press in moveUp.
function moveUp_Callback(hObject, eventdata, handles)

positions = getLocal(progmanager, hObject, 'positions');
if isempty(positions)
    return;
end

currentPosition = getLocal(progmanager, hObject, 'currentPosition');
if currentPosition == length(positions)
    return;
end

temp = positions{currentPosition + 1};
positions{currentPosition + 1} = positions{currentPosition};
positions{currentPosition} = temp;

%TO092605B %TO022106A
%TO120705A - positionIterationsArray is numeric, not a cell array. -- Tim O'Connor 12/7/05
positionIterationsArray = getLocal(progmanager, hObject, 'positionIterationsArray');
temp2 = positionIterationsArray(currentPosition + 1);
positionIterationsArray(currentPosition + 1) = positionIterationsArray(currentPosition);
positionIterationsArray(currentPosition) = temp2;

setLocalBatch(progmanager, hObject, 'positions', positions, 'currentPosition', currentPosition + 1, 'positionIterationsArray', positionIterationsArray);

saveInto(hObject, getLocal(progmanager, hObject, 'pathname'), getLocal(progmanager, hObject, 'cycleName'));

currentPosition_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes on button press in moveDown.
function moveDown_Callback(hObject, eventdata, handles)

positions = getLocal(progmanager, hObject, 'positions');
if isempty(positions)
    return;
end

currentPosition = getLocal(progmanager, hObject, 'currentPosition');
if currentPosition == 1
    return;
end

temp = positions{currentPosition - 1};
positions{currentPosition - 1} = positions{currentPosition};
positions{currentPosition} = temp;

%TO092605B %TO022106A
%TO120705A - positionIterationsArray is numeric, not a cell array. -- Tim O'Connor 12/7/05
positionIterationsArray = getLocal(progmanager, hObject, 'positionIterationsArray');
temp2 = positionIterationsArray(currentPosition - 1);
positionIterationsArray(currentPosition - 1) = positionIterationsArray(currentPosition);
positionIterationsArray(currentPosition) = temp2;

setLocalBatch(progmanager, hObject, 'positions', positions, 'currentPosition', currentPosition - 1, 'positionIterationsArray', positionIterationsArray);

saveInto(hObject, getLocal(progmanager, hObject, 'pathname'), getLocal(progmanager, hObject, 'cycleName'));

currentPosition_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes on button press in deleteAvailableConfiguration.
function deleteAvailableConfiguration_Callback(hObject, eventdata, handles)

configurationName = getLocal(progmanager, hObject, 'availableConfigurations');
delete(fullfile(getLocal(progmanager, hObject, 'pathname'), [getLocal(progmanager, hObject, 'cycleName') '_configurations'], ...
    [configurationName '.settings']));%TO120205F

availableConfigurations = getLocalGh(progmanager, hObject, 'availableConfigurations', 'String');
if length(availableConfigurations) == 1 | isempty(availableConfigurations)
    availableConfigurations = {};
end
indices = find(~strcmpi(availableConfigurations, configurationName));
if ~isempty(indices)
    availableConfigurations = {availableConfigurations{indices}};
end
if ~isempty(availableConfigurations)
    setLocalGh(progmanager, hObject, 'availableConfigurations', 'String', availableConfigurations, 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'availableConfigurations', 'String', availableConfigurations, 'Enable', 'Off');
end

setLocalGh(progmanager, hObject, 'availableConfigurations', 'String', availableConfigurations);

saveInto(hObject, getLocal(progmanager, hObject, 'pathname'), getLocal(progmanager, hObject, 'cycleName'));

enableControlsByCycleSelection(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in loadConfigurations.
function loadConfigurations_Callback(hObject, eventdata, handles)

loaded = load(fullfile(getLocal(progmanager, hObject, 'pathname'), [getLocal(progmanager, hObject, 'cycleName') '_configurations'], ...
    [getLocal(progmanager, hObject, 'selectedConfigurations') '.settings']), '-mat');%TO120205F
config = loaded.config;

if ~ismember(lower(config.programName), lower(fieldnames(config.settings)))
    warning('Cycler configuration ''%s'' may have become corrupted.', getLocal(progmanager, hObject, 'cycleName'));
end
    
programs = getLocal(progmanager, hObject, 'programs');
index = find(strcmpi({programs{:, 1}}, config.programName));
if isempty(index)
    error('No program found with name ''%s''.', config.programName);
elseif length(index) > 1
    warning('Multiple programs found with name ''%s''.', config.programName);
end

for i = 1 : length(index)
    setProgramSettings(progmanager, programs{index(i), 2}, config.settings);
end

return;
% currentProgram = getLocal(progmanager, hObject, 'currentProgram');
% programs = getLocal(progmanager, hObject, 'programs');
% 
% index = find(strcmpi({programs{:, 1}}, currentProgram));
% if isempty(index)
%     errordlg('Program handle not found.');
%     error('Program handle not found while capturing configuration: %s', currentProgram);
% elseif length(index) > 1
%     errordlg('Indeterminate program handle.');
%     error('More than one program handle has been found for program: %s', currentProgram);
% end
% 
% config.settings = getProgramSettings(progmanager, programs{index, 2});
% config.programName = currentProgram;
% save(fullfile(getLocal(progmanager, hObject, 'pathname'), [getLocal(progmanager, hObject, 'cycleName') '_configurations'], [configurationName '.settings']), 'config', '-mat');%TO120205F
% 
% if isempty(availableConfigurations)
%     availableConfigurations = {};%Make sure it's a cell array.
% end
% availableConfigurations = {availableConfigurations{:} configurationName};
% setLocalGh(progmanager, hObject, 'availableConfigurations', 'String', availableConfigurations, 'Enable', 'On');
% setLocal(progmanager, hObject, 'availableConfigurations', configurationName);
% 
% return;

% ------------------------------------------------------------------
% --- Executes on button press in enable.
function enable_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'enable')
    setLocalGh(progmanager, hObject, 'enable', 'String', 'Disable', 'ForegroundColor', [1 0 0]);
    cycler_loadEntirePosition(hObject);%TO022406C - Automatically load the current position when first enabled. -- Tim O'Connor 2/24/06
    fireEvent(getUserFcnCBM, 'cycler:Enable');%TO080406B - Add user functions for cycler enable/disable. -- Tim O'Connor 8/04/06
else
    fireEvent(getUserFcnCBM, 'cycler:Disable');%TO080406B - Add user functions for cycler enable/disable. -- Tim O'Connor 8/04/06
    setLocalGh(progmanager, hObject, 'enable', 'String', 'Enable', 'ForegroundColor', [0 0.6 0]);
    cycler_restoreProgramStateCache(hObject);
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in enable.
function othersaveCycleAs_Callback(hObject, eventdata, handles)

pathname = getLocal(progmanager, hObject, 'pathname');
[filename pathname] = uiputfile('*.cycle', 'Create a new cycle file', pathname);
if length(filename) == 1 & length(pathname) == 1
    if filename == 0 | pathname == 0
        return;
    end
end
if endsWithIgnoreCase(filename, '.cycle')
    filename = filename(1 : length(filename) - 6);
end

saveInto(hObject, pathname, filename);

return;

% ------------------------------------------------------------------
% --- Executes on button press in compressDisplay.
function compressDisplay_Callback(hObject, eventdata, handles)

f = getParent(hObject, 'figure');
kids = get(f, 'Children');
pos = get(f, 'Position');

% [103.80000000000001 32.30769230769234 82.2 29.153846153846164];
% [103.80000000000001 49.38461538461544 82.2 10.7692];
% [103.80000000000001 49.38461538461544 82.2 12.076923076923082];
% 29.153846153846164 - 12.076923076923082 - 1.3076923076923077;
shift = 15.7692;
shift = shift + 2.6;
if getLocal(progmanager, hObject, 'compressDisplay') & ~getLocal(progmanager, hObject, 'displayCompressed')
    setLocalGh(progmanager, hObject, 'compressDisplay', 'String', 'Expand Display');
    for i = 1 : length(kids)
        type = get(kids(i), 'Type');
        if ~strcmpi(type, 'uitoolbar') & ~strcmpi(type, 'uimenu')
            p = get(kids(i), 'Position');
            p(2) = p(2) - shift;
            set(kids(i), 'Position', p);
        end
    end
    setLocalGh(progmanager, hObject, 'availableConfigurations', 'Visible', 'Off');
    setLocalGh(progmanager, hObject, 'text5', 'Visible', 'Off');
    setLocalGh(progmanager, hObject, 'frame5', 'Visible', 'Off');
    if ~getLocal(progmanager, hObject, 'configLoadedFlag')
        pos(2) = pos(2) + 18.3769;
    end
    pos(4) = 10.7692;
%     set(f, 'Position', [103.80000000000001 50.68461538461544 82.2 10.7692]);
    set(f, 'Position', pos);
    setLocal(progmanager, hObject, 'displayCompressed', 1);
elseif getLocal(progmanager, hObject, 'displayCompressed')
    setLocalGh(progmanager, hObject, 'compressDisplay', 'String', 'Compress Display');
    for i = 1 : length(kids)
        type = get(kids(i), 'Type');
        if ~strcmpi(type, 'uitoolbar') & ~strcmpi(type, 'uimenu')
            p = get(kids(i), 'Position');
            p(2) = p(2) + shift;
            set(kids(i), 'Position', p);
        end
    end
    if ~getLocal(progmanager, hObject, 'configLoadedFlag')
        pos(2) = pos(2) - 18.3769;
    end
    pos(4) = 29.153846153846164;
%     set(f, 'Position', [103.80000000000001 32.30769230769234 82.2 29.153846153846164]);
    set(f, 'Position', pos);
    setLocalGh(progmanager, hObject, 'availableConfigurations', 'Visible', 'On');
    setLocalGh(progmanager, hObject, 'text5', 'Visible', 'On');
    setLocalGh(progmanager, hObject, 'frame5', 'Visible', 'On');
    setLocal(progmanager, hObject, 'displayCompressed', 0);
end

return;

% ------------------------------------------------------------------
function enableControlsByCycleSelection(hObject)

%Broken out into its own file.
cycler_enableControlsBySelection(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function positionIterations_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function positionIterations_Callback(hObject, eventdata, handles)

%TO092605B %TO022106A
positionIterationsArray = getLocal(progmanager, hObject, 'positionIterationsArray');
currentPosition = getLocal(progmanager, hObject, 'currentPosition');
positionIterationsArray(currentPosition) = getLocal(progmanager, hObject, 'positionIterations');
setLocal(progmanager, hObject, 'positionIterationsArray', positionIterationsArray);

saveInto(hObject, getLocal(progmanager, hObject, 'pathname'), getLocal(progmanager, hObject, 'cycleName'));

return;

% ------------------------------------------------------------------
% --- Executes on button press in precacheAllCycles.
function precacheAllCycles_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in heavyConfigurations.
function heavyConfigurations_Callback(hObject, eventdata, handles)

%TO080306H: Made this an option on the gui. -- Tim O'Connor 8/3/06
if getLocal(progmanager, hObject, 'heavyConfigurations')
    setLocal(progmanager, hObject, 'captureType', 'heavy');
else
    setLocal(progmanager, hObject, 'captureType', 'light');
end    

return;

% ------------------------------------------------------------------
% --- Executes on button press in verboseLoading.
function verboseLoading_Callback(hObject, eventdata, handles)

return;

% --- Executes on slider movement.
function currentPositionSliderDown_Callback(hObject, eventdata, handles)

%TO081606E - Slider functionality changed as of Matlab 7, invalidating most slider code. -- Tim O'Connor 8/16/06
[currentPosition, positions] = getLocalBatch(progmanager, hObject, 'currentPosition', 'positions');

if currentPosition > 1
    setLocal(progmanager, hObject, 'currentPosition', currentPosition - 1);
end
setLocal(progmanager, hObject, 'currentPositionSliderDown', 1);

currentPosition_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function currentPositionSliderDown_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

return;
function varargout = experimentSavingGui(varargin)
% EXPERIMENTSAVINGGUI M-file for experimentSavingGui.fig
%      EXPERIMENTSAVINGGUI, by itself, creates a new EXPERIMENTSAVINGGUI or raises the existing
%      singleton*.
%
%      H = EXPERIMENTSAVINGGUI returns the handle to a new EXPERIMENTSAVINGGUI or the handle to
%      the existing singleton*.
%
%      EXPERIMENTSAVINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERIMENTSAVINGGUI.M with the given input arguments.
%
%      EXPERIMENTSAVINGGUI('Property','Value',...) creates a new EXPERIMENTSAVINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before experimentSavingGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to experimentSavingGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help experimentSavingGui

% Last Modified by GUIDE v2.5 16-Feb-2010 14:05:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @experimentSavingGui_OpeningFcn, ...
                   'gui_OutputFcn',  @experimentSavingGui_OutputFcn, ...
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


% --- Executes just before experimentSavingGui is made visible.
function experimentSavingGui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes experimentSavingGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%------------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = experimentSavingGui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)
%  TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
out = {
       'hObject', hObject, ...
       'cbManager', callbackmanager, ...
       'directory', pwd, 'Class', 'char', 'Gui', 'directory', 'Config', 3, ...
       'initials', 'AA', 'Class', 'char', 'Gui', 'initials', 'Config', 3, ...
       'experimentNumber', '0001', 'Class', 'char', 'Gui', 'experimentNumber', 'Config', 3, ...
       'setID', 'AAAA', 'Class', 'char', 'Gui', 'setID', 'Config', 3, ...
       'acquisitionNumber', '0001', 'Class', 'char', 'Gui', 'acquisitionNumber', 'Config', 3, ...
       'acquisitionNumberBackup', '0001', ...
       'autosave', 1, 'Class', 'Numeric', 'Gui', 'autosave', 'Config', 1, ...
       'programHandles', [], ...
       'dataCreatingGuiCallbacks', {}, ...
       'started', 0, ...
       'status', '', 'Class', 'char', 'Gui', 'status', ...
       'addExperimentNumberToPath', 1, 'Class', 'Numeric', 'Gui', 'addExperimentNumberToPath', 'Config', 3, ...
       'addSetIDToPath', 0, 'Class', 'Numeric', 'Gui', 'addSetIDToPath', 'Config', 3, ...
       'configurationEnabled', 0, 'Class', 'Numeric', 'Gui', 'configurationEnabled', ...
       'configurationCache', [], ...
       'addInitialsToPath', 1, 'Class', 'Numeric', 'Gui', 'addInitialsToPath', 'Config', 3, ...
       'concatenateInitialsAndExpNum', 1, 'Class', 'Numeric', 'Gui', 'concatenateInitialsAndExpNum', 'Config', 3, ...
       'epoch', '0', 'Class', 'char', 'Gui', 'epoch', 'Min', 0, 'Config', 3, ...
       'overwriteConfirmedForDirectory', '', ...
       'streamToDisk', 0, 'Class', 'Numeric', 'Gui', 'streamToDisk', 'Config', 3, ...
       'fileHandleMap', {}, ...
       'zipFilesOnCompletion', 0, 'Class', 'Numeric', 'Gui', 'zipFilesOnCompletion', 'Config', 3, ...
       'xsgFileFormatVersion', '1.2.1', ...
      };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

% cbManager = getLocal(progmanager, hObject, 'cbManager');
% addEvent(cbManager, 'save');

cbm = getUserFcnCBM;
%TO060810D - Check for event existence.
if ~isEvent(cbm, 'xsg:Save')
    addEvent(cbm, 'xsg:Save', 'Passes the header and data as arguments.');
end
if ~isEvent(cbm, 'xsg:NewCell')
    addEvent(cbm, 'xsg:NewCell');
end

%TO123005F - Created xsg_saveData. Incrementing of the acquisition number is done in there now (so it's only incremented when a save actually occurs).
% bindStartListener(startmanager('acquisition'), {@incrementAcquisitionNumber, hObject}, 'experimentSavingGui');
% bindStartListener(startmanager('acquisition'), {@startmanagerCallback, hObject}, 'experimentSavingGui');
bindEventListener(daqjob('acquisition'), 'jobDone', {@xsg_saveData, hObject}, 'experimentSavingGui');
bindEventListener(daqjob('acquisition'), 'jobStart', {@xsg_StartAcqCallback, hObject}, 'experimentSavingGuiStartAcq');%TO101507D
bindEventListener(daqjob('acquisition'), 'jobTrigger', {@xsg_TriggerCallback, hObject}, 'experimentSavingGuiStartAcq');%TO101507D

%TO042806G - Check highlighting on startup, as well as on configuration load. -- Tim O'Connor 4/28/06
autosave_Callback(hObject, eventdata, handles);%TO033106B - Make sure to update the highlighting on the checkbox. -- Tim O'Connor 3/31/06
configurationEnabled_Callback(hObject, eventdata, handles);%TO042806G - Make sure to update the highlighting on the checkbox. -- Tim O'Connor 4/28/06

return;

% ------------------------------------------------------------------
%TO101507D
function xsg_StartAcqCallback(hObject, varargin)

setLocal(progmanager, hObject, 'started', 1);

return;

% ------------------------------------------------------------------
function xsg_TriggerCallback(hObject, varargin)

setLocal(progmanager, hObject, 'started', 1);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.3;

return;

%------------------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

% [experimentNumber, setID, acquisitionNumber] = getLocalBatch(progmanager, hObject, 'experimentNumber', 'setID', 'acquisitionNumber');
% fprintf(1, 'xsg: config saved - %s:%s:%s\n%s', experimentNumber, setID, acquisitionNumber, getStackTraceString);

return;

%------------------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

return;

%------------------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

%TO042806B: Make sure all relevant variables are cached and restored. -- Tim O'Connor 4/28/06
if ~getLocal(progmanager, hObject, 'configurationEnabled')
    [directory, initials, experimentNumber, setID, acquisitionNumber, addExperimentNumberToPath, addSetIDToPath, ...
        addInitialsToPath, concatenateInitialsAndExpNum, autosave] = getLocalBatch(progmanager, hObject, ...
        'directory', 'initials', 'experimentNumber', 'setID', 'acquisitionNumber', 'addExperimentNumberToPath', 'addSetIDToPath', ...
        'addInitialsToPath', 'concatenateInitialsAndExpNum', 'autosave');
    cache.directory = directory;
    cache.initials = initials;
    cache.experimentNumber = experimentNumber;
    cache.setID = setID;
    cache.acquisitionNumber = acquisitionNumber;
    cache.addExperimentNumberToPath = addExperimentNumberToPath;
    cache.addSetIDToPath = addSetIDToPath;
    cache.addInitialsToPath = addInitialsToPath;
    cache.concatenateInitialsAndExpNum = concatenateInitialsAndExpNum;
    cache.autosave = autosave;
    
    setLocal(progmanager, hObject, 'configurationCache', cache);
end

return;

%------------------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles)

%TO042806B: Make sure all relevant variables are cached and restored. -- Tim O'Connor 4/28/06
if ~getLocal(progmanager, hObject, 'configurationEnabled')
    cache = getLocal(progmanager, hObject, 'configurationCache');
    if ~isempty(cache)
        setLocalBatch(progmanager, hObject, 'directory', cache.directory, 'initials', cache.initials, ...
            'experimentNumber', cache.experimentNumber, 'setID', cache.setID, 'acquisitionNumber', cache.acquisitionNumber, ...
            'addExperimentNumberToPath', cache.addExperimentNumberToPath, 'addSetIDToPath', cache.addSetIDToPath, ...
        'addInitialsToPath', cache.addInitialsToPath, 'concatenateInitialsAndExpNum', cache.concatenateInitialsAndExpNum, 'autosave', cache.autosave);
    end
end

autosave_Callback(hObject, eventdata, handles);%TO033106B - Make sure to update the highlighting on the checkbox. -- Tim O'Connor 3/31/06
configurationEnabled_Callback(hObject, eventdata, handles);%TO042806G - Make sure to update the highlighting on the checkbox. -- Tim O'Connor 4/28/06

% [experimentNumber, setID, acquisitionNumber] = getLocalBatch(progmanager, hObject, 'experimentNumber', 'setID', 'acquisitionNumber');
% fprintf(1, 'xsg: config loaded - %s:%s:%s\n%s', experimentNumber, setID, acquisitionNumber, getStackTraceString);

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

% errordlg('Save is not supported by this GUI.');
xsg_saveData;

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

% errordlg('Save As is not supported by this GUI.');
[filename pathname] = uiputfile(getLocal(progmanager, hObject, 'directory'), 'Save data as...');
if length(filename) == 1 && length(pathname) == 1
    if filename == 0 && pathname == 0
        return;
    end
end

xsg_saveData(fullfile(pathname, filename));

return;

%------------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function initials_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%------------------------------------------------------------------------------
function initials_Callback(hObject, eventdata, handles)

initials = getLocal(progmanager, hObject, 'initials');

%BSTO060910B - Verify characters. -- Ben Suter/Tim O'Connor 6/9/10
%BS062110A - bugfix, setID should be initials
invalidChars = ~ismember(initials, ['A':'Z', 'a':'z']);
initials(invalidChars) = 'A';
% changed = 0;
% for i = 1 : length(initials)
%     if ~ismember(initials(i), ['A':'Z', 'a':'z'])
%         changed = 1;
%         initials(i) = 'A';
%     end
% end

if length(initials) > 2
    setLocal(progmanager, hObject, 'initials', initials(1:2));
elseif length(initials) == 1
    setLocal(progmanager, hObject, 'initials', ['A' initials]);
elseif isempty(initials)
    setLocal(progmanager, hObject, 'initials', 'AA');
elseif any(invalidChars)
    setLocal(progmanager, hObject, 'initials', initials);
end

%TO111908F - Clear 'overwriteConfirmedForDirectory', to prevent accidental overwrites when a user goes back to the directory. -- Tim O'Connor 11/19/08
if getLocal(progmanager, xsg_getHandle, 'addInitialsToPath')
    setLocal(progmanager, xsg_getHandle, 'overwriteConfirmedForDirectory', '');
end

return;

%------------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function experimentNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%------------------------------------------------------------------------------
function experimentNumber_Callback(hObject, eventdata, handles)

xsg_setExperimentNumber(getLocal(progmanager, hObject, 'experimentNumber'));
% xNumber = getLocal(progmanager, hObject, 'experimentNumber');
% if length(xNumber) > 4
%     xNumber = xNumber(1:4);
% elseif length(xNumber) == 1
%     xNumber = ['000' xNumber];
% elseif length(xNumber) == 2
%     xNumber = ['00' xNumber];
% elseif length(xNumber) == 3
%     xNumber = ['0' xNumber];
% end
% 
% for i = 1 : length(xNumber)
%     if isempty(str2num(xNumber(i)))
%         xNumber(i) = '0';
%     end
% end
% 
% setLocal(progmanager, hObject, 'experimentNumber', xNumber);

return;

%------------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function setID_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%------------------------------------------------------------------------------
function setID_Callback(hObject, eventdata, handles)

%TO031006D - Implemented `xsg_setSetID`. -- Tim O'Connor 3/10/06
xsg_setSetID(getLocal(progmanager, hObject, 'setID'));
% setID = getLocal(progmanager, hObject, 'setID');
% if length(setID) > 4
%     setID = setID(1:4);
% elseif length(setID) == 1
%     setID = ['AAA' setID];
% elseif length(setID) == 2
%     setID = ['AA' setID];
% elseif length(setID) == 3
%     setID = ['A' setID];
% end
% 
% for i = 1 : length(setID)
%     if ~isletter(setID(i))
%         setID(i) = 'A';
%     end
% end
% 
% setLocal(progmanager, hObject, 'setID', setID);

return;

%------------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function acquisitionNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%------------------------------------------------------------------------------
function acquisitionNumber_Callback(hObject, eventdata, handles)

%TO092805G: Enable this parameter for editing.
% setLocal(progmanager, hObject, 'acquisitionNumber', getLocal(progmanager, hObject, 'acquisitionNumberBackup'));
xsg_setAcquisitionNumber(hObject, getLocal(progmanager, hObject, 'acquisitionNumber'));%TO020206C - Created xsg_setAcquisitionNumber.
% acqNumber = getLocal(progmanager, hObject, 'acquisitionNumber');
% if length(acqNumber) > 4
%     acqNumber = acqNumber(1:4);
% elseif length(acqNumber) == 1
%     acqNumber = ['000' acqNumber];
% elseif length(acqNumber) == 2
%     acqNumber = ['00' acqNumber];
% elseif length(acqNumber) == 3
%     acqNumber = ['0' acqNumber];
% end
% 
% for i = 1 : length(acqNumber)
%     if isempty(str2num(acqNumber(i)))
%         acqNumber(i) = '0';
%     end
% end
% 
% setLocal(progmanager, hObject, 'acquisitionNumber', acqNumber);

return;

%------------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function directory_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%------------------------------------------------------------------------------
function directory_Callback(hObject, eventdata, handles)

d = getLocal(progmanager, hObject, 'directory');
if exist(d) ~= 7
    setLocalGh(progmanager, hObject, 'directory', 'ForegroundColor', [1 0 0]);
    warning('''%s'' is not a directory.', d);
else
    setLocalGh(progmanager, hObject, 'directory', 'ForegroundColor', [0 0 0]);
end

%TO111908F - Clear 'overwriteConfirmedForDirectory', to prevent accidental overwrites when a user goes back to the directory. -- Tim O'Connor 11/19/08
setLocal(progmanager, xsg_getHandle, 'overwriteConfirmedForDirectory', '');

%TO082907D
notesName = xsg_getFilename;
autonotes_setFilename(notesName(1 : end-8));
xsg_setEpochNumber(0);

header_saveMFile;

return;

%------------------------------------------------------------------------------
% --- Executes on button press in browseDirectory.
function browseDirectory_Callback(hObject, eventdata, handles)

d = getLocal(progmanager, hObject, 'directory');
d = uigetdir(d, 'Choose a save directory.');
if ~isempty(d) & d ~= 0
    setLocal(progmanager, hObject, 'directory', d);
end

setLocalGh(progmanager, hObject, 'directory', 'ForegroundColor', [0 0 0]);

%TO082907D
notesName = xsg_getFilename;
autonotes_setFilename(notesName(1 : end-8));
xsg_setEpochNumber(0);

header_saveMFile;

return;

% %------------------------------------------------------------------------------
% function incrementAcquisitionNumber(hObject)
% 
% %TO062705F - Only increment when a save actually occurs.
% if ~getLocal(progmanager, hObject, 'autosave')
%     return;
% end
% 
% acqNum = getLocal(progmanager, hObject, 'acquisitionNumber');
% acqNum = num2str(str2num(acqNum) + 1);
% 
% if length(acqNum) > 4
%     acqNum = acqNum(1:4);
% elseif length(acqNum) == 1
%     acqNum = ['000' acqNum];
% elseif length(acqNum) == 2
%     acqNum = ['00' acqNum];
% elseif length(acqNum) == 3
%     acqNum = ['0' acqNum];
% end
% 
% setLocal(progmanager, hObject, 'acquisitionNumber', acqNum);
% setLocal(progmanager, hObject, 'acquisitionNumberBackup', acqNum);
% 
% return;

%------------------------------------------------------------------------------
% --- Executes on button press in autosave.
function autosave_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'autosave')
    %Gray
    setLocalGh(progmanager, hObject, 'autosave', 'BackgroundColor', [0.8313725490196078 0.8156862745098039 0.7843137254901961]);
else
    %Red
    setLocalGh(progmanager, hObject, 'autosave', 'BackgroundColor', [1 0 0]);
end

return;

%------------------------------------------------------------------------------
%TO123005F
function startmanagerCallback(hObject, channels)

setLocal(progmanager, hObject, 'started', 1);

return;

%------------------------------------------------------------------------------
% --- Executes on button press in resetExperimentNumberButton.
function resetExperimentNumberButton_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'experimentNumber', '0001');
setLocal(progmanager, hObject, 'setID', 'AAAA');
setLocal(progmanager, hObject, 'acquisitionNumber', '0001');
xsg_setEpochNumber(0);

return;

%------------------------------------------------------------------------------
% --- Executes on button press in resetSetIDButton.
function resetSetIDButton_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'setID', 'AAAA');
setLocal(progmanager, hObject, 'acquisitionNumber', '0001');

return;

%------------------------------------------------------------------------------
% --- Executes on button press in resetAcquisitionNumberButton.
function resetAcquisitionNumberButton_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'acquisitionNumber', '0001');

return;

%------------------------------------------------------------------------------
% --- Executes on button press in incrementExperimentNumberButton.
function incrementExperimentNumberButton_Callback(hObject, eventdata, handles)

xsg_incrementExperimentNumber;
% setLocal(progmanager, hObject, 'setID', 'AAAA');
% setLocal(progmanager, hObject, 'acquisitionNumber', '0001');

return;

%------------------------------------------------------------------------------
% --- Executes on button press in incrementSetIDButton.
function incrementSetIDButton_Callback(hObject, eventdata, handles)

xsg_incrementSetID;
setLocal(progmanager, hObject, 'acquisitionNumber', '0001');

return;

%------------------------------------------------------------------------------
% --- Executes on button press in incrementAcquisitionNumberButton.
function incrementAcquisitionNumberButton_Callback(hObject, eventdata, handles)

xsg_incrementAcquisitionNumber;

return;

%------------------------------------------------------------------------------
% --- Executes on button press in addExperimentNumberToPath.
function addExperimentNumberToPath_Callback(hObject, eventdata, handles)

if ~getLocal(progmanager, hObject, 'addExperimentNumberToPath')
    setLocal(progmanager, hObject, 'concatenateInitialsAndExpNum', 0);
end

%TO082907D
notesName = xsg_getFilename;
autonotes_setFilename(notesName(1 : end-8));
xsg_setEpochNumber(0);

header_saveMFile;

return;

%------------------------------------------------------------------------------
% --- Executes on button press in addSetIDToPath.
function addSetIDToPath_Callback(hObject, eventdata, handles)

%TO082907D
notesName = xsg_getFilename;
autonotes_setFilename(notesName(1 : end-8));
xsg_setEpochNumber(0);

header_saveMFile;

return;

%------------------------------------------------------------------------------
% --- Executes on button press in configurationEnabled.
function configurationEnabled_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'configurationEnabled')
    %Gray
    setLocalGh(progmanager, hObject, 'configurationEnabled', 'BackgroundColor', [1 0 0]);
else
    %Red
    setLocalGh(progmanager, hObject, 'configurationEnabled', 'BackgroundColor', [0.8313725490196078 0.8156862745098039 0.7843137254901961]);
end

return;

%------------------------------------------------------------------------------
% --- Executes on button press in addInitialsToPath.
function addInitialsToPath_Callback(hObject, eventdata, handles)

if ~getLocal(progmanager, hObject, 'addInitialsToPath')
    setLocal(progmanager, hObject, 'concatenateInitialsAndExpNum', 0);
end

%TO082907D
notesName = xsg_getFilename;
autonotes_setFilename(notesName(1 : end-8));
xsg_setEpochNumber(0);

header_saveMFile;

return;

%------------------------------------------------------------------------------
% --- Executes on button press in concatenateInitialsAndExpNum.
%TO042806A
function concatenateInitialsAndExpNum_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'concatenateInitialsAndExpNum')
    setLocalBatch(progmanager, hObject, 'addInitialsToPath', 1, 'addExperimentNumberToPath', 1);
end

%TO111908F - Clear 'overwriteConfirmedForDirectory', to prevent accidental overwrites when a user goes back to the directory. -- Tim O'Connor 11/19/08
setLocal(progmanager, xsg_getHandle, 'overwriteConfirmedForDirectory', '');

%TO082907D
notesName = xsg_getFilename;
autonotes_setFilename(notesName(1 : end-8));
xsg_setEpochNumber(0);

header_saveMFile;

return;

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
global state
epoch = getLocal(progmanager, hObject, 'epoch');
if isempty(str2num(epoch))
    epoch = '0';
end
xsg_setEpochNumber(hObject, epoch);
setEpoch(str2num(epoch));

return;

%------------------------------------------------------------------------------
% --- Executes on button press in incrementEpochButton.
function incrementEpochButton_Callback(hObject, eventdata, handles)

newEpoch = str2num(getLocal(progmanager, hObject, 'epoch')) + 1;
xsg_setEpochNumber(newEpoch);
setEpoch(newEpoch);

return;

%------------------------------------------------------------------------------
% --- Executes on button press in resetEpochNumberButton.
function resetEpochNumberButton_Callback(hObject, eventdata, handles)

xsg_setEpochNumber(0);
setEpoch(0);

return;


% --- Executes on button press in streamToDisk.
function streamToDisk_Callback(hObject, eventdata, handles)
% hObject    handle to streamToDisk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of streamToDisk




% --- Executes on button press in zipFilesOnCompletion.
function zipFilesOnCompletion_Callback(hObject, eventdata, handles)
% hObject    handle to zipFilesOnCompletion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zipFilesOnCompletion



function varargout = imagingSystemConfiguration(varargin)
% IMAGINGSYSTEMCONFIGURATION M-file for imagingSystemConfiguration.fig
%      IMAGINGSYSTEMCONFIGURATION, by itself, creates a new IMAGINGSYSTEMCONFIGURATION or raises the existing
%      singleton*.
%
%      H = IMAGINGSYSTEMCONFIGURATION returns the handle to a new IMAGINGSYSTEMCONFIGURATION or the handle to
%      the existing singleton*.
%
%      IMAGINGSYSTEMCONFIGURATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGINGSYSTEMCONFIGURATION.M with the given input arguments.
%
%      IMAGINGSYSTEMCONFIGURATION('Property','Value',...) creates a new IMAGINGSYSTEMCONFIGURATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imagingSystemConfiguration_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imagingSystemConfiguration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imagingSystemConfiguration

% Last Modified by GUIDE v2.5 02-Mar-2006 16:07:02
%JL10152007A change codes with @daqjob

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imagingSystemConfiguration_OpeningFcn, ...
                   'gui_OutputFcn',  @imagingSystemConfiguration_OutputFcn, ...
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
end

% --- Executes just before imagingSystemConfiguration is made visible.
function imagingSystemConfiguration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imagingSystemConfiguration (see VARARGIN)

% Choose default command line output for imagingSystemConfiguration
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imagingSystemConfiguration wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = imagingSystemConfiguration_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'xBoardID', 1, 'Class', 'Numeric', 'Gui', 'xBoardID', 'Config', 1, ...
       'xChannelID', 0, 'Class', 'Numeric', 'Gui', 'xChannelID', 'Config', 1, ...
       'xOffset', 0, 'Class', 'Numeric', 'Gui', 'xOffset', 'Config', 3, ...
       'xOffsetSlider', 0, 'Class', 'Numeric', 'Gui', 'xOffsetSlider', ...
       'xOffsetSliderLast', 0, 'Class', 'Numeric', ...
       'xAmplitude', 0, 'Class', 'Numeric', 'Gui', 'xAmplitude', 'Min', 0, 'Config', 3, ...
       'xAmplitudeSlider', 0, 'Class', 'Numeric', 'Gui', 'xAmplitudeSlider', ...
       'xAmplitudeSliderLast', 0, 'Class', 'Numeric', ...
       'xMicrons', 1, 'Class', 'Numeric', 'Gui', 'xMicrons', 'Config', 3, ...
       'yBoardID', 1, 'Class', 'Numeric', 'Gui', 'yBoardID', 'Config', 1, ...
       'yChannelID', 1, 'Class', 'Numeric', 'Gui', 'yChannelID', 'Config', 1, ...
       'yOffset', 0, 'Class', 'Numeric', 'Gui', 'yOffset', 'Config', 3, ...
       'yOffsetSlider', 0, 'Class', 'Numeric', 'Gui', 'yOffsetSlider', ...
       'yOffsetSliderLast', 0, 'Class', 'Numeric', ...
       'yAmplitude', 0, 'Class', 'Numeric', 'Gui', 'yAmplitude', 'Min', 0, 'Config', 3, ...
       'yAmplitudeSlider', 0, 'Class', 'Numeric', 'Gui', 'yAmplitudeSlider', ...
       'yAmplitudeSliderLast', 0, 'Class', 'Numeric', ...
       'yMicrons', 1, 'Class', 'Numeric', 'Gui', 'yMicrons', 'Config', 3, ...
       'name', '', 'Class', 'char', 'Gui', 'name', ...
       'xPhaseLag', 0, 'Class', 'Numeric', 'Gui', 'xPhaseLag', ...
       'xPhaseLagSlider', 0, 'Class', 'Numeric', 'Gui', 'xPhaseLagSlider', ...
       'xPhaseLagSliderLast', 0, 'Class', 'Numeric', ...
       'yPhaseLag', 0, 'Class', 'Numeric', 'Gui', 'yPhaseLag', ...
       'yPhaseLagSlider', 0, 'Class', 'Numeric', 'Gui', 'yPhaseLagSlider', ...
       'yPhaseLagSliderLast', 0, 'Class', 'Numeric', ...
       'scanPattern', 'Stationary', 'Class', 'char', 'Gui', 'scanPattern', 'Config', 1, ...
       'scan', 0, 'Class', 'Numeric', 'Gui', 'scan', ...
       'scanRepeats', 100, 'Class', 'Numeric', ...
       'amplitudeLimit', 3, 'Class', 'Numeric', ...
       'offsetLimit', 3, 'Class', 'Numeric', ...
       'amplitudeOffsetSumLimit', 4, 'Class', 'Numeric', ...
       'limitViolation', 0, 'Class', 'Numeric', ...
       'xInvert', 0, 'Class', 'Numeric', 'Gui', 'xInvert', 'Config', 3, ...
       'yInvert', 0, 'Class', 'Numeric', 'Gui', 'yInvert', 'Config', 3, ...
       'job', [], ... %VI060308A -- was 'task'
       'recreate', 0, 'Class', 'Numeric', ...
       'triggerOrigin', '', ...
      };

end

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

end

%------------------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

end

%------------------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

end

%------------------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

end

%------------------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles)

checkForLimitViolation(hObject);
tempHack(hObject);

end

% ------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

errordlg('Open is not supported by this GUI.');

end

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

errordlg('Save is not supported by this GUI.');

end

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

errordlg('Save As is not supported by this GUI.');

end

% ------------------------------------------------------------------
%De facto 'constructor' for 'imagingSystemConfiguration' program
%Constructor Arguments:
%   name: Name of this 'imagingSystemConfiguration' object (typically indicates the program this X/Y mirror pair is associated with)
%   xMirrorChannelName: channel name (@daqjob handle) of X mirror managed by this imagingSystemConfig (typically a stimulator channel); use empty string to skip
%   yMirrorChannelName: channel name (@daqjob handle) of Y mirror managed by this imagingSystemConfig (typically a stimulator channel); use empty string to skip
%   jobName: name of @daqjob with which photodiodeChannel is associated (if blank/empty, the default @daqjob name --'acquisition'--is assumed)
function genericStartFcn(hObject, eventdata, handles, varargin)
    
xMirrorBoardID = [];
xMirrorChannelID = [];
yMirrorBoardID = [];
yMirrorChannelID = [];

%VI060108A -- Allow board/chan configuration to be determined via 'constructor' arguments 
if ~isempty(varargin)       
    imagingSysName = varargin{1};

    if length(varargin) >= 4
       jobName = varargin{4};
    else
       jobName = 'acquisition';
    end

    %TO073108D - As per TO073008D, don't call getDeviceNameByChannelName here, hoping to get 3 arguments back, because as the name implies, that method should only return the deviceName. -- Tim O'Connor 7/31/08
    if ~isempty(varargin{2})
        xMirrorStruct = getChannelStructure(daqjob(jobName), varargin{2});
        xMirrorBoardID = xMirrorStruct.boardID;
        xMirrorChannelID = xMirrorStruct.channelID;
    end

    if ~isempty(varargin{3})
        yMirrorStruct = getChannelStructure(daqjob(jobName), varargin{3});
        yMirrorBoardID = yMirrorStruct.boardID;
        yMirrorChannelID = yMirrorStruct.channelID;
    end
end

if ~isempty(xMirrorBoardID) && ~isempty(yMirrorBoardID) && ~isempty(xMirrorChannelID) && ~isempty(yMirrorChannelID)
    setLocalBatch(progmanager, hObject, 'xBoardID', xMirrorBoardID, 'xChannelID', xMirrorChannelID, ...
        'yBoardID', yMirrorBoardID, 'yChannelID', yMirrorChannelID, 'name', imagingSysName);
end

end

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

end

% ------------------------------------------------------------------
function genericSaveSettings(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xOffset_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
function xOffset_Callback(hObject, eventdata, handles)

checkForLimitViolation(hObject);
updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yOffset_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
function yOffset_Callback(hObject, eventdata, handles)

checkForLimitViolation(hObject);
updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xOffsetSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function xOffsetSlider_Callback(hObject, eventdata, handles)
end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yOffsetSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function yOffsetSlider_Callback(hObject, eventdata, handles)
end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xAmplitudeSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function xAmplitudeSlider_Callback(hObject, eventdata, handles)
end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xAmplitude_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
function xAmplitude_Callback(hObject, eventdata, handles)

checkForLimitViolation(hObject);
updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yAmplitude_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[1 1 1]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function yAmplitude_Callback(hObject, eventdata, handles)

updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yAmplitudeSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function yAmplitudeSlider_Callback(hObject, eventdata, handles)
end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function scanPattern_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
% --- Executes on selection change in scanPattern.
function scanPattern_Callback(hObject, eventdata, handles)

checkForLimitViolation(hObject);
updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes on button press in scan.
function scan_Callback(hObject, eventdata, handles)

checkForLimitViolation(hObject);
updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xBoardID_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
function xBoardID_Callback(hObject, eventdata, handles)

checkForLimitViolation(hObject);
setLocal(progmanager, hObject, 'recreate', 1);
updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xChannelID_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
function xChannelID_Callback(hObject, eventdata, handles)

checkForLimitViolation(hObject);
setLocal(progmanager, hObject, 'recreate', 1);
updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function name_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
function name_Callback(hObject, eventdata, handles)
end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xPhaseLagSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function xPhaseLagSlider_Callback(hObject, eventdata, handles)
end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xPhaseLag_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
function xPhaseLag_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function yBoardID_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
function yBoardID_Callback(hObject, eventdata, handles)

checkForLimitViolation(hObject);
setLocal(progmanager, hObject, 'recreate', 1);
updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yChannelID_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
function yChannelID_Callback(hObject, eventdata, handles)

checkForLimitViolation(hObject);
setLocal(progmanager, hObject, 'recreate', 1);
updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xMicronsSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function xMicronsSlider_Callback(hObject, eventdata, handles)
end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xMicrons_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function xMicrons_Callback(hObject, eventdata, handles)

updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yMicronsSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function yMicronsSlider_Callback(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yMicrons_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
function yMicrons_Callback(hObject, eventdata, handles)

updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function lens_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
% --- Executes on selection change in lens.
function lens_Callback(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
function checkForLimitViolation(hObject)

limitViolation = 0;
[xOffset xAmplitude yOffset yAmplitude amplitudeLimit offsetLimit amplitudeOffsetSumLimit] = getLocalBatch(progmanager, hObject, ...
    'xOffset', 'xAmplitude', 'yOffset', 'yAmplitude', 'amplitudeLimit', 'offsetLimit', 'amplitudeOffsetSumLimit');
if (xOffset + xAmplitude > amplitudeOffsetSumLimit) | (xOffset - xAmplitude < -amplitudeOffsetSumLimit)
    limitViolation = 1;
    warndlg(sprintf('The current settings violate the amplitude+offset limit for the x-axis scanner: %s', num2str(amplitudeOffsetSumLimit)));
end
if (yOffset + yAmplitude > amplitudeOffsetSumLimit) | (yOffset + yAmplitude < -amplitudeOffsetSumLimit)
    limitViolation = 1;
    warndlg(sprintf('The current settings violate the amplitude+offset limit for the y-axis scanner: %s', num2str(amplitudeOffsetSumLimit)));
end

setLocal(progmanager, hObject, 'limitViolation', limitViolation);

end

% ------------------------------------------------------------------
function updateScan(hObject)
% CHANGES
%   JL10162007A - change code with @daqjob
%   VI060308A - Switched from Nimex task to a real @daqjob, overriding JL10162007A (which didn't use @daqjob as stated). ALL references to 'task' are replaced with 'job'
tempHack(hObject);

[scan, limitViolation, xBoardID, xChannelID, xOffset, xAmplitude, ...
        yBoardID, yChannelID, yOffset, yAmplitude, scanPattern, scanRepeats, xInvert, yInvert, job, recreate] = getLocalBatch(progmanager, hObject, ...
    'scan', 'limitViolation', 'xBoardID', 'xChannelID', 'xOffset', 'xAmplitude', ...
    'yBoardID', 'yChannelID', 'yOffset', 'yAmplitude', 'scanPattern', 'scanRepeats', 'xInvert', 'yInvert', 'job', 'recreate');

if ~scan || limitViolation
    setLocal(progmanager, hObject, 'scan', 0);
    setLocalGh(progmanager, hObject, 'scan', 'String', 'Start', 'ForegroundColor', [0.3 0.7 0.3]);
    if ~isempty(job)
        stop(job);
    end
    return;
end

    %VI060308A 
    function createJob()
        job = daqjob('imagingSysConfig');
        addAnalogOutput(job,'xMirror',['/dev' num2str(xBoardID) '/ao'],xChannelID);
        addAnalogOutput(job,'yMirror',['/dev' num2str(yBoardID) '/ao'],yChannelID);
        setTriggerOrigin(job,getTriggerOrigin(daqjob('acquisition')));        
        %%%VI102608A%%%%%%%
        %setTriggerDestination(job,getTriggerDestination(daqjob('acquisition'))); 
        trigDests = getTriggerDestinations(daqjob('acquisition'));
        setTriggerDestination(job,trigDests{1});
        %%%%%%%%%%%%%%%%%%%
        setLocal(progmanager, hObject, 'job', job);
    end

%JL10162007A - change code with @daqjob
if isempty(job)
    %VI060308A
    createJob();          
    %REMOVED (VI060308A)
%     nimex_addAnalogOutput(task, ['/dev' num2str(xBoardID) '/ao' num2str(xChannelID)]);
%     nimex_setChannelProperty(task,['/dev' num2str(xBoardID) '/ao' num2str(xChannelID)], 'mnemonicName', 'xMirror');
%     nimex_addAnalogOutput(task, ['/dev' num2str(yBoardID) '/ao' num2str(yChannelID)]);
%     nimex_setChannelProperty(task,['/dev' num2str(yBoardID) '/ao' num2str(yChannelID)], 'mnemonicName', 'yMirror');
%     nimex_setTaskProperty(task, 'triggerSource', ['/dev' num2str(xBoardID) '/' getTriggerDestination(daqjob('acquisition'))]);
%     setLocal(progmanager, hObject, 'task', task);
else
    if recreate
        delete(job);
        createJob();
        recreate=0;
        setLocal(progmanager,hObject,'recreate',recreate);
        
        %REMOVED(VI060308A)
%         job = nimex;
%         nimex_addAnalogOutput(task, ['/dev' num2str(xBoardID) '/ao' num2str(xChannelID)]);
%         nimex_addAnalogOutput(task, ['/dev',num2str(yBoardID),'/ao',num2str(yChannelID)]);
%         nimex_setTaskProperty(task, 'triggerSource', ['/dev' num2str(xBoardID) '/' getTriggerDestination(daqjob('acquisition'))]); %VI060308A (Ensure trigger prop is set for possibly newly identified board)
%         recreate = 0;
%         setLocalBatch(progmanager, hObject, 'task', task, 'recreate', recreate);
    else
        %nimex_stopTask(task);
        stop(job); %VI060308A
    end
end

setLocal(progmanager, hObject, 'scan', 1);
setLocalGh(progmanager, hObject, 'scan', 'String', 'Stop', 'ForegroundColor', [1 0 0]);

try
%JL10162007C - change code with @daqjob        
%nimex_setTaskProperty(task, 'repeatOutput', scanRepeats);
setTaskProperty(job,'xMirror','repeatOutput',scanRepeats);
setTaskProperty(job,'yMirror','repeatOutput',scanRepeats);

%setAOProperty(dm, 'xMirror', 'RepeatOutput', scanRepeats, 'TriggerType', 'HwDigital');
%setAOProperty(dm, 'yMirror', 'RepeatOutput', scanRepeats, 'TriggerType', 'HwDigital');

%TO042106A - Redefine how invert applies to offset. -- Tim O'Connor 4/21/06
if xInvert
    xOffset = -xOffset;
end
if yInvert
    yOffset = -yOffset;
end

switch lower(scanPattern)
    case 'stationary'
%JL10172007A add setTaskProperty for stationary

        xdata = ones(100, 1) * xOffset;
        ydata = ones(100, 1) * yOffset;
        
    case 'five points'     
        %VI060308A
        %nimex_setTaskProperty(task, 'samplingRate', 3);
        %nimex_setTaskProperty(task, 'samplingRate', 3);
        setTaskProperty(job,'xMirror','samplingRate',3);
        setTaskProperty(job,'yMirror','samplingRate',3);
        
%         set([aoX aoY], 'SampleRate', 3);
        xdata = [xOffset+xAmplitude xOffset-xAmplitude xOffset+xAmplitude xOffset-xAmplitude xOffset]';
        ydata = [yOffset+yAmplitude yOffset+yAmplitude yOffset-yAmplitude yOffset-yAmplitude yOffset]';
        
    case 'circle'
        %VI060308A
        %JL10162007D - change code with @daqjob        
        %nimex_setTaskProperty(task, 'samplingRate', 101);
        %nimex_setTaskProperty(task, 'samplingRate', 101);
        setTaskProperty(job,'xMirror','samplingRate',101);
        setTaskProperty(job,'yMirror','samplingRate',101);       
        
        if ~xInvert
            xdata = xOffset + xAmplitude * sin(0 : 2 * pi / 200 : 2 * pi)';
        else
            xdata = xOffset - xAmplitude * sin(0 : 2 * pi / 200 : 2 * pi)';
        end
        if ~yInvert
            ydata = yOffset + yAmplitude * cos(0 : 2 * pi / 200 : 2 * pi)';
        else
            ydata = yOffset - yAmplitude * cos(0 : 2 * pi / 200 : 2 * pi)';
        end
        
    case 'square'

        %VI060308A
        %JL10162007E - change code with @daqjob
        %nimex_setTaskProperty(task, 'samplingRate', 101);
        %nimex_setTaskProperty(task, 'samplingRate', 101);
        setTaskProperty(job,'xMirror','samplingRate',101);
        setTaskProperty(job,'yMirror','samplingRate',101);    
        
        %setAOProperty(dm, 'xMirror', 'SampleRate', 101);
        %setAOProperty(dm, 'yMirror', 'SampleRate', 101);
%         set([aoX aoY], 'SampleRate', 101);
        
        xStep = xAmplitude/100;
        if ~xInvert
            xdata = cat(2, xOffset-xAmplitude:xStep:xOffset+xAmplitude, ones(1, 203) * xOffset+xAmplitude, ...
                xOffset+xAmplitude:-xStep:xOffset-xAmplitude, ones(1, 203) * xOffset-xAmplitude)';
        else
            xdata = cat(2, xOffset+xAmplitude:-xStep:xOffset-xAmplitude, ones(1, 203) * xOffset-xAmplitude, ...
                xOffset-xAmplitude:xStep:xOffset+xAmplitude, ones(1, 203) * xOffset+xAmplitude)';
        end
        
        yStep = yAmplitude/100;
        if ~yInvert
            ydata = cat(2, ones(1, 203) * yOffset-yAmplitude, yOffset-yAmplitude:yStep:yOffset+yAmplitude, ...
                ones(1, 203) * yOffset+yAmplitude, yOffset+yAmplitude:-yStep:yOffset-yAmplitude)';
        else
            ydata = cat(2, ones(1, 203) * yOffset+yAmplitude, yOffset+yAmplitude:-yStep:yOffset-yAmplitude, ...
                ones(1, 203) * yOffset-yAmplitude, yOffset-yAmplitude:yStep:yOffset+yAmplitude)';
        end
        
    case 'raster'
        %VI060308A
        %JL10162007F - change code with @daqjob
        %nimex_setTaskProperty(task, 'samplingRate', 501 * 101);
        %nimex_setTaskProperty(task, 'samplingRate', 501 * 101);
        setChannelProperty(job,'xMirror','samplingRate',501*101);
        setChannelProperty(job,'yMirror','samplingRate',501*101);  
        
        %setAOProperty(dm, 'xMirror', 'SampleRate', 501 * 101);
        %setAOProperty(dm, 'yMirror', 'SampleRate', 501 * 101);
        
% setAOProperty(dm, 'xMirror', 'SampleRate', 1000);
% setAOProperty(dm, 'yMirror', 'SampleRate', 1000);

        if ~xInvert
            xdata = repmat((xOffset-xAmplitude:xAmplitude/100:xOffset+xAmplitude)', [501 1]);
        else
            xdata = repmat((xOffset+xAmplitude:-xAmplitude/100:xOffset-xAmplitude)', [501 1]);
        end
        
        if ~yInvert
            ydata = (yOffset+yAmplitude:-yAmplitude/floor(length(xdata)/2):yOffset-yAmplitude)';
        else
            ydata = (yOffset-yAmplitude:yAmplitude/floor(length(xdata)/2):yOffset+yAmplitude)';
        end
%         ydata = interp(ydata, 101);
otherwise
        error('Unrecognized scan pattern: ''%s''', scanPattern);
end

% putdata(aoX, xdata);
% putdata(aoY, ydata);

%JL10162007G - change code with @daqjob       
%nimex_writeAnalogF64(task,['/dev' num2str(xBoardID) '/ao' num2str(xChannelID)], double(xdata), length(xdata));
%nimex_writeAnalogF64(task,['/dev' num2str(yBoardID) '/ao' num2str(yChannelID)], double(ydata), length(ydata));

%VI060308A    
writeAnalogF64(job,'xMirror',double(xdata));
writeAnalogF64(job,'yMirror',double(ydata));

%putDaqData(dm, 'xMirror', xdata);
%putDaqData(dm, 'yMirror', ydata);

%JL10172007B - change code with @daqjob
% sm = startmanager('acquisition');
% setTriggerOrigin(dj, '/dev1/port0/line0');
% setTriggerDestination(dj, 'PFI0');

%JL10162007H - change code with @daqjob  
%nimex_startTask(task);
%startChannel(dm, 'xMirror', 'yMirror');
start(job); %VI060308A

%figure; plot(xdata, ydata);

%%%VI102608A: Following should no longer be needed (see VI060308A)
%TO050208A - Removed hardcoding of '/dev1/port0/line0'. -- Tim O'Connor 5/2/08
% triggerOrigin = getTriggerOrigin(daqjob('acquisition'));
% origin = getLocal(progmanager, hObject, 'triggerOrigin');
% if isempty(origin) || isempty(triggerOrigin) || ~strcmpi(origin, triggerOrigin)
%     msg = sprintf('Either the source is being implied by the global setting (ie. `getTriggerOrigin(daqjob(''acquisition''))`) or ambiguity exists between the\n');
%     msg = sprintf('%sglobal setting and the last trigger source used by this program (ie. `getGlobal(progmanager, ''triggerOrigin'', ''imagingSys'', ''imagingSys'')`).\n', msg);
%     fprintf(1, '%s - imagingSystemConfiguration: Trigger source confirmation required.\n\t%s\n', datestr(now), strrep(msg, char(10), char([10, 9])));%Replace '\n' with '\n\t'
%     origin = inputdlg({'Trigger Source:', 'Reason For Confirmation:'}, 'Confirm Trigger Source', 2, {triggerOrigin, msg}, 'on');
%     if isempty(origin)
%         nimex_stopTask(task);
%         fprintf(1, '%s - imagingSystemConfiguration: No trigger source specified/confirmed.\n', datestr(now));
%         return;
%     end
%     triggerOrigin = origin{1};
%     setLocal(progmanager, hObject, 'triggerOrigin', triggerOrigin);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%JL10162007I - change code with @daqjob
%nimex_sendTrigger(task, triggerOrigin);%TO050208A - Removed hardcoding of '/dev1/port0/line0'.
%     pause(2);
trigger(job); %VI060308A


catch
    warning('Error updating scan: %s', lasterr);
    try
        %JL10162007J - change code with @daqjob  
        %stop(dj, 'xMirror','yMirror');
        %nimex_stopTask(task);
        %stopChannel(getDaqmanager, 'xMirror', 'yMirror');
        stop(job); %VI060308A
        setLocal(progmanager, hObject, 'scan', 0);
        setLocalGh(progmanager, hObject, 'scan', 'String', 'Start', 'ForegroundColor', [0.3 0.7 0.3]);
    catch
        warning('Error stopping ''xMirror'' and ''yMirror'' channels: %s', lasterr);
        %JL10162007K - change code with @daqjob  
        %nimex_stopTask(task);
        %stop(dj, 'xMirror','yMirror');
        %stopAllChannels(getDaqmanager);
        stop(job); %VI06038A
    end
end

% nimex_stopTask(task);

end

% ------------------------------------------------------------------
function tempHack(hObject)

try
    mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
    setLocal(progmanager, mapperObj, 'temp_xOffset', getLocal(progmanager, hObject, 'xOffset'));
    setLocal(progmanager, mapperObj, 'temp_xAmplitude', getLocal(progmanager, hObject, 'xAmplitude'));
    setLocal(progmanager, mapperObj, 'temp_xGain', getLocal(progmanager, hObject, 'xMicrons'));
    setLocal(progmanager, mapperObj, 'temp_xInvert', getLocal(progmanager, hObject, 'xInvert'));    
    setLocal(progmanager, mapperObj, 'temp_yOffset', getLocal(progmanager, hObject, 'yOffset'));
    setLocal(progmanager, mapperObj, 'temp_yAmplitude', getLocal(progmanager, hObject, 'yAmplitude'));
    setLocal(progmanager, mapperObj, 'temp_yGain', getLocal(progmanager, hObject, 'yMicrons'));
    setLocal(progmanager, mapperObj, 'temp_yInvert', getLocal(progmanager, hObject, 'yInvert'));
    
    %VI061208A -- Handle X/Y mirror flipping here as well, in true crapHack fashion
    %TO073108D - As per TO073008D, don't call getDeviceNameByChannelName here, hoping to get 3 arguments back, because as the name implies, that method should only return the deviceName. -- Tim O'Connor 7/31/08
    %
    % This code is still a bit muddled (and I don't just mean the formatting with the typical lack of commas/spaces). 
    % The whole 'axesSwitch' thing could be a lot cleaner, but I've got higher priorities than cleaning up more junk right now. -- Tim O'Connor 7/13/08
    xMirrorStruct = getChannelStructure(daqjob('acquisition'), 'xMirror');
    xBoardAct = xMirrorStruct.boardID;
    xChanAct = xMirrorStruct.channelID;
    yMirrorStruct = getChannelStructure(daqjob('acquisition'), 'yMirror');
    yBoardAct = yMirrorStruct.boardID;
    yChanAct = yMirrorStruct.channelID;

    [xBoardID,yBoardID,xChannelID,yChannelID] = getLocalBatch(progmanager,hObject,'xBoardID','yBoardID','xChannelID','yChannelID');
    if all([xBoardAct xChanAct yBoardAct yChanAct] == [xBoardID xChannelID yBoardID yChannelID])
        setLocal(progmanager,mapperObj,'axesSwitch',0);
    elseif  all([xBoardAct xChanAct yBoardAct yChanAct] == [yBoardID yChannelID xBoardID xChannelID])
        setLocal(progmanager,mapperObj,'axesSwitch',1);
    else
        fprintf(2,'WARNING: The horizontal/vertical board/channel IDs do not match those of ''xMirror'' and ''yMirror'' channels. Mapper behavior will be unpredictable.\n');
    end
    
    [f im] = getLocalBatch(progmanager, mapperObj, 'videoFigure', 'videoImage');
    xdata = get(im, 'xdata');
    ydata = get(im, 'ydata');

    setLocal(progmanager, mapperObj, 'temp_xGain', 2 * getLocal(progmanager, hObject, 'xAmplitude') / getLocal(progmanager, hObject, 'xMicrons'));
    setLocal(progmanager, mapperObj, 'temp_yGain', 2 * getLocal(progmanager, hObject, 'yAmplitude') / getLocal(progmanager, hObject, 'yMicrons'));
    
    feval(getLocal(progmanager, mapperObj, 'TEMP_updateDisplay'), mapperObj);
catch
    warning('Error updating mapper variables: %s', getLastErrorStack);
end

end

% ------------------------------------------------------------------
% --- Executes on slider movement.
function yPhaseLagSlider_Callback(hObject, eventdata, handles)
% hObject    handle to yphaseLagSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end
% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yPhaseLagSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yphaseLagSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% ------------------------------------------------------------------
function yPhaseLag_Callback(hObject, eventdata, handles)
% hObject    handle to phaseLagY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phaseLagY as text
%        str2double(get(hObject,'String')) returns contents of phaseLagY as a double
end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yPhaseLag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phaseLagY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% ------------------------------------------------------------------
% --- Executes on button press in xInvert.
function xInvert_Callback(hObject, eventdata, handles)

updateScan(hObject);

end

% ------------------------------------------------------------------
% --- Executes on button press in yInvert.
function yInvert_Callback(hObject, eventdata, handles)

updateScan(hObject);

end



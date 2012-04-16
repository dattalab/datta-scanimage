function varargout = photodiodeConfiguration(varargin)
% PHOTODIODECONFIGURATION M-file for photodiodeConfiguration.fig
%      PHOTODIODECONFIGURATION, by itself, creates a new PHOTODIODECONFIGURATION or raises the existing
%      singleton*.
%
%      H = PHOTODIODECONFIGURATION returns the handle to a new PHOTODIODECONFIGURATION or the handle to
%      the existing singleton*.
%
%      PHOTODIODECONFIGURATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHOTODIODECONFIGURATION.M with the given input arguments.
%
%      PHOTODIODECONFIGURATION('Property','Value',...) creates a new PHOTODIODECONFIGURATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before photodiodeConfiguration_OpeningFunction gets called.  An
%      unrecognized property photodiodeName or invalid value makes property application
%      stop.  All inputs are passed to photodiodeConfiguration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help photodiodeConfiguration

% Last Modified by GUIDE v2.5 07-Mar-2006 13:00:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @photodiodeConfiguration_OpeningFcn, ...
                   'gui_OutputFcn',  @photodiodeConfiguration_OutputFcn, ...
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
% --- Executes just before photodiodeConfiguration is made visible.
function photodiodeConfiguration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to photodiodeConfiguration (see VARARGIN)

% Choose default command line output for photodiodeConfiguration
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes photodiodeConfiguration wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'voltage', 0, 'Class', 'Numeric', 'Gui', 'voltage', ...
       'power', 0, 'Class', 'Numeric', 'Gui', 'power', ...
       'slope', 0, 'Class', 'Numeric', 'Gui', 'slope', ...
       'offset', 0, 'Class', 'Numeric', 'Gui', 'offset', ...
       'trendline', [], ...
       'datapoints', [], ...
       'photodiodeObject', [], ...
       'photodiodeName', '', 'Class', 'char', 'Gui', 'photodiodeName', ...
       'boardID', -1, 'Class', 'Numeric', 'Gui', 'boardID', ...
       'channelID', -1, 'Class', 'Numeric', 'Gui', 'channelID', ...
       'user', '', 'Class', 'char', 'Gui', 'user', ...
       'date', '', 'Class', 'char', 'Gui', 'date', ...
       'lensTransmission', 100, 'Class', 'Numeric', 'Gui', 'lensTransmission', ...
       'photodiodeObjectStruct', [], 'Config', 3, ...
   };

return;

% ------------------------------------------------------------------
%De facto 'constructor' for 'photodiodeConfiguration' program
%Constructor Arguments:
%   photodiodeChannel OR photodiodeChannelInfo OR photodiodeObject 
%       photodiodeChannel: name of pre-created channel attached to a photodiode, for which this program will handle configuration.  (this is a @daqjob channel name--typically, but not necessarily, assigned as an acquirer channel)
%       photodiodeChannelInfo: a cell array of format {channelName boardID chanID}, which will create the @photodiode object and @daqjob channel; if jobName is 'acquisition', implicitly or explicitly, new channel is added to acquirer program (created if necessary)
%       photodiodeObject: a pre-created @photodiode instance 
%   jobName: (if first arg is a photodiodeChannel or photodiodeChannelInfo) name of @daqjob with which photodiodeChannel is associated (otherwise, default @daqjob name --'acquisition'--is assumed); leave empty to skip
%
%Notes
%   Constructor /creates/ the photodiode object, if a @daqjob channel name is given 
%   In future, it would make more sense if the photodiode /channel/ (not just the object)  were created in combination with a photodiodeConfiguration GUI -- i.e. a specific form of smartDevice
%
%   Note that there is some potential inconsistency in the 'name' property of this program -- it is either the name of the photodiode object or the name of the channel associated with the photodiode
%
%   At present (6/2/08), the most natural usage is to supply the photodiodeChannel, which would most likely have been configured for use with acquirer program
%
%   The photodiodeChannelInfo constructor option is meant to illustrate the 'smartDevice' philosophy under consideration: specify the board/chanID, and the object/GUI/acquirer-binding all come in one go
%   Under smartDevice philosophy, configuration would include a series of smartDevice constructors; there would probably be /no/ setting of stimulator/acquirer channels--since /all/ channels would be associated with a smartDevice
%
function genericStartFcn(hObject, eventdata, handles,varargin)

ax = getLocalGh(progmanager, hObject, 'axes');
set(ax, 'NextPlot', 'Add');
setLocal(progmanager, hObject, 'trendline', plot([0 0], [0 0], 'Parent', ax, 'LineStyle', '-', 'Marker', 'None'));
setLocal(progmanager, hObject, 'datapoints', plot([0 0], [0 0], 'Parent', ax, 'LineStyle', 'None', 'Marker', 'o'));

%VI060108A -- Process newly required photodiodeChannel argument -- Vijay Iyer 6/1/08
if ~isempty(varargin)
    if isa(varargin{1},'photodiode') %arg is a photodiodeObject
        pdiode = varargin{1};
        photodiodeName = get(pdiode,'name');
    elseif ischar(varargin{1}) || (iscell(varargin{1}) && length(varargin{1}) == 3) %arg is a photodiodeChannel or photodiodeChannelInfo
        if length(varargin)>=2 
            jobName = varargin{1};
        else
            jobName = 'acquisition';
        end
        
        if ischar(varargin{1}) %photodiodeChannel
            photodiodeName = varargin{1};
            devName = getDeviceNameByChannelName(daqjob(jobName),photodiodeName); %VI102608A: Can't get board/chanID directly with this method anymore
            [boardID,chanID] = getPhysicalChannelIDs(daqjob(jobName), devName); %VI1020608A: use this (would-be) 'static' method to get board/chanID
        else %photodiodeChannelInfo
            photodiodeName = varargin{1}{1};
            boardID = varargin{1}{2};
            chanID = varargin{1}{3};
            
            %Add new channel to acquirer or directly to @daqjob, as appropriate; create acquirer if needed
            if strcmpi(jobName,'acquisition')
                if ~isprogram(progmanager,'acquirer')
                    acq = openprogram(progmanager,'acquirer');
                else
                    acq = getHandleFromName(progmanager,'acquirer','acquirer');
                end
                acq_addChannels(acq,photodiodeName,boardID,chanID);
            else %Create channel in specified @daqjob
                addAnalogInput(daqjob(jobName),photodiodeName, ['/dev' num2str(boardID) '/ai'], chanID);
            end

        end

        pdiode = photodiode; %create the photodiode!
        set(pdiode, 'boardID', boardID, 'channelID', chanID, 'name', photodiodeName);
    else
        error('First optional argument must be a {chanName,boardID,chanID} cell array,  a @daqjob channel name, or a valid @photodiode object');
    end

    setLocalBatch(progmanager,hObject,'photodiodeObject',pdiode,'boardID',boardID,'channelID',chanID,'photodiodeName',photodiodeName);
else %The following allows construction without arguments, for backwards compatibility purposes -- Vijay Iyer 10/26/08
    %TO080108H - This should be the default behavior, if you really want simple/streamlined, not that junk above. -- Tim O'Connor 8/1/08
    %            Of course, just creating the photodiode in the start-up file is kinda nice too (like it was originally).
    %try
    %for channelName = {'photodiode', 'photodiode0', 'photodiode1'} %VI102608A
    channelName = {'photodiode', 'photodiode0', 'photodiode1'}; %VI102608A
    for i=1:length(channelName) %VI102608A
        if isChannel(daqjob('acquisition'), channelName{i}) %VI102608A           
            photodiodeChannelStruct = getChannelStructure(daqjob('acquisition'), channelName{i});
            pdiode = photodiode;
            set(pdiode, 'boardID', photodiodeChannelStruct.boardID, 'channelID', photodiodeChannelStruct.channelID, 'name', channelName{i});
            setLocalBatch(progmanager, hObject, 'photodiodeObject', pdiode, 'boardID', photodiodeChannelStruct.boardID, 'channelID', photodiodeChannelStruct.channelID, 'photodiodeName', channelName{i});
            break;
        end
    end
    %catch
    %end
end
%VI060108A

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

% ------------------------------------------------------------------
function genericOpen(hObject, eventdata, handles)

errordlg('Open is not supported by this gui.');

return;

% ------------------------------------------------------------------
function genericSave(hObject, eventdata, handles)

errordlg('Save is not supported by this gui.');

return;

% ------------------------------------------------------------------
function genericSaveAs(hObject, eventdata, handles)

errordlg('Save as is not supported by this gui.');

return;

% ------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

%TO061508A - Handle the lack of a photodiode object/configuration properly. -- Tim O'Connor 6/15/08
pdiode = getLocal(progmanager, hObject, 'photodiodeObject');
if ~isempty(pdiode)
    photodiodeObjectStruct = getStruct(pdiode);
    setLocal(progmanager, hObject, 'photodiodeObjectStruct', photodiodeObjectStruct);
else
    setLocal(progmanager, hObject, 'photodiodeObjectStruct', []);
end

return;

% ------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles)

photodiodeObjectStruct = getLocal(progmanager, hObject, 'photodiodeObjectStruct');
if ~isempty(photodiodeObjectStruct)
    pdiode = getLocal(progmanager, hObject, 'photodiodeObject');
    %TO080108C - Create the photodiode if it doesn't already exist, due to Vijay's optional constructors. -- Tim O'Connor 8/1/08
    if isempty(pdiode)
        pdiode = photodiode; %create the photodiode!
        [boardID, chanID, photodiodeName] = getLocalBatch(progmanager, hObject, 'boardID', 'channelID', 'photodiodeName');
        set(pdiode, 'boardID', boardID, 'channelID', chanID, 'name', photodiodeName);
        setLocal(progmanager, hObject, 'photodiodeObject', pdiode);
    end
    setStruct(pdiode, photodiodeObjectStruct);
    update(hObject);
end

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

%TO062106A - Save the photodiode calibration in the header. -- Tim O'Connor 6/21/06
% %TO102608 - Watch out for this unofficial hack (only on the LSPS rig, and only necessary for the PCI start-up file), 
% %           this is a big TODO that needs fixing. The photodiode stuff is a real mess. -- Tim O'Connor 10/26/08
% if ~isempty(getLocal(progmanager, hObject, 'photodiodeObject'))
photodiodeObjectStruct = getStruct(getLocal(progmanager, hObject, 'photodiodeObject'));
setLocal(progmanager, hObject, 'photodiodeObjectStruct', photodiodeObjectStruct);
% end

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = photodiodeConfiguration_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function voltage_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function voltage_Callback(hObject, eventdata, handles)
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function power_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function power_Callback(hObject, eventdata, handles)

if isempty(getLocal(progmanager, hObject, 'user'))
    errordlg('A user name must be entered in order to create/modify a calibration.');
    return;
end
addCalibrationPoint(getLocal(progmanager, hObject, 'photodiodeObject'), getLocal(progmanager, hObject, 'power'));
update(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function slope_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function slope_Callback(hObject, eventdata, handles)
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function offset_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function offset_Callback(hObject, eventdata, handles)
return;

% ------------------------------------------------------------------
% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)

clearCalibration(getLocal(progmanager, hObject, 'photodiodeObject'));
update(hObject);

return;

% ------------------------------------------------------------------
function update(hObject)

photodiode = getLocal(progmanager, hObject, 'photodiodeObject');
userName = get(photodiode, 'calibrationUser');
setLocal(progmanager, hObject, 'user', userName);
if isempty(userName)
    setLocalGh(progmanager, hObject, 'power', 'Enable', 'Off');
    setLocalGh(progmanager, hObject, 'clear', 'Enable', 'Off');
else
    setLocalGh(progmanager, hObject, 'power', 'Enable', 'On');
    setLocalGh(progmanager, hObject, 'clear', 'Enable', 'On');
end

d = get(photodiode, 'calibrationDate');
if isempty(d)
    setLocal(progmanager, hObject, 'date', '');
else
    setLocal(progmanager, hObject, 'date', datestr(d, 1));
end

voltages = get(photodiode, 'calibrationVoltages');
powers = get(photodiode, 'calibrationPowers');

if isempty(powers) | isempty(voltages)
    set(getLocal(progmanager, hObject, 'trendline'), 'XData', [0 0], 'YData', [0 0]);
    set(getLocal(progmanager, hObject, 'datapoints'), 'XData', [0 0], 'YData', [0 0]);
    setLocalBatch(progmanager, hObject, 'power', 0, 'voltage', 0, 'slope', 0, 'offset', 0);
elseif length(powers) < 2 | length(voltages) < 2
    set(getLocal(progmanager, hObject, 'trendline'), 'XData', [0 0], 'YData', [0 0]);
    set(getLocal(progmanager, hObject, 'datapoints'), 'XData', voltages, 'YData', powers);
    setLocalBatch(progmanager, hObject, 'power', powers(end), 'voltage', voltages(end), 'slope', 0, 'offset', 0);
else
    slope = get(photodiode, 'calibrationSlope');
    offset = get(photodiode, 'calibrationOffset');
    yData = slope * voltages + offset;
    set(getLocal(progmanager, hObject, 'trendline'), 'XData', voltages, 'YData', yData);
    set(getLocal(progmanager, hObject, 'datapoints'), 'XData', voltages, 'YData', powers);
    setLocalBatch(progmanager, hObject, 'slope', slope, 'offset', offset);
end

%TO112008A - Update the lens transmission from the photodiode object when loading configurations. -- Tim O'Connor 11/20/08
setLocal(progmanager, hObject, 'lensTransmission', get(photodiode, 'lensTransmission'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function boardID_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
function boardID_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'photodiodeObject'), 'boardID', getLocal(progmanager, hObject, 'boardID'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function channelID_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function channelID_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'photodiodeObject'), 'channelID', getLocal(progmanager, hObject, 'channelID'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function photodiodeName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function photodiodeName_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'photodiodeObject'), 'Name', getLocal(progmanager, hObject, 'photodiodeName'));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function user_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function user_Callback(hObject, eventdata, handles)

set(getLocal(progmanager, hObject, 'photodiodeObject'), 'calibrationUser', getLocal(progmanager, hObject, 'user'));
update(hObject);%TO101606A - This should update here. Why this was never noticed before Leopoldo set up a new Windows XP/Matlab R2006a system at Janelia I'll never know... -- Tim O'Connor 10/16/06

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function date_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
function date_Callback(hObject, eventdata, handles)
return;


% --- Executes during object creation, after setting all properties.
function lens_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on selection change in lens.
function lens_Callback(hObject, eventdata, handles)
return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function lensTransmission_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
%TO030706C - Added lensTransmission factor.
function lensTransmission_Callback(hObject, eventdata, handles)

[pdiode transmission] = getLocalBatch(progmanager, hObject, 'photodiodeObject', 'lensTransmission');
set(pdiode, 'lensTransmission', transmission);

return;
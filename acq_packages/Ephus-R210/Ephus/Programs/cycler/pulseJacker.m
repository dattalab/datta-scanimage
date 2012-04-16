function varargout = pulseJacker(varargin)
% PULSEJACKER M-file for pulseJacker.fig
%      PULSEJACKER, by itself, creates a new PULSEJACKER or raises the existing
%      singleton*.
%
%      H = PULSEJACKER returns the handle to a new PULSEJACKER or the handle to
%      the existing singleton*.
%
%      PULSEJACKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PULSEJACKER.M with the given input arguments.
%
%      PULSEJACKER('Property','Value',...) creates a new PULSEJACKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pulseJacker_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pulseJacker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pulseJacker

% Last Modified by GUIDE v2.5 25-Aug-2006 17:46:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pulseJacker_OpeningFcn, ...
                   'gui_OutputFcn',  @pulseJacker_OutputFcn, ...
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


% --- Executes just before pulseJacker is made visible.
function pulseJacker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pulseJacker (see VARARGIN)

% Choose default command line output for pulseJacker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pulseJacker wait for user response (see UIRESUME)
% uiwait(handles.figure1);

return;

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = pulseJacker_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function positionIncrementSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function positionIncrementSlider_Callback(hObject, eventdata, handles)

[currentPosition, positions] = getLocalBatch(progmanager, hObject, 'currentPosition', 'positions');

if currentPosition < length(positions)
    setLocal(progmanager, hObject, 'currentPosition', currentPosition + 1);
end
setLocal(progmanager, hObject, 'positionIncrementSlider', 0.5);%TO113007A - Fixed sliders, down was never working, it was pegged at the min.

currentPosition_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function positionDecrementSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function positionDecrementSlider_Callback(hObject, eventdata, handles)

currentPosition = getLocalBatch(progmanager, hObject, 'currentPosition');

if currentPosition > 1
    setLocal(progmanager, hObject, 'currentPosition', currentPosition - 1);
end
setLocalBatch(progmanager, hObject, 'positionDecrementSlider', 0.5);%TO113007A - Fixed sliders, down was never working, it was pegged at the min.

currentPosition_Callback(hObject, eventdata, handles);

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

pj_currentPosition(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function currentChannel_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on selection change in currentChannel.
function currentChannel_Callback(hObject, eventdata, handles)

pj_currentChannel(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseSetName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on selection change in pulseSetName.
function pulseSetName_Callback(hObject, eventdata, handles)

pj_setPulseSetName(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pulseName_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% ------------------------------------------------------------------
% --- Executes on selection change in pulseName.
function pulseName_Callback(hObject, eventdata, handles)

pj_setPulseName(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in addPosition.
function addPosition_Callback(hObject, eventdata, handles)

pj_newPosition(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in deletePosition.
function deletePosition_Callback(hObject, eventdata, handles)

pj_deletePosition(hObject);

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
% --- Executes on selection change in cycleName.
function cycleName_Callback(hObject, eventdata, handles)

[cyclePath, cycleName] = getLocalBatch(progmanager, hObject, 'cyclePath', 'cycleName');
if ~isempty(cycleName)
    pj_loadCycle(hObject, fullfile(cyclePath, [cycleName '.pj']));
else
    setLocalBatch(progmanager, hObject, 'positions', [], 'currentPosition', 0);
    pj_selectCycle(hObject);
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in newCycle.
function newCycle_Callback(hObject, eventdata, handles)

pj_new(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in loadCycle.
function loadCycle_Callback(hObject, eventdata, handles)

pj_loadCycle(hObject);

return;

% ------------------------------------------------------------------
%TO091106E - Make sure that the callbacks are set up and the programs are hijacked on loopStart, since things may have been reset externally since the enable event. -- Tim O'Connor 9/11/06
% --- Executes on button press in enable.
function enable_Callback(hObject, eventdata, handles)

%TO091106E
% ufCbm = getUserFcnCBM;
% try
%     if hasCallback(ufCbm, 'ephys:SamplesOutput', 'userFcns_pj_samplesOutputCallback')
%         removeCallback(ufCbm, 'ephys:SamplesOutput', 'userFcns_pj_samplesOutputCallback');
%     end
%     if hasCallback(ufCbm, 'stim:SamplesOutput', 'userFcns_pj_samplesOutputCallback')
%         removeCallback(ufCbm, 'stim:SamplesOutput', 'userFcns_pj_samplesOutputCallback');
%     end
% catch
%     warning('Failed to properly remove user functions used when hijacking pulses: %s', lasterr);
% end
% 
% if getLocal(progmanager, hObject, 'enable')
%     setLocalGh(progmanager, hObject, 'enable', 'String', 'Disable', 'ForegroundColor', [1 0 0]);
%     setLocalGhBatch(progmanager, hObject, {'cycleName', 'newCycle', 'loadCycle', 'addPosition', 'deletePosition'}, 'Enable', 'Off');
%     setLocalGhBatch(progmanager, hObject, {'pulseSetName', 'pulseName'}, 'Enable', 'Off');
%     [precacheDefinitions, precacheData, programHandles] = getLocalBatch(progmanager, hObject, 'precacheDefinitions', 'precacheData', 'programHandles');
%     ephysCallbackSet = 0;
%     stimCallbackSet = 0;
%     for i = 1 : length(programHandles)
%         try
%             if strcmpi(getProgramName(progmanager, programHandles(i)), 'ephys')
%                 if ~ephysCallbackSet
%                     addCallback(ufCbm, 'ephys:SamplesOutput', {@pj_samplesOutputCallback, hObject, programHandles(i), 'ephys'}, 'userFcns_pj_samplesOutputCallback');
%                 end
%                 ephysCallbackSet = 1;
%                 setLocalBatch(progmanager, programHandles(i), 'segementedAcquisition', 1, 'transmissionsRemainingCounter', Inf, 'acquisitionsRemainingCounter', Inf, 'pulseHijacked', 1);
%             elseif strcmpi(getProgramName(progmanager, programHandles(i)), 'stimulator')
%                 if ~stimCallbackSet
%                     addCallback(ufCbm, 'stim:SamplesOutput', {@pj_samplesOutputCallback, hObject, programHandles(i), 'stim'}, 'userFcns_pj_samplesOutputCallback');
%                 end
%                 stimCallbackSet = 1;
%                 setLocalBatch(progmanager, programHandles(i), 'segementedAcquisition', 1, 'transmissionsRemainingCounter', Inf, 'pulseHijacked', 1);
%             else
%                 setLocalBatch(progmanager, programHandles(i), 'segementedAcquisition', 1, 'acquisitionsRemainingCounter', Inf);
%             end
%         catch
%             warning('Failed to properly hijack state of ''%s'': %s', getProgramName(progmanager, programHandles(i)), lasterr);
%         end
%     end
ufCbm = getUserFcnCBM;
if getLocal(progmanager, hObject, 'enable')
    setLocalGh(progmanager, hObject, 'enable', 'String', 'Disable', 'ForegroundColor', [1 0 0]);
    setLocalGhBatch(progmanager, hObject, {'cycleName', 'newCycle', 'loadCycle', 'addPosition', 'deletePosition'}, 'Enable', 'Off');
    setLocalGhBatch(progmanager, hObject, {'pulseSetName', 'pulseName'}, 'Enable', 'Off');
    [precacheDefinitions, precacheData] = getLocalBatch(progmanager, hObject, 'precacheDefinitions', 'precacheData');
    if precacheData
        pj_precacheData(hObject);
    elseif precacheDefinitions
        pj_precacheDefinitions(hObject);
    end
    pj_hijack(hObject);%TO101707D
    [programHandles] = getLocalBatch(progmanager, hObject, 'programHandles');
    for i = 1 : length(programHandles)
        setLocalGhBatch(progmanager, programHandles(i), {'pulseSetName', 'pulseName', 'stimOn'}, 'Enable', 'Off');
        setLocal(progmanager, programHandles(i), 'pulseHijacked', 1);
    end

    fireEvent(ufCbm, 'pulseJacker:Enable');
else
    %TO090706B - Terminate any running loops if this is disabled, because people have brainfarts. -- Tim O'Connor 9/7/06
    stop(getGlobal(progmanager, 'loopManager', 'loopGui', 'loopGui'));
    setLocalGhBatch(progmanager, hObject, {'cycleName', 'newCycle', 'loadCycle', 'addPosition', 'deletePosition'}, 'Enable', 'On');
    setLocalGhBatch(progmanager, hObject, {'pulseSetName', 'pulseName'}, 'Enable', 'On');
    setLocal(progmanager, hObject, 'loopEventData', []);%Clear loop information.
    pj_unhijack(hObject);%TO101707D
    [programHandles, precachedDefinitions] = getLocalBatch(progmanager, hObject, 'programHandles', 'precachedDefinitions');
    for i = 1 : length(programHandles)
        setLocalGhBatch(progmanager, programHandles(i), {'pulseSetName', 'pulseName', 'stimOn'}, 'Enable', 'On');
        setLocal(progmanager, programHandles(i), 'pulseHijacked', 0);
        %Force restart, if in external trigger, to refresh data.
        if getLocal(progmanager, programHandles(i), 'startButton')
            shared_Stop(programHandles(i));
        end
    end
%     for i = 1 : length(programHandles)
%         try
%             if strcmpi(getProgramName(progmanager, programHandles(i)), 'ephys')
%                 setLocalBatch(progmanager, programHandles(i), 'segmentedAcquisition', 0, 'transmissionsRemainingCounter', 0, 'acquisitionsRemainingCounter', Inf, 'pulseHijacked', 0);
%             elseif strcmpi(getProgramName(progmanager, programHandles(i)), 'stimulator')
%                 setLocalBatch(progmanager, programHandles(i), 'segmentedAcquisition', 0, 'transmissionsRemainingCounter', 0, 'pulseHijacked', 0);
%             else
%                 setLocalBatch(progmanager, programHandles(i), 'segmentedAcquisition', 0, 'acquisitionsRemainingCounter', 0);
%             end
%         catch
%             warning('Failed to properly reset state of ''%s'': %s', getProgramName(progmanager, programHandles(i)), lasterr);
%         end
%     end
    fireEvent(ufCbm, 'pulseJacker:Disable');
    setLocalGh(progmanager, hObject, 'enable', 'String', 'Enable', 'ForegroundColor', [0 0.6 0]);
    for i = 1 : length(precachedDefinitions)
        if ~isempty(precachedDefinitions{i})
            if strcmpi(class(precachedDefinitions{i}), 'signalobject')
                try
                    delete(precachedDefinitions{i});
                catch
                    warning('Failed to delete cached @signalobject: %s', lasterr);
                end
            end
        end
        
    end
    setLocalBatch(progmanager, hObject, 'positionsUsed', [], 'pulseDataMap', {}, 'precachedData', {});
end

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
        'hObject', hObject, ...
        'currentPosition', 0, 'Gui', 'currentPosition', 'Class', 'Numeric', 'Config', 7, ...
        'pulsePath', '', 'Class', 'char', 'Config', 7, ...
        'positions', {}, 'Config', 7, ...
        'pulseSetName', '', 'Gui', 'pulseSetName', 'Class', 'char', 'Config', 0, ...
        'pulseName', '', 'Gui', 'pulseName', 'Class', 'char', 'Config', 0, ...
        'pulseSetNameArray', {}, 'Config', 7, ...
        'pulseNameArray', {}, 'Config', 7, ...
        'currentChannel', '', 'Gui', 'currentChannel', 'Class', 'char', 'Config', 5, ...
        'programHandles', [], ...
        'enable', 0, 'Gui', 'enable', 'Class', 'char', 'Min', 0, 'Max', 1, 'Config', 7, ...
        'cycleName', '', 'Gui', 'cycleName', 'Class', 'char', 'Config', 7, ...
        'cyclePath', pwd, 'Class', 'char', 'Config', 7, ...
        'totalPositionsLabel', 0, 'Class', 'Numeric', 'Config', 5, 'Min', 0, 'Gui', 'totalPositionsLabel', ...
        'precacheDefinitions', 0, 'Class', 'Numeric', 'Config', 7, 'Min', 0, 'Max', 1, 'Gui', 'precacheDefinitions', ...
        'precachedDefinitions', {}, ...
        'precacheData', 0, 'Class', 'Numeric', 'Config', 7, 'Min', 0, 'Max', 1, 'Gui', 'precacheData', ...
        'precachedData', {}, ...
        'mappedProgramHandles', [], ...
        'loopCompleted', 0, ...
        'iterationCounter', 0, ...
        'pulseDataMap', {}, 'Config', 2, ...
        'loopEventData', [], ...
        'positionsUsed', [], ...
        'positionIncrementSlider', 0.5, 'Gui', 'positionIncrementSlider', 'Min', 0, 'Max', 1, ...
        'positionDecrementSlider', 0.5, 'Gui', 'positionDecrementSlider', 'Min', 0, 'Max', 1, ...
        'channelNames', {}, 'Config', 2, ...
    };

return;

% ------------------------------------------------------------------
%De facto 'constructor' for pulseJacker program
%Constructor Arguments:
%   programHandles - An array of program handles, which must be able to be hijacked (they must support certain variables
%                     and behaviors).
function genericStartFcn(hObject, eventdata, handles, varargin)

pm = progmanager;
setLocalBatch(pm, hObject, 'pulsePath', getDefaultCacheDirectory(pm, 'pulsePath'), 'cyclePath', getDefaultCacheDirectory(pm, 'cyclePath'));
%TO060810D - Check for event existence.
cbm = getUserFcnCBM;
if ~isEvent(cbm, 'pulseJacker:Enable')
    addEvent(cbm, 'pulseJacker:Enable');
end
if ~isEvent(cbm, 'pulseJacker:Disable')
    addEvent(cbm, 'pulseJacker:Disable');
end
bindEventListener(daqjob('acquisition'), 'jobDone', {@pj_jobDoneListener, hObject}, 'pj_jobDoneListener');%TO101707D

[lg lm] = lg_factory;%This opens the loop gui.
registerLoopable(lm, {@pj_loopListener, hObject}, 'pulseJacker', 1);%Make this a high priority listener, because later listeners may come looking for their data.

%To be implemented, stay tuned...
% try
%     addCallback(peCbm, 'pulseCreation', {@pj_pulseCreation, pj}, 'pj_pulseCreation');
%     addCallback(peCbm, 'pulseDeletion', {@pj_pulseDeletion, pj}, 'pj_pulseDeletion');
%     addCallback(peCbm, 'pulseSetCreation', {@pj_pulseSetCreation, pj}, 'pj_pulseSetCreation');
%     addCallback(peCbm, 'pulseSetDeletion', {@pj_pulseSetDeletion, pj}, 'pj_pulseSetDeletion');
%     addCallback(peCbm, 'pulseUpdate', {@pj_pulseUpdate, pj}, 'pj_pulseUpdate');
% catch
%     fprintf(2, 'Error registering pulseJacker callbacks for pulseEditor events.\n%s', getLastErrorStack);
% end
%TO053008B - Moved common start-up script functionality into the various programs. -- Tim O'Connor 5/30/08
try
    if ~isprogram(progmanager, 'pulseEditor')
        pe = program('pulseEditor', 'pulseEditor', 'pulseEditor');
        openprogram(progmanager, pe);
    else
        pe = getGlobal(progmanager, 'hObject', 'pulseEditor', 'pulseEditor');
    end
    peCbm = getLocal(progmanager, pe, 'callbackManager');
    addCallback(peCbm, 'pulseCreation', {@pj_pulseUpdate, hObject}, 'pj_pulseCreation');
    addCallback(peCbm, 'pulseDeletion', {@pj_pulseUpdate, hObject}, 'pj_pulseDeletion');
    addCallback(peCbm, 'pulseSetCreation', {@pj_pulseUpdate, hObject}, 'pj_pulseSetCreation');
    addCallback(peCbm, 'pulseSetDeletion', {@pj_pulseUpdate, hObject}, 'pj_pulseSetDeletion');
    addCallback(peCbm, 'pulseUpdate', {@pj_pulseUpdate, hObject}, 'pj_pulseUpdate');
catch
    fprintf(2, 'Error registering callbacks for pulseEditor events.\n%s', getLastErrorStack);
end

%VI060108A -- Process newly required programHandles argument -- Vijay Iyer 6/1/08
if ~isempty(varargin) 
    pj_setPrograms(hObject,varargin{1});
end

return;

% ------------------------------------------------------------------
%  TO101707D: Accept varargin, to allow for arguments automatically supplied by @daqjob's events. -- Tim O'Connor 10/17/07
function pj_jobDoneListener(hObject, varargin)
% fprintf(1, 'pj_jobDoneListener\n');
%TO112907I - Incrementing is handled in pj_getData for DAQ board timed loops. This was being redundant. -- Tim O'Connor 11/29/07
if getLocal(progmanager, hObject, 'enable') && ~get(loopManager, 'preciseTimeMode')
    pj_increment(hObject);
end

setLocal(progmanager, hObject, 'loopEventData', []);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

pj_currentCycle(hObject);

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

%TO060910B - Remove the events when we're done. -- Tim O'Connor 6/9/10
cbm = getUserFcnCBM;
if ~isEvent(cbm, 'pulseJacker:Enable')
    removeEvent(cbm, 'pulseJacker:Enable');
end
if ~isEvent(cbm, 'pulseJacker:Disable')
    removeEvent(cbm, 'pulseJacker:Disable');
end

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.3;

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
%TO090506H - First test, complete rewrite (was a one liner). -- Tim O'Connor 9/5/06
function genericPostLoadSettings(hObject, eventdata, handles, varargin)

ufCbm = getUserFcnCBM;
try
% fprintf(1, 'pulseJacker/genericPostLoadSettings: Removing callbacks...\n');
    if hasCallback(ufCbm, 'ephys:SamplesOutput', 'userFcns_pj_samplesOutputCallback')
        removeCallback(ufCbm, 'ephys:SamplesOutput', 'userFcns_pj_samplesOutputCallback');
    end
    if hasCallback(ufCbm, 'stim:SamplesOutput', 'userFcns_pj_samplesOutputCallback')
        removeCallback(ufCbm, 'stim:SamplesOutput', 'userFcns_pj_samplesOutputCallback');
    end
catch
    warning('Failed to properly remove user functions used when hijacking pulses: %s', lasterr);
end

%TO040710D - Make sure that the configured channel list matches the current channel list. -- Tim O'Connor 4/7/10
channelList = getLocalGh(progmanager, hObject, 'currentChannel', 'String');
actualChannels = pj_getChannelList(hObject);
invalidChannels = {};
keepIndices = [];
for i = 1 : length(channelList)
    if ismember(channelList{i}, actualChannels)
        keepIndices(length(keepIndices) + 1) = i;
    else
        invalidChannels{length(invalidChannels) + 1} = channelList{i};
    end
end
channelList = channelList(keepIndices);
if ~isempty(invalidChannels)
    fprintf(1, '%s - pulseJacker - Warning: The loaded configuration contains channels that do not exist: ', datestr(now));
    for i = 1 : length(invalidChannels)
        if i < length(invalidChannels)
            fprintf(1, '''%s'', ', invalidChannels{i});
        else
            fprintf(1, '''%s''', invalidChannels{i});
        end
    end
    fprintf(1, '\n\t\tNote: This may invalidate cycles created under this configuration. Attempts will be made to correct cycles as they are loaded.\n');
end
if any(~ismember(actualChannels, channelList))
    fprintf(1, '%s - pulseJacker - Warning: The loaded configuration is missing channels that should exist, they are being added.\n', datestr(now));
end
setLocalGh(progmanager, hObject, 'currentChannel', 'String', union(channelList, actualChannels));

[cycleName, cyclePath, pulsePath] = getLocalBatch(progmanager, hObject, 'cycleName', 'cyclePath', 'pulsePath');

if exist(pulsePath, 'dir') == 7
    pj_setPulsePath(hObject, pulsePath);
end

if ~isempty(cycleName) && ~isempty(cyclePath)
    filename = fullfile(cyclePath, [cycleName '.pj']);
    if exist(filename, 'file') == 2
        pj_loadCycle(hObject, filename);
    end
elseif ~isempty(cyclePath)
    pj_setCyclePath(hObject, cyclePath);
    pj_selectCycle(hObject);
end

enable_Callback(hObject, eventdata, handles);

return;

% ------------------------------------------------------------------
function genericPostLoadMiniSettings(hObject, eventdata, handles, varargin)

genericPostLoadSettings(hObject, eventdata, handles, varargin);

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericNewData(hObject, eventdata, handles)

pj_new(hObject);

return;

% ------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

pj_setPulsePath(hObject);

return;

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

pj_saveCycle(hObject);

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

[f, p] = uiputfile(fullfile(getDefaultCacheDirectory(progmanager, 'cyclePath'), '*.pj'));
if length(f) == 1
    if f == 0
        if length(p) == 1
            if p == 0
                return;
            end
        end
    end
end
if ~endsWithIgnoreCase(f, '.pj')
    f = [f '.pj'];
end
pj_saveCycle(hObject, fullfile(p, f));

return;

% ------------------------------------------------------------------
function genericPreCacheSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPreCacheMiniSettings(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostCacheSettings(hObject, eventdata, handles)

pj_currentCycle(hObject);

return;

% ------------------------------------------------------------------
function genericPostCacheMiniSettings(hObject, eventdata, handles)

pj_currentCycle(hObject);

return;

% ------------------------------------------------------------------
function genericCacheOperationBegin(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCacheOperationComplete(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes on button press in precacheDefinitions.
function precacheDefinitions_Callback(hObject, eventdata, handles)

[precacheDefinitions, precachedDefinitions, precacheData, enable] = getLocalBatch(progmanager, hObject, ...
    'precacheDefinitions', 'precachedDefinitions', 'precacheData', 'enable');

if precacheDefinitions && precacheData
    setLocalBatch(progmanager, hObject, 'precachedData', {}, 'precacheData', 0);
end

if ~precacheDefinitions
    setLocalBatch(progmanager, hObject, 'precacheDefinitions', 0, 'precachedDefinitions', {});
    if ~isempty(precachedDefinitions)
        for i = 1 : numel(precachedDefinitions)
            try
                delete(precachedDefinitions{i});
            catch
                warning('Failed to delete cached @signalobject instance: %s', lasterr);
            end
        end
    end
elseif enable
    pj_precacheDefinitions(hObject);
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in precacheData.
function precacheData_Callback(hObject, eventdata, handles)

[precacheDefinitions, precachedDefinitions, precacheData, enable] = getLocalBatch(progmanager, hObject, ...
    'precacheDefinitions', 'precachedDefinitions', 'precacheData', 'enable');

if precacheData && precacheDefinitions
    setLocalBatch(progmanager, hObject, 'precacheDefinitions', 0, 'precachedDefinitions', {});
    if ~isempty(precachedDefinitions)
        for i = 1 : numel(precachedDefinitions)
            try
                delete(precachedDefinitions{i});
            catch
                warning('Failed to delete cached @signalobject instance: %s', lasterr);
            end
        end
    end
end

if ~precacheData
    setLocalBatch(progmanager, hObject, 'precachedData', {}, 'precacheData', 0);
elseif enable
    pj_precacheData(hObject);
end

return;
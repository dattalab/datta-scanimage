function varargout = hotswitch(varargin)
% HOTSWITCH M-file for hotswitch.fig
%      HOTSWITCH, by itself, creates a new HOTSWITCH or raises the existing
%      singleton*.
%
%      H = HOTSWITCH returns the handle to a new HOTSWITCH or the handle to
%      the existing singleton*.
%
%      HOTSWITCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HOTSWITCH.M with the given input arguments.
%
%      HOTSWITCH('Property','Value',...) creates a new HOTSWITCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hotswitch_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hotswitch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hotswitch

% Last Modified by GUIDE v2.5 16-Mar-2010 12:18:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hotswitch_OpeningFcn, ...
                   'gui_OutputFcn',  @hotswitch_OutputFcn, ...
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
% --- Executes just before hotswitch is made visible.
function hotswitch_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
% UIWAIT makes hotswitch wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = hotswitch_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
return;

% ------------------------------------------------------------------
%TO031610A - Made the userFcns optional.
%TO031910A - Confirm when removing a userFcn event that has callbacks attached to it. -- Tim O'Connor 3/19/10
function updateUserFcnCallbacks(hObject)

[enableUserFcns, states] = getLocalBatch(progmanager, hObject, 'enableUserFcns', 'states');

removeConfirmed = 'Yes';

cbm = getUserFcnCBM;
for i = 1 : length(states)
    eventName = ['hotswitch:State' num2str(i)];

    if enableUserFcns && exist(states(i).directory, 'dir') == 7 && ~isempty(states(i).directory) && ~isEvent(cbm, eventName)
        addEvent(cbm, eventName);
    elseif isEvent(cbm, eventName) && (~enableUserFcns || exist(states(i).directory, 'dir') ~= 7) && ~strcmpi(removeConfirmed, 'No For All')
        if ~isempty(getCallbacks(cbm, eventName))
            removeConfirmed = questdlg(sprintf('The ''%s'' userFcn event has a callback attached. Are you sure it should be removed?', eventName), ...
                'Confirm Event Deletion', 'Yes', 'No', 'No For All', 'No For All');
        end
        if strcmpi(removeConfirmed, 'Yes')
            removeEvent(cbm, eventName);
        end
    end
end

return;

% ------------------------------------------------------------------
%TO031610A - Added a listbox and paging, to handle many more states.
function loadState(hObject, stateNumber)

setLocal(progmanager, hObject, 'stateNumber', stateNumber);
states = getLocal(progmanager, hObject, 'states');
stateNumStr = num2str(stateNumber);

%TO083107D - Log loading of a hotswitch state. -- Tim O'Connor 8/31/07
autonotes_addNote(['Hotswitch ' stateNumStr ' - ' states(stateNumber).name]);%TO031910A - Use `stateNumber`.
fprintf(1, '%s - Hotswitch %s: ''%s''\n', datestr(now), stateNumStr, states(stateNumber).name);%TO031910A - Use `stateNumber`.

lastConfigDir = getDefaultCacheDirectory(progmanager, 'lastConfigDir');
loadConfigurations(progmanager, states(stateNumber).directory);
setDefaultCacheValue(progmanager, 'lastConfigDir', lastConfigDir);

if getLocal(progmanager, hObject, 'enableUserFcns')
    eventName = ['hotswitch:State' stateNumStr];
    cbm = getUserFcnCBM;
    if isEvent(cbm, eventName)
        fireEvent(cbm, eventName);
    else
        fprintf(2, '%s - Hotswitch - Expected userFcn event ''%s'' not found.\n', datestr(now), eventName);
    end
end

return;

% ------------------------------------------------------------------
%TO031610A - Added a listbox and paging, to handle many more states.
function setPageNumber(hObject, pageNumber)

setLocalBatch(progmanager, hObject, 'pageNumber', pageNumber, 'pageSlider', pageNumber);
states = getLocal(progmanager, hObject, 'states');

for i = 1 : 12
    stateNumber = (pageNumber - 1) * 12 + i;
    stateNumStr = num2str(stateNumber);
    iStr = num2str(i);
    setLocalGh(progmanager, hObject, ['label' iStr], 'String', ['State' stateNumStr]);
    if exist(states(stateNumber).directory, 'dir') == 7
        setLocalGh(progmanager, hObject, ['state' iStr], 'String', states(stateNumber).name, 'Enable', 'On');
    else
        setLocalGh(progmanager, hObject, ['state' iStr], 'String', states(stateNumber).name, 'Enable', 'Off');
    end
end

return;

% ------------------------------------------------------------------
%TO031610A - Added a listbox and paging, to handle many more states.
function updateListBox(hObject)

states = getLocal(progmanager, hObject, 'states');
stateNames = cell(length(states), 1);

for i = 1 : length(states)
    stateNames{i} = states(i).name;
end

setLocalGh(progmanager, hObject, 'stateList', 'String', stateNames);

return;
    
% ------------------------------------------------------------------
% --- Executes on button press in state1.
function state1_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 1);

return;

% % ------------------------------------------------------------------
% % --- Executes on button press in configure1.
% function configure1_Callback(hObject, eventdata, handles)
% 
% f = getParent(getLocal(progmanager, hObject, 'configObj'), 'figure');
% hs_configureState(f, 1);
% set(f, 'Visible', 'On');
% movegui(f);
% 
% return;

% ------------------------------------------------------------------
% --- Executes on button press in state2.
function state2_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 2);

return;

% % ------------------------------------------------------------------
% % --- Executes on button press in configure2.
% function configure2_Callback(hObject, eventdata, handles)
% 
% f = getParent(getLocal(progmanager, hObject, 'configObj'), 'figure');
% hs_configureState(f, 2);
% set(f, 'Visible', 'On');
% movegui(f);
% 
% return;

% ------------------------------------------------------------------
% --- Executes on button press in state3.
function state3_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 3);

return;

% % ------------------------------------------------------------------
% % --- Executes on button press in configure3.
% function configure3_Callback(hObject, eventdata, handles)
% 
% f = getParent(getLocal(progmanager, hObject, 'configObj'), 'figure');
% hs_configureState(f, 3);
% set(f, 'Visible', 'On');
% movegui(f);
% 
% return;

% ------------------------------------------------------------------
% --- Executes on button press in state4.
function state4_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 4);

return;

% % ------------------------------------------------------------------
% % --- Executes on button press in configure4.
% function configure4_Callback(hObject, eventdata, handles)
% 
% f = getParent(getLocal(progmanager, hObject, 'configObj'), 'figure');
% hs_configureState(f, 4);
% set(f, 'Visible', 'On');
% movegui(f);
% 
% return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
        'hObject', hObject, ...
        'configObj', [], ...
        'states', [], 'Config', 5, ...
        'stateList', 1, 'Config', 5, 'Class', 'Numeric', 'Gui', 'stateList', ...
        'pageNumber', 1, 'Config', 5, ...
        'expandView', 1, 'Config', 5, 'Class', 'Numeric', 'Gui', 'expandView', ...
        'pageSlider', 1, 'Config', 5, 'Min', 1, 'Class', 'Numeric', 'Gui', 'pageSlider', ...
        'enableUserFcns', 1, 'Config', 5, 'Class', 'Numeric', 'Gui', 'enableUserFcns', ...
        'totalStates', 60, ...
        'buttonsPerPage', 12, ...
      };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

[totalStates, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'totalStates', 'buttonsPerPage');
sliderStep = 1 / ((totalStates / buttonsPerPage) - 1);
setLocalGh(progmanager, hObject, 'pageSlider', 'Max', totalStates / buttonsPerPage, 'SliderStep', [sliderStep, sliderStep]);

%TO060810A
%On Matlab R2010a the guis seem to load with different units, which screws up the hotswitch scaling.
%No idea why we're using characters though, anyway, must've been the default in some earlier versions.
setLocalGh(progmanager, hObject, 'hotswitch', 'Units', 'characters');

genericPostLoadSettings(hObject, eventdata, handles); %TO031610A
% cbm = getUserFcnCBM;
% addEvent(cbm, 'hotswitch:State1');
% addEvent(cbm, 'hotswitch:State2');
% addEvent(cbm, 'hotswitch:State3');
% addEvent(cbm, 'hotswitch:State4');
% addEvent(cbm, 'hotswitch:State5');
% addEvent(cbm, 'hotswitch:State6');
% addEvent(cbm, 'hotswitch:State7');
% addEvent(cbm, 'hotswitch:State8');
% addEvent(cbm, 'hotswitch:State9');
% addEvent(cbm, 'hotswitch:State10');
% addEvent(cbm, 'hotswitch:State11');
% addEvent(cbm, 'hotswitch:State12');
% 
% for i = 1 : 72
%     states(i).name = 'Undefined';
%     states(i).directory = '';
% end
% 
% setLocal(progmanager, hObject, 'states', states);

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

%TO060910B - Remove the events when we're done. -- Tim O'Connor 6/9/10
states = getLocal(progmanager, hObject, 'states');
cbm = getUserFcnCBM;
for i = 1 : length(states)
    eventName = ['hotswitch:State' num2str(i)];
    if isEvent(cbm, eventName)
        removeEvent(cbm, eventName);
    end
end

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.2;

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
%TO031610A - A near-complete rewrite of this function.
function genericPostLoadSettings(hObject, eventdata, handles, varargin)

[states, pageNumber, totalStates] = getLocalBatch(progmanager, hObject, 'states', 'pageNumber', 'totalStates');

if length(states) < totalStates
    for i = length(states) + 1 : totalStates
        states(i).name = ['Undefined' num2str(i)];
        states(i).directory = '';
    end
    setLocal(progmanager, hObject, 'states', states);
end

updateListBox(hObject);

setPageNumber(hObject, pageNumber);

updateUserFcnCallbacks(hObject);

% pos = get(getParent(hObject, 'figure'), 'Position');
% if pos(3) < 65.4
%     pos(3) = 65.4;
%     set(getParent(hObject, 'figure'), 'Position', pos);
% end

expandView_Callback(hObject, eventdata, handles);

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
% --- Executes on button press in state5.
function state5_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 5);

return;

% ------------------------------------------------------------------
% --- Executes on button press in state6.
function state6_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 6);

return;

% ------------------------------------------------------------------
% --- Executes on button press in state7.
function state7_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 7);

return;

% ------------------------------------------------------------------
% --- Executes on button press in state8.
function state8_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 8);

return;

% ------------------------------------------------------------------
% --- Executes on button press in state9.
function state9_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 9);

return;

% ------------------------------------------------------------------
% --- Executes on button press in state10.
function state10_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 10);

return;

% ------------------------------------------------------------------
% --- Executes on button press in state11.
function state11_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 11);

return;

% ------------------------------------------------------------------
% --- Executes on button press in state12.
function state12_Callback(hObject, eventdata, handles)

[pageNumber, buttonsPerPage] = getLocalBatch(progmanager, hObject, 'pageNumber', 'buttonsPerPage');
loadState(hObject, (pageNumber - 1) * buttonsPerPage + 12);

return;

% ------------------------------------------------------------------
% --- Executes on button press in expandView.
function expandView_Callback(hObject, eventdata, handles)

f = getFigHandle(progmanager, hObject);
pos = get(f, 'Position');

if getLocal(progmanager, hObject, 'expandView')
    pos(3) = 102.6;%102.60000000000001;   
    setLocalGh(progmanager, hObject, 'expandView', 'String', '<<', 'TooltipString', 'Compress the display to hide individual state buttons.');
else
    pos(3) = 35.4;
    setLocalGh(progmanager, hObject, 'expandView', 'String', '>>', 'TooltipString', 'Expand the display to show individual state buttons.');
end

set(f, 'Position', pos);

return;

% ------------------------------------------------------------------
% --- Executes on button press in nextPage.
function nextPage_Callback(hObject, eventdata, handles)

[pageNumber, totalStates] = getLocalBatch(progmanager, hObject, 'pageNumber', 'totalStates');
setPageNumber(hObject, min(totalStates / 12, pageNumber + 1));

return;

% ------------------------------------------------------------------
% --- Executes on button press in previousPage.
function previousPage_Callback(hObject, eventdata, handles)

setPageNumber(hObject, max(1, getLocal(progmanager, hObject, 'pageNumber') - 1));

return;

% ------------------------------------------------------------------
% --- Executes on selection change in stateList.
function stateList_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function stateList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in loadSelected.
function loadSelected_Callback(hObject, eventdata, handles)

[stateList, states] = getLocalBatch(progmanager, hObject, 'stateList', 'states');
if exist(states(stateList).directory, 'dir') == 7
    loadState(hObject, stateList);
else
    errordlg(['State' num2str(stateList) ' (''' states(stateList).name ''') is not defined.']);
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in editSelected.
function editSelected_Callback(hObject, eventdata, handles)

[stateList, configObj] = getLocalBatch(progmanager, hObject, 'stateList', 'configObj');

hs_configureState(configObj, stateList);

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function pageSlider_Callback(hObject, eventdata, handles)

setPageNumber(hObject, round(getLocal(progmanager, hObject, 'pageSlider')));

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function pageSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', [.9 .9 .9]);
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in enableUserFcns.
function enableUserFcns_Callback(hObject, eventdata, handles)

updateUserFcnCallbacks(hObject);

return;
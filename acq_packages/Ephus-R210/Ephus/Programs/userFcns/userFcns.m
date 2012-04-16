function varargout = userFcns(varargin)
% USERFCNS M-file for userFcns.fig
%      USERFCNS, by itself, creates a new USERFCNS or raises the existing
%      singleton*.
%
%      H = USERFCNS returns the handle to a new USERFCNS or the handle to
%      the existing singleton*.
%
%      USERFCNS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in USERFCNS.M with the given input arguments.
%
%      USERFCNS('Property','Value',...) creates a new USERFCNS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before userFcns_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to userFcns_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help userFcns

% Last Modified by GUIDE v2.5 09-Jun-2008 16:39:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @userFcns_OpeningFcn, ...
                   'gui_OutputFcn',  @userFcns_OutputFcn, ...
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


% --- Executes just before userFcns is made visible.
function userFcns_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to userFcns (see VARARGIN)

% Choose default command line output for userFcns
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes userFcns wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;


% --- Outputs from this function are returned to the command line.
function varargout = userFcns_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
return;

%--------------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'currentEvent', '', 'Class', 'char', 'Gui', 'events', 'Config', 3, ...
       'currentCallback', '', 'Class', 'char', 'Gui', 'callbacks', ...
       'callbackMappings', {},'Class', 'cell', 'Config', 3, ... %A Nx3 array. Column 1 contains events; column 2 contains cell array of callbacks bound to event; column 3 contains cell array of cell arrays containing the user-specified arguments
       'enable', 1, 'Class', 'Numeric', 'Gui', 'enable', 'Config', 2, ...
   };

return;

%--------------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

updateGuiFromCBM(hObject);

return;

%--------------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

%--------------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

%--------------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

errordlg('Open is not supported by this GUI.');

return;

%--------------------------------------------------------------------------
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

updateCBMFromGui(hObject);
updateGuiFromCBM(hObject);

return;

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)
updateCBMFromGui(hObject);
return;
%errordlg('Save is not supported by this GUI.');


% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)
updateGuiFromCBM(hObject);
return;
%errordlg('Save As is not supported by this GUI.');


% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function events_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on selection change in events.
function events_Callback(hObject, eventdata, handles)

updateGuiFromCBM(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function callbacks_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% ------------------------------------------------------------------
% --- Executes on selection change in callbacks.
function callbacks_Callback(hObject, eventdata, handles)

updateGuiFromCBM(hObject); %Forces update of arguments edit control (VI060908A)

return;

% ------------------------------------------------------------------
% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)

[currentEvent, callbackMappings] = getLocalBatch(progmanager, hObject, 'currentEvent', 'callbackMappings');
index = find(strcmpi({callbackMappings{:, 1}}, currentEvent));
if isempty(index)
    error('Unmapped event found: ''%s''', currentEvent);
end

%TO030906B: Allow the user to select the callback via gui, instead of requiring them to type in the function name.
% response = inputdlg({'Callback function name:'}, 'Add new user function.');
% if isempty(response)
%     end
% end
% 
% if exist([response{1} '.m']) ~= 2
%     warndlg(sprintf('M-File for ''%s'' could not be found on the path.', response{1}));
%     error('M-File for ''%s'' could not be found on the path.', response{1});
% end
[filename pathname] = uigetfile(fullfile(getDefaultCacheDirectory(progmanager, 'userFcnsDir'), '*.m'), 'Select an M-File...');
if length(filename) == 1 && filename == 0
    return;%Cancelled.
end

%TO030906B: Make sure it's in the path. -- Tim O'Connor 3/9/06
if endsWith(pathname, '\')
    pathname = pathname(1 : end-1);
end
if isempty(strfind(lower(path), lower(pathname)))
   answer = questdlg(sprintf('''%s'' is not currently in the Matlab path. Would you like to add this to the path?', ...
       fullfile(pathname, filename)), 'Not In Path', ...
       'Add to path', 'Add to path and save path', 'Cancel', 'Add to path and save path');

   switch lower(answer)
       case 'add to path'
           addpath(pathname);
       case 'add to path and save path'
           addpath(pathname);
           path2rc;
       case 'cancel'
           return;
       otherwise
           warning('Unrecognized option ''%s''', answer);
   end

   return;
end

[p, filename, ext, version] = fileparts(filename);

callbackList = getLocalGh(progmanager, hObject, 'callbacks', 'String');
if ismember(filename, callbackList) %TO030906B
    warndlg(sprintf('Function ''%s'' is already registered as a callback for ''%s''.', filename, currentEvent));%TO030906B
    error('Function ''%s'' is already registered as a callback for ''%s''.', filename, currentEvent);%TO030906B
end

fHandle = eval(sprintf('@%s;', filename));%TO121405C: Must convert the name into a function_handle. -- Tim O'Connor 12/14/05 %TO030906B
addCallback(getUserFcnCBM, currentEvent, fHandle, ['userFcns_' filename]);%TO030906B

%TO032210B - Get rid of all this mess, and just let the updateGuiFromCBM function handle everything, the way it should've been from the start. -- Tim O'Connor 3/22/10
% callbacks = callbackMappings{index, 2};
% callbacks{length(callbacks) + 1} = filename;%TO030906B
% callbackMappings{index, 2} = callbacks;
% %TO032210A - Make sure there is a third column before trying to access it. Also, you can't use {end + 1} if it is empty. -- Tim O'Connor 3/22/10
% if size(callbackMappings, 2) >= 3
%     callbackMappings{index, 3}{length(callbackMappings{index, 3}) + 1} = {};%VI061808B
% else
%     callbackMappings{index, 3} = {};%VI061808B
% end
% 
% setLocal(progmanager, hObject, 'callbackMappings', callbackMappings);
% callbackList{length(callbackList) + 1} = filename;%TO030906B
% setLocalGh(progmanager, hObject, 'callbacks', 'String', callbackList);
updateGuiFromCBM(hObject);%TO032210B

setDefaultCacheValue(progmanager, 'userFcnsDir', pathname);%TO030906B

return;

% ------------------------------------------------------------------
% --- Executes on button press in delete.
function delete_Callback(hObject, eventdata, handles)

[currentEvent, callbackMappings, currentCallback] = getLocalBatch(progmanager, hObject, 'currentEvent', 'callbackMappings', 'currentCallback');
index = find(strcmpi({callbackMappings{:, 1}}, currentEvent));
if isempty(index)
    error('Unmapped event found: ''%s''', currentEvent);
end

removeCallback(getUserFcnCBM, currentEvent, ['userFcns_' currentCallback]);

%TO032210B - Get rid of all this mess, and just let the updateGuiFromCBM function handle everything, the way it should've been from the start. -- Tim O'Connor 3/22/10
% %VI061808B--Do this more generally
% % callbacks = callbackMappings{index, 2};
% % callbacks = {callbacks{~strcmp(callbacks, currentCallback)}};
% % callbackMappings{index, 2} = callbacks;
% cbkIndex = strcmp(callbackMappings{index, 2}, currentCallback);
% callbackMappings{index, 2}(cbkIndex) = [];
% callbackMappings{index, 3}(cbkIndex) = [];
% %%%% 
% 
% setLocal(progmanager, hObject, 'callbackMappings', callbackMappings);
% setLocalGh(progmanager, hObject, 'callbacks', 'String', callbacks);
updateGuiFromCBM(hObject);%TO032210B

    
return;

% ------------------------------------------------------------------
% --- Executes on button press in enable.
function enable_Callback(hObject, eventdata, handles)

updateCBMFromGui(hObject);

return;

% ------------------------------------------------------------------
function updateGuiFromCBM(hObject)

cbm = getUserFcnCBM;

events = getEvents(cbm);

callbackMappings = {};
for i = 1 : length(events)
    index = size(callbackMappings, 1) + 1;
    callbackMappings{index, 1} = events{i};
    callbackMappings{index, 2} = getCallbacksAsStrings(cbm, events{i});

    numCallbacks = length(callbackMappings{index, 2});
    for j = 1 : numCallbacks
        callbackMappings{index, 3}{j} = getCallbackArgs(cbm, events{index}, callbackMappings{index, 2}{j});
    end
end

setLocal(progmanager, hObject, 'enable', get(cbm, 'enable'));

[currentEvent, currentCallback] = getLocalBatch(progmanager, hObject, 'currentEvent', 'currentCallback'); %VI060908A
setLocal(progmanager, hObject, 'callbackMappings', callbackMappings);
setLocalGh(progmanager, hObject, 'events', 'String', events);
callbackList = getCallbacksAsStrings(cbm, currentEvent);
setLocalGh(progmanager, hObject, 'callbacks', 'String', callbackList);
if ~isempty(callbackList)
    setLocal(progmanager, hObject, 'currentCallback', callbackList{1});%TO032210B.
end

%Handle callbackArgs (VI060908A) (VI072208A)
if ~isempty(currentCallback)
    cbkArgs = getCallbackArgs(cbm, currentEvent, currentCallback);
    setLocalGh(progmanager, hObject, 'etCallbackArgs', 'String', parseArgumentCellArray(cbkArgs));
else
    setLocalGh(progmanager, hObject, 'etCallbackArgs', 'String', '');
end

try
    documentation = getDocumentation(cbm, currentEvent);
    if isempty(documentation)
        setLocalGh(progmanager, hObject, 'events', 'TooltipString', 'Currently available events.');
    else
        setLocalGh(progmanager, hObject, 'events', 'TooltipString', sprintf('Currently available events.\n''%s'' - %s', currentEvent, documentation));
    end          
catch
    setLocalGh(progmanager, hObject, 'events', 'TooltipString', 'Currently available events.');
end

return;

% ------------------------------------------------------------------
function updateCBMFromGui(hObject)

cbm = getUserFcnCBM;
% setLocalGh(progmanager, hObject, 'events', 'String', getEvents(getUserFcnCBM));
[callbackMappings, currentEvent, currentCallback] = getLocalBatch(progmanager, hObject, 'callbackMappings', 'currentEvent','currentCallback');


for index = 1 : size(callbackMappings, 1)
    % index = find(strcmpi({callbackMappings{:, 1}}, currentEvent));
    if ~isempty(index)
        callbacks = callbackMappings{index, 2};
        % fprintf(1, 'userFcns/updateCBMFromGui: Removing callbacks for event ''%s''.\n', callbackMappings{index, 1});
        % % cbStructs = getCallbackStructs(cbm, callbackMappings{index, 1});
        % % for i = 1 : length(cbStructs)
        % %     cbStructs(i)
        % % end
        callbacks2 = getCallbacksAsStrings(cbm, callbackMappings{index, 1});
        %Remove any other callbacks that might exist.
        for i = 1 : length(callbacks2)
            %TO032406H: Remove all callbacks then re-add any from the gui. -- Tim O'Connor 3/24/06
            % if ~ismember(callbacks2{i}, callbacks)
            try
                % fprintf(1, 'userFcns/updateCBMFromGui: Attempting to remove callback ''%s'' from %s.\n', callbacks2{i}, callbackMappings{index, 1});
                removeCallback(cbm, callbackMappings{index, 1}, ['userFcns_' callbacks2{i}]);
            catch
                fprintf(1, 'Warning: userFcns failed to remove callback ''%s'' from event ''%s'': %s', callbacks2{i}, callbackMappings{index, 1}, getLastErrorStack);
            end
            % end
        end
        
        %TO032210E - Add missing events. -- Tim O'Connor 3/22/10
        for i = 1 : size(callbackMappings, 1)
            if ~isEvent(cbm, callbackMappings{i, 1})
                addEvent(cbm, callbackMappings{i, 1});
            end
        end

        %Add missing callbacks.
        for i = 1 : length(callbacks)
            if ~hasCallback(cbm, callbackMappings{index, 1}, ['userFcns_' callbacks{i}])
                if size(callbackMappings,2) == 3 %VI061808B                     
                    %addCallback(cbm, callbackMappings{index, 1}, str2func(callbacks{i}), ['userFcns_' callbacks{i}],callbackMappings{index,3}{i}); %VI061808B  %VI072208
                    callbackSpec = {str2func(callbacks{i})};
                    if ~isempty(callbackMappings{index, 3})
                        cbkArgs = callbackMappings{index, 3}{i};
                        callbackSpec = {callbackSpec{:} cbkArgs{:}};
                    end
                    addCallback(cbm, callbackMappings{index, 1}, callbackSpec, ['userFcns_' callbacks{i}]);                    
                else   %VI061808B: this is for backwards compatibility
                    addCallback(cbm, callbackMappings{index, 1}, str2func(callbacks{i}), ['userFcns_' callbacks{i}]);
                end
            end
        end

    end
end

set(getUserFcnCBM, 'enable', getLocal(progmanager, hObject, 'enable'));
       
return;


function etCallbackArgs_Callback(hObject, eventdata, handles)

[currentEvent, currentCallback,callbackMappings] = getLocalBatch(progmanager,hObject,'currentEvent','currentCallback','callbackMappings');

%Argument error checking
update = false;
if isempty(currentCallback)
    set(hObject,'String','');    
else
    argVal = {};
    if ~isempty(get(hObject,'String'))        
        try
            argVal = eval(get(hObject,'String'));            
        catch
            fprintf(2,[mfilename ': Unable to parse input argument string\n']);
            set(hObject,'String','{}');
            update=true;
        end
        if ~update
            if ~iscell(argVal) || ~isvector(argVal)
                fprintf(2,[mfilename ': Argument string in userFcns GUI must represent a vectorial cell array\n']);
                set(hObject,'String','{}');
            else
                update = true;
            end
        end
    else
        update = true; %update if empty!
    end
end

if update
    eventIdx = find(strcmpi({callbackMappings{:, 1}}, currentEvent));
    cbkIdx = find(strcmpi(callbackMappings{eventIdx, 2}, currentCallback));
    callbackMappings{eventIdx,3}{cbkIdx} = argVal;
    setLocal(progmanager,hObject,'callbackMappings',callbackMappings);
    
    updateCBMFromGui(hObject);
end

return;
   
    
%% HELPER FUNCTIONS
%%%Helper fucntion to get any callback args from the callback spec stored in the @callbackmanager
function cbkArgs = getCallbackArgs(cbm,event,callbackName)
callbackNames = getCallbacksAsStrings(cbm,event);
callbacks = getCallbacks(cbm,event);
[name,cbkIndex] = intersect(callbackNames,callbackName);
cbkArgs = {};
if ~isempty(cbkIndex)
    callback = callbacks{cbkIndex};
    if iscell(callback) && length(callback)>=2
        cbkArgs = {callback{2:end}};
    end
end
return;

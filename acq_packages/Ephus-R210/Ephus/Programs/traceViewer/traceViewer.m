function varargout = traceViewer(varargin)
% TRACEVIEWER M-file for traceViewer.fig
%      TRACEVIEWER, by itself, creates a new TRACEVIEWER or raises the existing
%      singleton*.
%
%      H = TRACEVIEWER returns the handle to a new TRACEVIEWER or the handle to
%      the existing singleton*.
%
%      TRACEVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACEVIEWER.M with the given input arguments.
%
%      TRACEVIEWER('Property','Value',...) creates a new TRACEVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before traceViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to traceViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help traceViewer

% Last Modified by GUIDE v2.5 22-Feb-2010 23:48:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @traceViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @traceViewer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%-----------------------------------------------------------------------
% --- Executes just before traceViewer is made visible.
function traceViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for traceViewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes traceViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);
return;

%-----------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = traceViewer_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

return;

%-----------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'filename', '' 'Class', 'char', 'Gui', 'filename', 'Config', 7, ...
       'defaultDirectory', '', 'Class', 'char', 'Config', 5, ...
       'inputChannelList', {}, 'Class', 'cell', 'Min', 0, 'Max', 100, 'Config', 5, ...
       'outputChannelList', {}, 'Class', 'cell', 'Min', 0, 'Max', 100, 'Config', 5, ...
       'oneFigurePerInputChannel', 1, 'Class', 'Numeric', 'Gui', 'oneInputFigurePerChannel', 'Config', 5, ...
       'oneFigureForAllInputChannels', 0, 'Class', 'Numeric', 'Gui', 'oneInputFigure', 'Config', 5, ...
       'showAllInputs', 1, 'Class', 'Numeric', 'Gui', 'showAllInputs', 'Config', 5, ...
       'showSelectedInputs', 0, 'Class', 'Numeric', 'Gui', 'showSelectedInputs', 'Config', 5, ...
       'showNoInputs', 0, 'Class', 'Numeric', 'Gui', 'showNoInputs', 'Config', 5, ...
       'oneFigurePerOutputChannel', 1, 'Class', 'Numeric', 'Gui', 'oneOutputFigurePerChannel', 'Config', 5, ...
       'oneFigureForAllOutputChannels', 0, 'Class', 'Numeric', 'Gui', 'oneOutputFigure', 'Config', 5, ...
       'showAllOutputs', 1, 'Class', 'Numeric', 'Gui', 'showAllOutputs', 'Config', 5, ...
       'showSelectedOutputs', 0, 'Class', 'Numeric', 'Gui', 'showSelectedOutputs', 'Config', 5, ...
       'showNoOutputs', 0, 'Class', 'Numeric', 'Gui', 'showNoOutputs', 'Config', 5, ...
       'fileData', [], ...
       'inputFigures', {}, ...
       'outputFigures', {}, ...
       'figures', {}, ...
       'inputAxes', {}, ...
       'outputAxes', {}, ...
       'inputFigurePositions', {}, 'Config', 5, ...
       'outputFigurePositions', {}, 'Config', 5, ...
       'pulse', signalobject('Name', 'traceViewerPulse', 'sampleRate', 10000), ...
       'oneFigurePerChannel', 0, 'Class', 'Numeric', 'Gui', 'oneFigurePerChannel', 'Config', 5, ...
       'oneFigureForAllChannels', 1, 'Class', 'Numeric', 'Gui', 'oneFigureForAllChannels', 'Config', 5, ...
       'figurePositions', {}, 'Config', 5, ...
   };

return;

%-----------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles, varargin)

set(getFigHandle(progmanager, hObject), 'KeyPressFcn', {@keyPressFcn_Callback, hObject});
%TO033110C - If the program is starting along with the rest of Ephus, it should not browse automatically. -- Tim O'Connor 3/31/10
% browseFile_Callback(hObject, eventdata, handles);

return;
%-----------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ----------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

[pulse] = getLocalBatch(progmanager, hObject, 'pulse');
clearFigures(hObject, 'inputFigures');
clearFigures(hObject, 'outputFigures');
clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');

delete(pulse);
setLocal(progmanager, hObject, 'pulse', []);

return;

% ----------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

return;

% ----------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

browseFile_Callback(hObject, eventdata, handles);

return;

% ----------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

errordlg('Save is not supported by this gui.');

return;

% ----------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

exportData_Callback(hObject, eventdata, handles);

return;

% ----------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

saveFigurePositions(hObject);

return;

% ----------------------------------------------------------------------
function saveFigurePositions(hObject)

[figures] = getLocalBatch(progmanager, hObject, 'figures');
figurePositions = {};
for i = 1 : size(figures, 1)
    if ishandle(figures{i, 2})
        figurePositions{i} = get(figures{i, 2}, 'Position');
    end
end

setLocalBatch(progmanager, hObject, 'figurePositions', figurePositions);

return;

% ----------------------------------------------------------------------
function restoreFigurePositions(hObject)

[figures, figurePositions] = getLocalBatch(progmanager, hObject, ...
    'figures', 'figurePositions');

if isempty(figurePositions)
    return;
end
if isempty(figures) || size(figures, 2) < 2
    return;
end

for i = 1 : size(figures, 1)
    if ishandle(figures{i, 2})
        if length(figurePositions) >= i
            %TO042210B - Some unknown bug is causing this to fail at `movegui` because of an invalid handle, even though `set` seems to work... -- Tim O'Connor 4/22/10
            try
                set(figures{i, 2}, 'Position', figurePositions{i});
                movegui(figures{i, 2});%Make sure it appears on the screen.
            catch
                fprintf(2, 'Failed to restore position of figure %s\n%s\n', num2str(i), getLastErrorStack);
            end
        %else
        %    set(figures{i, 2}, 'Position', figurePositions{end});
        %    movegui(figures{i, 2});%Make sure it appears on the screen.
        end
        % set(figures{i, 2}, 'Visible', 'On');
    end
end

return;

% ----------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

restoreFigurePositions(hObject);

return;

% ----------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

return;

% ----------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles)

%saveFigurePositions(hObject);
% clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');
filename_Callback(hObject, eventdata, handles);
%TO042210C - Let the loading of the data restore the figure positions, if necessary.
%restoreFigurePositions(hObject);

return;

% ----------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

return;

% ----------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

return;

%-----------------------------------------------------------------------
function selectedInputChannelList = getSelectedInputChannelList(hObject)

selectedInputChannelList = getLocal(progmanager, hObject, 'inputChannelList');
% inList = getLocalGh(progmanager, hObject, 'inputChannelList', 'String');
% if isempty(inList)
%     selectedInputChannelList = {};
%     return;
% end
% if ~iscell(inList)
%     inList = {inList};
% end
% selectedInputChannelList = {inList{selectedInputChannelList}};

return;

%-----------------------------------------------------------------------
function selectedOutputChannelList = getSelectedOutputChannelList(hObject)

selectedOutputChannelList = getLocal(progmanager, hObject, 'outputChannelList');
% outList = getLocalGh(progmanager, hObject, 'outputChannelList', 'String');
% if isempty(outList)
%     selectedOutputChannelList = {};
%     return;
% end
% if ~iscell(outList)
%     outList = {outList};
% end
% selectedOutputChannelList = {outList{selectedOutputChannelList}};

return;

%-----------------------------------------------------------------------
function traceCount = getTraceCount(data)

traceCount = 0;

if isempty(data)
    return;
end

%Step down into the structure, assuming it's the top level (so it has a .data and a .header field).
if isfield(data, 'data')
    data = data.data;
end

%Count Ephys traces.
if isfield(data, 'ephys')
    fields = fieldnames(data.ephys);
    for i = 1 : length(fields)
        if startsWithIgnoreCase(fields{i}, 'trace_')
            traceCount = traceCount + 1;
        end
    end
end
%Count Acquirer traces.
if isfield(data, 'acquirer')
    fields = fieldnames(data.acquirer);
    for i = 1 : length(fields)
        if startsWithIgnoreCase(fields{i}, 'trace_')
            traceCount = traceCount + 1;
        end
    end
end

%Count top-level traces, assuming data is only the ephys or acquirer portion of the struct.
fields = fieldnames(data);
for i = 1 : length(fields)
    if startsWithIgnoreCase(fields{i}, 'trace_')
        traceCount = traceCount + 1;
    end
end

return;

%-----------------------------------------------------------------------
function updateChannelLists(hObject)

[fileData] = getLocalBatch(progmanager, hObject, 'fileData');
selectedInputChannelList = getSelectedInputChannelList(hObject);
selectedOutputChannelList = getSelectedOutputChannelList(hObject);
inputChannelList = {};
outputChannelList = {};

inListIndices = [];
outListIndices = [];

%TO071310C - Check for existence of the fields. -- Tim O'Connor 7/13/10
if isfield(fileData.header, 'ephys')
    if ~isempty(fileData.header.ephys)
        if fileData.header.ephys.ephys.startButton
            if ~isfield(fileData.data.ephys, 'channelName_1')
                %fprintf(1, '%s - No channelName_x fields found for Ephys data.\n', datestr(now));
            end
            for i = 1 : getTraceCount(fileData.data.ephys)
                if fileData.header.ephys.ephys.acqOnArray(i)
                    if isfield(fileData.data.ephys, ['amplifierName_' num2str(i)])
                        inputChannelList{length(inputChannelList) + 1} = ['ephys:' fileData.data.ephys.(['amplifierName_' num2str(i)])];
                        inListIndices(length(inListIndices) + 1) = length(inputChannelList);
                    else
                        inputChannelList{length(inputChannelList) + 1} = ['ephys:inputChannel' num2str(i)];
                        inListIndices(length(inListIndices) + 1) = length(inputChannelList);
                    end
                end
            end
            for i = 1 : length(fileData.header.ephys.ephys.stimOnArray)
                if fileData.header.ephys.ephys.stimOnArray(i)
                    %TO033110B - Construct the amplifier output names. -- Tim O'Connor 3/31/10
                    if isfield(fileData.data.ephys, ['amplifierName_' num2str(i)])
                        outputChannelList{length(outputChannelList) + 1} = ['ephys:' fileData.data.ephys.(['amplifierName_' num2str(i)]) '-vCom'];
                        outListIndices(length(outListIndices) + 1) = length(outputChannelList);
                    else
                        outputChannelList{length(outputChannelList) + 1} = ['ephys:outputChannel' num2str(i)];
                        outListIndices(length(outListIndices) + 1) = length(outputChannelList);
                    end
                end
            end
        end
    end
end
if isfield(fileData.header, 'acquirer') %TO071310C
    if ~isempty(fileData.header.acquirer)
        if fileData.header.acquirer.acquirer.startButton
            if ~isfield(fileData.data.acquirer, 'channelName_1')
                %fprintf(1, '%s - No channelName_x fields found for Acquirer data.\n', datestr(now));
            end
            for i = 1 : getTraceCount(fileData.data.acquirer)
                if fileData.header.acquirer.acquirer.acqOnArray(i)
                    if isfield(fileData.data.acquirer, ['channelName_' num2str(i)])
                        inputChannelList{length(inputChannelList) + 1} = ['acq:' fileData.data.acquirer.(['channelName_' num2str(i)])];
                        inListIndices(length(inListIndices) + 1) = length(inputChannelList);
                    else
                        inputChannelList{length(inputChannelList) + 1} = ['acq:inputChannel' num2str(i)];
                        inListIndices(length(inListIndices) + 1) = length(inputChannelList);
                    end
                end
            end
        end
    end
end
if isfield(fileData.header, 'stimulator') %TO071310C
    if ~isempty(fileData.header.stimulator)
        if fileData.header.stimulator.stimulator.startButton
            for i = 1 : length(fileData.header.stimulator.stimulator.channels)
                if fileData.header.stimulator.stimulator.stimOnArray(i)
                    outputChannelList{length(outputChannelList) + 1} = ['stim:' fileData.header.stimulator.stimulator.channels(i).channelName];
                    outListIndices(length(outListIndices) + 1) = length(outputChannelList);
                end
            end
        end
    end
end

if isempty(selectedInputChannelList)
    selectedInputChannelList = {};
end
if ~iscell(selectedInputChannelList)
    selectedInputChannelList = {selectedInputChannelList};
end
% selectedInputChannelList = inputChannelList(find(ismember(selectedInputChannelList, inputChannelList)));
selectedInputChannelList = union(selectedInputChannelList, inputChannelList);
if isempty(selectedOutputChannelList)
    selectedOutputChannelList = {};
end
if ~iscell(selectedOutputChannelList)
    selectedOutputChannelList = {selectedOutputChannelList};
end
% selectedOutputChannelList = outputChannelList(find(ismember(selectedOutputChannelList, outputChannelList)));

selectedOutputChannelList = intersect(selectedOutputChannelList, outputChannelList);

inList = getLocalGh(progmanager, hObject, 'inputChannelList');
outList = getLocalGh(progmanager, hObject, 'outputChannelList');

inEnable = 'On';
if isempty(inputChannelList)
    inputChannelList = '';
    inEnable = 'Off';
end

outEnable = 'On';
if isempty(outputChannelList)
    outputChannelList = '';
    outEnable = 'Off';
end

if isempty(selectedInputChannelList) && ~isempty(inputChannelList)
    selectedInputChannelList = inputChannelList{1};
end
if isempty(selectedOutputChannelList) && ~isempty(outputChannelList)
    selectedOutputChannelList = outputChannelList{1};
end

set(inList, 'String', inputChannelList, 'Enable', inEnable, 'Value', 1);
set(outList, 'String', outputChannelList, 'Enable', outEnable, 'Value', 1);
setLocalBatch(progmanager, hObject, 'inputChannelList', selectedInputChannelList, 'outputChannelList', selectedOutputChannelList);

return;

%-----------------------------------------------------------------------
function loadXSGFile(hObject, filename)

data = load(filename, '-mat');

%TO060910A - Make sure the expected fields exist. -- Tim O'Connor 6/9/10
if ~isfield(data.data, 'acquirer')
    data.data.acquirer = [];
end
if ~isfield(data.header, 'acquirer')
    data.header.acquirer = [];
end
if ~isfield(data.data, 'stimulator')
    data.data.stimulator = [];
end
if ~isfield(data.header, 'stimulator')
    data.header.stimulator = [];
end
if ~isfield(data.data, 'ephys')
    data.data.ephys = [];
end
if ~isfield(data.header, 'pulseJacker')
    data.header.pulseJacker = [];
end

% [inputChannelList, outputChannelList] = getLocalBatch(progmanager, hObject, 'inputChannelList', 'outputChannelList');
setLocal(progmanager, hObject, 'fileData', data);
updateChannelLists(hObject);

% if isempty(inputChannelList)
%     inputChannelList = {};
% end
% if ~iscell(inputChannelList)
%     inputChannelList = {inputChannelList};
% end
% if isempty(outputChannelList)
%     outputChannelList = {};
% end
% if ~iscell(outputChannelList)
%     outputChannelList = {outputChannelList};
% end
% 
% inputChannels = getLocalGh(progmanager, hObject, 'inputChannelList', 'String');
% % if ~isempty(inputChannelList) && iscell(inputChannels)
% %     if length(inputChannelList) > length(inputChannels)
% %         inputChannelList = inputChannelList(1 : length(inputChannels));
% %     end
% %     inputChannelList = inputChannelList(inputChannelList <= length(inputChannels));
% % end
% outputChannels = getLocalGh(progmanager, hObject, 'outputChannelList', 'String');
% % if ~isempty(outputChannelList) && iscell(outputChannels)
% %     if length(outputChannelList) > length(outputChannels)
% %         outputChannelList = outputChannelList(1 : length(outputChannels));
% %     end
% %     outputChannelList = outputChannelList(outputChannelList <= length(outputChannels));
% % end
% 
% inList = getLocalGh(progmanager, hObject, 'inputChannelList');
% outList = getLocalGh(progmanager, hObject, 'outputChannelList');
% % set(inList, 'Value', find(ismember(inputChannelList, inputChannels)));
% % set(outList, 'Value', find(ismember(outputChannelList, outputChannels)));
% % setLocalBatch(progmanager, hObject, 'inputChannelList', union(inputChannels, inputChannelList), 'outputChannelList', union(outputChannels, outputChannelList));

saveFigurePositions(hObject);
% clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');
updateFigures(hObject);
restoreFigurePositions(hObject);

return;

%-----------------------------------------------------------------------
function filename_Callback(hObject, eventdata, handles)

filename = getLocal(progmanager, hObject, 'filename');
if exist(filename, 'file') ~= 2
    if ~isempty(filename)
        setLocalGh(progmanager, hObject, 'filename', 'ForegroundColor', [1, 0, 0]);
    else
        setLocalGh(progmanager, hObject, 'filename', 'ForegroundColor', [0, 0, 0]);
    end
    return;
else
    setLocalGh(progmanager, hObject, 'filename', 'ForegroundColor', [0, 0, 0]);
end

loadXSGFile(hObject, filename);

return;

%-----------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%-----------------------------------------------------------------------
% --- Executes on button press in browseFile.
function browseFile_Callback(hObject, eventdata, handles)

%TO033110D - If the XSG is running, use that to get the path, for online review of traces. -- Tim O'Connor 3/31/10
defaultDir = '';
if isprogram(progmanager, 'xsg')
    defaultDir = xsg_getPath;
end
if exist(defaultDir, 'dir') ~= 7
    defaultDirectory = getLocal(progmanager, hObject, 'defaultDirectory');
    if exist(defaultDirectory, 'dir') ~= 7
        defaultDir = getDefaultCacheDirectory(progmanager, 'traceViewDir');
    else
        defaultDir = defaultDirectory;
    end
else
    defaultDirectory = defaultDir; %TO040510A - Created the `else` case. -- Tim O'Connor 4/5/10
end

[f, p] = uigetfile({'*.xsg', 'XSG Files (*.xsg)'; '*.*', 'All Files (*.*)'}, 'Choose a data file to load.', defaultDir);
if length(f) == 1
    if f == 0
        return;
    end
elseif length(p) == 1
    if p == 0
        return;
    end
end

setLocal(progmanager, hObject, 'filename', fullfile(p, f));
setDefaultCacheValue(progmanager, 'traceViewDir', p);
if exist(defaultDirectory, 'dir') ~= 7
    setLocal(progmanager, hObject, 'traceViewDir', p);
end

filename_Callback(hObject, eventdata, handles);

return;

%-----------------------------------------------------------------------
function clearFigures(hObject, mapName)

map = getLocal(progmanager, hObject, mapName);

for i = 1 : size(map, 1)
    if ishandle(map{i, 2})
        delete(map{i, 2});
    end
end

setLocal(progmanager, hObject, mapName, {});

return;

%-----------------------------------------------------------------------
function f = createNewFigure(hObject)

f = figure('Color', [1, 1, 1], 'Name', 'traceViewer Figure', 'NumberTitle', 'Off', 'KeyPressFcn', {@keyPressFcn_Callback, getFigHandle(progmanager, hObject)});

return;

%-----------------------------------------------------------------------
function map = setFigureHandle(map, name, handle)

index = find(strcmpi({map{:, 1}}, name));
if isempty(index)
    map{size(map, 1) + 1, 1} = name;
    map{size(map, 1), 2} = handle;
else
    map{index, 2} = handle;
end

return;

%-----------------------------------------------------------------------
function [handle, map] = getOrCreateFigureHandle(hObject, map, name)
% % fprintf(1, 'getOrCreateFigureHandle(hObject, map, ''%s'')\n', name);
% if getLocal(progmanager, hObject, 'oneFigureForAllChannels')
%     if isempty(map)
%         handle = createNewFigure;
%         map = {name, handle};
%         return;
%     end
%     f = [map{:, 2}];
%     f = f(ishandle(f));
%     if length(f) > 1
%         delete(f(2:end));
%         f = f(1);
%     end
%     if ~ismember(name, map{:, 1})
%         map{size(map, 1) + 1, 1} = name;
%     end
%     map{:, 2} = f;
%     handle = f;
%     return;
% end
keepIndices = [];
for i = 1 : size(map, 1)
    if ~isempty(map{i, 1}) && length(map{i, 2}) == 1 && ishandle(map{i, 2})
        keepIndices(length(keepIndices) + 1) = i;
    end
end

index = find(strcmpi({map{:, 1}}, name));
if length(index) > 1
    index = index(1);
    for i = 2 : length(index)
        map{index(i), 1} = '';
        map{index(i), 2} = [];
    end
end

if isempty(index) && getLocal(progmanager, hObject, 'oneFigureForAllChannels')
    i = 1;
    while i <= size(map, 1) && isempty(index)
        if ishandle(map{i, 2})
            map{size(map, 1) + 1, 1} = name;
            map{size(map, 1), 2} = map{i, 2};
            index = i;
        end
        i = i + 1;
    end
end

if isempty(index)
    handle = createNewFigure(hObject);
    map{size(map, 1) + 1, 1} = name;
    map{size(map, 1), 2} = handle;
elseif ~ishandle(map{index, 2})
    handle = createNewFigure(hObject);
    map{size(map, 1) + 1, 1} = name;
    map{size(map, 1), 2} = handle;
else
    handle = map{index, 2};
end

return;

%-----------------------------------------------------------------------
function [handle, map] = getOrCreateAxesHandle(map, name, parentFigure, varargin)

keepIndices = [];
for i = 1 : size(map, 1)
    if ~isempty(map{i, 1}) && length(map{i, 2}) == 1 && ishandle(map{i, 2})
        keepIndices = i;
    end
end
map = {map{keepIndices, :}};

index = find(strcmpi({map{:, 1}}, name));
if length(index) > 1
    map{index(1), 1} = '';
    map{index(2), 2} = [];
    index = index(1);
end

if isempty(index)
    if ~isempty(varargin)
        handle = subplot(varargin{2}, 1, varargin{1});
    else
        handle = axes('Parent', parentFigure);
    end
    map{size(map, 1) + 1, 1} = name;
    map{size(map, 1), 2} = handle;
elseif ~ishandle(map{index, 2})
    if ~isempty(varargin)
        handle = subplot(varargin{2}, 1, varargin{1});
    else
        handle = axes('Parent', parentFigure);
    end
    map{size(map, 1) + 1, 1} = name;
    map{size(map, 1), 2} = handle;
else
    handle = map{index, 2};
end

return;

%-----------------------------------------------------------------------
function [data, sampleRate] = getInputDataByChannelName(name, fileData)

data = [];
sampleRate = NaN;

if startsWithIgnoreCase(name, 'ephys')
    sampleRate = fileData.header.ephys.ephys.sampleRate;
    for i = 1 : getTraceCount(fileData.data.ephys)
        if fileData.header.ephys.ephys.acqOnArray(i)
            if isfield(fileData.data.ephys, ['amplifierName_' num2str(i)])
                if strcmpi(name, ['ephys:' fileData.data.ephys.(['amplifierName_' num2str(i)])])
                    data = fileData.data.ephys.(['trace_' num2str(i)]);
                    return;
                end
            elseif strcmpi(name, ['ephys:inputChannel' num2str(i)])
                data = fileData.data.ephys.(['trace_' num2str(i)]);
                return;
            end
        end
    end
elseif startsWithIgnoreCase(name, 'acq')
    sampleRate = fileData.header.acquirer.acquirer.sampleRate;
    for i = 1 : getTraceCount(fileData.data.acquirer)
        if fileData.header.acquirer.acquirer.acqOnArray(i)
            if isfield(fileData.data.acquirer, ['channelName_' num2str(i)])
                if strcmpi(name, ['acq:' fileData.data.acquirer.(['channelName_' num2str(i)])])
                    data = fileData.data.acquirer.(['trace_' num2str(i)]);
                    return;
                end
            elseif strcmpi(name, ['acq:inputChannel' num2str(i)])
                data = fileData.data.acquirer.(['trace_' num2str(i)]);
                return;
            end
        end
    end
end

return;

%-----------------------------------------------------------------------
function [data, sampleRate] = getOutputDataByChannelName(hObject, name, fileData)

data = [];
sampleRate = NaN;
[pulse, fileData] = getLocalBatch(progmanager, hObject, 'pulse', 'fileData');

if fileData.header.pulseJacker.pulseJacker.enable
    channelIndex = find(strcmpi(strrep(name, 'stim:', 'stimulator:'), {fileData.header.pulseJacker.pulseJacker.pulseDataMap{:, 1}}));
    %if isfield(fileData.header.pulseJacker.pulseJacker, 'channelNames')
    %    channelIndex = find(strcmpi(strrep(name, 'stim:', 'stimulator:'), fileData.header.pulseJacker.pulseJacker.channelNames));
    %else
    %    fprintf(1, '%s%s', 'traceViewer - Warning: Data acquired with an older version of the pulseJacker. ', ...
    %            '''channelNames'' header field does not exist.Display data may not match the correct output channel(s).\n');
    %    channelIndex = find(strcmpi(name, getLocal(progmanager, hObject, 'outputChannelList')));
    %end
    if isempty(channelIndex)
        numericSuffix = getNumericSuffix(name);
        if endsWithIgnoreCase(name, [':outputChannel' num2str(numericSuffix)])
            
        else
            fprintf(2, 'traceViewer - Failed to find output data for channel ''%s''.\n', name);
        end
        return;
    end

   if startsWithIgnoreCase(name, 'ephys')
        sampleRate = fileData.header.ephys.ephys.sampleRate;
        traceLength = fileData.header.ephys.ephys.traceLength;
    elseif startsWithIgnoreCase(name, 'stim')
        sampleRate = fileData.header.stimulator.stimulator.sampleRate;
        traceLength = fileData.header.ephys.ephys.traceLength;
    end
    set(pulse, 'sampleRate', sampleRate);
    pulseDataStruct = fileData.header.pulseJacker.pulseJacker.pulseDataMap{channelIndex, ...
        fileData.header.pulseJacker.pulseJacker.currentPosition + 1};
    if ~isempty(pulseDataStruct)
        fromStruct(pulse, pulseDataStruct);
        data = getdata(pulse, traceLength);
    end
    return;
end

if startsWithIgnoreCase(name, 'ephys')
    for i = 1 : length(fileData.header.ephys.ephys.pulseParameters)
        if fileData.header.ephys.ephys.stimOnArray(i)
            %TO033110B - Construct the amplifier output names. -- Tim O'Connor 3/31/10
            if isfield(fileData.data.ephys, ['amplifierName_' num2str(i)])
                if strcmpi(name, ['ephys:' fileData.data.ephys.(['amplifierName_' num2str(i)]) '-vCom'])
                    fromStruct(pulse, fileData.header.ephys.ephys.pulseParameters{i});
                    sampleRate = fileData.header.ephys.ephys.sampleRate;
                    set(pulse, 'sampleRate', sampleRate);
                    data = getdata(pulse, fileData.header.ephys.ephys.traceLength);
                    return;
                else
                    if strcmpi(name, ['ephys:outputChannel' num2str(i)])
                        fromStruct(pulse, fileData.header.ephys.ephys.pulseParameters{i});
                        sampleRate = fileData.header.ephys.ephys.sampleRate;
                        set(pulse, 'sampleRate', sampleRate);
                        data = getdata(pulse, fileData.header.ephys.ephys.traceLength);
                        return;
                    end
                end
            end
        end
    end
elseif startsWithIgnoreCase(name, 'stim')
    if fileData.header.stimulator.stimulator.startButton
        for i = 1 : length(fileData.header.stimulator.stimulator.channels)
            if fileData.header.stimulator.stimulator.stimOnArray(i)
                if strcmpi(name, ['stim:' fileData.header.stimulator.stimulator.channels(i).channelName])
                    sampleRate = fileData.header.ephys.ephys.sampleRate;
                    set(pulse, 'sampleRate', sampleRate);
                    fromStruct(pulse, fileData.header.stimulator.stimulator.pulseParameters{i});
                    data = getdata(pulse, fileData.header.stimulator.stimulator.traceLength);
                    return;
                end
            end
        end
    end
end

return;

%-----------------------------------------------------------------------
function updateFigures(hObject)

[oneFigurePerInputChannel, oneFigureForAllInputChannels, showAllInputs, showSelectedInputs, ...
    showNoInputs, oneFigurePerOutputChannel, oneFigureForAllOutputChannels, showAllOutputs, ...
    showSelectedOutputs, showNoOutputs, fileData, inputFigures, outputFigures, ...
    inputAxes, outputAxes, figures, oneFigureForAllChannels, oneFigurePerChannel] = getLocalBatch(progmanager, hObject, ...
    'oneFigurePerInputChannel', 'oneFigureForAllInputChannels', 'showAllInputs', 'showSelectedInputs', ...
    'showNoInputs', 'oneFigurePerOutputChannel', 'oneFigureForAllOutputChannels', 'showAllOutputs', ...
    'showSelectedOutputs', 'showNoOutputs', 'fileData', 'inputFigures', 'outputFigures', ...
    'inputAxes', 'outputAxes', 'figures', 'oneFigureForAllChannels', 'oneFigurePerChannel');

if showSelectedInputs
    inputChannelList = getSelectedInputChannelList(hObject);
elseif showNoInputs
    inputChannelList = {};
else
    inputChannelList = getLocalGh(progmanager, hObject, 'inputChannelList', 'String');
end
if showSelectedOutputs
    outputChannelList = getSelectedOutputChannelList(hObject);
elseif showNoOutputs
    outputChannelList = {};
else
    outputChannelList = getLocalGh(progmanager, hObject, 'outputChannelList', 'String');
end
channelCount = length(inputChannelList) + length(outputChannelList);

%Delete unneeded figures.
keepList = [];
for i = 1 : size(inputAxes, 1)
    if any(strcmpi(inputAxes{i, 1}, inputChannelList))
        keepList(length(keepList) + 1) = i;
    elseif ishandle(inputAxes{i, 2})
        delete(inputAxes{i, 2});
    end
end
inputAxes = {inputAxes{keepList, :}};
keepList = [];
for i = 1 : size(outputAxes, 1)
    if any(strcmpi(outputAxes{i, 1}, outputChannelList))
        keepList(length(keepList) + 1) = i;
    elseif ishandle(outputAxes{i, 2})
        delete(outputAxes{i, 2});
    end
end
outputAxes = {outputAxes{keepList, :}};
keepList = [];

for i = 1 : size(figures, 1)
    if ishandle(figures{i, 2})
        if isempty(get(figures{i, 2}, 'Children')) && isempty(get(figures{i, 2}, 'Children'))
            delete(figures{i, 2});
        else
            keepList(length(keepList) + 1) = i;
        end
    end
end
figures = reshape({figures{keepList, :}}, length(keepList), 2);

figureHandle = [];
axesHandle = [];
% if oneFigureForAllInputChannels && ~isempty(inputFigures)
%     if all([inputFigures{:, 2}] ~= inputFigures{1, 2})
%         delete([inputFigures{:, 2}]);
%         inputFigures{:, 2} = zeros(size(inputFigures, 1), 1);
%     end
% end
if ~iscell(inputChannelList)
    inputChannelList = {inputChannelList};
end
inputFigures = figures;
if ~isempty(inputChannelList)
    if ~isempty(inputChannelList{1})
        for i = 1 : length(inputChannelList)
            %Update figure data (create figures if needed).
            if oneFigurePerChannel || isempty(figureHandle)
                [figureHandle, inputFigures] = getOrCreateFigureHandle(hObject, inputFigures, inputChannelList{i});
            else
                inputFigures = setFigureHandle(inputFigures, inputChannelList{i}, figureHandle);
            end
            if ~oneFigurePerChannel
                [axesHandle, inputAxes] = getOrCreateAxesHandle(inputAxes, inputChannelList{i}, figureHandle, i, channelCount);
            end
            [data, sampleRate] = getInputDataByChannelName(inputChannelList{i}, fileData);
            plot((1 : length(data)) / sampleRate, data);
            if oneFigurePerInputChannel
                title(strrep(inputChannelList{i}, '_', '\_'));
            else
                title('TraceViewer');
            end
            xlabel('Time [s]');
        end
    else
        inputChannelList = {};
    end
end
figures = inputFigures;
if oneFigurePerChannel
    figureHandle = [];
end
axesHandle = [];
% if oneFigureForAllInputChannels && ~isempty(outputFigures)
%     if all([outputFigures{:, 2}] ~= outputFigures{1, 2})
%         delete([inputFigures{:, 2}]);
%         outputFigures{:, 2} = zeros(size(outputFigures, 1), 1);
%     end
% end
if ~iscell(outputChannelList)
    outputChannelList = {outputChannelList};
end
outputFigures = figures;

if ~isempty(outputChannelList)
    if ~isempty(outputChannelList{1})
        for i = 1 : length(outputChannelList)
            %Update figure data (create figures if needed).
            if oneFigurePerChannel || isempty(figureHandle)
                [figureHandle, outputFigures] = getOrCreateFigureHandle(hObject, outputFigures, outputChannelList{i});
            else
                outputFigures = setFigureHandle(outputFigures, outputChannelList{i}, figureHandle);
            end
            if ~oneFigurePerChannel
                [axesHandle, outputAxes] = getOrCreateAxesHandle(outputAxes, outputChannelList{i}, figureHandle, i + length(inputChannelList), channelCount);
                axes(axesHandle);
            end
            [data, sampleRate] = getOutputDataByChannelName(hObject, outputChannelList{i}, fileData);
            plot((1 : length(data)) / sampleRate, data);
            if oneFigurePerOutputChannel
                title(strrep(outputChannelList{i}, '_', '\_'));
            else
                title('TraceViewer');
            end
            xlabel('Time [s]');
        end
    end
end
figures = outputFigures;

setLocalBatch(progmanager, hObject, 'figures', figures, 'inputAxes', inputAxes, 'outputAxes', outputAxes);

return;

%-----------------------------------------------------------------------
% --- Executes on selection change in inputChannelList.
function inputChannelList_Callback(hObject, eventdata, handles)

inList = getLocalGh(progmanager, hObject, 'inputChannelList');
channelNames = get(inList, 'String');
if ~iscell(channelNames)
    channelNames = {channelNames};
end
setLocal(progmanager, hObject, 'inputChannelList', {channelNames{get(hObject, 'Value')}});
% clearFigures(hObject, 'inputAxes');
% if getLocal(progmanager, hObject, 'oneFigureForAllChannels')
%     clearFigures(hObject, 'outputAxes');
% end
% updateFigures(hObject);
if getLocal(progmanager, hObject, 'showSelectedInputs')
    saveFigurePositions(hObject);
    % clearFigures(hObject, 'figures');
    clearFigures(hObject, 'inputAxes');
    clearFigures(hObject, 'outputAxes');
    updateFigures(hObject);
    restoreFigurePositions(hObject);
end

% outList = getLocalGh(progmanager, hObject, 'outputChannelList');
% set(inList, 'String', inputChannelList);
% set(outList, 'String', outputChannelList);


% [showAllInputs, showNoInputs] = getLocalBatch(progmanager, hObject, 'showAllInputs', 'showNoInputs');
% if ~(showAllInputs || showNoInputs)
% %     saveFigurePositions(hObject);
%     clearFigures(hObject, 'inputAxes');
%     updateFigures(hObject);
% %     restoreFigurePositions(hObject);
% end

return;

%-----------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function inputChannelList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;

%-----------------------------------------------------------------------
% --- Executes on button press in showAllInputs.
function showAllInputs_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'showAllInputs', 1, 'showSelectedInputs', 0, 'showNoInputs', 0);
setLocalGh(progmanager, hObject, 'showNoInputs', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'showAllInputs', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'showSelectedInputs', 'Enable', 'On');
saveFigurePositions(hObject);
% clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');
updateFigures(hObject);
restoreFigurePositions(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in showSelectedInputs.
function showSelectedInputs_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'showAllInputs', 0, 'showSelectedInputs', 1, 'showNoInputs', 0);
setLocalGh(progmanager, hObject, 'showNoInputs', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'showAllInputs', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'showSelectedInputs', 'Enable', 'Inactive');
saveFigurePositions(hObject);
% clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');
updateFigures(hObject);
restoreFigurePositions(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in showNoInputs.
function showNoInputs_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'showAllInputs', 0, 'showSelectedInputs', 0, 'showNoInputs', 1);
setLocalGh(progmanager, hObject, 'showNoInputs', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'showAllInputs', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'showSelectedInputs', 'Enable', 'On');
saveFigurePositions(hObject);
% clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');
updateFigures(hObject);
restoreFigurePositions(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on selection change in outputChannelList.
function outputChannelList_Callback(hObject, eventdata, handles)

outList = getLocalGh(progmanager, hObject, 'outputChannelList');
channelNames = get(outList, 'String');
if ~iscell(channelNames)
    channelNames = {channelNames};
end
setLocal(progmanager, hObject, 'outputChannelList', {channelNames{get(hObject, 'Value')}});
% clearFigures(hObject, 'outputAxes');
% if getLocal(progmanager, hObject, 'oneFigureForAllChannels')
%     clearFigures(hObject, 'inputAxes');
% end
if getLocal(progmanager, hObject, 'showSelectedOutputs')
    saveFigurePositions(hObject);
    % clearFigures(hObject, 'figures');
    clearFigures(hObject, 'inputAxes');
    clearFigures(hObject, 'outputAxes');
    updateFigures(hObject);
    restoreFigurePositions(hObject);
end

% [showAllOutputs, showNoOutputs] = getLocalBatch(progmanager, hObject, 'showAllOutputs', 'showNoOutputs');
% if ~(showAllOutputs || showNoOutputs)
% %     saveFigurePositions(hObject);
%     clearFigures(hObject, 'outputAxes');
%     updateFigures(hObject);
% %     restoreFigurePositions(hObject);
% end

return;

%-----------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function outputChannelList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;

%-----------------------------------------------------------------------
% --- Executes on button press in showAllOutputs.
function showAllOutputs_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'showAllOutputs', 1, 'showSelectedOutputs', 0, 'showNoOutputs', 0);
setLocalGh(progmanager, hObject, 'showNoOutputs', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'showAllOutputs', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'showSelectedOutputs', 'Enable', 'On');
saveFigurePositions(hObject);
% clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');
updateFigures(hObject);
restoreFigurePositions(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in showSelectedOutputs.
function showSelectedOutputs_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'showSelectedOutputs', 1, 'showAllOutputs', 0, 'showNoOutputs', 0);
setLocalGh(progmanager, hObject, 'showNoOutputs', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'showAllOutputs', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'showSelectedOutputs', 'Enable', 'Inactive');
saveFigurePositions(hObject);
% clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');
updateFigures(hObject);
restoreFigurePositions(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in showNoOutputs.
function showNoOutputs_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'showAllOutputs', 0, 'showSelectedOutputs', 0, 'showNoOutputs', 1);
setLocalGh(progmanager, hObject, 'showNoOutputs', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'showAllOutputs', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'showSelectedOutputs', 'Enable', 'On');
saveFigurePositions(hObject);
% clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');
updateFigures(hObject);
restoreFigurePositions(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in previousFile.
function previousFile_Callback(hObject, eventdata, handles)

filename = getLocal(progmanager, hObject, 'filename');
[pathstr, name, ext] = fileparts(filename);

try
    fileNumber = str2num(name(end-3:end)) - 1;
    if fileNumber < 0
        return;
    elseif fileNumber > 9999
        return;
    end
    fileNumber = num2str(fileNumber);
    if length(fileNumber) < 4
        fileNumber = ['000' fileNumber];
        fileNumber = fileNumber(end-3 : end);
    elseif length(fileNumber) > 4
        return;
    end
    previousFilename = fullfile(pathstr, [name(1:end-4) fileNumber ext]);
    if exist(previousFilename, 'file') == 2
        setLocal(progmanager, hObject, 'filename', previousFilename);
        filename_Callback(hObject, eventdata, handles);
    else
        currentFileInfo = dir(filename);
        if isempty(currentFileInfo)
            return;
        end
        currentFileDate = datenum(currentFileInfo.date, 'dd-mmm-yyyy HH:MM:SS');
        files = dir(fullfile(pathstr, '*.xsg'));
        nextName = '';
        lastTimestamp = 0;
        for i = 1 : length(files)
            timestamp = datenum(files(i).date, 'dd-mmm-yyyy HH:MM:SS');
            if timestamp < currentFileDate && timestamp > lastTimestamp
                lastTimestamp = timestamp;
                nextName = files(i).name;
            end
        end
        if ~isempty(nextName)
            fprintf(1, 'traceViewer: Expected previous file in sequence not found. Using timestamps to determine previous file.\n');
            setLocal(progmanager, hObject, 'filename', fullfile(pathstr, nextName));
            filename_Callback(hObject, eventdata, handles);
        end
    end
catch
    fprintf(2, 'Could not find "previous" file: %s\n', getLastErrorStack);
end

return;

%-----------------------------------------------------------------------
% --- Executes on button press in nextFile.
function nextFile_Callback(hObject, eventdata, handles)

filename = getLocal(progmanager, hObject, 'filename');
[pathstr, name, ext] = fileparts(filename);

try
    fileNumber = str2num(name(end-3:end)) + 1;
    if fileNumber < 0
        return;
    elseif fileNumber > 9999
        return;
    end
    fileNumber = num2str(fileNumber);
    if length(fileNumber) < 4
        fileNumber = ['000' fileNumber];
        fileNumber = fileNumber(end-3 : end);
    elseif length(fileNumber) > 4
        return;
    end
    nextFilename = fullfile(pathstr, [name(1:end-4) fileNumber ext]);
    if exist(nextFilename, 'file') == 2
        setLocal(progmanager, hObject, 'filename', nextFilename);
        filename_Callback(hObject, eventdata, handles);
    else
        currentFileInfo = dir(filename);
        if isempty(currentFileInfo)
            return;
        end
        currentFileDate = datenum(currentFileInfo.date, 'dd-mmm-yyyy HH:MM:SS');
        files = dir(fullfile(pathstr, '*.xsg'));
        nextName = '';
        lastTimestamp = Inf;
        for i = 1 : length(files)
            timestamp = datenum(files(i).date, 'dd-mmm-yyyy HH:MM:SS');
            if timestamp > currentFileDate && timestamp < lastTimestamp
                lastTimestamp = timestamp;
                nextName = files(i).name;
            end
        end
        if ~isempty(nextName)
            fprintf(1, 'traceViewer: Expected next file in sequence not found. Using timestamps to determine next file.\n');
            setLocal(progmanager, hObject, 'filename', fullfile(pathstr, nextName));
            filename_Callback(hObject, eventdata, handles);
        end
    end
catch
    fprintf(2, 'Could not find "next" file: %s\n', getLastErrorStack);
end

return;

%-----------------------------------------------------------------------
% --- Executes on button press in oneInputFigurePerChannel.
function oneInputFigurePerChannel_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'oneFigureForAllInputChannels', 0, 'oneFigurePerInputChannel', 1);
setLocalGh(progmanager, hObject, 'oneFigurePerInputChannel', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'oneFigureForAllInputChannels', 'Enable', 'On');
clearFigures(hObject, 'inputFigures');
updateFigures(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in oneInputFigure.
function oneInputFigure_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'oneFigureForAllInputChannels', 1, 'oneFigurePerInputChannel', 0);
setLocalGh(progmanager, hObject, 'oneFigureForAllInputChannels', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'oneFigurePerInputChannel', 'Enable', 'On');
clearFigures(hObject, 'inputFigures');
updateFigures(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in oneOutputFigurePerChannel.
function oneOutputFigurePerChannel_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'oneFigurePerOutputChannel', 0, 'oneFigurePerOutputChannel', 1);
setLocalGh(progmanager, hObject, 'oneFigurePerOutputChannel', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'oneFigurePerOutputChannel', 'Enable', 'On');
clearFigures(hObject, 'outputFigures');
updateFigures(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in oneOutputFigure.
function oneOutputFigure_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'oneFigurePerOutputChannel', 1, 'oneFigurePerOutputChannel', 0);
setLocalGh(progmanager, hObject, 'oneFigurePerOutputChannel', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'oneFigurePerOutputChannel', 'Enable', 'On');
saveFigurePositions(hObject);
% clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');
restoreFigurePositions(hObject);
updateFigures(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in oneFigurePerChannel.
function oneFigurePerChannel_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'oneFigureForAllChannels', 0, 'oneFigurePerChannel', 1);
setLocalGh(progmanager, hObject, 'oneFigureForAllChannels', 'Enable', 'On');
setLocalGh(progmanager, hObject, 'oneFigurePerChannel', 'Enable', 'Inactive');
saveFigurePositions(hObject);
% clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');
updateFigures(hObject);
restoreFigurePositions(hObject);

return;

%-----------------------------------------------------------------------

% --- Executes on button press in oneFigureForAllChannels.
function oneFigureForAllChannels_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'oneFigureForAllChannels', 1, 'oneFigurePerChannel', 0);
setLocalGh(progmanager, hObject, 'oneFigureForAllChannels', 'Enable', 'Inactive');
setLocalGh(progmanager, hObject, 'oneFigurePerChannel', 'Enable', 'On');
saveFigurePositions(hObject);
% clearFigures(hObject, 'figures');
clearFigures(hObject, 'inputAxes');
clearFigures(hObject, 'outputAxes');
updateFigures(hObject);
restoreFigurePositions(hObject);

return;

%-----------------------------------------------------------------------
function exportData(dataStruct, fileHandle, delimiter)

return;

%-----------------------------------------------------------------------
% --- Executes on button press in exportData.
function exportData_Callback(hObject, eventdata, handles)

exportDir = getDefaultCacheDirectory(progmanager, 'traceViewerExportDir');
[f, p, filterIndex] = uiputfile({'*.csv', '(*.csv) Comma-Delimited'; '*.tab', '(*.tab) Tab-Delimited'}, 'Designate a delimited file for output.');
if length(f) == 1
    if f == 0
        return;
    end
elseif length(p) == 1
    if p == 0
        return;
    end
end

fprintf(1, 'traceViewer: Exporting data to ''%s''...\n', fullfile(p, f));
fileHandle = fopen(fullfile(p, f), 'w');

if filterIndex == 1
    delimiter = ',';
elseif filterIndex == 2
    delimiter = sprintf('\t');
end

fileData = getLocal(progmanager, hObject, 'fileData');
fileData = fileData.data;

maxDataPoints = 0;
fields = {};

%This is probably going to be incredibly slow, but it'll have to do, for now.
if isfield(fileData, 'ephys')
    if ~isempty(fileData.ephys)
        for i = 1 : length(fieldnames(fileData.ephys)) / 3
            fprintf(fileHandle, '''%s''%s', fileData.ephys.(['amplifierName_', num2str(i)]), delimiter);
            fields{size(fields, 1) + 1, 1} = 'ephys';
            fields{size(fields, 1), 2} = ['trace_' num2str(i)];
            maxDataPoints = max(maxDataPoints, length(fileData.(fields{size(fields, 1), 1}).(fields{size(fields, 1), 2})));
        end
    end
end
if isfield(fileData, 'acquirer')
    if ~isempty(fileData.acquirer)
        for i = 1 : length(fieldnames(fileData.acquirer)) / 3
            fprintf(fileHandle, '''%s''%s', fileData.acquirer.(['channelName_', num2str(i)]), delimiter);
            fields{size(fields, 1) + 1, 1} = 'acquirer';
            fields{size(fields, 1), 2} = ['trace_' num2str(i)];
            maxDataPoints = max(maxDataPoints, length(fileData.(fields{size(fields, 1), 1}).(fields{size(fields, 1), 2})));
        end
    end
end
fprintf(fileHandle, '\n');

for i = 1 : maxDataPoints
    for j = 1 : size(fields, 1)
        if length(fileData.(fields{j, 1}).(fields{j, 2})) >= i
            fprintf(fileHandle, '%3.9f%s', fileData.(fields{j, 1}).(fields{j, 2})(i), delimiter);
        else
            fprintf(fileHandle, '%s', delimiter);
        end
    end
    fprintf(fileHandle, '\n');
end
fclose(fileHandle);

setDefaultCacheValue(progmanager, 'traceViewerExportDir', exportDir);

return;

%-----------------------------------------------------------------------
function keyPressFcn_Callback(hObject, eventdata, progObject)

switch eventdata.Key
    case 'rightarrow'
        nextFile_Callback(progObject, [], []);
    case 'leftarrow'
        previousFile_Callback(progObject, [], []);
    case 'home'
    case 'end'
end

return;
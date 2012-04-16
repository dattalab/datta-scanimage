function varargout = summaryTable(varargin)
% SUMMARYTABLE M-file for summaryTable.fig
%      SUMMARYTABLE, by itself, creates a new SUMMARYTABLE or raises the existing
%      singleton*.
%
%      H = SUMMARYTABLE returns the handle to a new SUMMARYTABLE or the handle to
%      the existing singleton*.
%
%      SUMMARYTABLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUMMARYTABLE.M with the given input arguments.
%
%      SUMMARYTABLE('Property','Value',...) creates a new SUMMARYTABLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before summaryTable_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to summaryTable_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help summaryTable

% Last Modified by GUIDE v2.5 17-Dec-2004 15:20:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @summaryTable_OpeningFcn, ...
                   'gui_OutputFcn',  @summaryTable_OutputFcn, ...
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

%-----------------------------------------------------------------------
% --- Executes just before summaryTable is made visible.
function summaryTable_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

return;

%-----------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = summaryTable_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

return;

%-----------------------------------------------------------------------
function cellButtonDownFcn(hObject, eventdata, handles)

tag = get(hObject, 'Tag');

column = tag(5);
row = str2num(tag(6 : end));

switch lower(column)
    case 'a'
        column = 1;
    case 'b'
        column = 2;
    case 'c'
        column = 3;
    case 'd'
        column = 4;
    case 'e'
        column = 5;
    case 'f'
        column = 6;
    case 'g'
        column = 7;
    case 'h'
        column = 8;
    otherwise
        error('Unrecognized cell tag.');
end

row = row + getLocal(progmanager, hObject, 'rowOffset');

column = column + getLocal(progmanager, hObject, 'columnOffset');

tableData = getLocal(progmanager, hObject, 'tableData');
if row > size(tableData, 1)
    return;
end
if column > size(tableData, 2)
    return;
end

% fprintf(1, 'Selected column: %s (%s) row: %s\n', tag(5), num2str(column), num2str(row));

cellSelectionCallback = getLocal(progmanager, hObject, 'cellSelectionCallback');
if ~isempty(cellSelectionCallback)
    if strcmpi(class(cellSelectionCallback), 'cell')
        feval(cellSelectionCallback{:}, row, column);
    else
        feval(cellSelectionCallback, row, column);
    end
end

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

closeFcn = getLocal(progmanager, hObject, 'closeFcnCallback');
if ~isempty(closeFcn)
    try
        if strcmpi(class(closeFcn), 'cell')
            feval(closeFcn{:});
        elseif strcmpi(class(closeFcn), 'char')
            eval(closeFcn);
        elseif strcmpi(class(closeFcn), 'function_handle')
            feval(closeFcn);
        end
    catch
        warning('Failed to execute bound closeFcnCallback for this summaryTable instance: %s', lasterr);
    end
end

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.1;

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'cellSelectionCallback', [], ...
       'tableData', {}, ...
       'columnNames', {}, ...
       'rowNames', {}, ...
       'rowOffset', 0, 'Class', 'Numeric', ...
       'columnOffset', 0, 'Class', 'Numeric', ...
       'rowSelectionCallback', [], ...
       'columnSelectionCallback', [], ...
       'tableColors', [], ...
       'closeFcnCallback', [], ...
   };

return;

%-----------------------------------------------------------------------
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)

st_refreshDataDisplay(hObject);

% fnames = fieldnames(handles);
% 
% for i = 1 : length(fnames)
%     if ~strcmpi(get(handles.(fnames{i}), 'Type'), 'Figure')
%         if strcmpi(get(handles.(fnames{i}), 'Style'), 'text')
% %             set(handles.(fnames{i}), 'Style', 'PushButton');
% %             set(handles.(fnames{i}), 'Callback', 'summaryTable(''cellButtonDownFcn'',gcbo,[],guidata(gcbo))');
% %             pos = get(handles.(fnames{i}), 'Position');
% %             pos(3) = 12.4;
% %             pos(4) = 1.4615384615384617;
% %             set(handles.(fnames{i}), 'Position', pos);
%         elseif strcmpi(get(handles.(fnames{i}), 'Style'), 'frame')
% %             delete(handles.(fnames{i}));
%         elseif strcmpi(get(handles.(fnames{i}), 'Style'), 'pushbutton')
%         end
%     end
% end

return;

%-----------------------------------------------------------------------
% --- Executes on button press in scrollLeft.
function scrollLeft_Callback(hObject, eventdata, handles)

columnOffset = getLocal(progmanager, hObject, 'columnOffset');

if columnOffset < 1
    return;
end

setLocal(progmanager, hObject, 'columnOffset', columnOffset - 1);

st_refreshDataDisplay(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in scrollRight.
function scrollRight_Callback(hObject, eventdata, handles)

columnOffset = getLocal(progmanager, hObject, 'columnOffset');

if columnOffset >= size(getLocal(progmanager, hObject, 'tableData'), 2) - 8
    return;
end

setLocal(progmanager, hObject, 'columnOffset', columnOffset + 1);

st_refreshDataDisplay(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in scrollDown.
function scrollDown_Callback(hObject, eventdata, handles)

rowOffset = getLocal(progmanager, hObject, 'rowOffset');

if rowOffset >= size(getLocal(progmanager, hObject, 'tableData'), 1) - 20
    return;
end

setLocal(progmanager, hObject, 'rowOffset', rowOffset + 1);

st_refreshDataDisplay(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in scrollUp.
function scrollUp_Callback(hObject, eventdata, handles)

rowOffset = getLocal(progmanager, hObject, 'rowOffset');

if rowOffset < 1
    return;
end

setLocal(progmanager, hObject, 'rowOffset', rowOffset - 1);

st_refreshDataDisplay(hObject);

return;

%-----------------------------------------------------------------------
function rowButtonDownFcn(hObject, eventdata, handles)

row = get(hObject, 'Tag');
row = str2num(row(4 : end)) + getLocal(progmanager, hObject, 'columnOffset');

rowSelectionCallback = getLocal(progmanager, hObject, 'rowSelectionCallback');
if ~isempty(rowSelectionCallback)
    if strcmpi(class(rowSelectionCallback), 'cell')
        feval(rowSelectionCallback{:}, row);
    else
        feval(rowSelectionCallback, row);
    end
end

return;

%-----------------------------------------------------------------------
function columnButtonDownFcn(hObject, eventdata, handles)

column = get(hObject, 'Tag');
column = str2num(column(7 : end)) + getLocal(progmanager, hObject, 'columnOffset');

columnSelectionCallback = getLocal(progmanager, hObject, 'columnSelectionCallback');
if ~isempty(columnSelectionCallback)
    if strcmpi(class(columnSelectionCallback), 'cell')
        feval(columnSelectionCallback{:}, column);
    else
        feval(columnSelectionCallback, column);
    end
end

return;

%-----------------------------------------------------------------------
% --- Executes on button press in pageLeft.
function pageLeft_Callback(hObject, eventdata, handles)

columnOffset = getLocal(progmanager, hObject, 'columnOffset');

if columnOffset < 9
    homeLeft_Callback(hObject, eventdata, handles);
end

setLocal(progmanager, hObject, 'columnOffset', columnOffset - min(columnOffset, 8));

st_refreshDataDisplay(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in homeLeft.
function homeLeft_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'columnOffset') == 0
    return;
end

setLocal(progmanager, hObject, 'columnOffset', 0);

st_refreshDataDisplay(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in pageRight.
function pageRight_Callback(hObject, eventdata, handles)

columnOffset = getLocal(progmanager, hObject, 'columnOffset');
tableData = getLocal(progmanager, hObject, 'tableData');

if columnOffset >= size(tableData, 2) - 8
    endRight_Callback(hObject, eventdata, handles);
end

setLocal(progmanager, hObject, 'columnOffset', min(columnOffset + 8, size(tableData, 2) - 8));

st_refreshDataDisplay(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in endRight.
function endRight_Callback(hObject, eventdata, handles)

tableData = getLocal(progmanager, hObject, 'tableData');

if getLocal(progmanager, hObject, 'columnOffset') >= size(tableData, 2) - 8
    return;
end

setLocal(progmanager, hObject, 'columnOffset', size(tableData, 2) - 8);

st_refreshDataDisplay(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in pageDown.
function pageDown_Callback(hObject, eventdata, handles)

rowOffset = getLocal(progmanager, hObject, 'rowOffset');
tableData = getLocal(progmanager, hObject, 'tableData');

if rowOffset >= size(tableData, 1) - 20
    endDown_Callback(hObject, eventdata, handles);
end

setLocal(progmanager, hObject, 'rowOffset', min(rowOffset + 20, size(tableData, 1) - 20));

st_refreshDataDisplay(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in endDown.
function endDown_Callback(hObject, eventdata, handles)

tableData = getLocal(progmanager, hObject, 'tableData');

if getLocal(progmanager, hObject, 'rowOffset') >= size(tableData, 1) - 20
    return;
end

setLocal(progmanager, hObject, 'rowOffset', size(tableData, 1) - 20);

st_refreshDataDisplay(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in pageUp.
function pageUp_Callback(hObject, eventdata, handles)

rowOffset = getLocal(progmanager, hObject, 'rowOffset');

if rowOffset < 21
    homeUp_Callback(hObject, eventdata, handles);
end

setLocal(progmanager, hObject, 'rowOffset', rowOffset - min(rowOffset, 20));

st_refreshDataDisplay(hObject);

return;

%-----------------------------------------------------------------------
% --- Executes on button press in homeUp.
function homeUp_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'rowOffset') == 0
    return;
end

setLocal(progmanager, hObject, 'rowOffset', 0);

st_refreshDataDisplay(hObject);

return;
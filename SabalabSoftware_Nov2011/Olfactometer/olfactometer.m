function varargout = olfactometer(varargin)
% BASICCONFIGURATIONGUI_OLD Application M-file for configurationGUI.fig
%    FIG = BASICCONFIGURATIONGUI_OLD launch configurationGUI GUI.
%    BASICCONFIGURATIONGUI_OLD('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 05-Oct-2009 15:43:06

if nargin == 0  % LAUNCH GUI
    
    fig = olfactometer_build();
    
    % Use system color scheme for figure:
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
    
    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    guidata(fig, handles);
    
    if nargout > 0
        varargout{1} = fig;
    end
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
        disp(lasterr);
    end
    
end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and
%| sets objects' callback properties to call them through the FEVAL
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

end

% --------------------------------------------------------------------
function varargout = generic_Callback(h, eventdata, handles, varargin)
% Stub for Callback of most uicontrol handles
global state
genericCallback(h);
buildOdorStateTransitions;
end

% --------------------------------------------------------------------
function varargout = connect_Callback(h, eventdata, handles, varargin)
global state
% check for connection state?
connectToOlfactometer();
end
% --------------------------------------------------------------------
function varargout = frameNum_Callback(h, eventdata, handles, varargin)
global state
% check for connection state?
genericCallback(h);
calculateFrameTimes();
buildOdorStateTransitions();
overrideFrames(state.olfactometer.nFrames);
applyChangesToOutput;
end

function varargout = enable_Callback(h, eventdata, handles, varargin)
global state gh
% check for connection state?

oldvalvestatus=state.olfactometer.valveStatusDAValue;
oldtrigger = state.olfactometer.triggerDAValue;

genericCallback(h);

newvalvestatus=state.olfactometer.valveStatusDAValue;
newtrigger = state.olfactometer.triggerDAValue;

% insure that both DAs aren't the same

if (newvalvestatus == newtrigger)
    if (newtrigger ~= oldtrigger)
        state.olfactometer.triggerDAValue = oldtrigger;
        updateguiByGlobal('state.olfactometer.triggerDAValue');
    else
        state.olfactometer.valveStatusDAValue = oldvalvestatus;
        updateguiByGlobal('state.olfactometer.valveStatusDAValue');
    end
end

set(gh.advancedCycleGui.aux4, 'Enable', 'on');
set(gh.advancedCycleGui.aux5, 'Enable', 'on');
set(gh.advancedCycleGui.aux6, 'Enable', 'on');
set(gh.advancedCycleGui.aux7, 'Enable', 'on');

% enable/disable appropriate aux entries in cycle window
%1=AUX4 2=5 3=6 4=7
if (state.olfactometer.enable)
    switch state.olfactometer.valveStatusDAValue
        case 1
            set(gh.advancedCycleGui.aux4, 'Enable', 'off');
        case 2
            set(gh.advancedCycleGui.aux5, 'Enable', 'off');
        case 3
            set(gh.advancedCycleGui.aux6, 'Enable', 'off');
        case 4
            set(gh.advancedCycleGui.aux7, 'Enable', 'off');
    end
    switch state.olfactometer.triggerDAValue
        case 1
            set(gh.advancedCycleGui.aux4, 'Enable', 'off');
        case 2
            set(gh.advancedCycleGui.aux5, 'Enable', 'off');
        case 3
            set(gh.advancedCycleGui.aux6, 'Enable', 'off');
        case 4
            set(gh.advancedCycleGui.aux7, 'Enable', 'off');
    end
end


end




% --------------------------------------------------------------------
function varargout = specific_Callback(h, eventdata, handles, varargin)
% Stub for Callback of most uicontrol handles
global state
state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
state.acq.pixelsPerLineGUI = get(h,'Value');
state.acq.pixelsPerLine = str2num(getMenuEntry(h, state.acq.pixelsPerLineGUI));
genericCallback(h);
setAcquisitionParameters;
end

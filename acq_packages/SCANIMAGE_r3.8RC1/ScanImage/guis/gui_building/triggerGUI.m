function varargout = triggerGUI(varargin)
global state
% TRIGGERGUI Application M-file for triggerGUI.fig
%    FIG = TRIGGERGUI launch triggerGUI GUI.
%    TRIGGERGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 30-Aug-2011 20:06:23

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
%%
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch ME %VI101910A
        most.idioms.reportError(ME);
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



% --------------------------------------------------------------------
function pbSaveCFG_Callback(hObject, eventdata, handles)
saveCurrentConfig();

% --------------------------------------------------------------------
function pmStartTrigEdge_Callback(hObject, eventdata, handles)
genericCallback(hObject);

% --------------------------------------------------------------------
function pmNextTrigEdge_Callback(hObject, eventdata, handles)
genericCallback(hObject);

% --------------------------------------------------------------------
function pmNextTrigNextMode_Callback(hObject, eventdata, handles)
genericCallback(hObject);

% --------------------------------------------------------------------
function pmNextTrigStopMode_Callback(hObject, eventdata, handles)
genericCallback(hObject);

% --------------------------------------------------------------------
function cbPureNextTrigger_Callback(hObject, eventdata, handles)
genericCallback(hObject);

% --------------------------------------------------------------------
function cbGapAdvance_Callback(hObject, eventdata, handles)
genericCallback(hObject);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
hideGUI('gh.triggerGUI.figure1');

function etStartTriggerSource_Callback(hObject, eventdata, handles)
global state;
genericCallback(hObject);
if ~isempty(state.acq.startTrigInputTerminal)
	state.acq.startTrigInputTerminal = ['PFI' state.acq.startTrigInputTerminal];
end

function etNextTriggerSource_Callback(hObject, eventdata, handles)
global state;
import dabs.ni.daqmx.*;

genericCallback(hObject);
if ~isempty(state.acq.nextTrigInputTerminal)
	state.acq.nextTrigInputTerminal = ['PFI' state.acq.nextTrigInputTerminal];
	
	% make sure we've created the 'hNextTrigCtr' object
	if isempty(state.init.hNextTrigCtr)
		state.init.hNextTrigCtr = Task('Stop Trigger Sensor'); %Task used to fire callback when stop/next trigger occurs
		state.init.hNextTrigCtr.createCICountEdgesChan(state.init.nextTrigBoardID, state.init.nextTrigCtrID);
		state.init.hNextTrigCtr.cfgSampClkTiming(1000, 'DAQmx_Val_HWTimedSinglePoint', [], 'PFI0'); %Sample rate is a 'dummy' values %NOTE: HwTimedSinglePoint doesn't work for USB M series devices, but is required for Counter In Event Counting Tasks-- Vijay Iyer 11/4/10
		state.init.hNextTrigCtr.registerSignalEvent(@nextTriggerFcn, 'DAQmx_Val_SampleClock');
	end
end

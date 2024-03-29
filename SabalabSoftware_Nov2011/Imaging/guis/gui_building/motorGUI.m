function varargout = motorGUI(varargin)
% MOTORGUI Application M-file for motorGUI.fig
%    FIG = MOTORGUI launch motorGUI GUI.
%    MOTORGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 28-Sep-2011 18:20:31

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

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



% --------------------------------------------------------------------
function varargout = generic_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handle
	global gh
	figure(gh.motorGUI.figure1)
	genericCallback(h);

% --------------------------------------------------------------------
function varargout = relPos_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handle
	global state gh
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	genericCallback(h);
	moveToRelativePosition;
	if state.piezo.usePiezo
		piezoUpdatePosition;
	end
	turnOnMotorButtons;

% --------------------------------------------------------------------
function varargout = readPosition_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton1.
	global gh
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	updateMotorPosition;
	turnOnMotorButtons;

% --------------------------------------------------------------------
function varargout = setZeroXYButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton2.
	global state gh
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	flag=updateMotorPosition;
	if isempty(flag)
		disp('setZeroXYButton_Callback : Unable to zero XY.  MP285 Error');
		beep;
	else
		state.motor.offsetX=state.motor.absXPosition;
		state.motor.offsetY=state.motor.absYPosition;
		updateRelativeMotorPosition;
	end
	turnOnMotorButtons;

% --------------------------------------------------------------------
function varargout = setZeroXYZButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton2.
	global state gh
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	flag=updateMotorPosition;
	if isempty(flag)
		disp('setZeroXYZButton_Callback : Unable to zero XYZ.  MP285 Error');
		beep;
	else
		state.motor.offsetX=state.motor.absXPosition;
		state.motor.offsetY=state.motor.absYPosition;
		state.motor.offsetZ=state.motor.absZPosition;
		updateRelativeMotorPosition;
	end
	turnOnMotorButtons;

% --------------------------------------------------------------------
function varargout = setZeroZButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton2.
	global state gh
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	flag=updateMotorPosition;
	if isempty(flag)
		disp('setZeroZButton_Callback : Unable to zero Z.  MP285 Error');
		beep;
	else
		state.motor.offsetZ=state.motor.absZPosition;
		state.motor.relZPosition=0;
		updateGUIByGlobal('state.motor.relZPosition');
	end
	turnOnMotorButtons;

% --------------------------------------------------------------------
function varargout = definePosition_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.definePosition.
	global gh
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	definePosition;
	turnOnMotorButtons;

% --------------------------------------------------------------------
function varargout = gotoPosition_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.gotoPosition.
	global gh
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	gotoPosition;
	turnOnMotorButtons;

% --------------------------------------------------------------------
function varargout = shiftXY_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.gotoPosition.
	global gh state
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	applyshiftXY(state.motor.position);
	turnOnMotorButtons;

% --------------------------------------------------------------------
function varargout = shiftXYZ_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.gotoPosition.
	global state gh
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	applyshift(state.motor.position);
	turnOnMotorButtons;


% --------------------------------------------------------------------
function varargout = setStackStart_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.setStackStart.
	global state gh
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	if state.piezo.usePiezo
		state.motor.stackStart=state.piezo.next_pos;
		setStatusString('Stack start set');
		calculateStackParameters;
	else
		flag=updateMotorPosition;
		if isempty(flag)
			disp('setStackStart_Callback : Unable to set stack start.  MP285 Error');
			beep;
		else
			state.motor.stackStart=state.motor.lastPositionRead;
			setStatusString('Stack start set');
			calculateStackParameters;
		end
	end
	turnOnMotorButtons;
	
% --------------------------------------------------------------------
function varargout = setStackStop_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.setStackStop.
	global state gh
	figure(gh.motorGUI.figure1)
	turnOffMotorButtons;
	if state.piezo.usePiezo
		state.motor.stackStop=state.piezo.next_pos;
		setStatusString('Stack start set');
		calculateStackParameters;
	else
		flag=updateMotorPosition;
		if isempty(flag)
			disp('setStackStop_Callback : Unable to set stack end.  MP285 Error');
			beep;
		else
			state.motor.stackStop=state.motor.lastPositionRead;
			setStatusString('Stack end set');
			calculateStackParameters;
		end
	end
	turnOnMotorButtons;

% --------------------------------------------------------------------
function varargout = GRAB_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.GRAB.
	global gh
	figure(gh.motorGUI.figure1)
	executeGrabOneStackCallback(h);
	
% --------------------------------------------------------------------
function varargout = savePositionListButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.savePositionListButton.
	global gh
	figure(gh.motorGUI.figure1)
	savePositionListAs;

% --------------------------------------------------------------------
function varargout = loadPositionListButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.loadPositionListButton.
	global gh
	figure(gh.motorGUI.figure1)
	loadPositionList;

function positionGUI_hideGUICallback()
%POSITIONGUI_HIDEGUICALLBACK Called when hideGUI() is used to close the positionGUI
	global gh;
	
	set(gh.roiGUI.tbPosnGUI,'Value',false);
end


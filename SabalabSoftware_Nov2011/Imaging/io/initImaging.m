function initScanImage(userFile, analysisMode)

	global state gh
	
	if nargin<1
		userFile='';
		analysisMode=0;
	end
	
	if nargin==1
		if isnumeric(userFile) && ~isempty(userFile)
			analysisMode=userFile;
			userFile='';
		else
			analysisMode=0;
		end
	end
			
	if analysisMode
		h = waitbar(0, 'Starting ScanImage in Analysis Mode...', 'Name', 'ScanImage Analysis Initialization', 'WindowStyle', 'modal', 'Pointer', 'watch');
	else
		h = waitbar(0, 'Starting ScanImage...', 'Name', 'ScanImage Software Initialization', 'WindowStyle', 'modal', 'Pointer', 'watch');
	end
	gh.imageGUI = guihandles(imageGUI);
	gh.channelGUI = guihandles(channelGUI);
	gh.basicConfigurationGUI=guihandles(basicConfigurationGUI);
	gh.motorGUI =guihandles(motorGUI);
	gh.siGUI_ImagingControls=guihandles(siGUI_ImagingControls);
	gh.pcellControl = guihandles(pcellControl);
	gh.fieldAdjustGUI = guihandles(fieldAdjustGUI);

	gh.resQuickChange=guihandles(resQuickChange);

	set(gh.fieldAdjustGUI.scanRotationSlider, 'SliderStep', [5/360 15/360]);	% 5 degree changes for slider

    
	% Open the waitbar for loading
	
	waitbar(.1,h, 'Reading Initialization File...');
	openini('imaging.ini');

	if analysisMode
		state.analysisMode=1;
		state.motor.motorOn=0;
	else
		state.analysisMode=0;
	end
	
	setStatusString('Initializing...');
	
	global lastAcquiredFrame imageData projectionData
	evalin('base', 'global state gh lastAcquiredFrame projectionData imageData compositeData')
	lastAcquiredFrame=cell(1,10+state.init.maximumNumberOfInputChannels);
	imageData=cell(1,10+state.init.maximumNumberOfInputChannels);
	projectionData=cell(1,10+state.init.maximumNumberOfInputChannels);
	
	initPCellBoxSettingsManager;

	waitbar(.25,h, 'Creating Figures for Imaging');
	makeImageFigures;	% config independent...rleies only on the .ini file for maxNumberOfChannles.
	mp285Config;
	
	setStatusString('Initializing...');
	if ~analysisMode
		waitbar(.4,h, 'Setting Up Data Acquisition Devices...');
		
		siCreateDAQDevices
		siApplyDAQSampleRates
	end
	
	updateChannelFlags;
	if ~analysisMode
		setAcquisitionParameters;
		updateDataForConfiguration;
	end
	updateKeepAllSlicesCheckMark; 
	siUpdateCompositeChannels;
	
	initBlaster;
	
	if ~isempty(userFile)
		waitbar(.7,h, 'Reading User Settings...');
		openAndLoadUserSettings(userFile);
	else
		loadConfig;
	end
	
	makeConfigurationMenu;
	if ~analysisMode
		parkMirrors;
	end
	
	setStatusString('Initializing...');
	
	state.internal.status=0;
	state.cycle.imageOn=1;
	updateGUIByGlobal('state.cycle.imageOn');
	state.cycle.imageOnList(1)=1;

	applyChangesToOutput(1);
	siShowHidePcellBoxControls
		
	waitbar(.9,h, 'Initialization Done');
	
	setStatusString('Ready to use');
	state.initializing=0;
	waitbar(1,h, 'Ready To Use');
	
	if analysisMode
		state.analysisMode=1;
		state.motor.motorOn=0;
        try
            set(get(gh.pcellControl.figure1, 'Children'), 'Enable', 'off');
        catch
        end
            
 		set(get(gh.fieldAdjustGUI.figure1, 'Children'), 'Enable', 'off');

		set(get(gh.motorGUI.figure1, 'Children'), 'Enable', 'off');
		set(gh.siGUI_ImagingControls.focusButton, 'Enable', 'off')
		set(gh.siGUI_ImagingControls.grabOneButton, 'Enable', 'off')
 %       set(get(gh.basicConfigurationGUI.figure1, 'Children'), 'Enable', 'off')	
 		set(gh.fieldAdjustGUI.figure1, 'Visible', 'off')
 		set(gh.pcellControl.figure1, 'Visible', 'off')
		set(gh.motorGUI.figure1, 'Visible', 'off');
		set(gh.blaster.figure1, 'Visible', 'off');
		set(state.internal.GraphFigure, 'Visible', 'off')
		set(state.internal.MaxFigure, 'Visible', 'off')
		set(state.internal.compositeFigure, 'Visible', 'off')
		set(gh.imageGUI.figure1, 'VIsible', 'off')		
 		initAvgAnalysis;
	else
		state.analysisMode=0;
	end

	close(h);
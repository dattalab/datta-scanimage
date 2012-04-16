function varargout = mapper(varargin)
% MAPPER M-file for mapper.fig
%      MAPPER, by itself, creates a new MAPPER or raises the existing
%      singleton*.
%
%      H = MAPPER returns the handle to a new MAPPER or the handle to
%      the existing singleton*.
%
%      MAPPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAPPER.M with the given input arguments.
%
%      MAPPER('Property','Value',...) creates a new MAPPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mapper_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mapper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mapper

% Last Modified by GUIDE v2.5 09-Nov-2006 19:25:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mapper_OpeningFcn, ...
                   'gui_OutputFcn',  @mapper_OutputFcn, ...
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

end
% End initialization code - DO NOT EDIT

% ------------------------------------------------------------------
% --- Executes just before mapper is made visible.
function mapper_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for mapper
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mapper wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = mapper_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;
end
% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

out = {
       'hObject', hObject, ...
       'sampleRate', 10000, 'Class', 'Numeric', 'Config', 3, ...
       'pockelsChannels', 'pockelsCell', 'Class', 'char', 'Config', 2, ...
       'shutterChannels', 'shutter0', 'Class', 'char', 'Config', 2, ...
       'photodiodeChannels', 'photodiode1', 'Class', 'char', 'Config', 2, ... %Doesn't seem to be used?! (VI060108)
       'mapNumber', 1, 'Class', 'Numeric', 'Min', 1, 'Config', 2, 'Gui', 'mapNumber', ...
       'map', 0, 'Class', 'Numeric', 'Gui', 'map', 'Config', 2, ...
       'videoFigure', [], 'Class', 'Numeric', ...
       'videoImage', [], 'Class', 'Numeric', ...
       'crosshairHandles', [], 'Class', 'Numeric', ...
       'displayBeam', 1, 'Class', 'Numeric', 'Gui', 'displayBeam', ...
       'displayPattern', 1, 'Class', 'Numeric', 'Gui', 'displayPattern', ...
       'displaySomata', 1, 'Class', 'Numeric', 'Gui', 'displaySomata', ...
       'displayCrosshairs', 1, 'Class', 'Numeric', 'Gui', 'displayCrosshairs', ...
       'beamHandles', [], 'Class', 'Numeric', ...
       'patternHandles', [], 'Class', 'Numeric', ...
       'beamCoordinates', [0 0], 'Class', 'Numeric', 'Config', 2, ...
       'soma1Coordinates', [], 'Class', 'Numeric', 'Config', 2, ...
       'soma2Coordinates', [], 'Class', 'Numeric', 'Config', 2, ...
       'soma1x', [], 'Class', 'Numeric', 'Gui', 'soma1x', ...
       'soma1y', [], 'Class', 'Numeric', 'Gui', 'soma1y', ...
       'soma2x', [], 'Class', 'Numeric', 'Gui', 'soma2x', ...
       'soma2y', [], 'Class', 'Numeric', 'Gui', 'soma2y', ...
       'somataHandles', [], 'Class', 'Numeric', ...
       'xSpacing', 75, 'Class', 'Numeric', 'Gui', 'xSpacing', 'Min', 0, 'Config', 3, ...
       'ySpacing', 75, 'Class', 'Numeric', 'Gui', 'ySpacing', 'Min', 0, 'Config', 3, ...
       'xSpacingEqualsYSpacing', 0, 'Class', 'Numeric', 'Gui', 'xSpacingEqualsYSpacing', 'Config', 1, ...
       'mapPattern', '', 'Class', 'char', 'Gui', 'mapPattern', 'Config', 3, ...
       'mapPatternDirectory', pwd, 'Class', 'char', 'Config', 3, ...
       'isi', 8, 'Class', 'Numeric', 'Gui', 'isi', 'Config', 3, ...
       'ephysPulse', [], ...
       'pockelsSignal', [], ...
       'shutterSignal', [], ...
       'flashNumber', 1, 'Class', 'Numeric', 'Min', 1, 'Gui', 'flashNumber', 'Config', 2, ...
       'mouse', 0, 'Class', 'Numeric', 'Gui', 'mouse', ...
       'ephysConfig', [], ...
       'xsgConfig', [], ...
       'stimConfig', [], ...
       'acqConfig', [], ...
       'loopConfig',[], ... 
       'sampleRate', 10000, 'Class', 'Numeric', ...
       'pockelsTransmission', 1, 'Class', 'Numeric', 'Min', 0, 'Max', 1, ...
       'temp_xOffset', 0, 'Class', 'Numeric', 'Config', 1, ...
       'temp_xAmplitude', 0, 'Class', 'Numeric', 'Config', 1, ...
       'temp_xGain', 0, 'Class', 'Numeric', 'Config', 1, ...%LTP11_20_06
       'temp_xInvert', 0, 'Class', 'Numeric', 'Config', 1, ...
       'temp_yOffset', 0, 'Class', 'Numeric', 'Config', 1, ...
       'temp_yAmplitude', 0, 'Class', 'Numeric', 'Config', 1, ...
       'temp_yGain', 0, 'Class', 'Numeric', 'Config', 1, ...
       'temp_yInvert', 0, 'Class', 'Numeric', 'Config', 1, ...
       'flashing', 0, 'Class', 'Numeric', ...
       'mapping', 0, 'Class', 'Numeric', ...
       'mousing', 0, 'Class', 'Numeric', ...
       'xVideoScaleFactor', 1, 'Class', 'Numeric', ...
       'yVideoScaleFactor', 1, 'Class', 'Numeric', ...
       'xPatternOffset', 0, 'Class', 'Numeric', 'Gui', 'xPatternOffset', 'Config', 3, ...
       'yPatternOffset', 0, 'Class', 'Numeric', 'Gui', 'yPatternOffset', 'Config', 3, ...
       'spatialRotation', 0, 'Class', 'Numeric', 'Config', 3, 'Gui', 'spatialRotation', ...
       'photodiodeObject', [], ...
       'xMirrorPos', 0, 'Class', 'Numeric', 'Gui', 'xMirrorPos', 'Config', 2, ...
       'yMirrorPos', 0, 'Class', 'Numeric', 'Gui', 'yMirrorPos', 'Config', 2, ...
       'interpipetteDistance', 0, 'Class', 'Numeric', 'Gui', 'interpipetteDistance', 'Config', 2, ...
       'positionNumber', 1, 'Class', 'Numeric', 'Min', 1, 'Gui', 'positionNumber', 'Config', 2, ...
       'backFocalPlanePower', 0, 'Class', 'Numeric', 'Min', 0, 'Gui', 'backFocalPlanePower', 'Config', 2, ...
       'specimenPlanePower', 0, 'Class', 'Numeric', 'Min', 0, 'Gui', 'specimenPlanePower', 'Config', 2, ...
       'patternFlip', 0, 'Class', 'Numeric', 'Min', 0, 'Max', 1, 'Gui', 'patternFlip', 'Config', 3, ...
       'patternRotation', '0', 'Class', 'Char', 'Gui', 'patternRotation', 'Config', 3, ...
       'axesSwitch',0,'Class','Numeric','Min',0,'Max',1,...
       'TEMP_updateDisplay', @updateDisplay, ...
       'mapPatternArray', [], 'Config', 2, ...
       'flashNumber', 1, ...
       'xsgConfigurationEnabled', 0, ...
       'mousePoints', [], ...
       'imageCounter', 1, ...
       'stoppingMap', 0, ...
       'xPatternOffsetSlider', .5, 'Min', 0, 'Max', 1, 'Gui', 'xPatternOffsetSlider', ...
       'yPatternOffsetSlider', .5, 'Min', 0, 'Max', 1, 'Gui', 'yPatternOffsetSlider', ...
       'spatialRotationSlider', .5, 'Min', 0, 'Max', 1, 'Gui', 'spatialRotationSlider', ...
       'xMirrorVoltages', [], ...
       'yMirrorVoltages', [], ...
       'mapperMiniScanSettings', [], 'Config', 3, ...
       'xMirrorCoordinates', [], ...
       'yMirrorCoordinates', [], ...
       'noPockelsCell', 1, ...
       'modulatorMax', 2, ...
       'modulatorMin', 0, ...
   };

end

% ------------------------------------------------------------------
function genericPreGetHeader(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
function genericPostGetHeader(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

%Cut & pasted from pulseEditor.m -- TO122805A Tim O'Connor 12/28/05
mapPatternDirectory = getLocal(progmanager, hObject, 'mapPatternDirectory');
if isempty(mapPatternDirectory)
    mapPatternDirectory = getDefaultCacheValue(progmanager, 'mapPatternDirectory');
end
if isempty(mapPatternDirectory)
    progdir = fileparts(which('mapper'));
    mapPatternDirectory = fullfile(progdir, 'mapPatterns');
end
mapPatternDirectory = uigetdir(mapPatternDirectory, 'Choose a directory containing map patterns...');
%TO092605H: Enhanced cancellation detection. -- Tim O'Connor 9/26/05
if length(mapPatternDirectory) == 1 && isnumeric(mapPatternDirectory)
    if mapPatternDirectory == 0
        return;
    end
end
if isempty(mapPatternDirectory) || exist(mapPatternDirectory, 'dir') ~= 7
    return;
end

setLocal(progmanager, hObject, 'mapPatternDirectory', mapPatternDirectory);

%TO020306A - Factored out the code that creates the list of map patterns.
updateMapPatternList(hObject);

end

% ------------------------------------------------------------------
%TO020306A - Factored out the code that creates the list of map patterns.
function updateMapPatternList(hObject)

mapPatternDirectory = getLocal(progmanager, hObject, 'mapPatternDirectory');
if exist(mapPatternDirectory, 'dir') ~= 7
    setLocalGh(progmanager, hObject, 'mapPattern', 'String', {});
    setLocalGh(progmanager, hObject, 'map', 'Enable', 'Off');
    return;
end

setDefaultCacheValue(progmanager, 'mapPatternDirectory', mapPatternDirectory);%TO120705D

patternNames = dir(fullfile(mapPatternDirectory, 'map*.m'));
patternNames = {patternNames(:).name};
patterns = {};
for i = 1 : length(patternNames)
    patterns{length(patterns) + 1} = patternNames{i}(4 : end - 2);
end
if isempty(patterns)
    patterns = {''};
end
setLocalGh(progmanager, hObject, 'mapPattern', 'String', patterns);
if ~isempty(patterns)
    if length(patterns) ~= 1 && ~isempty(patterns{1})
        setLocalGh(progmanager, hObject, 'map', 'Enable', 'On');
    else
        setLocalGh(progmanager, hObject, 'map', 'Enable', 'Off');
    end
else
    setLocalGh(progmanager, hObject, 'map', 'Enable', 'Off');
end

end

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

errordlg('Save is not supported by this GUI.');

end

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

errordlg('Save As is not supported by this GUI.');

end

% ------------------------------------------------------------------
%Constructor Arguments:
%   xMirrorChannel: EITHER a name (string) of channel already added to stimulator OR a numeric array of format [boardID chanID] specifying channel to create in stimulator; can leave empty to skip/defer
%   yMirrorChannel: EITHER a name (string) of channel already added to stimulator OR a numeric array of format [boardID chanID] specifying channel to create in stimulator; can leave empty to skip/defer
%   pockelsChannel: EITHER a name (string) of channel already added to stimulator OR a numeric array of format [boardID chanID] specifying channel to create in stimulator; can leave empty to skip/defer
%   shutterChannel: EITHER a name (string) of channel already added to stimulator OR a numeric array of format [boardID chanID] specifying channel to create in stimulator; can leave empty to skip/defer
%   photodiodeData: EITHER a @program object of 'photodiode' program OR a @photodiode instance OR a numeric array of format [boardID chanID]; can leave empty to skip/defer
%Notes
%   This 'constructor' opens the stimulator program if it hasn't already been done
%   
%   Currently, the channel names of pre-created channels MUST be 'xMirror', 'yMirror', 'pockelsCell', and (I think) 'shutter0' -- these are hard-coded into mapper at various places
%
%   Currently photodiodeProgram and photodiode object are separable. In the future, they could be inseperable as a type of smartDevice
function genericStartFcn(hObject, eventdata, handles,varargin)

progdir = which('mapper');
setLocal(progmanager, hObject, 'mapPatternDirectory', fullfile(progdir, 'mapPatterns'));

%stopAllChannels(getDaqmanager);%This is also part of 'el hacko de mierda', remove it when cleaning up this program.%TO102207A - Nimex port. It's been removed, but this comment amuses me, so it stays.

%TO030706D - Add userFcn events for the mapper. -- Tim O'Connor 3/7/06
cbm = getUserFcnCBM;
%TO060810D - Check for event existence.
if ~isEvent(cbm, 'mapper:MapStart')
    addEvent(cbm, 'mapper:MapStart');
end
if ~isEvent(cbm, 'mapper:MapStop')
    addEvent(cbm, 'mapper:MapStop');
end
if ~isEvent(cbm, 'mapper:FlashStart')
    addEvent(cbm, 'mapper:FlashStart');
end
if ~isEvent(cbm, 'mapper:FlashStop')
    addEvent(cbm, 'mapper:FlashStop');
end
if ~isEvent(cbm, 'mapper:MouseStart')
    addEvent(cbm, 'mapper:MouseStart');
end
if ~isEvent(cbm, 'mapper:MouseStop')
    addEvent(cbm, 'mapper:MouseStop');
end
if ~isEvent(cbm, 'mapper:Stimulate')
    addEvent(cbm, 'mapper:Stimulate');
end
if ~isEvent(cbm, 'mapper:PreGrabVideo')
    addEvent(cbm, 'mapper:PreGrabVideo', 'Passes the current xsg directory as an argument.');%TO053106B
end
if ~isEvent(cbm, 'mapper:PostGrabVideo')
    addEvent(cbm, 'mapper:PostGrabVideo');%TO053106B
end

acqJob = daqjob('acquisition');

%Make sure this one comes after all the programs are done with whatever they have to do, because it will reconfigure them, potentially stopping them.
bindEventListener(acqJob, 'jobCompleted', {@acquisitionCompleted_Callback, hObject}, 'mapper_acquisitionCompleted', 10);
bindEventListener(acqJob, 'jobDone', {@acquisitionDone_Callback, hObject}, 'mapper_acquisitionCompleted');
registerLoopable(loopManager, {@mapper_loopListener, hObject}, 'mapper');

%TO053008B - Moved common start-up script functionality into the various programs. -- Tim O'Connor 5/30/08
moap = program('mapperOnlineAnalysisParameters', 'mapperOnlineAnalysisParameters', 'mapperOnlineAnalysisParameters');
openprogram(progmanager, moap);

%VI060208A - Open stimulator, if not done so already
if isprogram(progmanager, 'stimulator') %stimulator's already added
    stim = getHandleFromName(progmanager,'stimulator','stimulator');
    %stim = getGlobal(progmanager, 'hObject', 'stimulator', 'stimulator'); %this was Tim's approach--I hadn't seen it at first...not sure pros/cons
else
    if ~isempty(varargin) && ~all(cellfun(@isempty,varargin{1:4}))   %stimulator's not been added, but is implied by presence of constructor args
        stim = openprogram(progmanager,'stimulator');
    else %don't add stimulator if it's not specifically implied
        fprintf(1, 'Warning: Mapper did not detect Stimulator, which is typically expected to be running. Will work without it.\n'); %I would call this an error! (VI060108) %I wouldn't call this an error. -- Tim O'Connor 7/30/08
    end
end

%VI060208A - Add channels to stimulator based on input args (or look for unnamed pre-existing stimulator channels, for backwards compatibility)
foundXY = 0;
foundPockels = 0;

    %Hmm, nested functions... this is really ugly and should be avoided. While skimming the code, it doesn't even jump out at you as a function. Not good. -- Tim O'Connor 7/22/08
    %
    %Also, there's some ridiculous weirdness going on (ie. "&& round(arg(1))==round(arg(1)) &&" and a distinct lack of commas/spaces), 
    %but I don't feel like looking at it right now. This should probably all be re-written. -- Still Tim O'Connor 7/22/08
    %
    %So, after speaking to Vijay, "&& round(arg(1))==round(arg(1)) &&" was indeed wrong (see TO073108C). He was testing to see if a value was an integer.
    %Upon further inspection, I realize why this nested function irks me so. It's because it's unnecessarily pedantic error checking.
    %While that's fine, it just seems like overkill to me. Let bozos who use non-integer values for boardIDs spend all day figuring it out, is my feeling. 
    %But, whatever, it's not the end of the world to be overly-pedantic. Of course, this small feature required modifying every function in the file, 
    %to change all `return` statements into `end` statements, to allow for nested functions. To top it off, this could've just as easily been a simple subfunction, 
    %instead of a nested function, since it doesn't require access to the parent function's scope. That would've been much easier to code, since it didn't involve 
    %changing all the `return` statements. A meaningful name for the function would help to divine its purpose. -- Tim O'Connor 7/31/08
    % ------------------------------------------------------------------
    %Helper for processing arguments...
    function processArg(arg, hardChanName)
        if ischar(arg) %a pre-added stimulator channel was specified
            if ~strcmp(arg, hardChanName) %this should be fixed
                error('Mirror/Pockels/Shutter signals must be ''xMirror'',''yMirror'',''pockelsCell'', and ''shutter0'' in present implementation.');
            end
            %here, we should ideally be binding /arbitrarily/ named channel to appropriate mapper variable (i.e. an xMirror, yMirror, shutter, etc. variable)
        elseif isnumeric(arg) && length(arg) == 2 && round(arg(1))==arg(1) && round(arg(2)) == arg(2) %TO073108C
            stim_addChannels(stim, {hardChanName arg(1) arg(2)});
        else
            error('First 4 constructor args must be empty, a string, or a 2-element array of integer values');
        end
    end

%Process arguments.
if ~isempty(varargin)
    %"Constructor" arguments specified.
    if ~isempty(varargin{1})
        foundXY = foundXY + 1;
        processArg(varargin{1},'xMirror');
    end

    if length(varargin) >= 2 && ~isempty(varargin{2})
        foundXY = foundXY + 1;
        processArg(varargin{2},'yMirror');
    end

    if length(varargin) >= 3 && ~isempty(varargin{3})
        foundPockels = foundPockels + 1;
        processArg(varargin{3},'pockelsCell');
    end

    if length(varargin) >= 4 && ~isempty(varargin{4})
        processArg(varargin{4},'shutter0');
    end
else
    %For backwards compatibility, look for unsupplied pre-existing stimulator channels.
    [stimChannels] = getLocalBatch(progmanager, stim, 'channels');%TO091506A
    for i = 1 : length(stimChannels)
        if strcmpi(stimChannels(i).channelName, 'xMirror') || strcmpi(stimChannels(i).channelName, 'yMirror')
            foundXY = foundXY + 1;
        elseif strcmpi(stimChannels(i).channelName, 'pockelsCell')
            foundPockels = 1;
        end
    end
    if foundXY < 2
        warning('Mapper did not detect ''xMirror''/''yMirror'' channel(s) in Stimulator. This may cause serious and undefined behavior.');
    elseif foundXY > 2
        warning('Mapper detected more than 1 each of ''xMirror''/''yMirror'' channel(s) in Stimulator. This may cause serious and undefined behavior.');
    end
    if foundPockels > 1
        warning('Mapper detected more than 1 ''pockelsCell'' channel in Stimulator. This may cause serious and undefined behavior.');
    end    

end

if foundXY == 2
    nimex_registerOutputDataPreprocessor(getTaskByChannelName(acqJob, 'xMirror'), getDeviceNameByChannelName(acqJob, 'xMirror'), ...
        {@mapper_mirrorChannelPreprocessor, hObject, 'X'}, 'xMirror', 5);
    nimex_registerOutputDataPreprocessor(getTaskByChannelName(acqJob, 'yMirror'), getDeviceNameByChannelName(acqJob, 'yMirror'), ...
        {@mapper_mirrorChannelPreprocessor, hObject, 'Y'}, 'yMirror', 5);
end

%These warnings were added for Gordon's case, where mapper will be used without acq. I think the warnings can be left out. (VI060108)
if ~isprogram(progmanager, 'acquirer')
    fprintf(1, 'Warning: Mapper did not detect Acquirer, which is typically expected to be running. Will work without it.\n');
end
if ~isprogram(progmanager, 'ephys')
    fprintf(1, 'Warning: Mapper did not detect Ephys, which is typically expected to be running. Will work without it.\n');
end

%Start associated programs.
if ~isprogram(progmanager, 'imagingSys') 
    if foundXY == 2
        openprogram(progmanager, {'imagingSys', 'imagingSys', 'imagingSystemConfiguration'}, 'Mapper-Scanner01', 'xMirror', 'yMirror');
    elseif foundXY == 1
        fprintf(1,'Warning: Mapper only detected one of the X/Y mirror channel pair usually employed. The imagingSysConfig program was not started.');
    end
end

%VI060108A -- Determine associated photodiode object via newly added 'constructor' argument
if ~isempty(varargin) && length(varargin)>=5
    if isa(varargin{5},'photodiode')
        setLocal(progmanager, hObject, 'photodiodeObject', varargin{5});
    elseif isa(varargin{5}, 'program') && strcmpi(get(varargin{5}, 'program_name'), 'photodiode') %Could test against m_filename of main_gui alias, to ensure it's 'photodiodeConfiguration'--but this works for now
        setLocal(progmanager, hObject, 'photodiodeObject', getLocal(progmanager, varargin{5}, 'photodiodeObject'));
    elseif ~isempty(varargin{5})
        error('Fifth optional argument must a valid @photodiode object or ''photodiode'' @program object (or empty)');
    end
elseif ~strcmpi(class(getLocal(progmanager, hObject, 'photodiodeObject')), 'photodiode')
    %TO031509A - Moved this from a stand-alone `if` to be an `elseif`
    %TO080108H - More nonsense to deal with Vijay's precious constructors. -- Tim O'Connor 8/1/08
    if isprogram(progmanager, 'photodiode')
        setLocal(progmanager, hObject, 'photodiodeObject', getGlobal(progmanager, 'photodiodeObject', 'photodiode', 'photodiode'));
    end
else
    %TO031509A - Added this extra error case, which may help to avoid some problems. -- Tim O'Connor 9/15/09
    if isprogram(progmanager, 'photodiode')
        error('No photodiode object specified, and no photodiode object could be found by probing the photodiode configuration gui.');
    else
        error('No photodiode object specified, and no photodiode configuration gui was found to be running.');
    end
end

%TO072010A - Moved all the binding of user functions down, to allow for conditional binding, based on the results above. -- Tim O'Connor 7/20/10
%TO082907D - Reset counters when an xsg:NewCell event occurs. This replaces the functionality of the "New Cell" button. -- Tim O'Connor 8/29/07
addCallback(cbm, 'xsg:NewCell', 'mapper_newCell_userFcn', 'userFcns_mapper_newCell_userFcn');
fprintf(1, '\t xsg:NewCell -> @mapper_newCell_userFcn\n');

if foundPockels %TO072010A
    %TO111908 - Doing this on the AcquisitionCompleted event resulted in always working with the previous (stale) trace data. See TO042806F. -- Tim O'Connor 11/19/08
    %TO052610A - Switch back to using samplesAcquired, to get an update per pixel in mapping. -- Tim O'Connor 5/26/10
    addCallback(cbm, 'acquirer:SamplesAcquired', @mapper_userFcn_laserPowerCalculation, 'userFcns_mapper_userFcn_laserPowerCalculation');%TO042010A
    fprintf(1, '\t acquirer:SamplesAcquired -> @mapper_userFcn_laserPowerCalculation\n');%TO042010A %TO052610A
end

%TO040510B - Moved some more userFcn set up out of the start up file. -- Tim O'Connor 4/5/10
addCallback(cbm, 'xsg:NewCell', @mapper_newCell_userFcn, 'userFcns_mapper_newCell_userFcn');
fprintf(1, '\t xsg:NewCell -> @mapper_newCell_userFcn\n');
if isprogram(progmanager, 'ephys')
    addCallback(cbm, 'ephys:SamplesAcquired', @mapper_userFcn_ephysSamplesAcquired_display, 'userFcns_mapper_userFcn_ephysSamplesAcquired_display');%TO042010A
    fprintf(1, '\t xsg:SamplesAcquired -> @mapper_userFcn_ephysSamplesAcquired_display\n');%TO042010A %TO052610A
    addCallback(cbm, 'ephys:SamplesAcquired', @mapper_userFcn_ephysSamplesAcquired_updateMirrorPosition, 'userFcns_mapper_userFcn_ephysSamplesAcquired_updateMirrorPosition');%TO042010A
    fprintf(1, '\t ephys:SamplesAcquired -> @mapper_userFcn_ephysSamplesAcquired_updateMirrorPosition\n');%TO042010A %TO052610A
end
addCallback(cbm, 'mapper:MapStart', @mapper_userFcn_mapStart_display, 'userFcns_mapper_userFcn_mapStart_display');
fprintf(1, '\t mapper:MapStart -> @mapper_userFcn_mapStart_display\n');
addCallback(cbm, 'mapper:MapStop', @mapper_userFcn_mapStop_display, 'userFcns_mapper_userFcn_mapStop_display');
fprintf(1, '\t mapper:MapStop -> @mapper_userFcn_mapStop_display\n');
addCallback(cbm, 'mapper:MouseStart', @mapper_userFcn_mouseStart_updateMirrorPosition, 'userFcns_mapper_userFcn_mouseStart_updateMirrorPosition');
fprintf(1, '\t mapper:MouseStart -> @mapper_userFcn_mouseStart_updateMirrorPosition\n');

if getLocal(progmanager, hObject, 'noPockelsCell')
    setLocalGh(progmanager, hObject, 'calibratePockels', 'Enable', 'Off');
end

%TO021510A - mouseBurst is deprecated (for the forseeable future). -- Tim O'Connor 2/15/10
% if ~isprogram(progmanager, 'mouseBurst')
%     openprogram(progmanager, 'mouseBurst');
% end
end

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

%TO060910B - Remove the events when we're done. -- Tim O'Connor 6/9/10
cbm = getUserFcnCBM;
if ~isEvent(cbm, 'mapper:MapStart')
    removeEvent(cbm, 'mapper:MapStart');
end
if ~isEvent(cbm, 'mapper:MapStop')
    removeEvent(cbm, 'mapper:MapStop');
end
if ~isEvent(cbm, 'mapper:FlashStart')
    removeEvent(cbm, 'mapper:FlashStart');
end
if ~isEvent(cbm, 'mapper:FlashStop')
    removeEvent(cbm, 'mapper:FlashStop');
end
if ~isEvent(cbm, 'mapper:MouseStart')
    removeEvent(cbm, 'mapper:MouseStart');
end
if ~isEvent(cbm, 'mapper:MouseStop')
    removeEvent(cbm, 'mapper:MouseStop');
end
if ~isEvent(cbm, 'mapper:Stimulate')
    removeEvent(cbm, 'mapper:Stimulate');
end
if ~isEvent(cbm, 'mapper:PreGrabVideo')
    removeEvent(cbm, 'mapper:PreGrabVideo');
end
if ~isEvent(cbm, 'mapper:PostGrabVideo')
    removeEvent(cbm, 'mapper:PostGrabVideo');
end

end

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.4;

end

%------------------------------------------------------------------------------
function genericPreSaveSettings(hObject, eventdata, handles)

end

%------------------------------------------------------------------------------
function genericPostSaveSettings(hObject, eventdata, handles)

end

%------------------------------------------------------------------------------
function genericPreLoadMiniSettings(hObject, eventdata, handles)

genericPreLoadSettings(hObject, eventdata, handles);

end

%------------------------------------------------------------------------------
function genericPreLoadSettings(hObject, eventdata, handles)

end

%------------------------------------------------------------------------------
function genericPostLoadMiniSettings(hObject, eventdata, handles)

genericPostLoadSettings(hObject, eventdata, handles);

end

%------------------------------------------------------------------------------
function genericPostLoadSettings(hObject, eventdata, handles)

%TO111706A - Make sure the local configuration is not overwriting changes that have been made over in imagingSys (ie. when loading an old hotswitch configuration).
imagingSysObj = getGlobal(progmanager, 'hObject', 'imagingSys', 'imagingSys');
[xOffset, xAmplitude, xMicrons, xInvert, yOffset, yAmplitude, yMicrons, yInvert] = getLocalBatch(progmanager, imagingSysObj, ...
    'xOffset', 'xAmplitude', 'xMicrons', 'xInvert', 'yOffset', 'yAmplitude', 'yMicrons', 'yInvert');
setLocalBatch(progmanager, hObject, 'temp_xOffset', xOffset, 'temp_xAmplitude', xAmplitude, 'temp_xGain', 2 * xAmplitude / xMicrons, 'temp_xInvert', xInvert, ...
    'temp_yOffset', yOffset, 'temp_yAmplitude', yAmplitude, 'temp_yGain', 2 * yAmplitude / yMicrons, 'temp_yInvert', yInvert);

%TO020306A - Factored out the code that creates the list of map patterns.
updateMapPatternList(hObject);

%TO080108H - More nonsense to deal with Vijay's precious constructors. -- Tim O'Connor 8/1/08
if ~strcmpi(class(getLocal(progmanager, hObject, 'photodiodeObject')), 'photodiode')
    if isprogram(progmanager, 'photodiode')
        setLocal(progmanager, hObject, 'photodiodeObject', getGlobal(progmanager, 'photodiodeObject', 'photodiode', 'photodiode'));
    end
end

%TO112008A - Update the display when loading a configuration. -- Tim O'Connor 11/20/08
updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes on button press in flash.
%TO020206B - Complete rewrite.
function flash_Callback(hObject, eventdata, handles)

mapper_captureConfigs(hObject);
mapper_setSaveConfig(hObject, 'flash');
% mapper_createSignals(hObject);

xsg_setAcquisitionNumber(getLocal(progmanager, hObject, 'flashNumber'));
setID = xsg_getSetID;
setID(1) = 'F';
xsg_setSetID(setID);

setLocal(progmanager, hObject, 'flashing', 1);

%TO040706F User @acquisitionCompleted_Callback instead. -- Tim O'Connor 4/7/06
fireEvent(getUserFcnCBM, 'mapper:FlashStart');%TO030706D: Add userFcn events for the mapper. -- Tim O'Connor 3/7/06
try
    xMirrorPos_Callback(hObject, eventdata, handles);%TO012909B - Make sure the beam is where it's supposed to be.
    yMirrorPos_Callback(hObject, eventdata, handles);%TO012909B - Make sure the beam is where it's supposed to be.
    mapper_stimulatePoint(hObject);
catch
    warning('Error encountered while taking a flash: %s', lasterr);
end

%TO042106B - Moved into the acquisitionCompleted_Callback. -- Tim O'Conor 4/21/06
% fireEvent(getUserFcnCBM, 'mapper:FlashStop');%TO030706D: Add userFcn events for the mapper. -- Tim O'Connor 3/7/06

end

% ------------------------------------------------------------------
% --- Executes on button press in mouse.
function mouse_Callback(hObject, eventdata, handles)

%TO042806C: Implement remouse functionality. Created mousePoints variable and moved most code into the new function `executeMousePattern`. -- Tim O'Connor 4/28/06
[f, mouse] = getLocalBatch(progmanager, hObject, 'videoFigure', 'mouse');
if mouse
    if ishandle(f)
        setLocalGh(progmanager, hObject, 'mouse', 'String', 'Selecting...', 'ForegroundColor', [1 .2 .2]);
        set(f, 'HandleVisibility', 'On', 'Pointer', 'cross');
        [x, y] = getPointsFromAxes(get(f, 'Children'));%TO031910D
        set(f, 'HandleVisibility', 'On', 'Pointer', 'arrow');
        setLocal(progmanager, hObject, 'mousePoints', cat(2, x, y));
    else
        warndlg('Mapper: No video image found for mouse selection.');
        warning('Mapper: No video image found for mouse selection.');
        return;
    end
end

executeMousePattern(hObject);

end

% ------------------------------------------------------------------
%TO042806C: Implement remouse functionality. -- Tim O'Connor 4/28/06
%           This used to all be in mouse_Callback, but was moved so remouse could use it. The mousePoints variable was added.
function executeMousePattern(hObject)

%TO020206B
[flashNumber, isi, f, mouse, xOffset, xAmplitude, xGain, yOffset, yAmplitude, yGain, xInvert, yInvert, mousePoints, sampleRate] = getLocalBatch(progmanager, hObject, ...
    'flashNumber', 'isi', 'videoFigure', 'mouse', ...
    'temp_xOffset', 'temp_xAmplitude', 'temp_xGain', 'temp_yOffset', 'temp_yAmplitude', 'temp_yGain', 'temp_xInvert', 'temp_yInvert', 'mousePoints', 'sampleRate');

if ~mouse
    setLocalGh(progmanager, hObject, 'mouse', 'String', 'Mouse', 'ForegroundColor', [0 .6 0]);
    return;
end

if isempty(mousePoints)
    setLocal(progmanager, hObject, 'mouse', 0);
    setLocalGh(progmanager, hObject, 'mouse', 'String', 'Mouse', 'ForegroundColor', [0 .6 0]);
    return;
end

setLocalGh(progmanager, hObject, 'mouse', 'String', 'Stop', 'ForegroundColor', [1 .2 .2]);

%TO102407B - Scale from volts to millivolts. -- Tim O'Connor 10/24/07
x = mousePoints(:, 1) * 1000;
y = mousePoints(:, 2) * 1000;

mapper_captureConfigs(hObject);
mapper_setSaveConfig(hObject, 'flash');
%mapper_createSignals(hObject);%TO031006B
flashNumber = getLocal(progmanager, hObject, 'flashNumber');
xsg_setAcquisitionNumber(flashNumber);
setID = xsg_getSetID;
setID(1) = 'F';
xsg_setSetID(setID);

% %TO030906C: Fix the beam position display to take into account any inversions.
% %TO102408B: Invert the Y-axis, because things have been inverted in our calculations (yet again), probably due to TO060308A. This is because of the flipped image, per Matlab convention. -- Tim O'Connor 10/24/08
% if ~xInvert
%     xSign = +1;
% else
%     xSign = -1;
% end
% if ~yInvert
%     ySign = -1;
% else
%     ySign = +1;
% end
% 
% samplesPerPoint = ceil(sampleRate * isi);
% xMirrorVoltages = ones(samplesPerPoint * length(x), 1);
% yMirrorVoltages = xMirrorVoltages;
% lastIndex = 1;
% for i = 1 : length(x)
%     index = i * samplesPerPoint;
%     %TO042106A - Redefine how invert applies to offset. -- Tim O'Connor 4/21/06
%     %TO102508I - Removed the factor of 1000 on the offset here, since it's handled in the preprocessor. -- Tim O'Connor 10/25/08
%     xMirrorVoltages(lastIndex : index) = xSign * ((0.5 * xOffset) + x(i) * xGain);%TO111407A - Apply V->mV scaling to offset.
%     yMirrorVoltages(lastIndex : index) = ySign * ((0.5 * yOffset) + y(i) * yGain);%TO111407A - Apply V->mV scaling to offset.
%     lastIndex = index;
% end

%TO012909A - Fixed the mouse feature, so it relies on the mapper_mirrorChannelPreprocessor and mapper_coordinates2Voltages functions. -- Tim O'Connor 1/29/09
samplesPerPoint = ceil(sampleRate * isi);
xMirrorCoordinates = ones(samplesPerPoint * size(mousePoints, 1), 1);
yMirrorCoordinates = xMirrorCoordinates;
lastIndex = 1;
for i = 1 : size(mousePoints, 1)
    index = i * samplesPerPoint;
    xMirrorCoordinates(lastIndex : index) = mousePoints(i, 1);
    yMirrorCoordinates(lastIndex : index) = mousePoints(i, 2);
    lastIndex = index;
end

% if any(xMirrorVoltages > xAmplitude + xOffset) | any(xMirrorVoltages < xOffset - xAmplitude)
%     xMirrorVoltages(find(xMirrorVoltages > xAmplitude + xOffset)) = xAmplitude + xOffset;
%     xMirrorVoltages(find(xMirrorVoltages < xOffset - xAmplitude)) = xOffset - xAmplitude;
%     warning('Calculated X values that are outside the x-axis galvo''s field of view.');
% end
% 
% if any(yMirrorVoltages > yAmplitude + yOffset) | any(yMirrorVoltages < yOffset - yAmplitude)
%     yMirrorVoltages(find(yMirrorVoltages > yAmplitude + yOffset)) = yAmplitude + yOffset;
%     yMirrorVoltages(find(yMirrorVoltages < yOffset - yAmplitude)) = yOffset - yAmplitude;
%     warning('Calculated Y values that are outside the y-axis galvo''s field of view.');
% end
% figure, plot(1:length(xMirrorVoltages), xMirrorVoltages, 1:length(yMirrorVoltages), yMirrorVoltages);
% fprintf(1, 'mapper/executeMousePattern @ mapper.m:626\n');
% figure, plot(1:length(xMirrorCoordinates), xMirrorCoordinates, 1:length(yMirrorCoordinates), yMirrorCoordinates);
% xMirrorCoordinates
% yMirrorCoordinates
% fprintf(1, '\n----------------------------------------------------\n');fprintf(1, '----------------------------------------------------\n');fprintf(1, '----------------------------------------------------\n\n\n\n\n');
setLocalBatch(progmanager, hObject, 'xMirrorCoordinates', xMirrorCoordinates, 'yMirrorCoordinates', yMirrorCoordinates, 'mousing', 1);
fireEvent(getUserFcnCBM, 'mapper:MouseStart');%TO030706D: Add userFcn events for the mapper. -- Tim O'Connor 3/7/06
turboMode(hObject);

end

% ------------------------------------------------------------------
% --- Executes on button press in zeroMirrors.
function zeroMirrors_Callback(hObject, eventdata, handles)

[xOffset yOffset xInvert yInvert] = getLocalBatch(progmanager, hObject, 'temp_xOffset', 'temp_yOffset', 'temp_xInvert', 'temp_yInvert');

% %Swap X and Y, for now, to be consistent with Matlab image conventions.
if xInvert
    putSample(daqjob('acquisition'), 'xMirror', -xOffset);
else
    putSample(daqjob('acquisition'), 'xMirror', xOffset);
end

if yInvert
    putSample(daqjob('acquisition'), 'yMirror', -yOffset);
else
    putSample(daqjob('acquisition'), 'yMirror', yOffset);
end

setLocal(progmanager, hObject, 'beamCoordinates', [0 0]);
updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes on button press in map.
%TO020206B - Complete rewrite.
function map_Callback(hObject, eventdata, handles)

%TO032906B
[mapPatternDirectory, mapPattern, mapNumber, xSpacing, ySpacing, ...
        xOffset, xAmplitude, xGain, yOffset, yAmplitude, yGain, xInvert, yInvert, ...
        xPatternOffset, yPatternOffset, spatialRotation, patternFlip, patternRotation, videoImage] = getLocalBatch(progmanager, hObject, ...
    'mapPatternDirectory', 'mapPattern', 'mapNumber', 'xSpacing', 'ySpacing', ...
    'temp_xOffset', 'temp_xAmplitude', 'temp_xGain', 'temp_yOffset', 'temp_yAmplitude', 'temp_yGain', 'temp_xInvert', 'temp_yInvert', ...
    'xPatternOffset', 'yPatternOffset', 'spatialRotation', 'patternFlip', 'patternRotation', 'videoImage');

if ~getLocal(progmanager, hObject, 'map')
    setLocalGh(progmanager, hObject, 'map', 'String', 'Map', 'ForegroundColor', [0 .6 0]);
    setLocal(progmanager, hObject, 'stoppingMap', 1);
    stop(loopManager);
    stop(daqjob('acquisition'), 'xMirror', 'yMirror');
    setPropertyForAllTasks(daqjob('acquisition'), 'forceFullBuffering', 0);%TO102407A
    restoreMap(pulseMap('acquisition'));%TO102207A
    mapper_restoreConfigs(hObject);
    return;
end

%TO110906H - Gracefully handle the absence of a video image. -- Tim O'Connor 11/9/06
%TO082907C - 0 is always a handle, so check that it's non-zero and non-empty. -- Tim O'Connor 8/29/07
if isempty(videoImage) || (~ishandle(videoImage) || (videoImage == 0))
    warndlg('A video image must be captured before taking a map.');
    videoCapture_Callback(hObject, eventdata, handles);
    videoImage = getLocal(progmanager, hObject, 'videoImage');
    if isempty(videoImage) || (~ishandle(videoImage) && (videoImage == 0))
        setLocalGh(progmanager, hObject, 'map', 'String', 'Map', 'ForegroundColor', [0 .6 0]);
        setLocal(progmanager, hObject, 'map', 0);
        return;
    end
end

%TO031006C
pattern = loadMapPattern(hObject);
if isempty(pattern)
    return;
end

%TO090807C - Add "safe" cancelling of maps on startup. -- Tim O'Connor 9/8/06
figurePos = get(getParent(hObject, 'figure'), 'Position');
wb = waitbarWithCancel(0, 'Starting map...');
set(wb, 'Units', get(getParent(hObject, 'figure'), 'Units'), 'HandleVisibility', 'Off');
wbPos = get(wb, 'Position');
wbPos(1) = figurePos(1);
wbPos(2) = figurePos(2) + 0.35 * figurePos(4);
set(wb, 'Position', wbPos);

setLocalGh(progmanager, hObject, 'map', 'String', 'Stop', 'ForegroundColor', [1 .2 .2]);

%TO090806C
waitbar(0.1, wb);
if isWaitbarCancelled(wb)
    setLocalGh(progmanager, hObject, 'map', 'String', 'Map', 'ForegroundColor', [0 .6 0]);
    setLocal(progmanager, hObject, 'map', 0);
    return;
end

mapper_captureConfigs(hObject);
mapper_setSaveConfig(hObject, 'map');

%TO090806C
waitbar(0.2, wb);
if isWaitbarCancelled(wb)
    setLocalGh(progmanager, hObject, 'map', 'String', 'Map', 'ForegroundColor', [0 .6 0]);
    setLocal(progmanager, hObject, 'stoppingMap', 1);
    mapper_restoreConfigs(hObject);
    delete(wb);
    setLocal(progmanager, hObject, 'map', 0);
    return;
end
%mapper_createSignals(hObject);%TO031006B

setID = xsg_getSetID;
setID(1) = 'M';
if mapNumber > 26
    setID(3) = char('A' + floor(mapNumber / 26));
    setID(4) = char('A' + mod(mapNumber, 26));
else
    setID(3) = 'A';
    setID(4) = char('A' + mapNumber - 1);
end
xsg_setSetID(setID);

[xMirrorVoltages, yMirrorVoltages] = mapper_getMirrorVoltages(hObject);
%TO060308A - Store the flipped pattern, for the header.
% mp = flipdim(mapper_getMapPattern(hObject), 2);
setLocalBatch(progmanager, hObject, 'xMirrorVoltages', xMirrorVoltages, 'yMirrorVoltages', yMirrorVoltages, 'stoppingMap', 0, 'mapPatternArray', mapper_getMapPattern(hObject));

delete(wb);

% figure;
% plot(1:length(xMirrorVoltages), xMirrorVoltages, 1:length(yMirrorVoltages), yMirrorVoltages);
% return;
% fprintf(1, 'mapper/map_Callback: entering turboMode.\n');
fireEvent(getUserFcnCBM, 'mapper:MapStart');%TO030706D: Add userFcn events for the mapper. -- Tim O'Connor 3/7/06
turboMode(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mapNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function mapNumber_Callback(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function positionNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function positionNumber_Callback(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xSpacing_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function xSpacing_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'xSpacingEqualsYSpacing')
    setLocal(progmanager, hObject, 'ySpacing', getLocal(progmanager, hObject, 'xSpacing'));
end

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function ySpacing_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function ySpacing_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'xSpacingEqualsYSpacing')
    setLocal(progmanager, hObject, 'xSpacing', getLocal(progmanager, hObject, 'ySpacing'));
end

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function mapPattern_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
% --- Executes on selection change in mapPattern.
function mapPattern_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'mapPatternArray', mapper_getMapPattern(hObject));%TO060308A - Refactored map calculations.
updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes on button press in displayBeam.
function displayBeam_Callback(hObject, eventdata, handles)

[f, beamHandles, displayBeam] = getLocalBatch(progmanager, hObject, 'videoFigure', 'beamHandles', 'displayBeam');
if isempty(beamHandles)
    return;
end

set(f, 'HandleVisibility', 'On');

if displayBeam
    set(beamHandles, 'Visible', 'On');
else
    set(beamHandles, 'Visible', 'Off');
end

set(f, 'HandleVisibility', 'Off');

end

% ------------------------------------------------------------------
% --- Executes on button press in displayPattern.
function displayPattern_Callback(hObject, eventdata, handles)

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes on button press in displaySomata.
function displaySomata_Callback(hObject, eventdata, handles)

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function lens_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
% --- Executes on selection change in lens.
function lens_Callback(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
% --- Executes on button press in markSoma.
function markSoma_Callback(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function backFocalPlanePower_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function backFocalPlanePower_Callback(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function specimenPlanePower_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function specimenPlanePower_Callback(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function soma1x_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function soma1x_Callback(hObject, eventdata, handles)

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function soma1y_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function soma1y_Callback(hObject, eventdata, handles)

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function soma2y_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function soma2y_Callback(hObject, eventdata, handles)

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function soma2x_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function soma2x_Callback(hObject, eventdata, handles)

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function interpipetteDistance_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function interpipetteDistance_Callback(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xMirrorPos_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function xMirrorPos_Callback(hObject, eventdata, handles)

%TO110906H - Forgot to get most of the variables, oops. -- Tim O'Connor 11/9/06
% [x, xGain, xOffset, xInvert, beamHandles] = getLocalBatch(progmanager, hObject, 'xMirrorPos', 'temp_xGain', 'temp_xOffset', 'temp_xInvert', 'beamHandles');
% 
% xSign = 1;
% if xInvert
%     xSign = -1;
%     x = -x;
% end
% 
% xMirrorVoltages = xSign * (x * xGain + xOffset);
% fprintf(1, 'x = %4.5f\nxGain = %4.5f\nxOffset = %4.5f\nxSign = %4.5f\nxVoltage = %4.5f\n\n', x, xGain, xOffset, xSign, xMirrorVoltages);
[x, beamHandles] = getLocalBatch(progmanager, hObject, 'xMirrorPos', 'beamHandles');
xMirrorVoltages = mapper_coordinates2Voltages(hObject, 'X', x);%TO111908B - Use mapper_coordinates2Voltages for calculations. -- Tim O'Connor 11/19/08
putSample(daqjob('acquisition'), 'xMirror', xMirrorVoltages);

try
    videoF = getParent(beamHandles(1), 'figure');
    fHV = get(videoF, 'HandleVisibility');
    set(videoF, 'HandleVisibility', 'On');
    pos = get(beamHandles(1), 'Position');
    pos(1) = x - pos(3) * 0.5;
    set(beamHandles(1), 'Position', pos);
    set(videoF, 'HandleVisibility', fHV);%TO112907C
catch
end

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yMirrorPos_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function yMirrorPos_Callback(hObject, eventdata, handles)

%TO110906H - Forgot to get most of the variables, oops. -- Tim O'Connor 11/9/06
% [y, yGain, yOffset, yInvert, beamHandles] = getLocalBatch(progmanager, hObject, 'yMirrorPos', 'temp_yGain', 'temp_yOffset', 'temp_yInvert', 'beamHandles');
% 
% ySign = 1;
% if yInvert
%     ySign = -1;
%     y = -y;
% end
% 
% yMirrorVoltages = ySign * (y * yGain + yOffset);
[y, beamHandles] = getLocalBatch(progmanager, hObject, 'yMirrorPos', 'beamHandles');
yMirrorVoltages = mapper_coordinates2Voltages(hObject, 'Y', y);%TO111908B - Use mapper_coordinates2Voltages for calculations. -- Tim O'Connor 11/19/08
% fprintf(1, 'y = %4.5f\nyGain = %4.5f\nyOffset = %4.5f\nySign = %4.5f\nyVoltage = %4.5f\n\n', y, yGain, yOffset, ySign, yMirrorVoltages);
putSample(daqjob('acquisition'), 'yMirror', yMirrorVoltages);

try
    videoF = getParent(beamHandles(1), 'figure');
    fHV = get(videoF, 'HandleVisibility');
    set(videoF, 'HandleVisibility', 'On');
    pos = get(beamHandles(1), 'Position');
    pos(2) = y - pos(4) * 0.5;
    set(beamHandles(1), 'Position', pos);
    set(videoF, 'HandleVisibility', fHV);%TO112907C
catch
end

end

% ------------------------------------------------------------------
% --- Executes on button press in xSpacingEqualsYSpacing.
function xSpacingEqualsYSpacing_Callback(hObject, eventdata, handles)

if getLocal(progmanager, hObject, 'xSpacingEqualsYSpacing')
    setLocal(progmanager, hObject, 'ySpacing', getLocal(progmanager, hObject, 'xSpacing'));
    ySpacing_Callback(hObject, eventdata, handles);
end

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function isi_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function isi_Callback(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
% --- Executes on button press in videoCapture.
function videoCapture_Callback(hObject, eventdata, handles)
global state;

fireEvent(getUserFcnCBM, 'mapper:PreGrabVideo', xsg_getDirectory);%TO053106B

[f, im, xVideoScaleFactor, yVideoScaleFactor, imageCounter] = getLocalBatch(progmanager, hObject, 'videoFigure', 'videoImage', 'xVideoScaleFactor', 'yVideoScaleFactor', 'imageCounter');

if isempty(f) || ~ishandle(f)
    f = figure('Colormap', gray, 'Color', [1 1 1]);
end
set(f, 'HandleVisibility', 'On', 'Name', 'VideoImg');

% cdata = get(state.video.imageHandle, 'CData');%TEST
% fprintf(1, 'mapper/videoCapture_Callback: Generating random image values for testing.\n');
% cdata = rand(1024, 1024);
% xdata = 1:1024;
% ydata = xdata;
% movegui(f);
cdata = get(state.video.imageHandle, 'CData');
cdata = cdata(end:-1:1, :);%Flip the y-axis, so up is up and down is down. -- Tim O'Connor 2/16/06 TO021606A
xdata = get(state.video.imageHandle, 'XData');
ydata = get(state.video.imageHandle, 'YData');

xVideoScaleFactor = xVideoScaleFactor / xdata(2);
yVideoScaleFactor = yVideoScaleFactor / ydata(2);
% %HARDCODED STUFF HERE, FIX_ME
% %     totalX = 1900; % 4 oct 04
% %     totalY = 1520; % 4 oct 04
% xScaleFactor = 1900 / xdata(2);%um/pixel
% yScaleFactor = 1520 / ydata(2);%um/pixel

ax = get(f, 'Children');
if isempty(ax)
    ax = axes('Parent', f, 'DataAspectRatio', [1 1 1], 'XLim', [-0.5 0.5] * size(cdata, 2) * xVideoScaleFactor, 'YLim', [-0.5 0.5] * size(cdata, 1) * yVideoScaleFactor);
    im = imagesc('CData', cdata, 'XData', round([-0.5 0.5] * xdata(2) * xVideoScaleFactor), 'YData', round([-0.5 0.5] * ydata(2) * yVideoScaleFactor), 'Parent', ax, 'Tag', 'VideoImage');
else
    set(im, 'CData', cdata);
end

setLocalBatch(progmanager, hObject, 'videoFigure', f, 'videoImage', im);

try
    if xsg_getAutosave
        imageDir = xsg_getPath;
        if exist(fullfile(imageDir, 'images'), 'dir') ~= 7
            [success, message, messageID] = mkdir(imageDir, 'images');
            if ~success
                warning('mapper failed to create images subdirectory: %s - %s', messageID, message);
            end
            imageDir = fullfile(imageDir, 'images');
        else
            imageDir = fullfile(imageDir, 'images');
        end
        if getLocal(progmanager, xsg_getHandle, 'concatenateInitialsAndExpNum')
            imageFileName = fullfile(imageDir, ['videoImg_' xsg_getInitials xsg_getExperimentNumber '_' num2str(imageCounter) '.tif']);
        else
            imageFileName = fullfile(imageDir, ['videoImg_' xsg_getExperimentNumber '_' num2str(imageCounter) '.tif']);
        end

        cdata = double(cdata);%TO050806C - Make sure it's a double.
        imwrite(flipdim(cdata, 1) / max(max(cdata)), imageFileName, 'TIFF');
        setLocal(progmanager, hObject, 'imageCounter', imageCounter + 1);
        dirRoot = xsg_getDirectory;
        autonotes_addNote(strrep(['...' imageFileName(length(dirRoot)+1 : end)], '\', '\\'));%TO082907A - Insert a note upon saving data.
%         autonotes_addNote(['Mapper: Saved video image as ''' strrep(imageFileName, '\', '\\') '''']);%TO082907A - Add a note.
        fprintf(1, 'Mapper: Saved video image as ''%s''\n', imageFileName);
    end
catch
    warning('Failed to autosave video image to disk: %s', lasterr);
end

set(f, 'HandleVisibility', 'Off');

updateDisplay(hObject);

fireEvent(getUserFcnCBM, 'mapper:PostGrabVideo');%TO053106B

end

% ------------------------------------------------------------------
function updateDisplay(hObject)

try
    [f, im, beamCoordinates, displayCrosshairs, displayBeam, displayPattern, displaySomata, crosshairHandles, beamHandles, somataHandles, patternHandles, ...
            soma1Coordinates, soma2Coordinates, patternRotation] = ...
        getLocalBatch(progmanager, hObject, 'videoFigure', 'videoImage', 'beamCoordinates', 'displayCrosshairs', 'displayBeam', 'displayPattern', 'displaySomata', ...
        'crosshairHandles', 'beamHandles', 'somataHandles', 'patternHandles', 'soma1Coordinates', 'soma2Coordinates', 'patternRotation');

    if ~isempty(soma1Coordinates) && ~isempty(soma2Coordinates)
        interpipetteDistance = roundTo(sqrt(sum((soma1Coordinates - soma2Coordinates).^2)), 0);
    else
        interpipetteDistance = 0;
    end
    
    setLocalBatch(progmanager, hObject, 'xMirrorPos', beamCoordinates(1), 'yMirrorPos', beamCoordinates(2), 'interpipetteDistance', interpipetteDistance);
    
    if isempty(f)
        return;
    end
    
    %TO012408A - Make sure there's a valid video figure. -- Tim O'Connor 1/24/08
    if ~ishandle(f)
        return;
    end
    
    set(f, 'HandleVisibility', 'On');
    ax = get(f, 'Children');
    
    xdata = get(im, 'xdata');
    ydata = get(im, 'ydata');

    if all(ishandle(crosshairHandles))
        delete(crosshairHandles);
    end
    %TO021406A - Use zeros(size(xdata)) and zeros(size(ydata)) instead of [0 0], in case the size is different. -- Tim O'Connor 2/14/06
    crosshairHandles(1) = line(xdata, zeros(size(xdata)), 'Parent', ax, 'Tag', 'CrosshairX');
    crosshairHandles(2) = line(zeros(size(ydata)), ydata, 'Parent', ax, 'Tag', 'CrosshairY');

    if displayCrosshairs
        set(crosshairHandles, 'Visible', 'On');
    else
        set(crosshairHandles, 'Visible', 'Off');
    end

    if all(ishandle(beamHandles))
        delete(beamHandles);
    end

    radius = ceil(mean(xdata(2), ydata(2)) * 0.03);

    beamHandles(1) = rectangle('Position', [beamCoordinates(1, 1) - radius, beamCoordinates(1, 2) - radius, 2 * radius, 2 * radius], ...
        'Curvature', [1 1], 'EdgeColor', [1 0 0], 'Tag', 'Beam1', 'LineWidth', 2, 'Parent', getParent(im, 'axes'));

    if displayBeam
        set(beamHandles, 'Visible', 'On');
    else
        set(beamHandles, 'Visible', 'Off');
    end

    radius = ceil(mean(xdata(2), ydata(2)) * 0.05);
    if all(ishandle(somataHandles))
        delete(somataHandles);
    end
    if ~isempty(soma1Coordinates)
        somataHandles(1) = rectangle('Position', [soma1Coordinates(1) - radius, soma1Coordinates(2) - radius, 2 * radius, 2 * radius], 'Curvature', [1 1], ...
            'EdgeColor', [0 0 1], 'Tag', 'Soma1', 'LineWidth', 2);
    end
    if ~isempty(soma2Coordinates)
        somataHandles(2) = rectangle('Position', [soma2Coordinates(1) - radius, soma2Coordinates(2) - radius, 2 * radius, 2 * radius], 'Curvature', [1 1], ...
            'EdgeColor', [.1 .8 .1], 'Tag', 'Soma2', 'LineWidth', 2);
    end

    %TO112907J - Check for existence of the handles. -- Tim O'Connor 11/29/07
    if ~isempty(somataHandles) && all(ishandle(somataHandles))
        if displaySomata
            set(somataHandles, 'Visible', 'On');
        else
            set(somataHandles, 'Visible', 'Off');
        end
    end

    if all(ishandle(patternHandles))
        delete(patternHandles);
    end

    %TO060308A - Factored out the coordinate calculations into mapper_getCoordinates.m. -- Tim O'Connor 6/3/08
%     %TO031006C
%     pattern = loadMapPattern(hObject);
%     if isempty(pattern)
%         return;
%     end
%     
%     %TO042806E: Assorted mapper fixes. Pattern rotation must appear on the display.
%     switch patternRotation
%         case '0'
%             %Do nothing.
%         case '90'
%             pattern = rot90(pattern, 1);
%         case '180'
%             pattern = rot90(pattern, 2);
%         case '270'
%             pattern = rot90(pattern, 3);
%         otherwise
%             errordlg(sprintf('Invalid pattern rotation value: %s', patternRotation));
%             warning('Mapper - Invalid pattern rotation value: %s', patternRotation);
%     end
% 
%     %TO030205B %TO031006C
%     [xSpacing, ySpacing, xOffset, yOffset, spatialRotation] = getLocalBatch(progmanager, hObject,...
%         'xSpacing', 'ySpacing', 'xPatternOffset', 'yPatternOffset', 'spatialRotation');
%     
%     xorig = reshape(repmat((0 : size(pattern, 2) - 1) * xSpacing - 0.5 * (size(pattern, 2) - 1) * xSpacing, [size(pattern, 1) 1]), [prod(size(pattern)) 1]);
%     yorig = reshape(repmat((0 : size(pattern, 1) - 1) * ySpacing - 0.5 * (size(pattern, 1) - 1) * ySpacing, [1 size(pattern, 2)]), [prod(size(pattern)) 1]);
% 
%     %TO030206B - Implemented a spatial rotation and offset. Mix the signals accordingly. -- Tim O'Connor 3/2/06
%     xpoints = xorig * cos(pi / 180 * spatialRotation) + yorig * (-sin(pi / 180 * spatialRotation)) + xOffset;
%     ypoints = xorig * sin(pi / 180 * spatialRotation) + yorig * cos(pi / 180 * spatialRotation) + yOffset;
    [xpoints, ypoints] = mapper_getMapCoordinates(hObject);%TO060308A
    %ypoints = flipdim(ypoints, 1);
    
    patternHandles = line('XData', xpoints, 'YData', ypoints, 'Parent', ax, 'Tag', 'Pattern', 'LineStyle', 'None', 'Marker', '*', 'Color', [0 1 1]);
    if displayPattern
        set(patternHandles, 'Visible', 'On');
    else
        set(patternHandles, 'Visible', 'Off');
    end

    setLocalBatch(progmanager, hObject, 'crosshairHandles', crosshairHandles, 'beamHandles', beamHandles, ...
        'patternHandles', patternHandles, 'somataHandles', somataHandles);

    set(f, 'HandleVisibility', 'Off');
catch
    err = lasterror;
    warning('Error updating mapping display: %s\n%s', lasterr, getStackTraceString(err.stack));
    
    %TO012408A - Make sure there's a valid video figure. -- Tim O'Connor 1/24/08
    f = getLocal(progmanager, hObject, 'videoFigure');
    if ~isempty(f)
        if ishandle(f)
            set(f, 'HandleVisibility', 'Off');
        end
    end
end

end

% ------------------------------------------------------------------
%TO031006C: Factored out the loading of map patterns. -- Tim O'Connor 3/10/06
function pattern = loadMapPattern(hObject)

pattern = mapper_loadMapPattern(hObject);

end

% ------------------------------------------------------------------
% --- Executes on button press in displayCrosshairs.
function displayCrosshairs_Callback(hObject, eventdata, handles)

[f, crosshairHandles, displayCrosshairs] = getLocalBatch(progmanager, hObject, 'videoFigure', 'crosshairHandles', 'displayCrosshairs');
if isempty(crosshairHandles)
    return;
end

set(f, 'HandleVisibility', 'On');

if displayCrosshairs
    set(crosshairHandles, 'Visible', 'On');
else
    set(crosshairHandles, 'Visible', 'Off');
end

set(f, 'HandleVisibility', 'Off');

end

% ------------------------------------------------------------------
function soma1_Callback(hObject, eventdata, handles)

f = getLocal(progmanager, hObject, 'videoFigure');
set(f, 'HandleVisibility', 'On');

set(f, 'Pointer', 'crosshair');

[x, y] = getPointsFromAxes(get(f, 'Children'), 'numberOfPoints', 1);%TO031910D %TO042210A
x = round(x(1));
y = round(y(1));

set(f, 'Pointer', 'arrow');

set(f, 'HandleVisibility', 'Off');
setLocalBatch(progmanager, hObject, 'soma1Coordinates', [x(1) y(1)], 'soma1x', x(1), 'soma1y', y(1), 'displaySomata', 1);

updateDisplay(hObject);

end

% ------------------------------------------------------------------
function soma2_Callback(hObject, eventdata, handles)

f = getLocal(progmanager, hObject, 'videoFigure');
set(f, 'HandleVisibility', 'On');

set(f, 'Pointer', 'crosshair');

[x, y] = getPointsFromAxes(get(f, 'Children'), 'numberOfPoints', 1);%TO031910D %TO042210A
x = round(x(1));
y = round(y(1));

set(f, 'Pointer', 'arrow');

set(f, 'HandleVisibility', 'Off');
setLocalBatch(progmanager, hObject, 'soma2Coordinates', [x(1) y(1)], 'soma2x', x(1), 'soma2y', y(1), 'displaySomata', 1);

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function spatialRotation_CreateFcn(hObject, eventdata, handles)
    if ispc
        set(hObject,'BackgroundColor','white');
    else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end
end

% ------------------------------------------------------------------
function spatialRotation_Callback(hObject, eventdata, handles)

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yPatternOffset_CreateFcn(hObject, eventdata, handles)
    if ispc
        set(hObject,'BackgroundColor','white');
    else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end
end

% ------------------------------------------------------------------
function yPatternOffset_Callback(hObject, eventdata, handles)

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xPatternOffset_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function xPatternOffset_Callback(hObject, eventdata, handles)

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function edit22_Callback(hObject, eventdata, handles)
end

% ------------------------------------------------------------------
% --- Executes on button press in patternFlip.
function patternFlip_Callback(hObject, eventdata, handles)
end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function patternRotation_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end

% ------------------------------------------------------------------
function patternRotation_Callback(hObject, eventdata, handles)

updateDisplay(hObject);

end

% ------------------------------------------------------------------
% --- Executes on button press in calibratePockels.
%TO021510E - Make the Pockels cell optional and the voltage range configurable.
function calibratePockels_Callback(hObject, eventdata, handles)

job = daqjob('acquisition');

%%VI102608A: Force use of the 'first' external trigger in the 'acquisition' daqJob
%pockelsTrigger = getTaskProperty(job, 'pockelsCell', 'triggerSource');
%photodiodeTrigger = getTaskProperty(job, 'photodiode1', 'triggerSource');
trigDests = getTriggerDestinations(job);
[pockelsTrigger, photodiodeTrigger] = deal(trigDests{1});
%%%%%%%%%%%%%%%

%TO080108E - Digital lines require a sample clock, borrow it from the @daqjob, for now. -- Tim O'Connor 8/1/08
masterSampleClock = getMasterSampleClock(daqjob('acquisition'));
clockDestination = getSampleClockDestination(daqjob('acquisition'));

%TO080108E - We need a try catch here to ensure we stop the sample clock.
try
    if isempty(masterSampleClock)
        %TO033108A - Get the trigger origin from the daqjob, instead of hardcoding '/dev1/port0/line0' here.
        coeffs = getPockelsCalibrationFit(getDeviceNameByChannelName(job, 'pockelsCell'), getDeviceNameByChannelName(job, 'photodiode1'), ...
            getTriggerOrigin(daqjob('acquisition')), pockelsTrigger, photodiodeTrigger, getDeviceNameByChannelName(job, 'shutter0'), ...
            getLocal(progmanager, hObject, 'modulatorMin'), getLocal(progmanager, hObject, 'modulatorMax')); 
    else
        %TO080108E
%         coeffs = getPockelsCalibrationFit(getDeviceNameByChannelName(job, 'pockelsCell'), getDeviceNameByChannelName(job, 'photodiode1'), ...
%             getTriggerOrigin(daqjob('acquisition')), pockelsTrigger, photodiodeTrigger, getDeviceNameByChannelName(job, 'shutter0'), ...
%             getLocal(progmanager, hObject, 'modulatorMin'), getLocal(progmanager, hObject, 'modulatorMax'), masterSampleClock, clockDestination);
        %%%VI102608A%%%%%%%%%%
        coeffs = getPockelsCalibrationFit(getDeviceNameByChannelName(job, 'pockelsCell'), getDeviceNameByChannelName(job, 'photodiode1'), ...
            getTriggerOrigin(daqjob('acquisition')), pockelsTrigger, photodiodeTrigger, getDeviceNameByChannelName(job, 'shutter0'), ...
            getLocal(progmanager, hObject, 'modulatorMin'), getLocal(progmanager, hObject, 'modulatorMax'), daqjob('acquisition'));
        %%%%%%%%%%%%%%%%%%%%%%%%
    end
catch
    coeffs = [];
    fprintf(2, 'mapper - Error calibrating Pockels cell:\n%s\n', getLastErrorStack);
end

%TO080108E
%TO102508G - Make sure the sample clock exists before trying to stop it (didn't I fix this before?). -- Tim O'COnnor 10/25/08
if ~isempty(masterSampleClock)
    nimex_stopTask(masterSampleClock);
end

setLocal(progmanager, hObject, 'coeffs', coeffs);

%TO111908C - Set the Pockels to minimum power after calibration.
putSample(daqjob('acquisition'), 'pockelsCell', mapper_pockelsCellPreprocessor(hObject, 0));

end

% ------------------------------------------------------------------
function acquisitionDone_Callback(hObject, varargin)

[mouse, map] = getLocalBatch(progmanager, hObject, 'mouse', 'map');

if mouse || map
% fprintf(1, '%s - mapper/acquisitionCompleted_Callback - Restoring pulseMap\n', datestr(now));
    % stop(daqjob('acquisition'), 'xMirror', 'yMirror');
    setPropertyForAllTasks(daqjob('acquisition'), 'forceFullBuffering', 0);%TO102407A
    restoreMap(pulseMap('acquisition'));%TO102207A
end

end

% ------------------------------------------------------------------
%TO031306A, TO040706F
function acquisitionCompleted_Callback(hObject, varargin)
% fprintf(1, '%s - mapper/acquisitionCompleted_Callback\n', datestr(now));

[map, mouse, flash, positionNumber, mapPatternArray, mapNumber] = getLocalBatch(progmanager, hObject, ...
    'map', 'mouse', 'flashing', 'positionNumber', 'mapPatternArray', 'mapNumber');

if ~(map || mouse || flash)
% fprintf(1, '%s - mapper/acquisitionCompleted_Callback - Quitting immediately, mapper not in use.\n', datestr(now));
    return;
end

if map && ~get(loopManager, 'preciseTimeMode')
% fprintf(1, '%s - mapper/acquisitionCompleted_Callback - Updating position number from %s...\n', datestr(now), num2str(positionNumber));
    positionNumber = positionNumber + 1;
    setLocal(progmanager, hObject, 'positionNumber', positionNumber);
    if positionNumber <= numel(mapPatternArray)
        return;
    else
        setLocalBatch(progmanager, hObject, 'positionNumber', 1, 'mapNumber', mapNumber + 1);
    end
end

%TO111908A: Backed out TO042806F. Doing this on the AcquisitionCompleted event resulted in always working with the previous (stale) trace data. -- Tim O'Connor 11/19/08
%TO042806F: "Hardcode" the laser power measurement into the mapper, so it's not necessary as a configured user function. -- Tim O'Connor 4/28/06
try
% fprintf(1, '%s - mapper/acquisitionCompleted_Callback - Calculating laser power.\n', datestr(now));
%     mapper_userFcn_laserPowerCalculation;
catch
    warning('Failed to execute ''mapper_userFcn_laserPowerCalculation'': %s\n', getLastErrorStack);
end

% fprintf(1, '%s - mapper/mirrorStopFcn_Callback\n', datestr(now));

% removeChannelStopListener(getDaqmanager, 'xMirror', 'mapper_xMirror_Stop');
% removeChannelStopListener(getDaqmanager, 'yMirror', 'mapper_yMirror_Stop');

try
    %%TO042806D: Only make one call to xsg_getAutosave and cache the value. -- Tim O'Connor 4/28/06
    autosave = xsg_getAutosave;
    if map && autosave
        xsg_incrementSetID;
        setLocal(progmanager, hObject, 'mapNumber', getLocal(progmanager, hObject, 'mapNumber') + 1);
    elseif flash && autosave
        setLocal(progmanager, hObject, 'flashNumber', getLocal(progmanager, hObject, 'flashNumber') + 1);
    elseif mouse && autosave
        setLocal(progmanager, hObject, 'flashNumber', getLocal(progmanager, hObject, 'flashNumber') + 1);%TO042106C
    end
catch
    warning('Mapper: Failed to update counter(s) - %s', lasterr);
end

if mouse || map
% fprintf(1, '%s - mapper/acquisitionCompleted_Callback - Restoring pulseMap\n', datestr(now));
    % stop(daqjob('acquisition'), 'xMirror', 'yMirror');
    setPropertyForAllTasks(daqjob('acquisition'), 'forceFullBuffering', 0);%TO102407A
    restoreMap(pulseMap('acquisition'));%TO102207A
    %TO060308C - If the pulseJacker was on, we broke it, so turn it off now.
    if isprogram(progmanager, 'pulseJacker')
        pj = getGlobal(progmanager, 'hObject', 'pulseJacker', 'pulseJacker');
        if getLocal(progmanager, pj, 'enable')
            pulseJacker('enable_Callback', pj, [], pj);
        end
    end
end

try
    % %TO041006A: This will get taken care of in the mouse callback.
    % if ~(mouse && ~get(loopManager, 'preciseTimeMode'))
    %     mapper_restoreConfigs(hObject);
    % end
% fprintf(1, '%s - mapper/acquisitionCompleted_Callback - Restoring configurations...\n', datestr(now));
    mapper_restoreConfigs(hObject);
catch
    warning('Mapper: Failed to restore configurations - %s', lasterr);
end

% %TO113007D - The stimulator resets all channels to 0V. Make sure the mouse leaves the mirrors parked at the last mouse position.
% if mouse
%     try
%         [xOffset, xAmplitude, xGain, yOffset, yAmplitude, yGain, xInvert, yInvert, mousePoints] = getLocalBatch(progmanager, hObject, ...
%             'temp_xOffset', 'temp_xAmplitude', 'temp_xGain', 'temp_yOffset', 'temp_yAmplitude', 'temp_yGain', 'temp_xInvert', 'temp_yInvert', 'mousePoints');
%         x = mousePoints(end, 1);
%         y = mousePoints(end, 2);
%         if ~xInvert
%             xSign = +1;
%         else
%             xSign = -1;
%         end
%         if ~yInvert
%             ySign = +1;
%         else
%             ySign = -1;
%         end
%         xMirrorVoltage = xSign * (xOffset + x * xGain);
%         yMirrorVoltage = ySign * (yOffset + y * yGain);
%         putSample(daqjob('acquisition'), 'xMirror', xMirrorVoltage);
%         putSample(daqjob('acquisition'), 'yMirror', yMirrorVoltage);
%     catch
%         fprintf(2, '%s - Mapper Warning: Failed to park mirrors at final mouse position.\n%s', datestr(now), getLastErrorStack);
%     end
% end
%TO012909A - Fixed the mouse feature, so it relies on the mapper_mirrorChannelPreprocessor and mapper_coordinates2Voltages functions. -- Tim O'Connor 1/29/09
try
    [mousePoints] = getLocalBatch(progmanager, hObject, 'mousePoints');
    if ~isempty(mousePoints)
        putSample(daqjob('acquisition'), 'xMirror', mapper_coordinates2Voltages(hObject, 'X', mousePoints(end, 1)));
        putSample(daqjob('acquisition'), 'yMirror', mapper_coordinates2Voltages(hObject, 'Y', mousePoints(end, 2)));
    end
catch
    fprintf(2, '%s - Mapper Warning: Failed to park mirrors at final mouse position.\n%s', datestr(now), getLastErrorStack);
end

setLocalBatch(progmanager, hObject, 'map', 0, 'mouse', 0, 'flashing', 0);%TO112008C - Removed 'flash' being set to 0, this was a typo and shouldn't have existed. -- Tim O'Connor 11/20/08

setLocalGh(progmanager, hObject, 'map', 'String', 'Map', 'ForegroundColor', [0 .6 0]);
setLocalGh(progmanager, hObject, 'mouse', 'String', 'Mouse', 'ForegroundColor', [0 .6 0]);

% fprintf(1, '%s - mapper/acquisitionCompleted_Callback - Firing appropriate stop event...\n', datestr(now));
if map
    fireEvent(getUserFcnCBM, 'mapper:MapStop');%TO030706D: Add userFcn events for the mapper. -- Tim O'Connor 3/7/06
elseif mouse
    fireEvent(getUserFcnCBM, 'mapper:MouseStop');
elseif flash
    %TO042106B - Added event execution here. -- Tim O'Connor 4/21/06
    fireEvent(getUserFcnCBM, 'mapper:FlashStop');%TO030706D: Add userFcn events for the mapper. -- Tim O'Connor 3/7/06
end

%TO082907E - Don't zero mirrors anymore, as per Gordon's preference. -- Tim O'Connor 8/29/07
% zeroMirrors_Callback(hObject, [], []);%TO110906B - Make sure mirrors are properly zeroed. -- Tim O'Connor 11/9/06

end

% ------------------------------------------------------------------
%TO053108B - Allow the mapper to work without the usual 'Big 3' programs. -- Tim O'Connor 5/31/08
function turboMode(hObject)

try
    lm = loopManager;
    
    %TO012909A - A lot of these variables were vestigial (used for calculating mirror voltages. -- Tim O'Connor 1/29/09
    %TO091506B - Use the same sample rate for the mirrors as for everything else. -- Tim O'Connor 9/15/06
    % [xInvert, xAxisOffset, xGain, yInvert, yAxisOffset, yGain, sampleRate, mapperMiniScanSettings, isi, mapPatternArray, mapButton, mouse, mousePoints] = getLocalBatch(progmanager, hObject, ...
    %   'temp_xInvert', 'temp_xOffset', 'temp_xGain', 'temp_yInvert', 'temp_yOffset', 'temp_yGain', 'sampleRate', 'mapperMiniScanSettings', 'isi', 'mapPatternArray', 'map', 'mouse', 'mousePoints');
    [sampleRate, mapperMiniScanSettings, isi, mapPatternArray, mapButton, mouse, mousePoints] = getLocalBatch(progmanager, hObject, ...
        'sampleRate', 'mapperMiniScanSettings', 'isi', 'mapPatternArray', 'map', 'mouse', 'mousePoints');

    %Implement duration. -- Tim O'Connor 1/26/06
    %TO020206A - Duration has been abandonded (let individual programs determine it for themselves). -- Tim O'Connor 2/2/06
    %TO091506B - Removed a multiplicative factor of 100 with the sampleRate. -- Tim O'Connor 9/15/06
    %TO052610A - Force the update rate to be 1/isi, to get a samplesAcquired event per pixel. -- Tim O'Connor 5/26/10
    if isprogram(progmanager, 'acquirer')
        acq = getGlobal(progmanager, 'hObject', 'acquirer', 'acquirer');
        %acqChannels = getLocal(progmanager, acq, 'channels');%TO053108 - Looks like this one's never used either.
        setLocalBatch(progmanager, acq, 'sampleRate', sampleRate, 'selfTrigger', 0, 'externalTrigger', 1, 'autoUpdateRate', 0, 'updateRate', 1 / isi);%TO091506B %TO052610A
        if ~getLocal(progmanager, acq, 'startButton')
            acquirer('externalTrigger_Callback', acq, [], acq);
        end
    end
    
    if isprogram(progmanager, 'stimulator')
        stim = getGlobal(progmanager, 'hObject', 'stimulator', 'stimulator');
% fprintf(1, 'mapper/turboMode: Disabling mirror control in stimulator.\n');
        %TO091506A - Turn off mirror channels in stimulator, if they exist. -- Tim O'Connor 9/15/06
        %TO102207A - Now, under nimex, we want these on. -- Tim O'Connor 10/22/07
        %TO102307C - Now we want these off, and we'll start them ourselves. -- Tim O'Connor 10/23/07
        [stimChannels, stimStimOnArray] = getLocalBatch(progmanager, stim, 'channels', 'stimOnArray');%TO091506A
        for i = 1 : length(stimChannels)
            if strcmpi(stimChannels(i).channelName, 'xMirror') || strcmpi(stimChannels(i).channelName, 'yMirror')
                stimStimOnArray(i) = 1;
            else
                %stimStimOnArray(i) = 1;%TO111706C: Leave channels off if they are turned off in the gui. -- Tim O'Connor 11/17/06
            end
        end
        setLocalBatch(progmanager, stim, 'sampleRate', sampleRate, 'selfTrigger', 0, 'externalTrigger', 1, 'stimOnArray', stimStimOnArray);%TO020206A %TO091506B
        if ~getLocal(progmanager, stim, 'startButton')
            stimulator('externalTrigger_Callback', stim, [], stim);
        end
    end

    if isprogram(progmanager, 'ephys')
        ephysObj = getGlobal(progmanager, 'hObject', 'ephys', 'ephys');
        %TO053108B - Looks like this wasn't being used.
        %ephysStimAcqOnArray = getLocal(progmanager, ephys, 'stimOnArray');%TO031306D
        %ephysStimAcqOnArray(:) = 1;
        setLocalBatch(progmanager, ephysObj, 'sampleRate', sampleRate, 'selfTrigger', 0, 'externalTrigger', 1, 'autoUpdateRate', 0, 'updateRate', 1 / isi);%TO020206A %TO031306D %TO091506B %TO052610A
        if ~getLocal(progmanager, ephysObj, 'startButton')
            ephys('externalTrigger_Callback', ephysObj, [], ephysObj);
        end
    end

    pm = pulseMap('acquisition');
    map = getMap(pm);
    setXMirror = 0;
    setYMirror = 0;
    for i = 1 : size(map, 1)
        if strcmpi(map{i, 1}, 'xMirror')
            map{i, 2} = {@mapper_xMirrorDataSource, hObject};
            setXMirror = 1;
        elseif strcmpi(map{i, 1}, 'yMirror')
            map{i, 2} = {@mapper_yMirrorDataSource, hObject};
            setYMirror = 1;
        else
            %TO060308C - Allow the mapper to work with the pulseJacker, don't clobber callbacks.
            if ~strcmpi(class(map{i, 2}), 'signalobject')
                map{i, 2} = {@mapper_dataReplicator, hObject, map{i, 1}, map{i, 2}};
            end
        end
    end
    if ~setXMirror
        map{size(map, 1) + 1, 1} = 'xMirror';
        map{size(map, 1), 2} = {@mapper_xMirrorDataSource, hObject};
    end
    if ~setYMirror
        map{size(map, 1) + 1, 1} = 'yMirror';
        map{size(map, 1), 2} = {@mapper_yMirrorDataSource, hObject};
    end
    setMap(pm, map);
    lockPulse(pm, 'xMirror');
    lockPulse(pm, 'yMirror');
    setPropertyForAllTasks(daqjob('acquisition'), 'forceFullBuffering', 1);%TO102407A
%     if mouse
%         setPropertyForAllTasks(daqjob('acquisition'), 'repeatOutput', 0);
%     end
%     start(daqjob('acquisition'), 'xMirror', 'yMirror');%TO102307C
%     %TO052207A - Allow perturbation of the mirrors at each position in the map.
%     if ~isempty(mapperMiniScanSettings)
%         if mapperMiniScanSettings.enable
%             %TO052407A - First use debugging, stupid errors about printing incorrect values and test code. -- Tim O'Connor 5/24/07
%             try
%                 modulation = signalobject('sampleRate', sampleRate);
%                 fprintf(1, '%s - mapper: mapperMiniScan enabled. Introducing %s micron (%s X [V], %s Y [V]) oscillation at %s Hz.\n', datestr(now), ...
%                     num2str(mapperMiniScanSettings.wobbleAmplitude), num2str(mapperMiniScanSettings.wobbleAmplitude * xGain), ...
%                     num2str(mapperMiniScanSettings.wobbleAmplitude * yGain), num2str(mapperMiniScanSettings.wobbleFrequency));%TO052407A
%                 sin(modulation, mapperMiniScanSettings.wobbleAmplitude * xGain, 0, mapperMiniScanSettings.wobbleFrequency, 0);
%                 xMirrorSignal = xMirrorSignal + getdata(getdata(modulation, length(xMirrorSignal) / sampleRate));%TO052407A
% % figure, plot(xMirrorSignal + getdata(modulation, length(xMirrorSignal) / sampleRate));
%             cos(modulation, mapperMiniScanSettings.wobbleAmplitude * xGain, 0, mapperMiniScanSettings.wobbleFrequency, 0);
%                 yMirrorSignal = yMirrorSignal + getdata(getdata(modulation, length(yMirrorSignal) / sampleRate));%TO052407A
% % figure, plot(yMirrorSignal + getdata(modulation, length(yMirrorSignal) / sampleRate));
%                 delete(modulation);
%             catch
%                 fprintf(2, '%s - mapper: Failed to implement miniScan - %s\n', datestr(now), lasterr);
%             end
%         end
%     end
% fprintf(1, 'mapper/turboMode: Setting mirror data...\n');
    if isi ~= get(lm, 'interval')
        warndlg('mapper: precise loop interval does not match mapper ISI, adjusting interval');
        set(lm, 'interval', isi);
    end
    if mapButton
        set(lm, 'iterations', numel(mapPatternArray));
    elseif mouse
        set(lm, 'iterations', numel(mousePoints) / 2);
    end
    
    %VI061208A -- For now, /force/ the looper to use DAQ board timing, as CPU timing doesn't work at the moment
    %TO072208B - If we force something, we should always let the user know. Also, I'm not sure why CPU timing isn't working... -- Tim O'Connor 7/22/08
    if ~get(lm, 'preciseTimeMode')
        fprintf(1, 'Warning - The mapper "prefers" loops to use precise (ie. board clock) timing, so it''s being forced (See VI061208A & TO072208B).\n');
        set(lm, 'preciseTimeMode', 1);
    end
    
    %TO060910A - Why are we forcing this? I see no reason to do this, it actually prevents us from setting up for a map, then letting it get triggered externally. -- Tim O'Connor 6/9/10
    %%VI102608A -- Force the acquisition @daqjob to use the 'first' external trigger
    %if get(daqjob('acquisition'),'triggerDestinationIndex') ~= 1
    %    fprintf(1, 'Warning - The mapper presently requires that the ''first'' external trigger line be used, so this is being forced');
    %    trigDests = getTriggerDestinations(daqjob('acquisition'));
    %    setTriggerDestination(daqjob('acquisition'),trigDests{1});
    %end   
    %%%%%%%%%%%%%%%%%

    start(lm);
% getTaskByChannelName(daqjob('acquisition'), 'shutter0')
catch
    warning('An error occurred while doing a map/mouse acquisition in turbo mode: %s', lasterr);
end

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function flashNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
function flashNumber_Callback(hObject, eventdata, handles)

end

% ------------------------------------------------------------------
% --- Executes on button press in newCell.
function newCell_Callback(hObject, eventdata, handles)

setLocalBatch(progmanager, hObject, 'mapNumber', 1, 'flashNumber', 1, 'imageCounter', 1);
xsg_incrementExperimentNumber;
setLocalBatch(progmanager, xsg_getHandle, 'setID', 'AAAA', 'acquisitionNumber', '0001');
% try
%     videoCapture_Callback(hObject, eventdata, handles);
% catch
%     warning('Failed to update video image for new cell: %s', lasterr);
% end

end

% ------------------------------------------------------------------
% --- Executes on button press in remouse.
%TO042806C: Implement remouse functionality. -- Tim O'Connor 4/28/06
function remouse_Callback(hObject, eventdata, handles)

setLocal(progmanager, hObject, 'mouse', 1);
executeMousePattern(hObject);

end

% ------------------------------------------------------------------
%TO091406B
% --- Executes on button press in exportMousePositions.
function exportMousePositions_Callback(hObject, eventdata, handles)

[mousePoints] = getLocalBatch(progmanager, hObject, 'mousePoints');
if isempty(mousePoints)
    return;
end

directory = uigetdir(getDefaultCacheDirectory(progmanager, 'pulseDir'), 'Choose a subdirectory in which to store pulses.');
if length(directory) == 1
    if directory == 0
        return;
    end
end
if exist(fullfile(directory, 'mousePositions')) ~= 7
    mkdir(directory, 'mousePositions');
    directory = fullfile(directory, 'mousePositions');
else
    directory = fullfile(directory, 'mousePositions');
end

for i = 1 : size(mousePoints, 1)
    signal = signalobject;
    squarePulseTrain(signal, mousePoints(i, 1), 0, 0, 100000, 0, 1);
    set(signal, 'Name', ['mousePosition-' num2str(i) 'X']);
    saveCompatible(fullfile(directory, [get(signal, 'Name') '.signal']), 'signal', '-mat');
    delete(signal);
    signal = signalobject;
    squarePulseTrain(signal, mousePoints(i, 2), 0, 0, 100000, 0, 1);
    set(signal, 'Name', ['mousePosition-' num2str(i) 'Y']);
    saveCompatible(fullfile(directory, [get(signal, 'Name') '.signal']), 'signal', '-mat');
    delete(signal);
end

fprintf(1, '%s - Exported %s mouse positions to ''%s''\n', datestr(now), num2str(size(mousePoints, 1)), directory);

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xPatternOffsetSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
%TO110906B
% --- Executes on slider movement.
function xPatternOffsetSlider_Callback(hObject, eventdata, handles)

[slider, xPatternOffset] = getLocalBatch(progmanager, hObject, 'xPatternOffsetSlider', 'xPatternOffset');
if slider > 0.5
    setLocalBatch(progmanager, hObject, 'xPatternOffsetSlider', 0.5, 'xPatternOffset', xPatternOffset + 5);
    xPatternOffset_Callback(hObject, eventdata, handles);
else
    setLocalBatch(progmanager, hObject, 'xPatternOffsetSlider', 0.5, 'xPatternOffset', xPatternOffset - 5);
    xPatternOffset_Callback(hObject, eventdata, handles);
end

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function yPatternOffsetSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
%TO110906B
% --- Executes on slider movement.
function yPatternOffsetSlider_Callback(hObject, eventdata, handles)

[slider, yPatternOffset] = getLocalBatch(progmanager, hObject, 'yPatternOffsetSlider', 'yPatternOffset');
if slider > 0.5
    setLocalBatch(progmanager, hObject, 'yPatternOffsetSlider', 0.5, 'yPatternOffset', yPatternOffset + 5);
    yPatternOffset_Callback(hObject, eventdata, handles);
else
    setLocalBatch(progmanager, hObject, 'yPatternOffsetSlider', 0.5, 'yPatternOffset', yPatternOffset - 5);
    yPatternOffset_Callback(hObject, eventdata, handles);
end

end

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function spatialRotationSlider_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end

% ------------------------------------------------------------------
%TO110906B
% --- Executes on slider movement.
function spatialRotationSlider_Callback(hObject, eventdata, handles)

[slider, spatialRotation] = getLocalBatch(progmanager, hObject, 'spatialRotationSlider', 'spatialRotation');
if slider > 0.5
    setLocalBatch(progmanager, hObject, 'spatialRotationSlider', 0.5, 'spatialRotation', spatialRotation + 1);
    spatialRotation_Callback(hObject, eventdata, handles);
else
    setLocalBatch(progmanager, hObject, 'spatialRotationSlider', 0.5, 'spatialRotation', spatialRotation - 1);
    spatialRotation_Callback(hObject, eventdata, handles);
end

end

% ------------------------------------------------------------------
%TO082907E - Allow soma position to be exported to the pattern offset.
% --- Executes on button press in useSoma1AsOffset.
function useSoma1AsOffset_Callback(hObject, eventdata, handles)

[somaX, somaY] = getLocalBatch(progmanager, hObject, 'soma1x', 'soma1y');
setLocalBatch(progmanager, hObject, 'xPatternOffset', somaX, 'yPatternOffset', somaY);
updateDisplay(hObject);

end

% ------------------------------------------------------------------
%TO082907E - Allow soma position to be exported to the pattern offset.
% --- Executes on button press in useSoma2AsOffset.
function useSoma2AsOffset_Callback(hObject, eventdata, handles)

[somaX, somaY] = getLocalBatch(progmanager, hObject, 'soma2x', 'soma2y');
setLocalBatch(progmanager, hObject, 'xPatternOffset', somaX, 'yPatternOffset', somaY);
updateDisplay(hObject);

end

% ------------------------------------------------------------------
function data = mapper_xMirrorDataSource(hObject, varargin)

[map, mouse, flash, xMirrorCoordinates, xMirrorVoltages, positionNumber, sampleRate] = getLocalBatch(progmanager, hObject, ...
    'map', 'mouse', 'flashing', 'xMirrorCoordinates', 'xMirrorVoltages', 'positionNumber', 'sampleRate');

if ~(map || mouse)
    fprintf(2, 'mapper: Error - xMirror data requested when not in map or mouse state.\n%s', getStackTraceString);
    return;
end

%TO012909A - Mouse now produces coordinates, not voltages, and they will get preprocessed like normal. -- Tim O'Connor 1/29/09
if map
    data = xMirrorVoltages;
elseif mouse
    data = xMirrorCoordinates;
end
% fprintf(1, '\n\nmapper_xMirrorDataSource: size(data) = %s\n\n', mat2str(size(data)));
% setTaskProperty(daqjob('acquisition'), 'xMirror', 'sampsPerChanToAcquire', length(xMirrorVoltages), 'repeatOutput', 0);

% if length(varargin) == 1
%     samples = ceil(sampleRate * varargin{1});
% else
%     samples = varargin{1};
% end
% 
% % data = xMirrorVoltages(positionNumber * samples : positionNumber * samples + samples);
% figure, plot(xMirrorVoltages, ':o')
% xMirrorVoltages(:) = -5;
% getTaskByChannelName(daqjob('acquisition'), 'shutter0')
% getTaskByChannelName(daqjob('acquisition'), 'xMirror')
% fprintf(1, '\n----------------------\n\n');

end

% ------------------------------------------------------------------
function data = mapper_yMirrorDataSource(hObject, varargin)

[map, mouse, flash, yMirrorCoordinates, yMirrorVoltages, positionNumber, sampleRate] = getLocalBatch(progmanager, hObject, ...
    'map', 'mouse', 'flashing', 'yMirrorCoordinates', 'yMirrorVoltages', 'positionNumber', 'sampleRate');

if ~(map || mouse)
    fprintf(2, 'mapper: Error - yMirror data requested when not in map or mouse state.\n%s', getStackTraceString);
    return;
end

%TO012909A - Mouse now produces coordinates, not voltages, and they will get preprocessed like normal. -- Tim O'Connor 1/29/09
if map
    data = yMirrorVoltages;
elseif mouse
    data = yMirrorCoordinates;
end

% figure, plot(yMirrorVoltages, ':o'), title('Y-Mirror')

% if length(varargin) == 1
%     samples = ceil(sampleRate * varargin{1});
% else
%     samples = varargin{1};
% end
% 
% % data = yMirrorVoltages(positionNumber * samples : positionNumber * samples + samples);

end

% ------------------------------------------------------------------
function mapper_loopListener(hObject, loopEventData)
% fprintf(1, '%s - mapper_loopListener\n', datestr(now));

[map, mouse, sampleRate, xMirrorVoltages, xMirrorCoordinates, isi, sampleRate] = getLocalBatch(progmanager, hObject, ...
    'map', 'mouse', 'sampleRate', 'xMirrorVoltages', 'xMirrorCoordinates', 'isi', 'sampleRate');
if ~(map || mouse)
    return;
end

%TO031309B - We were previously using `length(xMirrorVoltages)`, which doesn't take into account the samples when doing a mouse, thus causing problems if xMirrorVoltages is empty (no map has been done, yet).
if map
    sampsPerChanToAcquire = length(xMirrorVoltages);
else
    sampsPerChanToAcquire = length(xMirrorCoordinates);
end

job = daqjob('acquisition');

if strcmpi(loopEventData.eventType, 'loopstartprecisetiming')
    setTaskProperty(job, 'xMirror', 'sampsPerChanToAcquire', sampsPerChanToAcquire, 'repeatOutput', 0, 'autoRestart', 0, ...
        'everyNSamples', isi * sampleRate);
    setTaskProperty(job, 'yMirror', 'sampsPerChanToAcquire', sampsPerChanToAcquire, 'repeatOutput', 0, 'autoRestart', 0, ...
        'everyNSamples', isi * sampleRate);
end
% getTaskByChannelName(job, 'xMirror')

% % stop(job, 'xMirror', 'yMirror');
% start(job, 'xMirror', 'yMirror');

end

% ------------------------------------------------------------------
function data = mapper_dataReplicator(hObject, channelName, callback, varargin)
    % fprintf(1, '%s - mapper_dataReplicator: ''%s''\n', datestr(now), channelName);

    [sampleRate, mapPatternArray, isi, map, mouse, mousePoints] = getLocalBatch(progmanager, hObject, 'sampleRate', 'mapPatternArray', 'isi', 'map', 'mouse', 'mousePoints');

    %TO121707B - Mouse must replicate out its data (properly). -- Tim O'Connor 12/17/07
    if map
        iterations = numel(mapPatternArray);
    elseif mouse
        %TO012408B - Make sure iterations is valid for use with repmat (see also TO012208A). As per Mac Hooks' recurring errors. -- Tim O'Connor 1/24/08
        if ~any(size(mousePoints) == 2)
            fprintf(2, 'mapper_dataReplicator: Number of coordinates for mousePoints is not a multiple of 2 (2 coordinates per point).\n\tsize(mousePoints) = %s\n\tmousePoints = %s\n%s\n', mat2str(size(mousePoints)), mat2str(mousePoints), getStackTraceString);
        end
        iterations = numel(mousePoints) / 2;%TO012208A - Added numel(...) instead of directly using mousePoints. - Tim O'Connor 1/22/08
    else
        fprintf(2, 'mapper_dataReplicator: Indeterminate mode (map or mouse), number of iterations unknown...\n');
        iterations = 0;
    end
    if strcmpi(class(callback), 'signalobject')
        data = getdata(callback, varargin{:});
    else
        data = feval(callback{:}, varargin{:});
    end

    %TO012408B - Make sure iterations is valid for use with repmat (see also TO012208A). As per Mac Hooks' recurring errors. -- Tim O'Connor 1/24/08
    sz = size(iterations);
    if length(sz) ~= 2
        fprintf(2, 'mapper_dataReplicator: Indeterminate number of iterations (should be a scalar integer value) - iterations: %s\n%s', mat2str(iterations), getStackTraceString);
    elseif ~any(sz == 1)
        fprintf(2, 'mapper_dataReplicator: Indeterminate number of iterations (should be a scalar integer value) - iterations: %s\n%s', mat2str(iterations), getStackTraceString);
    elseif sz(2) > sz(1)
        fprintf(2, 'mapper_dataReplicator: Indeterminate number of iterations (should be a scalar integer value) - iterations: %s\n\tReshaping into a row vector...\n%s', mat2str(iterations), getStackTraceString);
        iterations = iterations';
    end

    % fprintf(1, '%s - mapper_dataReplicator: Retrieved %s samples from original source.\n', datestr(now), num2str(numel(data)));
    if length(data) < ceil(sampleRate * iterations * isi)
        data = repmat(data, iterations, 1);
    end
    % fprintf(1, '%s - mapper_dataReplicator: Returning %s samples.\n', datestr(now), num2str(numel(data)));
end


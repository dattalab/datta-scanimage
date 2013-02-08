function ephus(infile)

%% LOAD INITIALIZATION FILE
if nargin < 1 || isempty(infile)
    %TO060710A - Use the @progmanager defaultCache functions to make this smoother and more helpful. -- Tim O'Connor 6/7/10
    startDir = getDefaultCacheDirectory(progmanager, 'lastEphusStartupDir');
    f = getDefaultCacheValue(progmanager, 'lastEphusStartupFile');

    if exist(fullfile(startDir, f), 'file') == 2
        startDir = fullfile(startDir, f);
    else
        startDir = fullfile(startDir, '*.m');
    end

    [f, lastDirectory] = uigetfile('*.m', 'Select Ephus initialization file', startDir);
    if ~f %Startup cancelled
        return;
    end
    initFile = fullfile(lastDirectory, f);
    try
        if isempty(which(initFile))
            addpath(lastDirectory);
            [p, initFileName] = fileparts(initFile);
            eval(initFileName);
            rmpath(lastDirectory);
        else
            [p, initFileName] = fileparts(initFile);
            eval(initFileName)
        end
        setDefaultCacheValue(progmanager, 'lastEphusStartupDir', lastDirectory);
        setDefaultCacheValue(progmanager, 'lastEphusStartupFile', f);
    catch
        error('Specified initialization file is invalid or corrupted. Cannot start Ephus.');
    end
else
    try
        currDir = cd();
        [initFilePath, initFileName] = fileparts(infile);
        if exist(initFilePath, 'dir') == 7 %TO032310B
            cd(initFilePath);
        end
        eval(initFileName);
        cd(currDir);
    catch
        error('Specified initialization file is invalid or corrupted. Cannot start Ephus.');
    end
end

%% CLEAR LINGERING SINGLETON OBJECTS
acqJob = daqjob('acquisition');
if getChannelCount(acqJob) ~= 0
    delete(acqJob);
end
scopeJob = daqjob('scope');
if getChannelCount(scopeJob) ~= 0
    delete(scopeJob);
end

%% PROCESS INITIALIZATION VARIABLES

%Bulk validation that all non-structure variables exist and are of correct type.
%NOTE: Validation related to 'amp' structure is handled as part of its processing below.
numericArrays = {'xMirrorBoardID', 'xMirrorChannelID', 'yMirrorBoardID', 'yMirrorChannelID', 'pockelsBoardID', 'pockelsChannelID', ...
    'photodiodeBoardID', 'photodiodeChannelID', 'shutterBoardID', 'shutterPortID', 'shutterLineID', 'shutterChannelID', 'xVideoImageSize', 'yVideoImageSize', ...
    'acqBoardIDs', 'acqChannelIDs', 'stimBoardIDs', 'stimChannelIDs', 'digStimBoardIDs', 'digStimPortIDs', 'digStimLineIDs', 'initialSampleRate'};
cellArrays = {'acqChannelNames', 'stimChannelNames', 'digStimChannelNames', 'stimChannelNamesOrder', 'acqChannelNamesOrder', 'triggerDestinations'};
strings = {'xsgStartDirectory', 'triggerOrigin', 'sampleClockOrigin', 'sampleClockDestination'};
logicals = {'mapperEnabled', 'qcamEnabled', 'clearInputBuffersOnStop', 'zeroOutputChannelsOnStop'};
allVars = [numericArrays, cellArrays, strings, logicals];

existErrors = cellfun(@(x)~exist(x, 'var'), allVars);
assert(~any(existErrors), 'The initialization file value ''%s'' is missing. It is required that intialization file contain all values specified in model file. Cannot start Ephus.', allVars{find(existErrors, 1)});

numericArrayErrors = cellfun(@(x)~isnumeric(eval(x)),numericArrays);
assert(~any(numericArrayErrors), 'The initialization file value ''%s'' must be a numeric array. Cannot start Ephus.', numericArrays{find(numericArrayErrors, 1)});

cellArrayErrors = cellfun(@(x)~iscell(eval(x)),cellArrays);
assert(~any(cellArrayErrors), 'The initialization file value ''%s'' must be a cell array. Cannot start Ephus.', cellArrays{find(cellArrayErrors, 1)});

stringErrors = cellfun(@(x)~ischar(eval(x)) || ~ismember(min(size(x)), [0, 1]), strings);
assert(~any(stringErrors), 'The initialization file value ''%s'' must be a string. Cannot start Ephus.', strings{find(stringErrors, 1)});

logicalErrors = cellfun(@(x)~islogical(eval(x)) || ~ismember(eval(x), [0, 1]), logicals);
assert(~any(logicalErrors), 'The initialization file value ''%s'' must be a logical (true/false or 0/1). Cannot start Ephus.', logicals{find(logicalErrors, 1)});

%Handle 'hidden' variables that are NOT shown in model initialization file, but can be added optionally by advanced users (wiki documented features)
hiddenVars = {'clearBuffersOnGetData'};
hiddenVarsDefaults = {'true'};

for i=1:length(hiddenVars)
    if ~exist(hiddenVars{i},'var')
        eval([hiddenVars{i} '=' hiddenVarsDefaults{i} ';']);
    end
end

%Prepare to configure Stimulator/Acquirer channels into an ordered structure (this is done to allow for subsequent optional reordering step)
stimChannels = struct('channelName', {}, 'boardID', {}, 'channelID', {}, 'portID', {}, 'lineID', {});
acqChannels = struct('channelName', {}, 'boardID', {}, 'channelID', {});

%Add Mapper-related Acquirer and Stimulator channels firts
if mapperEnabled
    mirrorNames = {'xMirror' 'yMirror'};
    for i=1:length(mirrorNames)
        stimChannels(i).channelName = mirrorNames{i};
        stimChannels(i).boardID = eval([mirrorNames{i} 'BoardID']);
        stimChannels(i).channelID = eval([mirrorNames{i} 'ChannelID']);
    end

    if ~isempty(pockelsBoardID) && ~isempty(pockelsChannelID)
        pockelsOn = true;
        stimChannels(3).channelName = 'pockelsCell';
        stimChannels(3).boardID = pockelsBoardID;
        stimChannels(3).channelID = pockelsChannelID;
    else
        pockelsOn = false;
    end

    if pockelsOn
        if ~isempty(photodiodeBoardID) && ~isempty(photodiodeChannelID)
            acqChannels(1).channelName = 'photodiode1';
            acqChannels(1).boardID = photodiodeBoardID;
            acqChannels(1).channelID = photodiodeChannelID;
        else
            error('A Pockels Cell is configured for Mapper, without a photodiode. This is not presently allowed. Cannot start Ephus.');
        end

        if ~isempty(shutterBoardID)
            if shutterDigital
                if ~isempty(shutterPortID) && ~isempty(shutterLineID);
                    stimChannels(3+pockelsOn).channelName = 'shutter0';
                    stimChannels(3+pockelsOn).boardID = shutterBoardID;
                    stimChannels(3+pockelsOn).portID = shutterPortID;
                    stimChannels(3+pockelsOn).lineID = shutterLineID;
                end
            else
                if ~isempty(shutterChannelID)
                    stimChannels(3+pockelsOn).channelName = 'shutter0';
                    stimChannels(3+pockelsOn).boardID = shutterBoardID;
                    stimChannels(3+pockelsOn).channelID = shutterChannelID;
                end
            end
        else
            error('A Pockels Cell is configured for Mapper, without a shutter. This is not presently allowed. Cannot start Ephus.');
        end
    else
        %TO031010N - Photodiodes and shutters do not require a Pockels cell. Mapping may be done without a Pockels, but you may still want to record the light and use a shutter. GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
        if ~isempty(photodiodeBoardID) && ~isempty(photodiodeChannelID)
            acqChannels(1).channelName = 'photodiode1';
            acqChannels(1).boardID = photodiodeBoardID;
            acqChannels(1).channelID = photodiodeChannelID;
        end
        if shutterDigital
            if ~isempty(shutterPortID) && ~isempty(shutterLineID);
                stimChannels(3+pockelsOn).channelName = 'shutter0';
                stimChannels(3+pockelsOn).boardID = shutterBoardID;
                stimChannels(3+pockelsOn).portID = shutterPortID;
                stimChannels(3+pockelsOn).lineID = shutterLineID;
            end
        else
            if ~isempty(shutterChannelID)
                stimChannels(3+pockelsOn).channelName = 'shutter0';
                stimChannels(3+pockelsOn).boardID = shutterBoardID;
                stimChannels(3+pockelsOn).channelID = shutterChannelID;
            end
        end
    end
end

%Add general Acquirer channels
if ~isempty(acqChannelNames)
    if isscalar(acqBoardIDs)
        acqBoardIDs = repmat(acqBoardIDs, size(acqChannelNames));
    end

    startIdx = length(acqChannels);
    for i=1:length(acqChannelNames)
        idx = startIdx + i;
        acqChannels(idx).channelName = acqChannelNames{i};
        if isempty(acqBoardIDs(i))
            error('The initialization file value ''acqBoardIDs'' must either be a scalar or a vector of length equal to ''acqChannelNames''');
        elseif isempty(acqChannelIDs(i))
            error('The initialization file value ''acqChannelIDs'' must be a vector of length equal to ''acqChannelNames''');
        else
            acqChannels(idx).boardID = acqBoardIDs(i);
            acqChannels(idx).channelID = acqChannelIDs(i);
        end
    end
end

%Add general Stimulator channels
if ~isempty(stimChannelNames) || ~isempty(digStimChannelNames)
    if isscalar(stimBoardIDs)
        stimBoardIDs = repmat(stimBoardIDs, size(stimChannelNames));
    end
    if isscalar(digStimBoardIDs)
        digStimBoardIDs = repmat(digStimBoardIDs, size(digStimChannelNames));
    end
    if isscalar(digStimPortIDs)
        digStimPortIDs = repmat(digStimPortIDs, size(digStimChannelNames));
    end

    startIdx = length(stimChannels);
    for i = 1 : length(stimChannelNames)
        idx = startIdx + i;
        stimChannels(idx).channelName = stimChannelNames{i};
        if isempty(stimBoardIDs(i))
            error('The initialization file value ''stimBoardIDs'' must either be a scalar or a vector of length equal to ''stimChannelNames''');
        elseif isempty(stimChannelIDs(i))
            error('The initialization file value ''stimChannelIDs'' must be a vector of length equal to ''stimChannelNames''');
        else
            stimChannels(idx).boardID = stimBoardIDs(i);
            stimChannels(idx).channelID = stimChannelIDs(i);
        end
    end

    startIdx = length(stimChannels);
    for i = 1 : length(digStimChannelNames)
        idx = startIdx + i;
        stimChannels(idx).channelName = digStimChannelNames{i};
        if isempty(digStimBoardIDs(i))
            error('The initialization file value ''digStimBoardIDs'' must either be a scalar or a vector of length equal to ''digStimChannelNames''');
        elseif isempty(digStimPortIDs(i))
            error('The initialization file value ''digStimPortIDs'' must be a vector of length equal to ''digStimChannelNames''');
        elseif isempty(digStimLineIDs(i))
            error('The initialization file value ''digStimLineIDs'' must be a vector of length equal to ''digStimChannelNames''');
        else
            stimChannels(idx).boardID = digStimBoardIDs(i);
            stimChannels(idx).portID = digStimPortIDs(i);
            stimChannels(idx).lineID = digStimLineIDs(i);
        end
    end
end

%Reorder Stimulator/Acquirer channels, if specified
if ~isempty(stimChannelNamesOrder)
    currentOrder = {stimChannels.channelName};
    if ~isempty(setxor(currentOrder, stimChannelNamesOrder))
        error('The initialization file value ''stimChannelNamesOrder'' has been configured, but its members do not exactly match the channels configured for the Stimulator, as required. Cannot start Ephus.');
    end
    [junk, newOrder] = ismember(stimChannelNamesOrder, currentOrder);
    stimChannels = stimChannels(newOrder);
end

if ~isempty(acqChannelNamesOrder)
    currentOrder = {acqChannels.channelName};
    if ~isempty(setxor(currentOrder, acqChannelNamesOrder))
        error('The initialization file value ''acqChannelNamesOrder'' has been configured, but its members do not exactly match the channels configured for the Acquirer, as required. Cannot start Ephus.');
    end
    [junk, newOrder] = ismember(acqChannelNamesOrder, currentOrder);
    acqChannels = acqChannels(newOrder);
end

%% SET UP WAIT BAR
wb = waitbarWithCancel(0, 'Starting ephus...', 'Name', 'Loading software...');
pos = get(wb, 'Position');
pos(2) = pos(2) - pos(4);
set(wb, 'Position', pos);

%% CONFIGURE AMPLIFIER CHANNELS
%TO030310B - Fixed the naming so the names are more easily digestable and conform to the previously used naming conventions (thus preserving existing configurations). -- Tim O'Connor 3/3/10
%TO030410A - Changed the increment algorithm for the amplifier naming. -- Tim O'Connor 3/4/10
activeAmps = false;
try
    if exist('amp')
        assert(isstruct(amp), 'The initialization file value ''amp'' must be a structure array containing amplifier configuration information. Cannot start Ephus.');

        propsShared = {'amplifierType', 'scaledOutputBoardID', 'scaledOutputChannelID', 'vComBoardID', 'vComChannelID'};
        propsMulticlamp = {'amplifierChannelID'};
        props700A = {'comPortID', 'axoBusID'};
        props700B = {'serialNumber'};
        
        propsAxoPatch = {'gainBoardID', 'gainChannelID', 'modeBoardID', 'modeChannelID', 'vHoldBoardID', 'vHoldChannelID'};
        propsAxoPatchConstructor = {'gain_daq_board_id', 'gain_channel', 'mode_daq_board_id', 'mode_channel', 'v_hold_daq_board_id', 'v_hold_channel'};
        assert(isempty(setxor(fieldnames(amp), [propsShared propsMulticlamp props700A props700B propsAxoPatch])), ...
            'One or more of the required fields of the initialization file value ''amp'' is missing. Cannot start Ephus.');

        patch = cell(1, length(amp));
        activeAmps = false(1, length(amp));
        
        %%%VI030910A
        serials700A = [];
        serials700B = [];
        count700A = 0;
        count700B = 0;
        
        for i=1:length(amp)
            if i==1
                if all(cellfun(@(x)isempty(amp(i).(x)), fieldnames(amp))) %There is no configured amplifier
                    break;
                else
                    activeAmps = true; %There is at least one configured amplifier (if partially/erroneously confiured, error will be flagged below)
                end
            end

            assert(ischar(amp(i).amplifierType), 'The ''amplifierType'' field of the ''amp'' structure must be a string value. Cannot start Ephus.');
            numericFields = cellfun(@(x)isnumeric(amp(i).(x)), setdiff(fieldnames(amp), {'amplifierType'}));
            assert(all(numericFields), 'One or more fields of the initialization file value ''amp'' is non-numeric, but should be numeric. Cannot start Ephus.');

            amplifierType = amp(i).amplifierType;           
 
            switch lower(amplifierType)
                case 'multi_clamp'
                    ampChan = amp(i).amplifierChannelID;
                    if isempty(ampChan) || ~isnumeric(ampChan)
                        error('The ''amplifierChannelID'' field, required for all MultiClamp amplifier devices, is not configured correctly for amplifier #%d',i);
                    end

                    if all(cellfun(@(x)~isempty(amp(i).(x)), props700B)) %700B
                        if ~ismember(amp(i).serialNumber, serials700B)
                            count700B = count700B + 1;
                            serials700B = [serials700B amp(i).serialNumber];
                        end
                        extraPVArgs = {'uSerialNum', amp(i).serialNumber, 'channel', ampChan, 'uChannelID', ampChan, 'name', ['700B-' num2str(2*(count700B-1) + ampChan)]}; %VI030910A %TO030310B %TO030410A
                    elseif all(cellfun(@(x)~isempty(amp(i).(x)), props700A)) %700A
                        if ~ismember(amp(i).serialNumber, serials700A)
                            count700A = count700A + 1;
                            serials700A = [serials700A amp(i).serialNumber];
                        end
                        extraPVArgs = {'uChannelID', ampChan, 'channel', ampChan, 'uComPortID', amp(i).comPortID, 'uAxoBusID', amp(i).axoBusID, 'name', ['700A-' num2str(2*(count700A-1) + ampChan)]}; %VI030910A %TO030310B %TO030410A
                    else
                        error('One or more required fields for 700A or 700B amplifier has not been configured for amplifier #%d',i);
                    end
                case 'axopatch_200b'
                    amplifierType = 'axopatch_200B'; %Force match to constructor name case style
                    
                    if ~all(cellfun(@(x)~isempty(amp(i).(x)), propsAxoPatch))
                        error('One or more required fields for Axopatch 200B amplifier has not been configured for amplifier #%d',i);
                    else
                        extraPVArgs = cell(1,2*length(propsAxoPatch));
                        extraPVArgs(1:2:end) = propsAxoPatchConstructor;
                        for j=1:length(propsAxoPatch)                            
                            extraPVArgs{2*j} = amp(i).(propsAxoPatch{j});
                        end                        
                    end
                case 'dumbamp' %TO052710 - Support @dumbamp (and maybe others in a little while). Actually, this amplifier initialization stuff should be simplified, it's really convoluted now. -- Tim O'Connor 5/27/10
                    amplifierType = 'dumbamp';
                    extraPVArgs = {'inputBoardID', 1, 'inputChannelID', 0, 'outputBoardID', 1, 'outputChannelID', 0};
                otherwise
                    error('The specified ''amplifier'' type for amplifier #%d is not recognized.', i);
            end

            argList = {};
            simpleFields = {'scaledOutputBoardID' 'scaledOutputChannelID' 'vComBoardID' 'vComChannelID'}; %These are fields for which initialization file field and constructor argument names  match
            for j=1:length(simpleFields)
                val = amp(i).(simpleFields{j});

                argList{end+1} = simpleFields{j}; %#ok<AGROW>
                argList{end+1} = val; %#ok<AGROW>
            end

            %TO052710
            if exist('extraPVArgs', 'var') == 1
                if ~isempty(extraPVArgs)
                    argList = [argList extraPVArgs];
                end
            end
            
            patch{i} = feval(amplifierType,argList{:});
        end
    end


%% TIMING/CLOCK CONFIG
    %Set up the triggering.
    acqJob = daqjob('acquisition');
    scopeJob = daqjob('scope');

    set([acqJob scopeJob], 'triggerOrigin', triggerOrigin);
    set(acqJob,'triggerDestinations', triggerDestinations);
    set(scopeJob,'triggerDestinations', triggerDestinations{1});
    set(scopeJob,'readErrorMode', 'drop');
    
    %Determine unique board IDs
    uniqueBoardIDs = [xMirrorBoardID yMirrorBoardID pockelsBoardID photodiodeBoardID shutterBoardID acqBoardIDs stimBoardIDs digStimBoardIDs];
    for i=1:length(amp)
        boardIDFields = {'scaledOutput' 'vCom' 'gain' 'mode' 'vHold'};
        for j=1:length(boardIDFields)
            uniqueBoardIDs = [uniqueBoardIDs amp(i).([boardIDFields{j} 'BoardID'])];
        end
    end
    uniqueBoardIDs = unique(uniqueBoardIDs);

    if ~isempty(sampleClockOrigin)
        cellfun(@(x)createMasterSampleClock(x, sampleClockOrigin, initialSampleRate),{acqJob scopeJob});
    elseif ~isempty(digStimChannelNames)
        if length(uniqueBoardIDs) > 1
            %error message                                                          
        else %Handle case of 1 board with digital stimulator channels in default manner                              
            cellfun(@(x)createMasterSampleClock(x,['/dev' num2str(uniqueBoardIDs) '/ctr0'],initialSampleRate),{acqJob scopeJob});
        end        
    end

    if ~isempty(sampleClockDestination)
        cellfun(@(x)setSampleClockDestination(x, sampleClockDestination), {acqJob scopeJob});
    elseif ~isempty(digStimChannelNames)
        if length(uniqueBoardIDs) > 1
            %error message            
        elseif ~isempty(sampleClockOrigin)
            %error message
        else %Handle case of 1 board with digital stimulator channels in default manner 
            cellfun(@(x)setSampleClockDestination(x,'ctr0InternalOutput'),{acqJob scopeJob});
        end
    end
        

%% START PROGRAMS
    if waitbarUpdate(0.0, wb, 'Starting experimentSavingGui...'); return; end
    xsg = openprogram(progmanager, {'xsg', 'experimentSavingGui'});
    setLocalBatch(progmanager, xsg, 'directory', xsgStartDirectory);
    %setLocal(progmanager,xsg,'autosave',0);  %turns off autosave %TODO: Initialize on/off by default


    if waitbarUpdate(0.1, wb, 'Starting ephys...'); return; end
   if activeAmps
        ep = openprogram(progmanager, 'ephys', patch);
        setLocal(progmanager, ep, 'sampleRate', initialSampleRate);%TO011909A - You MUST set the program's sample rate, to produce the correctly sampled data.
        setLocal(progmanager, ep, 'zeroChannelsOnStop', zeroOutputChannelsOnStop);
        setLocal(progmanager, ep, 'clearBuffersWhenNotRunning', clearInputBuffersOnStop);
        setLocal(progmanager, ep, 'clearBuffersOnGetData', clearBuffersOnGetData);

        if waitbarUpdate(0.16, wb, 'Starting ephysScopeAccessory...'); return; end
        scg = program('scopeGui', 'scopeGui', 'scopeGui', 'ephysScopeAccessory', 'ephysScopeAccessory');
        openprogram(progmanager, scg);
        ephysAcc = getGlobal(progmanager, 'hObject', 'ephysScopeAccessory', 'ScopeGui');
        if activeAmps
            %TODO: Determine if this loop is needed -- appears redundant with ephysAcc_setAmplifiers
            for i = 1 : length(patch)
                bindToDaqJob(patch{i}, scopeJob);
            end
            
            ephysAcc_setAmplifiers(ephysAcc, patch);
        end
   else
       ep = [];
   end

    if waitbarUpdate(0.24, wb, 'Starting stimulator...'); return; end
    if ~isempty(stimChannels)
        stim = openprogram(progmanager, 'stimulator');
        setLocal(progmanager, stim, 'sampleRate', initialSampleRate);%TO011909A - You MUST set the program's sample rate, to produce the correctly sampled data.
        stim_setChannels(stim, stimChannels);
        setLocalBatch(progmanager, stim, 'zeroChannelsOnStop', zeroOutputChannelsOnStop);
        setLocal(progmanager, stim, 'clearBuffersOnGetData', clearBuffersOnGetData);
    else
        stim = [];
    end

    if waitbarUpdate(0.32, wb, 'Starting acquirer...');return;end
    if ~isempty(acqChannels)
        acq = openprogram(progmanager, 'acquirer');
        setLocal(progmanager, acq, 'sampleRate', initialSampleRate);%TO011909A - You MUST set the program's sample rate, since it's sharing hardware with the other programs.
        acq_setChannels(acq, acqChannels);
        setLocal(progmanager, acq, 'clearBuffersWhenNotRunning', clearInputBuffersOnStop);
        setLocal(progmanager, acq, 'clearBuffersOnGetData', clearBuffersOnGetData);
    end

    if waitbarUpdate(0.48, wb, 'Starting pulseJacker...');return;end
    if ~isempty(stim) || ~isempty(ep)
        progHandles = {ep, stim};
        progHandles = progHandles(cellfun(@(x)~isempty(x), progHandles));
        openprogram(progmanager, 'pulseJacker', progHandles);
    end
    %TODO: Hide by default?

    if waitbarUpdate(0.52, wb, 'Starting userFcns...');return;end
    openprogram(progmanager, 'userFcns');
    %TODO: Hide by default?

    if waitbarUpdate(0.56, wb, 'Starting autonotes...');return;end
    openprogram(progmanager, 'autonotes');
    %TODO: Hide by default if not mapping?

    if waitbarUpdate(0.60, wb, 'Starting HotSwitch...');return;end
    openprogram(progmanager, {'hotswitch', 'hotswitch', 'hotswitch', 'hs_config', 'hs_config'});

    %TO031010B - The headerGUI is not a mapper-specific GUI. GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
    if waitbarUpdate(0.64, wb, 'Starting headerGui...');return;end
    openprogram(progmanager, 'headerGUI');

    %TO033110C - Start traceViewer by default. -- Tim O'Connor 3/31/10
    if waitbarUpdate(0.68, wb, 'Starting traceViewer...');return;end
    startTraceViewer;
    
    if mapperEnabled
        if pockelsOn
            if waitbarUpdate(.72, wb, 'Starting photodiode configuration...');return;end
            pdiode = openprogram(progmanager, {'photodiode', 'photodiode', 'photodiodeConfiguration'},'photodiode1');
        else
            pdiode = [];
        end

        if waitbarUpdate(.76, wb, 'Starting mapper...');return;end
        if shutterDigital
            shutterInfo = [shutterBoardID, shutterPortID, shutterLineID];
        else
            shutterInfo = [shutterBoardID, shutterChannelID];
        end

        openprogram(progmanager, 'mapper', 'xMirror', 'yMirror', 'pockelsCell', 'shutter0', pdiode);

        setLocalBatch(progmanager, mapper, 'xVideoScaleFactor', xVideoImageSize, 'yVideoScaleFactor', yVideoImageSize);%<<<<<<<<<<---------- CONFIG
        if pockelsOn
            mapper_enablePockelsCell;
            
            setLocalBatch(progmanager, mapper, 'modulatorMax', pockelsModulatorMax);
        end
    end

    if qcamEnabled
        if waitbarUpdate(0.80, wb, 'Starting qcam...');return;end
        openprogram(progmanager, 'qcam');
    end

%% USERFCN BINDINGS
    %These userFcns allow developers to customize Ephus to specific applications

    if waitbarUpdate(0.84, wb, 'Setting up default (built-in) userFcns...');return;end

    userFcnCBM = getUserFcnCBM;

    %TO040510B - Moved most of these event bindings into the mapper's start function. -- Tim O'Connor 4/5/10
    if mapperEnabled
        if qcamEnabled
            addCallback(userFcnCBM, 'mapper:PreGrabVideo', @qcammexSnapshot, 'userFcns_qcammexSnapshot');
        end
    end

%% Load a configuration (if requested).
    if waitbarUpdate(0.88, wb, 'Loading configuration...');return;end
    loadConfigurations(progmanager);
    fprintf(1, '\nLoading Completed.\n\n');

    delete(wb); %Kill the waitbar.
    fprintf(1, '\n\n-----------------------------------\n-----------------------------------\n\n\n\n\n\n\n\n');

catch ME
    delete(wb);
    rethrow(ME);
end
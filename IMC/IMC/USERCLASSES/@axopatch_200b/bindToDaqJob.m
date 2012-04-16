% AXOPATCH_200B/bindToDaqJob
%
% SYNTAX
%   bindToAIMUX(this, job)
%     this - @multi_clamp instance
%     job - @daqjob instance
%
% USAGE
%
% CHANGES
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%  TO110607A - Start all input channels. Listen for telegraph changes. -- Tim O'Connor 11/6/07
%  TO110907B - Since we don't actually use the vhold for anything, don't set up channels for it (for the time being). -- Tim O'Connor 11/9/07
%
% Created 7/31/07 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function bindToDaqJob(this, job, varargin)
global axopatch200bs;

name = get(this, 'name');

gainName = [name '-gain'];
%TO022505c
if ~isChannel(job, gainName)
    gainPhysicalChannel = ['/dev' num2str(get(this, 'gain_daq_board_id')) '/ai' num2str(get(this, 'gain_channel'))];
    addAnalogInput(job, gainName, ['/dev' num2str(get(this, 'gain_daq_board_id')) '/ai'], get(this, 'gain_channel'));
    bindDataListener(job, gainName, {@axopatch200b_gainSamplesAcquiredFcn, this}, [name '-gainTelegraph']);%TO110607A
end

modeName = [name '-mode'];
%TO022505c
if ~isChannel(job, modeName)
    modePhysicalChannel = ['/dev' num2str(get(this, 'mode_daq_board_id')) '/ai' num2str(get(this, 'mode_channel'))];
    addAnalogInput(job, modeName, ['/dev' num2str(get(this, 'mode_daq_board_id')) '/ai'], get(this, 'mode_channel'));
    bindDataListener(job, modeName, {@axopatch200b_modeSamplesAcquiredFcn, this}, [name '-modeTelegraph']);%TO110607A
end

%TO110907B?
v_holdName = [name '-v_hold'];
%TO022505c
if ~isChannel(job, v_holdName)
    v_holdPhysicalChannel = ['/dev' num2str(get(this, 'v_hold_daq_board_id')) '/ai' num2str(get(this, 'v_hold_channel'))];
    addAnalogInput(job, v_holdName, ['/dev' num2str(get(this, 'v_hold_daq_board_id')) '/ai'], get(this, 'v_hold_channel'));
    bindDataListener(job, v_holdName, {@axopatch200b_vholdSamplesAcquiredFcn, this}, [name '-vholdTelegraph']);%TO110607A
end

%Listen to these channels, to update the scaling parameters.
bindDataListener(job, gainName, {@axopatch200b_gainSamplesAcquiredFcn, this}, [name '_gainListener']);%TO101707F
bindDataListener(job, modeName, {@axopatch200b_modeSamplesAcquiredFcn, this}, [name '_modeListener']);%TO101707F
bindDataListener(job, v_holdName, {@axopatch200b_vholdSamplesAcquiredFcn, this}, [name '_vHoldListener']);%TO101707F

scaledChannelName = [name '_scaledOutput'];
if ~isChannel(job, scaledChannelName)
    inputPhysicalChannel = ['/dev' num2str(get(this, 'scaledOutputBoardID')) '/ai' num2str(get(this, 'scaledOutputChannelID'))];
    addAnalogInput(job, scaledChannelName, ['/dev' num2str(get(this, 'scaledOutputBoardID')) '/ai'], get(this, 'scaledOutputChannelID'));
    %This will do the actual data scaling.
    bindDataPreprocessor(job, scaledChannelName, {@axopatch200b_InputPreprocessor, this}, [scaledChannelName '_preprocessor']);
%     nimex_registerSamplesAcquiredPreprocessor(getTaskByChannelName(job, scaledChannelName), inputPhysicalChannel, {@axopatch200b_preprocessor, this}, [scaledChannelName '_preprocessor']);
    setInputChannelNames(this, {scaledChannelName});
    set(this, 'scaledOutputChannel', scaledChannelName);
end

setInputChannelNames(this, {scaledChannelName, gainName, modeName, v_holdName});%TO110607A %TO110907B?
set(this, 'scaledOutputChannel', scaledChannelName);
setScaledOutputChannelName(this, scaledChannelName);
vCom = [name '-VCom'];
if ~isChannel(job, vCom)
    outputPhysicalChannel = ['/dev' num2str(get(this, 'vComBoardID')) '/ao' num2str(get(this, 'vComChannelID'))];
    addAnalogOutput(job, vCom, ['/dev' num2str(get(this, 'vComBoardID')) '/ao'], get(this, 'vComChannelID'));
    setVComChannelName(this, vCom);
    nimex_registerOutputDataPreprocessor(getTaskByChannelName(job, vCom), outputPhysicalChannel, {@axopatch200b_OutputPreprocessor, this}, [vCom '_preprocessor'], 1);
end

%---------------------------------------------------------------
% AXOPATCH_200B/axopatch200b_gainSamplesAcquiredFcn - Listens for gain telegraphs.
%
%  SYNTAX
%   axopatch200b_InputPreprocessor(this, data, ai, strct, varargin)
%    this - AXOPATCH_200B
%    data - The unscaled voltage data.
%
%  USAGE
%
%  CHANGES
%   TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% Created 2/10/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function data = axopatch200b_InputPreprocessor(this, data)

cc = get(this, 'current_clamp');
% fprintf(1, 'axopatch200b_InputPreprocessor - current_clamp: %d, gain: %d\n', cc, get(this, 'gain'));
% fprintf(1, 'axopatch200b_InputPreprocessor (before): %s - %s\n', num2str(min(data)), num2str(max(data)));
if cc
    %See Axopatch 200B Patch Clamp Theory And Operation manual page 80
    %I = alpha * beta mV/pA
    data = 1000 * data / get(this, 'gain') / get(this, 'beta');
else
    %See Axopatch 200B Patch Clamp Theory And Operation manual page 80
    %V = alpha mV/mV
    data = 1000 * data / get(this, 'gain');
end
% fprintf(1, 'axopatch200b_InputPreprocessor (after): %s - %s\n', num2str(min(data)), num2str(max(data)));
return;

%---------------------------------------------------------------
function preprocessed = axopatch200b_OutputPreprocessor(this, data)
% fprintf(1, 'axopatch200b_OutputPreprocessor (before): %s - %s\n', num2str(min(data)), num2str(max(data)));
if get(this, 'current_clamp')
    %See Axopatch 200B Patch Clamp Theory And Operation manual page 79.
    %Front-switched: 2 / beta nA/V = (2000 / beta) pA/V
    %Rear-switched: 2 / beta nA/V = (2000 / beta) pA/V
    preprocessed = data * get(this, 'i_clamp_output_factor') / get(this, 'beta');
else
    %See Axopatch 200B Patch Clamp Theory And Operation manual page 80.
    %Front-switched: 20 mv/V
    %Rear-switched: 100 mV/V
    preprocessed = data * get(this, 'v_clamp_output_factor');
end
% fprintf('%s --> %s\n', num2str(max(abs(data))), num2str(max(abs(preprocessed))));
% fprintf(1, 'axopatch200b_OutputPreprocessor (after): %s - %s\n', num2str(min(preprocessed)), num2str(max(preprocessed)));
return;
% multi_clamp/bindToDaqJob
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
%
% Created 7/31/07 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function bindToDaqJob(this, job)

name = get(this, 'name');

scaledChannelName = [name '_scaledOutput'];
if ~isChannel(job, scaledChannelName)
    addAnalogInput(job, scaledChannelName, ['/dev' num2str(get(this, 'scaledOutputBoardID')) '/ai'], get(this, 'scaledOutputChannelID'));
%    nimex_registerSamplesAcquiredPreprocessor(getTaskByChannelName(job, scaledChannelName), inputPhysicalChannel, {@multiclamp_InputPreprocessor, this}, [scaledChannelName '_preprocessor']);
    bindDataPreprocessor(job, scaledChannelName, {@multiclamp_InputPreprocessor, this}, [scaledChannelName '_preprocessor']);
    setInputChannelNames(this, {scaledChannelName});
    set(this, 'scaledOutputChannel', scaledChannelName);
end
setScaledOutputChannelName(this, scaledChannelName);

vCom = [name '-VCom'];
if ~isChannel(job, vCom)
    addAnalogOutput(job, vCom, ['/dev' num2str(get(this, 'vComBoardID')) '/ao'], get(this, 'vComChannelID'));
    setVComChannelName(this, vCom);
%     bindDataPreprocessor(job, vCom, {@multiclamp_OutputPreprocessor, this}, [vCom '_preprocessor']);
    nimex_registerOutputDataPreprocessor(getTaskByChannelName(job, vCom), getDeviceNameByChannelName(job, vCom), ...
        {@multiclamp_OutputPreprocessor, this}, [vCom '_preprocessor'], 1);
end

%--------------------------------------------------------
function data = multiclamp_InputPreprocessor(this, data)
% fprintf(1, 'multiclamp_InputPreprocessor\n');
%TO033106G: Updating takes lots of time, and nothing here should be changing during a trace anyway?
update(this);
cc = get(this, 'current_clamp');
% fprintf(1, 'multiclamp_InputPreprocessor (before): %s - %s\n', num2str(min(data)), num2str(max(data)));
if cc
    %See MultiClamp 700B Patch Clamp Theory And Operation manual page 144
    %I = alpha * beta mV/V
    data = data / get(this, 'input_gain');
else
    %See MultiClamp 700B Patch Clamp Theory And Operation manual page 144
    %V = alpha pA/V
    data = data / get(this, 'input_gain');
end
% input_gain = get(this, 'input_gain')
% fprintf(1, 'multiclamp_InputPreprocessor (after): %s - %s\n', num2str(min(data)), num2str(max(data)));
return;


%---------------------------------------------------------------
function preprocessed = multiclamp_OutputPreprocessor(this, data)

update(this);
cc = get(this, 'current_clamp');
% fprintf(1, '@multi_clamp/bindToDaqJob: current_clamp = %s\n', num2str(cc));
% fprintf(1, 'multiclamp_OutputPreprocessor (before): %s - %s\n', num2str(min(data)), num2str(max(data)));
if cc
    %See Axopatch 700B Patch Clamp Theory And Operation manual page 144.
    %400 pA/V | 2 nA/V
    preprocessed = data * get(this, 'i_clamp_output_factor');
% fprintf(1, 'I-Clamp: From [%s %s] to [%s %s] by %s\n', num2str(min(data)), num2str(max(data)), num2str(min(preprocessed)), num2str(max(preprocessed)), num2str(get(this, 'i_clamp_output_factor')));
else
    %See Axopatch 700B Patch Clamp Theory And Operation manual page 144.
    %20mV/V | 100mv/V
    preprocessed = data * get(this, 'v_clamp_output_factor');
% fprintf(1, 'V-Clamp: From [%s %s] to [%s %s] by %s\n', num2str(min(data)), num2str(max(data)), num2str(min(preprocessed)), num2str(max(preprocessed)), num2str(get(this, 'i_clamp_output_factor')));
end
% fprintf('%s --> %s\n', num2str(max(abs(data))), num2str(max(abs(preprocessed))));
% fprintf(1, 'multiclamp_OutputPreprocessor (after): %s - %s\n', num2str(min(preprocessed)), num2str(max(preprocessed)));
return;
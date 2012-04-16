function bindToDaqJob(this, job)

[scaledChannelName, vCom] = get(this, 'inputName', 'outputName');
if ~isempty(get(this, 'inputBoardID'))
    if ~isChannel(job, scaledChannelName)
        addAnalogInput(job, scaledChannelName, ['/dev' num2str(get(this, 'inputBoardID')) '/ai'], get(this, 'inputChannelID'));
        bindDataPreprocessor(job, scaledChannelName, {@dumbamp_InputPreprocessor, this}, [scaledChannelName '_preprocessor']);
        setInputChannelNames(this, {scaledChannelName});
        set(this, 'scaledOutputChannel', scaledChannelName);%Redundant?
    end
    setScaledOutputChannelName(this, scaledChannelName);
end

if ~isempty(get(this, 'outputBoardID'))
    if ~isChannel(job, vCom)
        addAnalogOutput(job, vCom, ['/dev' num2str(get(this, 'outputBoardID')) '/ao'], get(this, 'outputChannelID'));
        setVComChannelName(this, vCom);
        nimex_registerOutputDataPreprocessor(getTaskByChannelName(job, vCom), getDeviceNameByChannelName(job, vCom), ...
            {@dumbamp_OutputPreprocessor, this}, [vCom '_preprocessor'], 1);
    end
end

%--------------------------------------------------------
function preprocessed = dumbamp_InputPreprocessor(this, data)
global globalDumbampObjects;

% fprintf(1, 'dumbamp_InputPreprocessor (before): %s - %s\n', num2str(min(data)), num2str(max(data)));
preprocessed = globalDumbampObjects(this.ptr).input_gain * data + globalDumbampObjects(this.ptr).input_offset;
% fprintf(1, 'dumbamp_InputPreprocessor (after): %s - %s\n', num2str(min(preprocessed)), num2str(max(preprocessed)));

return;

%---------------------------------------------------------------
function preprocessed = dumbamp_OutputPreprocessor(this, data)
global globalDumbampObjects;

% fprintf(1, 'dumbamp_OutputPreprocessor (before): %s - %s\n', num2str(min(data)), num2str(max(data)));
preprocessed = globalDumbampObjects(this.ptr).output_gain * data + globalDumbampObjects(this.ptr).output_offset;
% fprintf(1, 'dumbamp_OutputPreprocessor (after): %s - %s\n', num2str(min(preprocessed)), num2str(max(preprocessed)));

return;
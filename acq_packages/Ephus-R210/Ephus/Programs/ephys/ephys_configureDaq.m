% ephys_configureDaq - Configure the @daqjob object for the ephys GUI.
%
% SYNTAX
%  ephys_configureDaq(hObject)
%
% USAGE
%
% NOTES
%  Subsumes ephys_configureAimux and ephys_configureAomux.
%
% CHANGES
%
% Created 7/31/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function ephys_configureDaq(hObject)

[amps, sc, acqOnArray] = getLocalBatch(progmanager, hObject, 'amplifiers', 'scopeObject', 'acqOnArray');

stackTrace = getStackTraceString;

buffers = getLocal(progmanager, hObject, 'saveBuffers');%TO032106D
for i = 1 : length(amps)
    bindToDaqJob(amps{i}, daqjob('acquisition'));
    %TO032106D
    nimex_registerSamplesAcquiredListener(getTaskByChannelName(job, scaledChannelName), inputPhysicalChannel, ...
        {@recordEphysData, hObject, bufferName, scaledOutputChannel}, [scaledChannelName '_preprocessor'], ['recordEphysData-' get(amps{i}, 'name')]);%TO120205A %TO110906A
    bufferName = ['trace_' num2str(i)];
    if isempty(buffers)
        buffers.(bufferName).data = [];
        buffers.(bufferName).amplifierName = get(amps{1}, 'name');%;%TO120205A
        buffers.(bufferName).debug.creationStackTrace = getStackTraceString;
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
        buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
    elseif ~isfield(buffers, bufferName)
        buffers.(bufferName).data = [];
        buffers.(bufferName).amplifierName = get(amps{1}, 'name');%;%TO120205A
        buffers.(bufferName).debug.creationStackTrace = getStackTraceString;
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
        buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
    elseif ~acqOnArray(i)
        buffers.(bufferName).data = [];
        buffers.(bufferName).amplifierName = get(amps{i}, 'name');%TO120205A
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
    else
        %Make sure the name is in sync with whatever's displayed in the gui.
        buffers.(bufferName).amplifierName = get(amps{1}, 'name');%;%TO120205A
    end
    buffers.(bufferName).resetOnNextSamplesAcquired = 1;
end

return;
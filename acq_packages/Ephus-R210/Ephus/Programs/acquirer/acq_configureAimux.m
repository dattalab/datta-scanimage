% acq_configureAimux - Configure the AIMUX object for the ephys GUI.
%
% SYNTAX
%  acq_configureAimux(hObject)
%
% USAGE
%
% NOTES
%  This is a copy & paste job from ephys_configureAimux.m, with some editting where necessary.
%
% CHANGES
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO123005B - Initiate automatic data saving when all the data has been read. -- Tim O'Connor 12/30/05
%  TO012606B - Implemented the expectedDataSourceList variable in the xsg. -- Tim O'Connor 1/26/06
%  TO012706A - Push the call to flush input data into the xsg. -- Tim O'Connor 1/27/06
%  TO012706B - Deprecated xsg_removeExpectedDatSource. See @startmanager/removeExpectedDataSource and @startmanager/removeExpectedDataSink -- Tim O'Connor 1/27/06
%  TO031306A - Allow access to the samplesAcquired event as a user function, for processing before completion when using board timing. -- Tim O'Connor 3/13/06
%  TO032106D - Only clear the buffer when data is first acquired after a restart. Use a flag to indicate a reset is desired. -- Tim O'Connor 3/22/06
%  TO032206B - Have to check all channels before stopping. -- Tim O'Connor 3/22/06
%  TO032306C - Update conditions for alternate channel checking when stopping. See TO032206B. -- Tim O'Connor 3/23/06
%  TO033006A - Pass the name of the most recently updated buffer to the acq:SamplesAcquired UserFcn. -- Tim O'Connor 3/30/06
%  TO080306A - Allow multiple acquisitions to be prequeued, and sequentially triggered. -- Tim O'Connor 8/3/06
%  TO091106F - Update the TriggerRepeat property on AI objects in the event that segmentedAcquisition has been set externally. See TO091106E. -- Tim O'Connor 9/11/06
%  TO102306A - Apparently, the SamplesPerTrigger value can not be relied on to count SamplesAcquiredFcn calls. Add a field to the buffer instead. --Tim O'Connor 10/23/06
%  TO110206A - Moved startmanager event conditions, but this may not have been strictly necessary (see other TO110206A). -- Tim O'Connor 11/2/06
%  TO110906A - Get the channel's SamplesPerTrigger, not the (possibly shared) ai object's. -- Tim O'Connor 11/9/06
%
% Created 12/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function acq_configureAimux(hObject)
warning('Deprecated.');
%Configure the input multiplexing.
[aim, channels, sc, acqOnArray] = getLocalBatch(progmanager, hObject, 'aimux', 'channels', 'scopeObject', 'acqOnArray');

stackTrace = getStackTraceString;

buffers = getLocal(progmanager, hObject, 'saveBuffers');%TO032106D
for i = 1 : length(channels)
    %The channel must exist before it can have a preprocessor bound to it.
    dm = getDaqmanager;
    if ~hasChannel(dm, channels(i).channelName)
        nameInputChannel(dm, channels(i).boardID, channels(i).channelID, channels(i).channelName);
        enableChannel(dm, channels(i).channelName);
    end
    
    bufferName = ['trace_' num2str(i)];
    
    bindAimuxChannel(sc(i), channels(i).channelName, aim);%TO120205A
    bind(aim, channels(i).channelName, {@recordAcquirerData, hObject, bufferName, channels(i).channelName}, ['recordAcquirerData-' channels(i).channelName]);%TO120205A %TO110906A
    
    %TO032106D
    if isempty(buffers)
        buffers.(bufferName).data = [];
        buffers.(bufferName).channelName = channels(i).channelName;%TO120205A
        buffers.(bufferName).debug.creationStackTrace = getStackTraceString;
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
        buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
    elseif ~isfield(buffers, bufferName)
        buffers.(bufferName).data = [];
        buffers.(bufferName).channelName = channels(i).channelName;%TO120205A
        buffers.(bufferName).debug.creationStackTrace = getStackTraceString;
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
        buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
    elseif ~acqOnArray(i)
        buffers.(bufferName).data = [];
        buffers.(bufferName).channelName = channels(i).channelName;%TO120205A
        buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
    end
    buffers.(bufferName).resetOnNextSamplesAcquired = 1;
end
setLocal(progmanager, hObject, 'saveBuffers', buffers);

% ephys_updateInput(hObject);

return;

%--------------------------------------------------------------------------------
function recordAcquirerData(hObject, bufferName, channelName, data, ai, strct, varargin)
% fprintf(1, '%s - acq_configureAimux/recordAcquirerData\n', datestr(now));
buffers = getLocal(progmanager, hObject, 'saveBuffers');

if buffers.(bufferName).resetOnNextSamplesAcquired
% fprintf(1, '%s - acq_configureAimux/recordAcquirerData - Clearing buffer...\n', datestr(now));
    buffers.(bufferName).resetOnNextSamplesAcquired = 0;
    buffers.(bufferName).data = [];
    buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
    buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
end

buffers.(bufferName).data = cat(1, buffers.(bufferName).data, data);
setLocal(progmanager, hObject, 'saveBuffers', buffers);
% fprintf(1, '%s - acq_configureAimux/recordAcquirerData: Acquired %s of %s samples.\n', datestr(now), num2str(length(buffers.(bufferName).data)), num2str(get(ai, 'SamplesPerTrigger')));
fireEvent(getUserFcnCBM, 'acq:SamplesAcquired', data, bufferName);%TO031306A %TO033006A

%TO032206B: Have to check all channels before stopping. -- Tim O'Connor 3/22/06
%TO123005B
%TO032306C - Update conditions for alternate channel checking when stopping. See TO032206B. -- Tim O'Connor 3/23/06
[acqOnArray, segmentedAcquisition, acquisitionsRemainingCounter] = getLocalBatch(progmanager, hObject, 'acqOnArray', ...
    'segmentedAcquisition', 'acquisitionsRemainingCounter');%TO080306A

buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter + 1;%TO102306A

%TO110906A - Get the channel's samplesPerTrigger, not the (possibly shared) ai object's. -- Tim O'Connor 11/9/06
% samplesPerTrigger = get(ai, 'SamplesPerTrigger');
samplesPerTrigger = takeAIProperty(getDaqmanager, channelName, 'SamplesPerTrigger');
if ~segmentedAcquisition
%     samplesPerTrigger = samplesPerTrigger * get(ai, 'TriggersExecuted');
    samplesPerTrigger = samplesPerTrigger * buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter;%TO102306A
end

if length(buffers.(bufferName).data) == samplesPerTrigger
% fprintf(1, '%s - acq_configureAimux/recordAcquirerData: Acquired all (%s) samples.\n', datestr(now), length(buffers.(bufferName).data));
    fnames = fieldnames(buffers);
    for i = 1 : length(fnames)
        if (length(buffers.(fnames{i}).data) ~= samplesPerTrigger | buffers.(fnames{i}).resetOnNextSamplesAcquired) & acqOnArray(i)
            return;
        end
    end
    
    drawnow expose;%This will let interrupting calls get executed, such as other SamplesAcquiredFcn calls. %TO042309A - Not using expose can cause C-spawned events to fire out of order.
    %flushAllInputChannels(getDaqmanager);%TO012706A
    %xsg_removeExpectedDataSource('acq');%TO012606B, TO012706B
    
    %xsg_saveData;%TO012706B
% fprintf(1, '%s - acq_configureAimux/recordAcquirerData: segmentedAcquisition = %s; acquisitionsRemainingCounter = %s\n', datestr(now), num2str(segmentedAcquisition), num2str(acquisitionsRemainingCounter));
    if ~segmentedAcquisition
        acq_Stop(hObject);
    else
        %TO091106F
        if get(ai, 'TriggerRepeat') < acquisitionsRemainingCounter - 1 & acquisitionsRemainingCounter > 1
% fprintf(1, '%s - acq_configureAimux/recordAcquirerData: Updating TriggerRepeat to %s...\n', datestr(now), num2str(acquisitionsRemainingCounter - 1));
            startFcn = get(ai, 'StartFcn');
            stopFcn = get(ai, 'StopFcn');
            stop(ai);
            set(ai, 'TriggerRepeat', acquisitionsRemainingCounter - 1);
            start(ai);
            set(ai, 'StartFcn', startFcn, 'StopFcn', stopFcn);
        end
        
        buffers.(bufferName).resetOnNextSamplesAcquired = 1;
        %TO080306A
        acquisitionsRemainingCounter = acquisitionsRemainingCounter - 1;
        if acquisitionsRemainingCounter < 1
% fprintf(1, '%s - acq_configureAimux/recordAcquirerData: Stopping...\n', datestr(now));
            setLocalBatch(progmanager, hObject, 'acquisitionsRemainingCounter', 0, 'SegmentedAcquisition', 0, 'saveBuffers', buffers);
            acq_Stop(hObject);
        else
% fprintf(1, '%s - acq_configureAimux/recordAcquirerData: Replacing data source...\n', datestr(now));
            %TO110206A - Moved this inside the segmentedAcquisition condition, because it will be called by acq_Stop otherwise, and double calls can cause unexpected consequences. -- Tim O'Connor 11/2/06
            removeExpectedDataSource(startmanager('acquisition'), 'acq');%TO012706B
            addExpectedDataSource(startmanager('acquisition'), 'acq');
            setLocalBatch(progmanager, hObject, 'acquisitionsRemainingCounter', acquisitionsRemainingCounter, 'SegmentedAcquisition', 0, 'Status', 'Waiting...', 'saveBuffers', buffers);
            drawnow expose;%TO042309A - Not using expose can cause C-spawned events to fire out of order.
% fprintf(1, '%s - acq_configureAimux/recordAcquirerData - Status set to ''Waiting...''\n', datestr(now));
        end
    end
end

return;
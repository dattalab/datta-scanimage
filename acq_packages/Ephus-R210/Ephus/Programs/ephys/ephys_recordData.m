% ephys_recordData - Store data that is dispatched to this listener, for saving later.
%
% SYNTAX
%  ephys_recordData(hObject)
%
% USAGE
%
% NOTES
%  Refactored out of ephys_configureAimux. -- Tim O'Connor 8/14/07 TO073107B
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
%  TO033006A - Pass the name of the most recently updated buffer to the ephys:SamplesAcquired UserFcn. -- Tim O'Connor 3/30/06
%  TO080306A - Allow multiple acquisitions to be prequeued, and sequentially triggered. -- Tim O'Connor 8/3/06
%  TO091106F - Update the TriggerRepeat property on AI objects in the event that segmentedAcquisition has been set externally. See TO091106E. -- Tim O'Connor 9/11/06
%  TO102306A - Apparently, the SamplesPerTrigger value can not be relied on to count SamplesAcquiredFcn calls. Add a field to the buffer instead. --Tim O'Connor 10/23/06
%  TO110206A - Moved startmanager event conditions, but this may not have been strictly necessary (see other TO110206A). -- Tim O'Connor 11/2/06
%  TO110906A - Get the channel's SamplesPerTrigger, not the (possibly shared) ai object's. -- Tim O'Connor 11/9/06
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%  TO080607A - Watch 64-bit datatypes that don't support most math operations. -- Tim O'Connor 8/5/07
%  TO101407A - Nimex port. The done event can be relied upon to stop the acquisition now. -- Tim O'Connor 10/14/07
%
% Created 8/14/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function ephys_recordData(hObject, bufferName, channelName, data, sampleRate)
% lg = lg_factory;
% fprintf(1, '\n=================\niteration: %s\n', num2str(getLocal(progmanager, lg, 'iterationCounter')));
% fprintf(1, '%s - ephys_configureAimux/recordEphysData: %s samples\n', datestr(now), num2str(length(data)));
warning('Deprecated.');
buffers = getLocal(progmanager, hObject, 'saveBuffers');
if buffers.(bufferName).resetOnNextSamplesAcquired
% fprintf(1, '%s - ephys_configureAimux/recordEphysData - Clearing buffer...\n', datestr(now));
    buffers.(bufferName).resetOnNextSamplesAcquired = 0;
    buffers.(bufferName).data = [];
    buffers.(bufferName).debug.resetStackTrace = getStackTraceString;
    buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
    buffers.(bufferName).debug.channelName = channelName;%TO101407A - Might as well track this here.
    buffers.(bufferName).debug.sampleRate = sampleRate;%TO101407A - Might as well track this here.
end

buffers.(bufferName).data = cat(1, buffers.(bufferName).data, data);

%TO101407A - Moved this up here, since the saveBuffers field is now only set up here, the counters would be lost otherwise.
buffers.(bufferName).resetOnNextSamplesAcquired = 1;
buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter + 1;%TO102306A

setLocal(progmanager, hObject, 'saveBuffers', buffers);

% fprintf(1, '%s - ephys_configureAimux/recordEphysData: Acquired %s samples (%s of %s samples) for ''%s''.\n', datestr(now), num2str(length(data)), num2str(length(buffers.(bufferName).data)), num2str(get(ai, 'SamplesPerTrigger')), bufferName);
fireEvent(getUserFcnCBM, 'ephys:SamplesAcquired', data, bufferName);%TO031306A %TO033006A
% fprintf(1, '%s - ephys_configureAimux/recordEphysData: Complete.\n', datestr(now));
return;

%% TO101407A - Nimex port, the done event can be relied upon to stop the acquisition now.
% As of TO101407A all the following junky code is no longer necessary. Everything's nice and clean!
%TO032206B: Have to check all channels before stopping. -- Tim O'Connor 3/22/06
%TO123005B
%TO032306C - Update conditions for alternate channel checking when stopping. See TO032206B. -- Tim O'Connor 3/23/06
% [acqOnArray, segmentedAcquisition, acquisitionsRemainingCounter] = getLocalBatch(progmanager, hObject, 'acqOnArray', ...
%    'segmentedAcquisition', 'acquisitionsRemainingCounter');%TO080306A

%TO110906A - Get the channel's samplesPerTrigger, not the (possibly shared) ai object's. -- Tim O'Connor 11/9/06
%TO080607A - Watch 64-bit datatypes that don't support most math operations. -- Tim O'Connor 8/5/07
%samplesPerTrigger = double(getTaskProperty(daqjob('acquisition'), channelName, 'sampsPerChanToAcquire'));
% if ~segmentedAcquisition
%    samplesPerTrigger = samplesPerTrigger * buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter;%TO102306A
% end
% fprintf(1, '%s - ephys_configureAimux/recordEphysData - %s == %s\n', datestr(now), num2str(length(buffers.(bufferName).data)), num2str(samplesPerTrigger));
%if length(buffers.(bufferName).data) == samplesPerTrigger
% fprintf(1, 'ephys_configureAimux/recordEphysData - Recieved all samples.\n');
% fprintf(1, '%s - ephys_configureAimux/recordEphysData: Acquired all (%s) samples.\n', datestr(now), num2str(length(buffers.(bufferName).data)));
%    fnames = fieldnames(buffers);
%    for i = 1 : length(fnames)
%        if (length(buffers.(fnames{i}).data) ~= samplesPerTrigger || buffers.(fnames{i}).resetOnNextSamplesAcquired) && acqOnArray(i)
%            return;
%        end
%    end
%    drawnow expose;%This will let interrupting calls get executed, such as other SamplesAcquiredFcn calls. %TO042309A - Not using expose can cause C-spawned events to fire out of order.
    %flushAllInputChannels(getDaqmanager);%TO012706A
    %xsg_removeExpectedDataSource('ephys');%TO012606B, TO012706B
% fprintf(1, '%s - ephys_configureAimux/recordEphysData: segmentedAcquisition = %s; acquisitionsRemainingCounter = %s\n', datestr(now), num2str(segmentedAcquisition), num2str(acquisitionsRemainingCounter));
    %xsg_saveData;%TO012706B
    
    % if ~segmentedAcquisition
        %ephys_Stop(hObject);
    % else
        %TO091106F
%         if get(ai, 'TriggerRepeat') < acquisitionsRemainingCounter - 1 & acquisitionsRemainingCounter > 1
% % fprintf(1, '%s - ephys_configureAimux/recordEphysData: Updating TriggerRepeat to %s...\n', datestr(now), num2str(acquisitionsRemainingCounter - 1));
%             startFcn = get(ai, 'StartFcn');
%             stopFcn = get(ai, 'StopFcn');
%             stop(ai);
%             set(ai, 'TriggerRepeat', acquisitionsRemainingCounter - 1);
%             start(ai);
%             set(ai, 'StartFcn', startFcn, 'StopFcn', stopFcn);
%         end
        
% fprintf(1, '%s - ephys_configureAimux/recordEphysData - Requesting buffer reset on next acquisition...\n', datestr(now));
        % buffers.(bufferName).resetOnNextSamplesAcquired = 1;
        %TO101407A
        %TO080306A
        % acquisitionsRemainingCounter = acquisitionsRemainingCounter - 1;
        % if acquisitionsRemainingCounter < 1
% fprintf(1, '%s - ephys_configureAimux/recordEphysData: Stopping...\n', datestr(now));
        %     setLocalBatch(progmanager, hObject, 'acquisitionsRemainingCounter', 0, 'SegmentedAcquisition', 0, 'saveBuffers', buffers);
        %     ephys_Stop(hObject);
        % else
% fprintf(1, '%s - ephys_configureAimux/recordEphysData: Replacing data source...\n', datestr(now));
        %     %TO110206A - Moved this inside the segmentedAcquisition condition, because it will be called by acq_Stop otherwise, and double calls can cause unexpected consequences. -- Tim O'Connor 11/2/06
        %     removeExpectedDataSource(startmanager('acquisition'), 'ephys');%TO012706B
        %     addExpectedDataSource(startmanager('acquisition'), 'ephys');
        %     setLocalBatch(progmanager, hObject, 'acquisitionsRemainingCounter', acquisitionsRemainingCounter, 'SegmentedAcquisition', 0, 'Status', 'Waiting...', 'saveBuffers', buffers);
        %     drawnow expose;%TO042309A - Not using expose can cause C-spawned events to fire out of order.
% fprintf(1, '%s - ephys_configureAimux/recordEphysData - Status set to ''Waiting...''\n', datestr(now));
        % end
%    end
%end

%return;
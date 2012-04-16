% @daqjob/dispatchData - Read data from the task, preprocess it, and pass it to interested listeners.
%
% SYNTAX
%  dispatchData(job, channelName)
%    job - @daqjob instance.
%    channelName - A channel name that identifies the task for which to dispatch data.
%                  All channel data on the task will be read and dispatched, not just the channelName specified.
%
% USAGE
%  This is intended as temporary stopgap implementation in Matlab, before switching over to the direct NIMEX implementation.
%
% NOTES
%
% CHANGES
%  TO103007A - Dumb change of variable errors. -- Tim O'Connor 10/30/07
%  TO042808A - Only dispatch to enabled channels. -- Tim O'Connor 4/28/08
%  TO060108I - Don't print a warning if the event is recieved but the task/job has been stopped. This is a common, and harmless, race condition. -- Tim O'Connor 6/1/08
%  VI060608A - Handle input overflow based on the inputOverflowMode property -- Vijay Iyer 6/6/08
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%  VI080808A - inputOverlowMode has been renamed to readErrorMode -- Vijay Iyer 8/8/08
%
% CREDITS
% Created 8/14/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function dispatchData(this, channelName)
global daqjobGlobalStructure;
% fprintf(1, '%s - @daqjob/dispatchData\n', datestr(now));

if ~isEvent(daqjobGlobalStructure(this.ptr).callbackManager, channelName)
    channelName = getDeviceNameByChannelName(this, channelName);
    if ~isEvent(daqjobGlobalStructure(this.ptr).callbackManager, channelName)
        mnemonicChannel = channelNamesToPseudoChannels(this, channelName);
        if isEvent(daqjobGlobalStructure(this.ptr).callbackManager, mnemonicChannel)
            channelName = mnemonicChannel;
        else
            return;
        end
    end
end

task = getTaskByDeviceName(this, channelName);

try
    [channels, samples, sampleRate] = nimex_getTaskProperty(task, 'channels', 'everyNSamples', 'samplingRate');
    samples = double(samples);
    sampleRate = double(sampleRate);
    try
        data = nimex_readAnalogF64(task, samples);
    catch
        if ~daqjobGlobalStructure(this.ptr).started
            %TO060108I
            % fprintf(2, '@daqjob/dispatchData: Warning - Failed to read data.\n\tNote: The everyN event was recieved even though this @daqjob is not currently running.\n%s\n', getLastErrorStack);
        else
            %VI060608A - note that we're assuming the error is -200279, a failure to read 
            switch daqjobGlobalStructure(this.ptr).readErrorMode %VI080808A
                case 'drop'
                    fprintf(2, 'Warning - @daqjob/dispatchData: Failed to read data from job ''%s''. Ignoring...\n', daqjobGlobalStructure(this.ptr).name);                    
                case 'error'                
                    fprintf(2, '@daqjob/dispatchData: Failed to dispatch data - %s\n\tStopping @daqjob ''%s''\n', getLastErrorStack, daqjobGlobalStructure(this.ptr).name);
                    stop(this);
            end
        end
        return;
    end

    k = 0;
    for i = 1 : length(channels)
        if nimex_getChannelProperty(task, channels{i}, 'enable') %TO042808A
            k = k + 1;
            preprocessors = getCallbacks(daqjobGlobalStructure(this.ptr).preprocessors, channels{i});
            channelData = data((k * samples) - samples + 1 : k * samples);
            for j = 1 : length(preprocessors)
                channelData = feval(preprocessors{j}{:}, channelData);
            end
            % fprintf(1, '@daqjob/dispatchData: Executing listener for channel ''%s''...\n', channels{i});
            if isEvent(daqjobGlobalStructure(this.ptr).callbackManager, channels{i})
                fireEvent(daqjobGlobalStructure(this.ptr).callbackManager, channels{i}, channelData, sampleRate);
            end
            pseudoNames = getPseudoNamesByDeviceName(this, channels{i});
            if isEvent(daqjobGlobalStructure(this.ptr).callbackManager, pseudoNames)
                fireEvent(daqjobGlobalStructure(this.ptr).callbackManager, pseudoNames, channelData, sampleRate);
            end            
        end
    end
catch
    fprintf(2, '@daqjob/dispatchData: Failed to dispatch data - %s\n\tStopping @daqjob ''%s''\n', getLastErrorStack, daqjobGlobalStructure(this.ptr).name);
    stop(this);
end

return;
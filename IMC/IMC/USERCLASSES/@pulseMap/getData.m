%  @pulseMap/getData - Retrieve the data for a specified channel name.
%
% SYNTAX
%  data = getdata(pm, channelName)
%  data = getdata(pm, channelName, job)
%  data = getdata(pm, channelName, time)
%  data = getdata(pm, channelName, samples, 'Samples')
%  data = getdata(pm, channelName, job, actualChannelName)
%   pm - @pulseMap instance.
%   channelName - The channel for which to retrieve data.
%   job - A @daqjob instance.
%         In this form, the amount of data to retrieve is determined by examining the @daqjob.
%   time - The amount of data to retrieve, in seconds.
%   samples - The amount of data to retrieve, in samples.
%             Only applies when an extra argument is supplied and that argument is the string 'Samples'.
%   actualChannelName - Another channel name, corresponding to the actual underlying channel, for times when the mnemonic name in a GUI doesn't match the hardware configuration.
%
% NOTES
%  Typically, this will just call through to a @signalobject instance. But, it may also evaluate a callback instead.
%  For callbacks, they must support the same arguments as the @signalobject/getdata function.
%  The first use of this callback feature is intended for the pulseJacker, to allow it insert its own callback, 
%  then within its custom callback it will choose the pulse from which to retrieve the data at runtime.
%
% CHANGES
%  TO110907D - Added a try/catch. -- Tim O'Connor 11/9/07
%  TO072208A - Allow multiple digital lines to appear separate in the GUI, but actually be grouped underneath. Implemented actualChannelName. -- Tim O'Connor 7/22/08
%
% Created
%  Timothy O'Connor 8/13/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function data = getData(this, channelName, varargin)
% getStackTraceString
data = [];
pulse = getPulse(this, channelName);
if isempty(pulse)
    warning('pulseMap: Pulse for ''%s'' not found.', channelName);
    return;
end

iterations = 1;
[lg, lm] = lg_factory;
if get(lm, 'preciseTimeMode') && getLocal(progmanager, lg, 'startLoop')
    iterations = get(lm, 'iterations');
end

try
    if strcmpi(class(varargin{1}), 'daqjob')
        if length(varargin) > 1
            actualChannelName = varargin{2};
        else
            actualChannelName = channelName;
        end
        [sampleRate, samplesPerChannel] = getTaskProperty(varargin{1}, actualChannelName, 'samplingRate', 'sampsPerChanToAcquire');
        sampleRate = double(sampleRate);
        samplesPerChannel = double(samplesPerChannel);
        switch lower(class(pulse))
            case 'signalobject'
                for i = 1 : length(pulse)
                    set(pulse, 'sampleRate', sampleRate);
                    data = cat(2, getdata(pulse(i), samplesPerChannel / sampleRate));
                end
% fprintf(1, '@pulseMap/getData(..., ''%s'', ...) - @signalobject/getData = %s samples from ''%s''\n', channelName, num2str(length(data)), get(pulse(i), 'name'));
            case 'cell'
                data = feval(pulse{:}, samplesPerChannel / sampleRate);
% fprintf(1, '@pulseMap/getData(..., ''%s'', ...) - feval({@%s, ...}) = %s samples\n', channelName, func2str(pulse{1}), num2str(length(data)));
% fprintf(1, 'DEBUG: @pulseMap/getData(..., ''%s'', ...) - feval({@%s, ..., ''%s''}) = %s samples\n', channelName, func2str(pulse{1}), pulse{5}, num2str(length(data)));
            case 'function_handle'
                data = feval(pulse, samplesPerChannel / sampleRate);
% fprintf(1, '@pulseMap/getData(..., ''%s'', ...) - feval(@%s) = %s samples\n', channelName, func2str(pulse), num2str(length(data)));
            otherwise
                error('Invalid type found in pulseMap ''%s'' for channel ''%s''.', pulseMapGlobalStructure(this.ptr).name, channelName);
        end
    else
        switch lower(class(pulse))
            case 'signalobject'
                for i = 1 : length(pulse)
                    data = cat(2, getdata(pulse(i), varargin{:}));
                end
% fprintf(1, '@pulseMap/getData(..., ''%s'', ...) - @signalobject/getData = %s samples from ''%s''\n', channelName, num2str(length(data)), get(pulse(i), 'name'));
            case 'cell'
                data = feval(pulse{:}, varargin{:});
% fprintf(1, '@pulseMap/getData(..., ''%s'', ...) - feval({@%s, ...}) = %s samples\n', channelName, func2str(pulse{1}), num2str(length(data)));
% fprintf(1, 'DEBUG: @pulseMap/getData(..., ''%s'', ...) - feval({@%s, ..., ''%s''}) = %s samples\n', channelName, func2str(pulse{1}), pulse{5}, num2str(length(data)));
            case 'function_handle'
                data = feval(pulse, varargin{:});
% fprintf(1, '@pulseMap/getData(..., ''%s'', ...) - feval(@%s) = %s samples\n', channelName, func2str(pulse), num2str(length(data)));
            otherwise
                error('Invalid type found in pulseMap ''%s'' for channel ''%s''.', pulseMapGlobalStructure(this.ptr).name, channelName);
        end
    end
catch
    err = lasterror;
    fprintf(2, 'Warning - @pulseMap/getData: Failed to get data for ''%s'' - %s\n%s\n', lasterr, getStackTraceString(err.stack));
end

return;
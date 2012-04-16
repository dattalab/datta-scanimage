% @daqjob/setMasterSampleClock - Set a nimex task to be used as a master sample clock.
% 
% SYNTAX
%  setMasterSampleClock(dj, task)
%  setMasterSampleClock(dj, counterTimerName, frequency)
%  setMasterSampleClock(dj, counterTimerName, frequency, dutyCycle)
%   dj - @daqjob instance.
%   task - @nimex instance.
%   counterTimerName - The NIDAQmx terminal name of a free counter-timer.
%   frequency - The desired frequency of the clock signal.
%   dutyCycle - The desired dutyCycle of the clock signal (ratio of high-time to low-time).
%               Default: 0.5
%  
% NOTES
%  The type of nimex task does not necessarily matter, but is assumed to be a counter/timer.
%  In any case, the task must be able to be started/stopped as many times as necessary and be
%  configured for the correct frequency.
%
%  See TO050508G.
%
%   The 'Master Sample Clock' is really just a task that will be started/stopped with every other task in this @daqjob. 
%   In fact, it could be any task. However, it is primarily intended to be a frequency counter task, to be used as a sample clcok for one or more of the job's tasks (e.g. of a digital output task)  
%   By using the option of supplying a pre-created @nimex task, one can supply a task array. This would be a way to support multiple 'master' sample clocks.
%   In the future, this could be extended to allow multiple sample clocks to be specified (i.e. arrays of sourceSpec, destTerminals, etc)
%
%   See also getMasterSampleClock and updateMasterSampleClock.
%
% CHANGES
%   TO033008B - Allow convenient creation of a counter/timer. -- Tim O'Connor 7/30/08
%  
% Created
%  Timothy O'Connor 5/5/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function setMasterSampleClock(this, varargin)
global daqjobGlobalStructure;

if length(varargin) == 1 && strcmpi(class(varargin{1}), 'nimex')
    daqjobGlobalStructure(this.ptr).masterSampleClock = varargin{1};
else
    if length(varargin) ~= 2 && length(varargin) ~= 3
        error('Invalid number of arguments.');
    end

    daqjobGlobalStructure(this.ptr).masterSampleClock = nimex;
    nimex_addCOFrequency(daqjobGlobalStructure(this.ptr).masterSampleClock, varargin{1});
    updateMasterSampleClock(this, 'idleState', 'DAQmx_Val_Low', 'sampleMode', 'DAQmx_Val_ContSamps');

    if ~isempty(daqjobGlobalStructure(this.ptr).triggerDestination)
        nimex_setTaskProperty(daqjobGlobalStructure(this.ptr).masterSampleClock, 'triggerSource', daqjobGlobalStructure(this.ptr).triggerDestination);
    end

    updateMasterSampleClock(this, varargin{2:end});%Set frequency and dutyCycle.
end

return;
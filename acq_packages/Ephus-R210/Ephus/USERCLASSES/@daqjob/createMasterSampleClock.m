% @daqjob/createMasterSampleClock - Creates a nimex counter task, and sets it as the job's master sample clock.
% 
%% SYNTAX
%  createMasterSampleClock(dj, terminalName, frequency)
%  createMasterSampleClock(dj, terminalName, frequency, dutyCycle)
%   dj - @daqjob instance.
%   task - @nimex instance.
%   deviceOrCounterName - A fully specified DAQmx counter terminal name (e.g. '/dev1/ctr0'), which will serve as the master sample clock source.
%   frequency - The desired frequency of the clock signal.
%   dutyCycle - The desired dutyCycle of the clock signal (ratio of high-time to low-time).
%               Default: 0.1
%  
%% NOTES
%  The 'masterSampleClock' is a NIMEX counter task, which is started/stopped along with the other daqjob tasks.
%   
%  Creating a clock via this function removes any previously created clocks. At present, there is /one/ masterSampleClock per job.
%
%  A default dutyCyle of 0.2 is employed. This allows timebase 'ticks' to be clearly identified, but does not require excessive signal bandwidth. 
%
%  See also updateMasterSampleClock.
%
%% CHANGES
%   VI082708A Vijay Iyer 8/27/08 -- Apply default dutyCycle value here, rather than in updateMasterSampleClock()
%   VI102308A Vijay Iyer 10/23/08 - Handle new triggerDestinations property
%  
%% CREDITS
%  Timothy O'Connor/Vijay Iyer -- 8/11/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function createMasterSampleClock(this, terminalName, frequency, varargin)
global daqjobGlobalStructure;

%Check input argument
if ~isnumeric(frequency) || frequency < 0
    error('Invalid frequency value supplied. Unable to create Master Sample Clock task');
end

%Create new sample clock
try
    masterSampleClock = nimex;
    nimex_addCOFrequency(masterSampleClock, terminalName);
    nimex_setTaskProperty(masterSampleClock, 'idleState', 'DAQmx_Val_Low', 'sampleMode', 'DAQmx_Val_ContSamps');
    if ~isempty(daqjobGlobalStructure(this.ptr).triggerDestinations) %VI102308A
        %nimex_setTaskProperty(masterSampleClock, 'triggerSource', daqjobGlobalStructure(this.ptr).triggerDestination);
        nimex_setTaskProperty(masterSampleClock, 'triggerSource', getTriggerDestination(this));
    end
catch
    error('Unable to create Master Sample Clock task');
    if isa(masterSampleClock,'nimex')
        nimex_delete(masterSampleClock);
    end
end 

%Remove previous clock if necessary
prevClock = daqjobGlobalStructure(this.ptr).masterSampleClock;
if ~isempty(prevClock) && ~isempty(masterSampleClock)
    nimex_stopTask(prevClock);
    nimex_delete(prevClock);
end

%Set new clock as the job's masterSampleClock
daqjobGlobalStructure(this.ptr).masterSampleClock = masterSampleClock;

%Update frequency/duty cycle
%%%%VI082708A%%%%%%%%%
dutyCycle = 0.2;
if ~isempty(varargin)
    if isnumeric(varargin{1}) && varargin{1} > 0 && varargin{1} < 1
        dutyCycle = varargin{1};
    else
        fprintf(2,'WARNING: Invalid duty cycle value supplied. Using default value %d instead.',dutyCycle);
    end
end      
%%%%%%%%%%%%%%%%%%%%%%
updateMasterSampleClock(this,frequency,dutyCycle); %VI082708A


return;
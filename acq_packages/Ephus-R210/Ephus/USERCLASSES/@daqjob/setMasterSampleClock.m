% @daqjob/setMasterSampleClock - Set a nimex task to be used as a master sample clock.
% 
%% SYNTAX
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
%% NOTES
%  DEPRECATED - Use createMasterSampleClock() or set() instead
%   
%% CHANGES
%   TO033008B - Allow convenient creation of a counter/timer. -- Tim O'Connor 7/30/08
%   VI082808A - Remove counter/time conveience from this function. This now resides in createMasterSampleClock -- Vijay Iyer 8/28/08
%   
%% CREDITS
%  Timothy O'Connor 5/5/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function setMasterSampleClock(this, task)
global daqjobGlobalStructure;

if strcmpi(class(task),'nimex')
    daqjobGlobalStructure(this.ptr).masterSampleClock = task;
else
    error('Input must be of class ''nimex''');
end    

% if length(varargin) == 1 && strcmpi(class(varargin{1}), 'nimex')
%     daqjobGlobalStructure(this.ptr).masterSampleClock = varargin{1};
% else
%     
%     if length(varargin) ~= 2 && length(varargin) ~= 3
%         error('Invalid number of arguments.');
%     end
% 
%     daqjobGlobalStructure(this.ptr).masterSampleClock = nimex;
%     nimex_addCOFrequency(daqjobGlobalStructure(this.ptr).masterSampleClock, varargin{1});
%     updateMasterSampleClock(this, 'idleState', 'DAQmx_Val_Low', 'sampleMode', 'DAQmx_Val_ContSamps');
% 
%     if ~isempty(daqjobGlobalStructure(this.ptr).triggerDestination)
%         nimex_setTaskProperty(daqjobGlobalStructure(this.ptr).masterSampleClock, 'triggerSource', daqjobGlobalStructure(this.ptr).triggerDestination);
%     end
% 
%     updateMasterSampleClock(this, varargin{2:end});%Set frequency and dutyCycle.
% end

return;
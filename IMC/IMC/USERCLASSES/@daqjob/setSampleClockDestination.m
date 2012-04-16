% @daqjob/setSampleClockDestination - Set the "relative" destination of the sample clock, for all tasks in this job.
% 
% SYNTAX
%  setSampleClockDestination(job, sampleClockDestination)
%   job - A @dajob instance.
%   clockDestination - The NIDAQmx terminal on which to accept the clock.
%                      This value is relative to the device.
%                      For example: 'PFI6' would map to '/dev1/PFI6' on dev1.
%
% NOTES
%  The sample rate of acquisitions using an external sample clock is determined by the clock, not the task's `samplingRate` setting.
%  When using an external clock, as per NIDAQmx documentation, the `samplingRate` should be set to the maximum expected rate of the clock.
%
% CHANGES
%  TO050508C - Renamed this function from setClockDestination. Reworked the clock synchronization to allow for a sampleClock and a timebaseClock (20MHz). -- Tim O'Connor 5/5/08
%  TO083007C - Forcibly update the underlying task property immediately. -- Tim O'Connor 7/30/08
%  
% Created
%  Timothy O'Connor 10/15/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function setSampleClockDestination(this, sampleClockDestination)
global daqjobGlobalStructure;

daqjobGlobalStructure(this.ptr).sampleClockDestination = sampleClockDestination;

%TO083007C
for i = 1 : size(daqjobGlobalStructure(this.ptr).taskMap, 1)
    updateTaskProperties(this, daqjobGlobalStructure(this.ptr).taskMap{i, 1}, daqjobGlobalStructure(this.ptr).taskMap{i, 2}, 'clockSource');
end

return;
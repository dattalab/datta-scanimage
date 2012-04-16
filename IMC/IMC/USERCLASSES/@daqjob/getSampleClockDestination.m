% @daqjob/getSampleClockDestination - Get the "relative" destination of the sample clock, for all tasks in this job.
% 
% SYNTAX
%  sampleClockDestination = getSampleClockDestination(job)
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
%  
% Created
%  Timothy O'Connor 8/1/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function sampleClockDestination = getSampleClockDestination(this)
global daqjobGlobalStructure;

sampleClockDestination = daqjobGlobalStructure(this.ptr).sampleClockDestination;

return;
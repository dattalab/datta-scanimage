% @daqjob/setClockOrigin - Set the source of the "global" clock, for all tasks in this job.
% 
% SYNTAX
%  setClockOrigin(job, clockOrigin)
%   job - A @dajob instance.
%   clockOrigin - The NIDAQmx terminal on which to export the clock.
%                 For example: '/dev1/PFI7'
%  
% NOTES
%  Deprecated. Although it may be resurrected in the future. -- Tim O'Connor 5/5/08 (see TO050508C)
%
% CHANGES
%  
% Created
%  Timothy O'Connor 7/30/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function setClockOrigin(this, clockOrigin)
global daqjobGlobalStructure;
error('@daqjob/setClockOrigin - This function has been deprecated.');
daqjobGlobalStructure(this.ptr).clockOrigin = clockOrigin;

return;
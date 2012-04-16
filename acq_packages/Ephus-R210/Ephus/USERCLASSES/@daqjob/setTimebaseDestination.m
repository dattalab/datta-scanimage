% @daqjob/setTimebaseDestination - Set the input of the "global" 20MHz clock, for all tasks in this job.
% 
%% SYNTAX
%  setTimebaseDestination(job, timebaseDestination)
%   job - A @dajob instance.
%   timebaseDestination - The NIDAQmx terminal on which to recieve the clock.
%                         As per NIMEX, setting this to '' causes the board to use its internal timebase.
%                         For example: '/dev1/PFI6'
%  
%% NOTES
%  See TO050508C.
%
%% CHANGES
%  
%% CREDITS
%  Timothy O'Connor 5/5/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function setTimebaseDestination(this, timebaseDestination)
global daqjobGlobalStructure;
error('@daqjob/setTimebaseDestination - Deprecated. Use nimex_connectTerms.');
daqjobGlobalStructure(this.ptr).timebaseDestination = timebaseDestination;

return;
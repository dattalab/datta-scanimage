% @daqjob/getMasterSampleClock - Get the nimex task to be used as the master sample clock.
% 
% SYNTAX
%  task = getMasterSampleClock(dj)
%   dj - @daqjob instance.
%   task - @nimex instance.
%  
% NOTES
%  The type of nimex task does not necessarily matter, but is assumed to be a counter/timer.
%  In any case, the task must be able to be started/stopped as many times as necessary and be
%  configured for the correct frequency.
%
%  See TO050508G.
%
% CHANGES  
%  
% Created
%  Timothy O'Connor 5/5/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function task = getMasterSampleClock(this)
global daqjobGlobalStructure;

task = daqjobGlobalStructure(this.ptr).masterSampleClock;

return;
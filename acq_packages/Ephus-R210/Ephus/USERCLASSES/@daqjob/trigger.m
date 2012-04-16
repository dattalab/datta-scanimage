%  - 
% 
% SYNTAX
%  
% NOTES
%
% CHANGES
%  
% Created
%  Timothy O'Connor 7/30/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function trigger(this)
global daqjobGlobalStructure;
% fprintf(1, '@daqjob/trigger\n');

% if ~daqjobGlobalStructure(this.ptr).started
%     warning('Attempting to trigger an unstarted daqjob (''%s'').', daqjobGlobalStructure(this.ptr).name);
% end

% commit(this);

daqjobGlobalStructure(this.ptr).waitingForTrigger = 0;
daqjobGlobalStructure(this.ptr).triggersExecuted = daqjobGlobalStructure(this.ptr).triggersExecuted + 1;
nimex_sendTrigger(daqjobGlobalStructure(this.ptr).taskMap{1, 2}, daqjobGlobalStructure(this.ptr).triggerOrigin);

fireEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'jobTrigger');

return;
% @nimex/nimex_acquireLock - Allows Matlab callbacks to access the task's synchronization primitive.
%
% SYNTAX
%  nimex_acquireLock(nimextask)
%   nimextask - An instance of the nimex class.
%
% NOTES
%  Relies on NIMEX_acquireLock.mex32.
%
%  Calls to nimex_acquireLock MUST be paired with calls to nimex_releaseLock.
%
% Created
%  Timothy O'Connor 8/1/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_acquireLock(this)

NIMEX_acquireLock(this.NIMEX_TaskDefinition);

% fprintf(1, 'nimex_acquireLock: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
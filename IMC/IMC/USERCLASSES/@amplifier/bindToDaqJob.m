% AMPLIFIER/bindToDaqJob - Subclasses must implement this method, to get running updates.
%
%  SYNTAX
%   bindToDaqJob(this, job)
%    this - AMPLIFIER subclass
%    job - @daqjob instance to be bound to.
%
%  USAGE
%   This method is just a placeholder, and will issue an error if called. All subclasses should override this.
%
%  CHANGES
%
% Created 7/31/07 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function bindToDaqJob(this, job)

error('AMPLIFIER/bindToDaqJob must get overridden by subclasses.');

return;
% loopManager/acquisitionCompleted - Recieve acquisition completion signals from the @startmanager.
%
% SYNTAX
%  acquisitionCompleted(instance)
%
% USAGE
%  This is meant to be bound to, and called by, the @startmanager. The intention is for the object to 
%  get a notification which will let the loopManager know when a precision timed loop has been completed.
%
% NOTES
%  See TO031306A, the first implementation of board-based (precise) timing.
%
% CHANGES
%  TO032006A: Only stop when in preciseTimeMode. -- Tim O'Connor 3/20/06
%  TO110907C: Check if a loop has been started before stopping and propogating events. -- Tim O'Connor 11/9/07
%
% Created 3/13/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function acquisitionCompleted(this, job)
global loopManagers;

%TO032006A
if loopManagers(this.ptr).preciseTimeMode && loopManagers(this.ptr).started
    stop(this);
end

return;
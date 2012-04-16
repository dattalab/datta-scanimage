% loopManager/stop - Stop a loop.
%
% SYNTAX
%  stop(INSTANCE)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO092605C: Added the 'started' field, this should allow the TimerFcn to just return. -- Tim O'Connor 9/26/05
%  TO100705E: Do the object update before the iteration. -- Tim O'Connor 10/7/05
%  TO121505D: Introduced the stopped flag, to disambiguate the loopManager/start/stopFcn function. -- Tim O'Connor 12/15/05
%
% Created 6/21/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function stop(this)
global loopManagers;

loopManagers(this.ptr).stopped = 1;

if ~loopManagers(this.ptr).preciseTimeMode
    stop(loopManagers(this.ptr).timer);
end

%TO092605C
loopManagers(this.ptr).started = 0;

%Clean up?
loopManagers(this.ptr).running = 0;

eventdata.eventType = 'loopStop';
eventdata.eventTime = clock;
eventdata.iterationNumber = 1;
eventdata.loopManager = this;

fireEvent(loopManagers(this.ptr).callbackManager, 'objectUpdate');%TO100705E - Do this before the actual iteration. -- Tim O'Connor 10/7/05
fireEvent(loopManagers(this.ptr).callbackManager, 'loopStop', eventdata);

return;
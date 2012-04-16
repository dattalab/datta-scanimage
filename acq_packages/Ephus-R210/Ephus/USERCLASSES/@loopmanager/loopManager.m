% loopManager/loopManager - Create an instance of a loopManager object, used to coordinate loops across programs.
%
% SYNTAX
%  loopManager
%  loopManager(PROPERTY_NAME, PROPERTY_VALUE)
%
% USAGE
%  All registering programs must support the following event types:
%   loopStart
%   loopStartPreciseTiming
%   loopIterate
%   loopStop
%
%  The event structure passed as the last argument when the registered callback is 
%  executed will have the following fields:
%   eventType - See above.
%   eventTime - The clock time of the event occurence.
%   iterationNumber - The iteration number in the currently executing loop (incrementing from 1).
%   loopManager - The loopManager instance that initiated the loop.
%   totalIterations - The total number of iterations to be executed. This is useful when building signals for board timing. %TO031306A
%   interval - The expected time between iterations. %TO031306A
%
%  It is also possible to register for object state change events. This is done with the `registerObjectListener`
%  method. It is primarily intended for interface purposes, like GUIs, so they may stay up to date when the object
%  is changed underneath them. All the above mentioned events will cause an event to be fired for these types of
%  listeners, as well as all `set` method call events.
%
% STRUCTURE
%  callbackManager - A @callbackManager instance, to manage loop capability registrations.
%  readOnly - A list of fields which can not be set by outside code.
%  preciseTimeMode - A flag determining if precise timing is used.
%                    Default: 0
%  lastStartTime - The time of the last call to the start method.
%  lastStartStackTrace - The stack trace for the last call to the start method.
%  lastIterationTime - The timestamp of the previous iteration (meaningless in preciseTimingMode).
%  iterationCounter - The number of the current iteration in the series.
%  iterations - The total number of iterations to perform.
%  timer - The timer object, used to spawn iteration events, when under CPU time control.
%  busyMode - See the help for timer objects. May be 'Queue', 'Error', or 'Drop'.
%             Default: 'Queue'
%  totalIterationCounter - Tracks the total number of iterations for the entire life of this object.
%  running - A flag to indicate it a loop is in progress.
%
% NOTES
%  This is a singleton object, only one instance may exist.
%
%  All registered listeners will be passed a loop definition structure in their callbacks, for all events.
%  The structure has the following fields:
%   
%
% CHANGES
%  TO092605C: Added the 'started' field, this should allow the TimerFcn to just return. -- Tim O'Connor 9/26/05
%  TO112205E: Changed the default interval value to 3 seconds. -- Tim O'Connor 11/22/05
%  TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%  TO031306A: Implemented board-based (precise) timing. As only one trigger is issued, cycles have no effect. -- Tim O'Connor 3/13/06
%  TO101607A: Nimex port. -- Tim O'Connor 10/16/07
%  TO121909A: Added userFcn level callbacks. -- Tim O'Connor 12/19/09
%
% Created 6/7/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = loopManager(varargin)
global loopManagers;

if ~isempty(loopManagers)
    this.ptr = 1;
    this = class(this, 'loopManager');
    return;
end

this.ptr = 1;

loopManagers(this.ptr).callbackManager = callbackmanager;%TO122205A

addEvent(loopManagers(this.ptr).callbackManager, 'loopStart');
addEvent(loopManagers(this.ptr).callbackManager, 'loopStartPreciseTiming');
addEvent(loopManagers(this.ptr).callbackManager, 'loopIterate');
addEvent(loopManagers(this.ptr).callbackManager, 'loopStop');
addEvent(loopManagers(this.ptr).callbackManager, 'objectUpdate');

addEvent(getUserFcnCBM, 'loopManager:start');%TO121909A
addEvent(getUserFcnCBM, 'loopManager:iterate');%TO121909A
addEvent(getUserFcnCBM, 'loopManager:stop');%TO121909A

loopManagers(this.ptr).readOnly = {'readOnly', 'callbackManager', 'started'};
loopManagers(this.ptr).started = 0;
loopManagers(this.ptr).interval = 3;
loopManagers(this.ptr).preciseTimeMode = 0;
loopManagers(this.ptr).iterationNumber = 1;
loopManagers(this.ptr).lastStartTime = -1;
loopManagers(this.ptr).lastStartStackTrace = '';
loopManagers(this.ptr).lastIterationTime = -1;
loopManagers(this.ptr).iterationCounter = 0;
loopManagers(this.ptr).iterations = 1;
loopManagers(this.ptr).timer = timer('Tag', sprintf('loopManagerTimer_%s', num2str(this.ptr)));
loopManagers(this.ptr).busyMode = 'Queue';
loopManagers(this.ptr).totalIterationCounter = 0;
loopManagers(this.ptr).running = 0;

this = class(this, 'loopManager');

%TO031306A
%TO101607A
% bindCompletionListener(startmanager('acquisition'), {@acquisitionCompleted, this}, 'loopManagerCompletionListener');
bindEventListener(daqjob('acquisition'), 'jobDone', {@acquisitionCompleted, this}, 'loopManagerCompletionListener', 2);

set(this, varargin{:});

return;
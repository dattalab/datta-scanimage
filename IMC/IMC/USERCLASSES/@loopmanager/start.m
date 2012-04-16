% loopManager/start - Start a loop.
%
% SYNTAX
%  start(INSTANCE)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO092605C: Added the 'started' field, this should allow the TimerFcn to just return. -- Tim O'Connor 9/26/05
%  TO100705E: Do the object update before the iteration. -- Tim O'Connor 10/7/05
%  TO100705I: Make sure displays are updated throughout a loop. -- Tim O'Connor 10/7/05
%  TO120205E: Added an ErrorFcn. -- Tim O'Connor 12/2/05
%  TO121505C: Block erroneous stops, wait for loop completion. -- Tim O'Connor 12/15/05
%  TO121505D: Introduced the stop flag. -- Tim O'Connor 12/15/05
%  TO121505F: Implement internal iteration counter, instead of relying on the timerobject's 'TasksExecuted' property. -- Tim O'Connor 12/15/05
%  TO031306A: Implemented board-based (precise) timing. As only one trigger is issued, cycles have no effect. -- Tim O'Connor 3/13/06
%  TO101607A: Nimex port. -- Tim O'Connor 10/16/07
%
% Created 6/9/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function start(this)
global loopManagers;

loopManagers(this.ptr).lastStartStackTrace = getStackTraceString;

loopManagers(this.ptr).stopped = 0;%TO121505C

eventdata.eventTime = clock;
eventdata.iterationNumber = 1;
eventdata.loopManager = this;
eventdata.totalIterations = loopManagers(this.ptr).iterations;
eventdata.interval = loopManagers(this.ptr).interval;

if loopManagers(this.ptr).preciseTimeMode
    eventdata.eventType = 'loopStartPreciseTiming';
    startPrecisionLoop(this, eventdata);
else
    eventdata.eventType = 'loopStart';
    startTimerLoop(this, eventdata);
end

loopManagers(this.ptr).started = 1;%TO092605C
% fireEvent(loopManagers(this.ptr).callbackManager, 'objectUpdate');%TO100705E

return;

%--------------------------------------------------
function startTimerLoop(this, eventdata)
global loopManagers;
% fprintf(1, '%s - @loopManager/start/startTimerLoop\n', datestr(now));

fireEvent(loopManagers(this.ptr).callbackManager, 'loopStart', eventdata);

stop(loopManagers(this.ptr).timer);

set(loopManagers(this.ptr).timer, 'StartDelay', 0, 'Period', loopManagers(this.ptr).interval, 'TasksToExecute', loopManagers(this.ptr).iterations, ...
    'TimerFcn', {@timerFcn, this, eventdata}, 'BusyMode', loopManagers(this.ptr).busyMode, 'ExecutionMode', 'fixedRate', ...
    'StopFcn', {@stopFcn, this, eventdata}, 'ErrorFcn', {@errorFcn, this, eventdata});%TO120205E

loopManagers(this.ptr).started = 1;%TO092605C
loopManagers(this.ptr).running = 1;

fireEvent(loopManagers(this.ptr).callbackManager, 'objectUpdate');%TO100705E

loopManagers(this.ptr).lastStartTime = clock;

% fprintf(1, '%s - @loopManager/start/startTimerLoop start_timer\n', datestr(now));

start(loopManagers(this.ptr).timer);

return;

%--------------------------------------------------
%TO031306A
function startPrecisionLoop(this, eventdata)
global loopManagers;
% fprintf(1, '%s - @loopManager/start/startPrecisionLoop\n', datestr(now));

% error('NOT_YET_SUPPORTED');%TO031306A
fireEvent(loopManagers(this.ptr).callbackManager, 'loopStartPreciseTiming', eventdata);

stop(loopManagers(this.ptr).timer);

loopManagers(this.ptr).started = 1;%TO092605C
loopManagers(this.ptr).running = 1;

loopManagers(this.ptr).lastStartTime = clock;

loopManagers(this.ptr).lastIterationTime = clock;
loopManagers(this.ptr).iterationCounter = NaN;
loopManagers(this.ptr).totalIterationCounter = loopManagers(this.ptr).totalIterationCounter + 1;

fireEvent(loopManagers(this.ptr).callbackManager, 'objectUpdate');%TO100705E

%TO100705I - Make sure displays are updated at this point.
drawnow;

%TO101607A - Nimex port. -- Tim O'Connor 10/16/07
trigger(daqjob('acquisition'));

return;

%--------------------------------------------------
function timerFcn(t, timer_eventdata, this, eventdata)
global loopManagers;
% fprintf(1, '@loopManager/start/timerFcn\n');
% fprintf(1, '%s - @loopManager/start/timerFcn - changing ''displayHardwareBuffer'' property in @daqmanager object...\n', datestr(now));
% if loopManagers(this.ptr).iterationCounter == 3 | loopManagers(this.ptr).iterationCounter == 4
%     set(getDaqmanager, 'displayHardwareBuffer', 1);
% else
%     set(getDaqmanager, 'displayHardwareBuffer', 0);
% end
% fprintf(1, '%s - @loopManager/start/timerFcn - iteration: %s\n', datestr(now), num2str(get(loopManagers(this.ptr).timer, 'TasksExecuted')));
%TO092605C
if ~loopManagers(this.ptr).started || ~loopManagers(this.ptr).running
    stop(this);
    return;
end

%TO100705I - Make sure displays are updated at this point.
drawnow;

loopManagers(this.ptr).lastIterationTime = clock;
loopManagers(this.ptr).iterationCounter = get(loopManagers(this.ptr).timer, 'TasksExecuted');%This was returning huge values. TO121505F
loopManagers(this.ptr).totalIterationCounter = loopManagers(this.ptr).totalIterationCounter + 1;
% fprintf(1, '%s - @loopmanager/start/timerFcn: iterationCounter=%s, totalIterationCounter=%s\n', datestr(now), num2str(loopManagers(this.ptr).iterationCounter), num2str(loopManagers(this.ptr).totalIterationCounter));

eventdata.eventTime = timer_eventdata.Data.time;
eventdata.eventType = 'loopIteration';
eventdata.iterationNumber = loopManagers(this.ptr).iterationCounter;
fireEvent(loopManagers(this.ptr).callbackManager, 'objectUpdate');%TO100705E - Do this before the actual iteration. -- Tim O'Connor 10/7/05
fireEvent(loopManagers(this.ptr).callbackManager, 'loopIterate', eventdata);
trigger(daqjob('acquisition'));%TO101607A - Nimex port. -- Tim O'Connor 10/16/07

%TO100705I - Make sure displays are updated at this point.
% pause(0.001);
% drawnow;

return;

% %--------------------------------------------------
function stopFcn(t, timer_eventdata, this, eventdata)
global loopManagers;

%TO121505C: Block erroneous stops, wait for loop completion. -- Tim O'Connor 12/15/05
counter = 1;
while loopManagers(this.ptr).iterationCounter < loopManagers(this.ptr).iterations && counter < 10 && ...
        ~loopManagers(this.ptr).stopped %TO121505D
    counter = counter + 1;
% fprintf(1, '%s - loopManager/start/stopFcn: Waiting to stop...\n', datestr(now));
    pause(loopManagers(this.ptr).interval * (loopManagers(this.ptr).iterations - loopManagers(this.ptr).iterationCounter));
    
    if counter == 10
        fprintf(1, '%s - loopManager/start/stopFcn Warning: It appears that this loop is taking far longer than the expected time (%s [s] vs %s [s]). Terminating loop forcibly.\n', ...
            datestr(now), num2str(loopManagers(this.ptr).interval * loopManagers(this.ptr).iterations), etime(now, loopManagers(this.ptr).lastStartTime));
    end
end
% fprintf(1, '%s - loopManager/start/stopFcn: stopping...\n', datestr(now));
% fprintf(1, '@loopManager/start/stopFcn\n');
stop(this);

return;

% %--------------------------------------------------
function errorFcn(t, timer_eventdata, this, eventdata)
global loopManagers;

err = lasterr;
if isempty(err)
    err = 'CAUSE_UNKNOWN (may be due to too short of a time interval)';
end
fprintf(2, '%s - Warning: Timer object encountered an error: %s\n                       The loop has been automatically terminated.\n', datestr(now), err);
% stop(this);%Not necessary, the timer will call the StopFcn all by itself.

return;
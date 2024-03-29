function incrementOdorByTrigger(ai, eventdata)
global state gh;


triggerTask = state.olfactometer.triggertask;
stop(triggerTask);

nextValvePosition = state.olfactometer.odorStateList(state.olfactometer.odorPosition+1);
if (nextValvePosition==0)
    nextValvePosition = 1;
end
nextValveBank = state.olfactometer.(['valveBank_' num2str(nextValvePosition)]);

% set the valve radio button (ones based)
set(gh.olfactometer.valvePanel, 'SelectedObject', state.olfactometer.valveButtonGUIHandles(nextValvePosition));

%send the command (ZERO BASED)
sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ...
    ['write Bank' num2str(nextValveBank) '_Valves ' num2str(nextValvePosition-1)]);

state.olfactometer.odorPosition=state.olfactometer.odorPosition+1;

if (state.olfactometer.odorPosition > length(state.olfactometer.odorStateList))
    state.olfactometer.odorPosition=1;
end

start(triggerTask);

return;

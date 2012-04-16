function olfactometerClearValves()

state.olfactometer.valveBank_1
state.olfactometer.valveEnable_1

for i=1:16

sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ...
    ['write Bank' num2str(state.olfactometer.valveBank_i) '_Valves ' num2str(nextValvePosition-1)]);

end
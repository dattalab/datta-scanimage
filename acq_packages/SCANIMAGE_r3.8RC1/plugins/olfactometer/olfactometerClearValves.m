function olfactometerClearValves()
global state gh;

if ~(isfield(state, 'olfactometer'))
    state = struct('olfactometer', struct('host', '192.168.20.85', 'port', 3336, 'lastCommand', '', 'lastResponse', ''));
    gh = struct('olfactometer', struct('lastResponse',struct('ForegroundColor', '')));
end
connectToOlfactometer()

for i=1:8
    disp(['Clearing valve ' num2str(i-1)])
sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ...
     ['write Bank3_Valves ' num2str(i-1)]);
    %['write Bank' num2str(state.olfactometer.valveBank_i) '_Valves ' num2str(nextValvePosition-1)]);
pause(1200)

end

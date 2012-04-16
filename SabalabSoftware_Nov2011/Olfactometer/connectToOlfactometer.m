function connectToOlfactometer()
global state gh;

%If the connection is persistent, we can do most of this just once.
olfactometerHost = state.olfactometer.host;
olfactometerPort = state.olfactometer.port; % 3336

if ~isfield(state.olfactometer, 'olfactometerConnection')
    state.olfactometer.olfactometerConnection = [];
end

olfactometerConn = state.olfactometer.olfactometerConnection;

if ~isempty(olfactometerConn)
    disp('closing existing connection...')
    pnet(olfactometerConn, 'close');
    state.olfactometer.olfactometerConnection = [];
end

if isempty(olfactometerHost)
    return;
end

disp('opening new connection...');
olfactometerConn = pnet('tcpconnect', olfactometerHost, olfactometerPort);
pnet(olfactometerConn, 'setwritetimeout', 1);
pnet(olfactometerConn, 'setreadtimeout', 3);
pnet(olfactometerConn, 'read', 256, 'view');

state.olfactometer.olfactometerConnection = olfactometerConn;

updateMFCRates();

end
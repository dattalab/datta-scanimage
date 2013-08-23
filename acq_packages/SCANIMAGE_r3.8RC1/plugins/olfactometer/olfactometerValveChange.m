function olfactometerValveChange(handle,EventData)
global state gh;

oldvalve = get(EventData.OldValue,'string');
newValve = get(EventData.NewValue,'string');

%valve nomenclature is 0 order
newValveNumeric = str2num(newValve)-1;

bank = getfield(state.olfactometer, ['valveBank_' newValve]);

%sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write Bank' num2str(bank) '_Valves ' num2str(newValveNumeric)])
fprintf(state.olfactometer.arduino, '%s\n', ['X', valve2hex(newValve)]);

end

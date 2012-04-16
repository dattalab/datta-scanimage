function olfactometerValveChange(handle,EventData)
global state gh;

%disp([EventData.EventName,'  ',...
%disp(get(get(handle,'selectedobject'),'string'));

oldvalve = get(EventData.OldValue,'string');
newValve = get(EventData.NewValue,'string');

%valve nomenclature is 0 order
newValveNumeric = str2num(newValve)-1;

bank = getfield(state.olfactometer, ['valveBank_' newValve]);

sendCommandToOlfactometer(state.olfactometer.olfactometerConnection, ['write Bank' num2str(bank) '_Valves ' num2str(newValveNumeric)])

%set(a.valvepanel, 'selectedobject', a.valveradiobutton(3))

end
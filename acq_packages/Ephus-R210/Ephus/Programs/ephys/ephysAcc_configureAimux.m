% ephysAcc_configureAimux - Configure the AIMUX object for the ephysAccessory GUI.
%
% SYNTAX
%  ephysAcc_configureAimux(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO120205I - Add timer that counts from the last click of the break-in button.
%
% Created 3/1/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephysAcc_configureAimux(hObject)

%Configure the input multiplexing.
aim = getLocal(progmanager, hObject, 'aimux');
amps = getLocal(progmanager, hObject, 'amplifiers');
sc = getMain(progmanager, hObject, 'scopeObject');

% unbindAll(aim);

for i = 1 : length(amps)
%     scaledOutputChannel = getScaledOutputChannelName(amps(i));
%     bindToAIMUX(amps{i}, aim, scaledOutputChannel);%TO120205A
    bindToAIMUX(amps{i}, aim);%TO120205A
    scaledOutputChannel = getScaledOutputChannelName(amps{i});%TO120205A
    bindAimuxChannel(sc(i), scaledOutputChannel, aim);
    %TO070605H: Hook the cell parameter calculation into the GUI. -- Tim O'Connor 7/6/05
% fprintf(1, 'Binding cellparams for amp %s - %s\n', num2str(i), ['ephysAcc_calcCellParams-' get(amps(i), 'name')]);
    bind(aim, scaledOutputChannel, {@ephysAcc_calcCellParams, hObject, i}, ['ephysAcc_calcCellParams-' get(amps{i}, 'name')]);%TO120205A
    bind(aim, scaledOutputChannel, {@ephysAcc_breakInTimer, hObject, i}, ['ephysAcc_breakInTimer-' get(amps{i}, 'name')]);%TO120205I
end

ephysAcc_updateInput(hObject);

return;
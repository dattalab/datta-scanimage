function testEphysAcc(patch)

if ~strcmpi(input('Warning: This script will clear all global variables. Continue? (y/n): ', 's'), 'y')
    return;
end

try
    if ~isempty(daqfind)
        stop(daqfind)
        delete(daqfind)
    end
catch
    warning('Failed in attempt to clear DAQ objects: %s', lasterr);
end
d = daqfind;
if ~isempty(d)
    fprintf(1, 'Stopping all DAQ objects...\n');
    stop(d);
    fprintf(1, 'Deleting all DAQ objects...\n');
    delete(d);
end
fprintf(1, 'Clearing ''all''...\n');
clear all;
fprintf(1, 'Clearing ''global''...\n');
clear global;
fprintf(1, 'Deleting all children of handle 0...\n');
delete(allchild(0));
fprintf(1, 'Clearing ''classes''...\n');
clear classes;
fprintf(1, '\nBeginning test...\n\n');

%------------------------------------------------------------------------------------
%Start the program.
scg = program('scopeGui', 'scopeGui', 'scopeGui', 'ephysScopeAccessory', 'ephysScopeAccessory');
openprogram(progmanager, scg);

%Configure the daqmanager.
% dm = getDaqmanager;
% dm = daqmanager('nidaq');
% dm = getLocal(progmanager, scg, 'daqmanager');
nameInputChannel(dm, 1, 1, 'TestIn11');
enableChannel(dm, 'TestIn11');
nameOutputChannel(dm, 1, 0, 'TestOut10');
enableChannel(dm, 'TestOut10');

%Configure an amplifier.
% patch = axopatch_200B('gain_daq_board_id', 2, 'mode_daq_board_id', 2, 'v_hold_daq_board_id', 2, 'gain_channel', 0, 'mode_channel', 2, 'v_hold_channel', 1, ...
%     'vComBoardID', 1, 'vComChannelID', 1);


patch = axopatch_200B('gain_daq_board_id', 1, 'mode_daq_board_id', 1, 'v_hold_daq_board_id', 2, 'gain_channel', 2, 'mode_channel', 3, 'v_hold_channel', 1, ...
    'vComBoardID', 1, 'vComChannelID', 1);
set(patch, 'scaledOutputChannelID', 1);

%Configure a trigger source.
dio = digitalio('nidaq', 1);
triggerLine = addline(dio, 0, 'out', 'TriggerOutput');
putvalue(triggerLine, 0);

% aim = aimux(dm);
% aom = aomux(dm);
% 
% %Put the configured stuff into the program.
% % setGlobal(progmanager, 'scaledOuputChannels', 'ephysScopeAccessory', 'ScopeGui', {'TestIn11'});
% % setGlobal(progmanager, 'amplifiers', 'ephysScopeAccessory', 'ScopeGui', patch);
% setGlobal(progmanager, 'aimux', 'ephysScopeAccessory', 'ScopeGui', aim);
% setGlobal(progmanager, 'aomux', 'ephysScopeAccessory', 'ScopeGui', aom);

ephysAcc = getGlobal(progmanager, 'hObject', 'ephysScopeAccessory', 'ScopeGui');

% scg2 = program('scopeGui2', 'scopeGui', 'scopeGui', 'ephysScopeAccessory', 'ephysScopeAccessory');
% openprogram(progmanager, scg2);

% patch2 = axopatch_200B('gain_daq_board_id', 2, 'mode_daq_board_id', 1, 'v_hold_daq_board_id', 1, 'gain_channel', 4, 'mode_channel', 2, 'v_hold_channel', 3...
%     'vComBoardID', 1, 'vComChannelID', 0);
% % nameOutputChannel(dm, 1, 1, 'TestOut11');
% % enableChannel(dm, 'TestOut11');
% set(patch2, 'scaledOutputChannelID', 0);

% setGlobal(progmanager, 'aimux', 'ephysScopeAccessory', 'ScopeGui2', aim);
% setGlobal(progmanager, 'aomux', 'ephysScopeAccessory', 'ScopeGui2', aom);
% 
% ephysAcc2 = getGlobal(progmanager, 'hObject', 'ephysScopeAccessory', 'ScopeGui2');

ephysAcc_setAmplifiers(ephysAcc, patch);
% ephysAcc_setAmplifiers(ephysAcc2, patch2);

return;
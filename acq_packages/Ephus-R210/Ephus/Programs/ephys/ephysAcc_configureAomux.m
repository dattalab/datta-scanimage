% ephysAcc_configureAomux - Configure the AOMUX object for the ephysAccessory GUI.
%
% SYNTAX
%  ephysAcc_configureAomux(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO050605B: Created a bindToAomux function in the axopatch_200b class. -- Tim O'Connor 5/6/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% Created 3/1/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephysAcc_configureAomux(hObject)

%Get the output channel names.
%Configure the output multiplexing.
aom = getLocal(progmanager, hObject, 'aomux');
amplifiers = getLocal(progmanager, hObject, 'amplifiers');
if isempty(amplifiers)
    return;
end

pulses = getLocal(progmanager, hObject, 'testPulses');
if isempty(pulses)
    for i = 1 : length(amplifiers)
        testPulses(i) = signalobject;
    end
    setLocal(progmanager, hObject, 'testPulses', testPulses);
else
    testPulses = pulses;
end

for i = 1 : length(amplifiers)
    bindToAOMUX(amplifiers{i}, aom, testPulses(i));%TO120205A, TO122205A
%     commandInputChannel = get(amplifiers(i), 'commandInputChannel');
%     bind(aom, commandInputChannel, testPulses(i));
%     setPreprocessor(aom, commandInputChannel, {@ephysAcc_aomuxPreprocessor, amplifiers{i}}, getParent(hObject, 'figure'));%TO120205A
end

ephysAcc_updateOutput(hObject);

return;
% 
% %---------------------------------------------------------------
% function preprocessed = ephysAcc_aomuxPreprocessor(amp, data)
% % fprintf(1, 'aomuxPreprocessor (before): %s - %s\n', num2str(min(data)), num2str(max(data)));
% if get(amp, 'current_clamp')
%     preprocessed = data * get(amp, 'i_clamp_output_factor');
% else
%     preprocessed = data * get(amp, 'v_clamp_output_factor');
% end
% % fprintf(1, 'aomuxPreprocessor (after): %s - %s\n', num2str(min(preprocessed)), num2str(max(preprocessed)));
% return;
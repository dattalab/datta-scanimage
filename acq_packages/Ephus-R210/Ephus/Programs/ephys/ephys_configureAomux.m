% ephysAcc_configureAomux - Configure the AOMUX object for the ephys GUI.
%
% SYNTAX
%  ephys_configureAomux(hObject)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% Created 5/23/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephys_configureAomux(hObject)

%Get the output channel names.
%Configure the output multiplexing.
amplifiers = getLocal(progmanager, hObject, 'amplifiers');
if isempty(amplifiers)
    return;
end

% signalCollection = getLocal(progmanager, hObject, 'signalCollection');
pulseSetNames = getLocal(progmanager, hObject, 'pulseSetNameArray');
pulseNames = getLocal(progmanager, hObject, 'pulseNameArray');

if isempty(pulseSetNames) | isempty(pulseNames)
    return;
end

% for i = 1 : length(amplifiers)
%     bindToAomux(amplifiers(i), aom, );
% end

return;
% pj_unhijack - Unhijack pulses.
%
% SYNTAX
%  pj_unhijack(hObject)
%
% USAGE
%  This function will swap out callbacks in the pulseMap, to restore the actual pulses and remove the hijacked ones.
%
% NOTES
%  See TO101607G.
%
% CHANGES
%  TO101907B - Created a shadow map, to protect the real map when it's swapped out externally. -- Tim O'Connor 10/18/07
%
% Created 10/16/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function pj_unhijack(hObject)

[enable] = getLocalBatch(progmanager, hObject, 'enable');

if enable
    warning('Call to unhijack pulses issued when pulseJacker is enabled. Honoring call...');
end

restoreMap(pulseMap('acquisition'));
setLocal(progmanager, hObject, 'pulseDataMap', []);
%See how easy that was, as compared with the kludge before using the daqtoolbox architecture?

return;
% mapper_createSignals - Create all outbound signals for the mappoint.
%
% SYNTAX
%  mapper_createSignals(hObject)
%
% USAGE
%
% NOTES
%  See TO020206B (creation of this function).
%
% CHANGES
%  TO030706A - Handle NaNs. -- Tim O'Connor 3/7/06
%  TO031006B - With the moving of pockels cell control entirely into the stimulator, this function no longer has any tasks to perform. -- Tim O'Connor 3/10/06
%
% Created 2/2/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_createSignals(hObject)

%TO031006B
warning('DEPRECATED.');

return;
% 
% [ephysPulse, pockelsSignal, shutterSignal sampleRate] = getLocalBatch(progmanager, hObject, ...
%     'ephysPulse', 'pockelsSignal', 'shutterSignal', 'sampleRate');
% % delete(ephysPulse);
% % delete(pockelsSignal);
% % delete(shutterSignal);
% 
% % ephysPulse = signalObject('Name', 'uncaging', 'SampleRate', sampleRate);
% % squarePulseTrain(ephysPulse, -5, 0, .6, .05, 0, 1);
% if isempty(pockelsSignal)
%     pockelsSignal = signalObject('Name', 'pockels', 'SampleRate', sampleRate);
%     setLocal(progmanager, hObject, 'pockelsSignal', pockelsSignal);
% end
% coeffs = getLocal(progmanager, hObject, 'coeffs');
% mn = coeffs(1);
% transmission = 1;
% mx = [1 transmission transmission^2 transmission^3] * coeffs;
% %TO030706A - Handle NaNs.
% if mx == NaN
%     mx = 0;
% end
% if mn == NaN
%     mn = 0;
% end
% squarePulseTrain(pockelsSignal, mx - mn, mn, .1, .001, 0, 1);
% 
% % shutterSignal = signalObject('Name', 'shutter0', 'SampleRate', sampleRate);
% % squarePulseTrain(shutterSignal, 5, 0, .098, .004, 0, 1);
% % 
% % setLocalBatch(progmanager, hObject, 'ephysPulse', ephysPulse, 'pockelsSignal', pockelsSignal, 'shutterSignal', shutterSignal);%TO020206B
% 
% return;
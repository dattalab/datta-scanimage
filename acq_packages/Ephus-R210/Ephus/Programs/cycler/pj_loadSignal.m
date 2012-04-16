% pj_loadSignal - Retrieve the signal for a given position and channel.
%
% SYNTAX
%  s = pj_loadSignal(hObject)
%  s = pj_loadSignal(hObject, pulseSetName, pulseName)
%    hObject - The program handle.
%    pulseSetName - The name of the pulse set from which to load a pulse.
%    pulseName - The name of the pulse to be loaded.
%    s - Loaded @signalobject instance.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/28/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function s = pj_loadSignal(hObject, varargin)

[pulsePath, positions, currentPosition, currentChannel] = getLocalBatch(progmanager, hObject, 'pulsePath', 'positions', 'currentPosition', 'currentChannel');
if length(varargin) == 2
    pulseSetName = varargin{1};
    pulseName = varargin{2};
else
    pos = pj_positionArray2positionStruct(positions{currentPosition}, currentChannel);
    pulseSetName = pos.pulseSetName;
    pulseName = pos.pulseName;
end

if ~endsWithIgnoreCase(pulseName, '.signal')
    pulseName = [pulseName '.signal'];
end

s = load(fullfile(pulsePath, pulseSetName, pulseName), '-mat');
s = s.signal;

return;
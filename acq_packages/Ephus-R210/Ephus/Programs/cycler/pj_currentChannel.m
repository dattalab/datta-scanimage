% pj_currentChannel - Update gui and internal variables to reflect the currentChannel variable.
%
% SYNTAX
%  pj_currentChannel(hObject)
%  pj_currentChannel(hObject, currentChannel)
%    hObject - The program handle.
%    currentChannel - The new currentChannel.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO060108B - Allow currentChannel as an argument. -- Tim O'Connor 6/1/08
%
% Created 8/28/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_currentChannel(hObject, varargin)

if isempty(varargin)
    [positions, currentPosition, currentChannel] = getLocalBatch(progmanager, hObject, 'positions', 'currentPosition', 'currentChannel');
else
    [positions, currentPosition] = getLocalBatch(progmanager, hObject, 'positions', 'currentPosition');
    currentChannel = varargin{1};
    setLocal(progmanager, hObject, 'currentChannel', currentChannel);%TO060108B
end

if isempty(positions) || currentPosition <= 0
    setLocalBatch(progmanager, hObject, 'pulseSetName', '', 'pulseName', '');
    return;
elseif length(positions) < currentPosition
    error('pulseJacker::pulseJacker::currentPosition out of range 1:%s', num2str(length(positions)));
end

pos = pj_positionArray2positionStruct(positions{currentPosition}, currentChannel);
pj_setPulseSetName(hObject, pos.pulseSetName);
pj_setPulseName(hObject, pos.pulseName);

return;
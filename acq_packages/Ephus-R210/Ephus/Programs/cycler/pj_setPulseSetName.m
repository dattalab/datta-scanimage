% pj_setPulseSetName - Select the pulse set for the current channel.
%
% SYNTAX
%  pj_setPulseSetName(hObject)
%  pj_setPulseSetName(hObject, pulseSetName)
%    hObject - The program handle.
%    pulseSetName - The new pulse set.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/29/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_setPulseSetName(hObject, varargin)

[pulseSetName, pulsePath, positions, currentPosition, currentChannel] = getLocalBatch(progmanager, hObject, ...
    'pulseSetName', 'pulsePath', 'positions', 'currentPosition', 'currentChannel');
if ~isempty(varargin)
    pulseSetName = varargin{1};
    setLocal(progmanager, hObject, 'pulseSetName', pulseSetName);
end

pulseNames = {''};
pulseFiles = dir(fullfile(pulsePath, pulseSetName, '*.signal'));
for i = 1 : length(pulseFiles)
    if strcmpi(pulseFiles(i).name, '.') | strcmpi(pulseFiles(i).name, '..')
        continue;
    end
    if ~pulseFiles(i).isdir
        pulseNames{length(pulseNames) + 1} = pulseFiles(i).name(1 : end - 7);
    end
end
setLocalGh(progmanager, hObject, 'pulseName', 'String', pulseNames);
% fprintf(1, 'pj_setPulseSetName: %s (%s)\n%s', currentChannel, class(currentChannel), getStackTraceString);
pos = positions{currentPosition};
index = pj_positionArray2positionIndex(positions{currentPosition}, currentChannel);
pos(index).pulseSetName = pulseSetName;
pos(index).pulseName = '';
positions{currentPosition} = pos;

setLocalBatch(progmanager, hObject, 'positions', positions, 'pulseName', '');
pj_saveCycle(hObject);

return;
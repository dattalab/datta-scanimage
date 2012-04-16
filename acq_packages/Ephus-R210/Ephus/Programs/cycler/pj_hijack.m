% pj_hijack - Hijack pulses.
%
% SYNTAX
%  pj_hijack(hObject)
%   hObject - The program's handle.
%
% USAGE
%  This function will swap out callbacks in the pulseMap, to replace the actual pulses with hijacked ones.
%
% NOTES
%  See TO101607G.
%
% CHANGES
%  TO101907B - Created a shadow map, to protect the real map when it's swapped out externally. -- Tim O'Connor 10/18/07
%  TO032410C - Store the ordered channelNames list, for the headers. -- Tim O'Connor 3/24/10
%
% Created 10/16/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function pj_hijack(hObject)

if ~getLocal(progmanager, hObject, 'enable')
    warning('Call to hijack pulses issued when pulseJacker is disabled. Ignoring call...');
    return;
end

pm = pulseMap('acquisition');
map = getMap(pm);

mappedProgramHandles = getLocal(progmanager, hObject, 'mappedProgramHandles');
channelNames = get(getLocalGh(progmanager, hObject, 'currentChannel'), 'String');
if ischar(channelNames)
    channelNames = {channelNames};
end

%Now, set the callbacks en-masse, for efficiency.
for i = 1 : size(channelNames, 1)
    idx = find(channelNames{i} == ':');
    if isempty(idx)
        idx = 1;
    else
        idx = idx(1) + 1;
    end
    map{i, 1} = channelNames{i}(idx:end);
    map{i, 2} = {@pj_getData, hObject, mappedProgramHandles(i), i, map{i, 1}};
% fprintf(1, 'pj_hijack - ''%s'':''%s''\n', getProgramName(progmanager, mappedProgramHandles(i)), map{i, 1});
end
setMap(pm, map);

pulseDataMap = cell(length(channelNames), 2);
pulseDataMap(1:length(channelNames)) = channelNames;
setLocalBatch(progmanager, hObject, 'pulseDataMap', pulseDataMap, 'channelNames', channelNames);%TO032410C

%See how easy that was, as compared with the kludge before using the daqtoolbox architecture?

return;
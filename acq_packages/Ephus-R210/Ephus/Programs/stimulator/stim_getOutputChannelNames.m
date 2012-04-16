% stim_getOutputChannelNames - Retrieve a list of output channel names
%
% SYNTAX
%
% USAGE
%
% NOTES
%  This is a copy & paste job from stim_getOutputChannelNames.m, with some editting where necessary.
%
% CHANGES
%  Watch out for empty channel names. -- Tim O'Connor 5/26/06 TO052606A
%  Make sure any return values are cell arrays. -- Tim O'Connor 5/26/05 TO052605C
%  Fixed TO052606A -- Tim O'Connor 6/1/05 TO060106B
%
% Created 11/22/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function channelNames = stim_getOutputChannelNames(hObject)

channelNames = {};

[channels stimOnArray] = getLocalBatch(progmanager, hObject, 'channels', 'stimOnArray');
if isempty(channels)
    return;
end

indices = find(stimOnArray);
if isempty(indices)
    return;
end

channelNames = {channels(indices).channelName};

return;
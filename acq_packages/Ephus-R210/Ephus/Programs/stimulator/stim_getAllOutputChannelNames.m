% stim_getAllOutputChannelNames - Retrieve a list of all output channel names, regardless of them being in use or not.
%
% SYNTAX
%
% USAGE
%
% NOTES
%  Copy & paste from stim_getOutputChannelNames.
%  See TO090706A.
%
% CHANGES
%
% Created 9/7/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function channelNames = stim_getAllOutputChannelNames(hObject)

channelNames = {};

[channels] = getLocalBatch(progmanager, hObject, 'channels');
if isempty(channels)
    return;
end

channelNames = {channels(:).channelName};

return;
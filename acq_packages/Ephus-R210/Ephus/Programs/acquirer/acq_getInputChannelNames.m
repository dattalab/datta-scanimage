% acq_getInputChannelNames - Retrieve a list of input channel names
%
% SYNTAX
%
% USAGE
%
% NOTES
%  This is a copy & paste job from ephys_getInputChannelNames.m, with some editting where necessary.
%
% CHANGES
%  Watch out for empty channel names. -- Tim O'Connor 5/26/06 TO052606A
%  Make sure any return values are cell arrays. -- Tim O'Connor 5/26/05 TO052605C
%  Fixed TO052606A -- Tim O'Connor 6/1/05 TO060106B
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO032106E - Make sure it works when no input channels are enabled. -- Tim O'Connor 3/21/06
%  TO032306D - Make sure only cell arrays get returned. -- Tim O'Conno 3/23/06
%
% Created 12/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function channelNames = acq_getInputChannelNames(hObject)

[channels acqOnArray] = getLocalBatch(progmanager, hObject, 'channels', 'acqOnArray');
if isempty(channels)
    channelNames = {};
    return;
end

channelNames = {channels(find(acqOnArray)).channelName};%TO032106E

%TO052605C
if isempty(channelNames)
    channelNames = {};
elseif strcmpi(class(channelNames), 'char')
    channelNames = {channelNames};
end

%TO052606A, TO060106B
for i = 1 : length(channelNames)
    if isempty(channelNames{i})
        channelNames = cat(1, channelNames{1:i-1}, channelNames{i+1:end});
    end
end
% channelNames = channelNames{find(~isempty(channelNames))};%This doesn't work, I was being dumb. TO060106B

%TO032306D
if strcmpi(class(channelNames), 'char')
    channelNames = {channelNames};
end

return;
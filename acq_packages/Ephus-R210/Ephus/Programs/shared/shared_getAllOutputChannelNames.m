% ephys_getAllOutputChannelNames - Retrieve a list of all output channel names, regardless of them being in use or not.
%
% SYNTAX
%
% USAGE
%
% NOTES
%  Copy & paste from ephys_getOutputChannelNames.
%  See TO090706A.
%  Adapted from shared_getOutputChannelNames.m
%
% CHANGES
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  VI042808A - Correctly strip out empty channels from channelNames -- Vijay Iyer 4/28/08
%
% Created 9/7/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function channelNames = ephys_getAllOutputChannelNames(hObject)

[channels, amps, stimOnArray] = getLocalBatch(progmanager, hObject, 'channels', 'amplifiers', 'stimOnArray');

if isempty(stimOnArray)
    channelNames = {};
    return;
end

if ~isempty(amps) && ~isempty(channels)
    error('One program should not have both amplifiers and raw channels: ''%s''\n', getProgramName(progmanager, hObject));
end

channelNames = {};
if ~isempty(amps)
    for i = 1 : length(amps)
        channelNames{length(channelNames) + 1} = getOutputChannelNames(amps{i});%, 'vCom');%TO120205A
    end
end
if ~isempty(channels)
    channelNames = {channels(:).channelName};%TO032106E
end

%TO052605C
if isempty(channelNames)
    channelNames = {};
elseif ischar(channelNames)
    channelNames = {channelNames};
end

%TO052606A, TO060106B, VI042808A
indices = [];
for i = 1 : length(channelNames)
    if isempty(channelNames{i})
        %         channelNames = cat(1, channelNames{1:i-1}, channelNames{i+1:end}); %this removes elements as you go, causing an error at end of loop
        indices = [indices i];
    end
end
channelNames(indices) = []; %VI042808A -- remove all the empty channels in one go

%     end
% end
% channelNames = channelNames{find(~isempty(channelNames))};%This doesn't work, I was being dumb. TO060106B

%TO032306D
if ischar(channelNames)
    channelNames = {channelNames};
end

return;
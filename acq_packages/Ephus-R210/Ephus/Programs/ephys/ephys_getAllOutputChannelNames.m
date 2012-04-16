% ephys_getAllOutputChannelNames - Retrieve a list of all output channel names, regardless of them being in use or not.
%
% SYNTAX
%
% USAGE
%
% NOTES
%  Copy & paste from ephys_getOutputChannelNames.
%  See TO090706A.
%
% CHANGES
%
% Created 9/7/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function channelNames = ephys_getAllOutputChannelNames(hObject)

amps = getLocal(progmanager, hObject, 'amplifiers');
channelNames = {};
for i = 1 : length(amps)
    channelNames{length(channelNames) + 1} = getOutputChannelNames(amps{i});%, 'vCom');%TO120205A
end

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
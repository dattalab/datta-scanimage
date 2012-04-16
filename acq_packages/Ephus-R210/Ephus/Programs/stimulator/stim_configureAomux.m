% stim_configureAomux - Configure the AOMUX object for the stimulator GUI.
%
% SYNTAX
%  stim_configureAomux(hObject)
%
% USAGE
%
% NOTES
%  This is a copy & paste job from ephys_configureAomux.m, with some editting where necessary.
%
% CHANGES
%  TO121605B: Implemented 'extraGain' feature, which was there but had been postponed. -- Tim O'Connor 12/16/05
%  TO121905C: Forgot to pass 'hObject' into the preprocessor callback. -- Tim O'Connor 12/19/05
%  TO123005M: Convert values into mV (the pulseEditor's units) before they go out to the board. -- Tim O'Connor 12/30/05
%
% Created 11/22/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function stim_configureAomux(hObject)

% return;%NOTHING TO DO...?%TO121605B - Now there's something to do.

%Get the output channel names.
%Configure the output multiplexing.
aom = getLocal(progmanager, hObject, 'aomux');
channels = getLocal(progmanager, hObject, 'channels');
if isempty(channels)
    return;
end

%TO121605B - This is irrelevant, right? No need to check if a pulse is selected, the @AOMUX still needs to be configured.
% % signalCollection = getLocal(progmanager, hObject, 'signalCollection');
% pulseSetNames = getLocal(progmanager, hObject, 'pulseSetNameArray');
% pulseNames = getLocal(progmanager, hObject, 'pulseNameArray');
% 
% if isempty(pulseSetNames) | isempty(pulseNames)
%     return;
% end

%TO121605B
for i = 1 : length(channels)
    %The channel must exist before it can have a preprocessor bound to it.
    dm = getDaqmanager;
    if ~hasChannel(dm, channels(i).channelName)
        nameOutputChannel(dm, channels(i).boardID, channels(i).channelID, channels(i).channelName);
        enableChannel(dm, channels(i).channelName);
    end
    
    setPreprocessor(aom, channels(i).channelName, {@stim_aomuxPreProcessor, hObject, i}, ['stim_' channels(i).channelName]);%TO121905C
end

return;

% ------------------------------------------------------------------
%TO121605B, TO121905C
function preprocessed = stim_aomuxPreProcessor(hObject, channelIndex, data)
% fprintf(1, 'stim_configureAomux/stim_aomuxPreProcessor: InitialRange = [%s %s].\n', num2str(min(data)), num2str(max(data)));

extraGainArray = getLocal(progmanager, hObject, 'extraGainArray');
% fprintf(1, 'stim_configureAomux/stim_aomuxPreProcessor: Scaling data by a factor of %s (%s) with channelIndex %s.\n', num2str(extraGainArray(channelIndex)), num2str(extraGainArray(channelIndex) * 0.001), num2str(channelIndex));
preprocessed = data * extraGainArray(channelIndex) * 0.001;%TO123005M

% fprintf(1, 'stim_configureAomux/stim_aomuxPreProcessor: FinalRange = [%s %s].\n', num2str(min(preprocessed)), num2str(max(preprocessed)));

return;
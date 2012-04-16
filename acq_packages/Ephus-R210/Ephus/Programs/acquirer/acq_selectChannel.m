% acq_selectChannel - Select a specific channel in the GUI.
%
% SYNTAX
%  acq_selectChannel(hObject)
%  acq_selectChannel(hObject, chanIndex)
%    chanIndex - The index of the channel to switch to.
%
% USAGE
%
% NOTES
%  This is a copy & paste job from stim_selectChannel.m, with some editting where necessary.
%
% CHANGES
%  TO071605A: Optimized using `getLocalBatch` and `setLocalBatch`. Saved about 50ms (a 50% reduction). -- Tim O'Connor 7/16/05
%  TO083005A: Altered pulses to be stored in individual files. -- Tim O'Connor 8/30/05
%  TO091405A: Continuation of TO083005A. -- Tim O'Connor 9/14/05
%  TO090506C - Only enable the Start button if not in external trigger mode. -- Tim O'Connor 9/5/06
%  TO090506D - Made chanIndex optional. -- Tim O'Connor 9/5/06
%
% Created 12/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function stim_selectChannel(hObject, varargin)

[channels, acqOnArray, channelList] = ...
    getLocalBatch(progmanager, hObject, 'channels', 'acqOnArray', 'channelList');

%TO090506D
chanIndex = channelList;
if ~isempty(varargin)
    chanIndex = varargin{1};
    setLocal(progmanager, hObject, 'channelList', chanIndex);
end

if chanIndex >= 1 & chanIndex <= length(channels)
    %TO091405A
    setLocal(progmanager, hObject, 'acqOn', acqOnArray(chanIndex));
else
    error('chanIndex out of range.');
end

%TO083005A %TO090506C
if ~getLocal(progmanager, hObject, 'externalTrigger')
    setLocalGh(progmanager, hObject, 'startButton', 'Enable', 'On');
end

return;
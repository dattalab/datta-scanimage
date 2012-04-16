% AXOPATCH_200B/bindToAIMUX - Link this object to an AIMUX and specific input/output channels.
%
%  SYNTAX
%   bindToAIMUX(this, aim)
%   bindToAIMUX(this, aim, scaledChannelName)
%    this - AXOPATCH_200B
%    aim - AIMUX to be bound to.
%    scaledChannel - The name of the channel that will get scaled (preprocessed).
%
%  CHANGES
%   TO022505a - Implemented the scaledOutputChannelName property. -- Tim O'Connor 2/25/05
%   TO022505c - Check to see if the channels are already added to the daqmanager, before trying to add them.
%   TO040405A - Autogenerate the scaledInputName, if not specified.
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%   TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% Created 2/10/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function bindToAIMUX(this, aim, varargin)
global axopatch200bs;

error('Deprecated - TO073107B');

%Add the telegraph channels.
dm = getDaqManager(aim);%TO122205A

%TO040405A
if ~isempty(varargin)
    scaledChannelName = varargin{1};
else
    scaledChannelName = [get(this, 'name') '_scaledOutput'];
end

if ~hasChannel(dm, scaledChannelName)
    nameInputChannel(dm, get(this, 'scaledOutputBoardID'), get(this, 'scaledOutputChannelID'), scaledChannelName);
    enableChannel(dm, scaledChannelName);
end
setScaledOutputChannelName(this, scaledChannelName);

%This will do the actual data scaling.
setPreprocessor(aim, scaledChannelName, {@axopatch200b_preprocessor, this}, this);

gainName = [axopatch200bs(this.ptr).name '-gain'];
%TO022505c
if ~hasChannel(dm, gainName)
    nameInputChannel(dm, get(this, 'gain_daq_board_id'), get(this, 'gain_channel'), gainName);
    enableChannel(dm, gainName);
end

modeName = [axopatch200bs(this.ptr).name '-mode'];
%TO022505c
if ~hasChannel(dm, modeName)
    nameInputChannel(dm, get(this, 'mode_daq_board_id'), get(this, 'mode_channel'), modeName);
    enableChannel(dm, modeName);
end

v_holdName = [axopatch200bs(this.ptr).name '-v_hold'];
%TO022505c
if ~hasChannel(dm, v_holdName)
    nameInputChannel(dm, get(this, 'v_hold_daq_board_id'), get(this, 'v_hold_channel'), v_holdName);
    enableChannel(dm, v_holdName);
end

%Listen to these channels, to update the scaling parameters.
bind(aim, gainName, {@axopatch200b_gainSamplesAcquiredFcn, this}, this);
bind(aim, modeName, {@axopatch200b_modeSamplesAcquiredFcn, this}, this);
bind(aim, v_holdName, {@axopatch200b_vholdSamplesAcquiredFcn, this}, this);

%Hang on to these names for use later (starting, stopping, etcetera).
setInputChannelNames(this, {scaledChannelName, gainName, modeName, v_holdName});
set(this, 'scaledOutputChannel', scaledChannelName);

return;
% multi_clamp/bindToAIMUX
%
% SYNTAX
%   bindToAIMUX(this, aim)
%     this - @multi_clamp instance
%     aim - @aimux instance
%
% USAGE
%
% CHANGES
%  TO033106G: Updating takes lots of time, and nothing should be changing while the preprocessor is running anyway? -- Tim O'Connor 3/31/06
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% Created 6/29/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function bindToAIMUX(this, aim, varargin)
global multi_clampObjects;

error('Deprecated - TO073107B');

%Add the telegraph channels.
dm = getDaqManager(aim); % GS20060706a - 'm' to uppercase 'M'

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

setInputChannelNames(this, {scaledChannelName});
set(this, 'scaledOutputChannel', scaledChannelName);

%This will do the actual data scaling.
setPreprocessor(aim, scaledChannelName, {@multiclamp_preprocessor, this}, this);

%--------------------------------------------------------
function data = multiclamp_preprocessor(this, data, ai, strct, varargin)

%TO033106G: Updating takes lots of time, and nothing here should be changing during a trace anyway?
update(this);
cc = get(this, 'current_clamp');
% fprintf(1, 'aimuxPreprocessor (before): %s - %s\n', num2str(min(data)), num2str(max(data)));
if cc
    %See MultiClamp 700B Patch Clamp Theory And Operation manual page 144
    %I = alpha * beta mV/V
    data = data / get(this, 'input_gain');
else
    %See MultiClamp 700B Patch Clamp Theory And Operation manual page 144
    %V = alpha pA/V
    data = data / get(this, 'input_gain');
end
% input_gain = get(this, 'input_gain')
% fprintf(1, 'aimuxPreprocessor (after): %s - %s\n', num2str(min(data)), num2str(max(data)));
return;
% AXOPATCH_200B/bindToAOMUX - Link this object to an AOMUX and specific input/output channels.
%
%  SYNTAX
%   bindToAIMUX(this, aom, pulse)
%    this - An AXOPATCH_200B object.
%    aom - An AOMUX object.
%    pulse - A SIGNALOBJECT object.
%
%  CHANGES
%   TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% Created 5/6/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function bindToAOMUX(this, aom, pulse)
global axopatch200bs;

error('Deprecated - TO073107B');

%Construct a name for the channel.
name = get(this, 'name');
vCom = [get(this, 'name') '-VCom'];

%Add the telegraph channels.
dm = getDaqmanager(aom);

if ~hasChannel(dm, vCom)
    nameOutputChannel(dm, get(this, 'vComBoardID'), get(this, 'vComChannelID'), vCom);
    enableChannel(dm, vCom);
end

setVComChannelName(this, vCom);
bind(aom, vCom, pulse);
setPreprocessor(aom, vCom, {@AXOPATCH_200B_aomuxPreprocessor, this}, name);

return;

%---------------------------------------------------------------
function preprocessed = AXOPATCH_200B_aomuxPreprocessor(this, data)
% fprintf(1, 'aomuxPreprocessor (before): %s - %s\n', num2str(min(data)), num2str(max(data)));
if get(this, 'current_clamp')
    %See Axopatch 200B Patch Clamp Theory And Operation manual page 79.
    %Front-switched: 2 / beta nA/V = (2000 / beta) pA/V
    %Rear-switched: 2 / beta nA/V = (2000 / beta) pA/V
    preprocessed = data * get(this, 'i_clamp_output_factor') / get(this, 'beta');
else
    %See Axopatch 200B Patch Clamp Theory And Operation manual page 80.
    %Front-switched: 20 mv/V
    %Rear-switched: 100 mV/V
    preprocessed = data * get(this, 'v_clamp_output_factor');
end
% fprintf('%s --> %s\n', num2str(max(abs(data))), num2str(max(abs(preprocessed))));
% fprintf(1, 'aomuxPreprocessor (after): %s - %s\n', num2str(min(preprocessed)), num2str(max(preprocessed)));
return;
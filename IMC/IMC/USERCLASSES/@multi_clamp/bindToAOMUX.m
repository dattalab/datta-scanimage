% MUTLI_CLAMP/bindToAOMUX - Link this object to an AOMUX and specific input/output channels.
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
setPreprocessor(aom, vCom, {@multiclamp_OutputPreprocessor, this}, name);

return;

%---------------------------------------------------------------
function preprocessed = multiclamp_OutputPreprocessor(this, data)

update(this);
cc = get(this, 'current_clamp');
% fprintf(1, '@multi_clamp/bindToAIMUX: current_clamp = %s\n', num2str(cc));
% fprintf(1, 'aomuxPreprocessor (before): %s - %s\n', num2str(min(data)), num2str(max(data)));
if cc
    %See Axopatch 700B Patch Clamp Theory And Operation manual page 144.
    %400 pA/V | 2 nA/V
    preprocessed = data * get(this, 'i_clamp_output_factor');
% fprintf(1, 'I-Clamp: From [%s %s] to [%s %s] by %s\n', num2str(min(data)), num2str(max(data)), num2str(min(preprocessed)), num2str(max(preprocessed)), num2str(get(this, 'i_clamp_output_factor')));
else
    %See Axopatch 700B Patch Clamp Theory And Operation manual page 144.
    %20mV/V | 100mv/V
    preprocessed = data * get(this, 'v_clamp_output_factor');
% fprintf(1, 'V-Clamp: From [%s %s] to [%s %s] by %s\n', num2str(min(data)), num2str(max(data)), num2str(min(preprocessed)), num2str(max(preprocessed)), num2str(get(this, 'i_clamp_output_factor')));
end
% fprintf('%s --> %s\n', num2str(max(abs(data))), num2str(max(abs(preprocessed))));
% fprintf(1, 'aomuxPreprocessor (after): %s - %s\n', num2str(min(preprocessed)), num2str(max(preprocessed)));
return;
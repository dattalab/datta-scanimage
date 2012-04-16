% AXOPATCH_200B/axopatch200b_modeSamplesAcquiredFcn - Listens for mode telegraphs.
%
%  SYNTAX
%   axopatch200b_modeSsamplesAcquiredFcn(this, data, ai, strct, varargin)
%    this - AXOPATCH_200B
%    data - The mode telegraph data.
%    ai - The analoginput object, on which the mode telegraph is recieved.
%    strct - A SamplesAcquiredFcn struct.
%
%  USAGE
%    Monitors the Axopatch's mode telegraph. This function recieves calls from an AIMUX object.
%
%  CHANGES
%   TO110607A - Listen for telegraph changes via nimex. -- Tim O'Connor 11/6/07
%
% Created 2/10/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function axopatch200b_modeSamplesAcquiredFcn(this, data, varargin)

[mode, current_clamp] = indexTelegraph(this, 'mode', data(end));

oldMode = get(this, 'mode');
oldCc = get(this, 'current_clamp');
set(this, 'mode', mode);
set(this, 'current_clamp', current_clamp);

% Now set the generic amplifier properties...
if current_clamp
    set(this, 'input_units', 'mV');
    set(this, 'input_gain', get(this, 'i_clamp_input_factor') / get(this, 'gain'));
else
    set(this, 'input_units', 'pA');
    set(this, 'input_gain', get(this, 'v_clamp_input_factor') / get(this, 'gain'));
end

if ~strcmp(mode, oldMode) || current_clamp ~= oldCc
    try
        notifyStateListeners(this);
    catch
        warning('Failed to notify AXOPATCH 200B state listeners for ''%s'': %s', get(this, 'name'), lasterr);
    end
end

return;
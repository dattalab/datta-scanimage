% AXOPATCH_200B/axopatch200b_vholdSamplesAcquiredFcn - Listens for v-hold telegraphs.
%
%  SYNTAX
%   axopatch200b_vholdSamplesAcquiredFcn(this, data, ai, strct, varargin)
%    this - AXOPATCH_200B
%    data - The v-hold telegraph data.
%    ai - The analoginput object, on which the v-hold telegraph is recieved.
%    strct - A SamplesAcquiredFcn struct.
%
%  USAGE
%    Monitors the Axopatch's v-hold telegraph. This function recieves calls from an AIMUX object.
%
%  CHANGES
%   TO021805c - Tim O'Connor 2/18/05: Put in a threshold for change notification.
%   TO110607A - Listen for telegraph changes via nimex. -- Tim O'Connor 11/6/07
%
% Created 2/10/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function axopatch200b_vholdSamplesAcquiredFcn(this, data, varargin)

v_hold = 100 * data(end); % correct for scaling of channel voltage
oldVhold = get(this, 'v_hold');
set(this, 'v_hold', v_hold);

%TO021805c: Choosing .75 volts as the threshold for notification is sort of arbitrary, based on a quick empirical observation.
if abs(v_hold - oldVhold) > .75
    notifyStateListeners(this);
end

return;
% AXOPATCH_200B/axopatch200b_gainSamplesAcquiredFcn - Listens for gain telegraphs.
%
%  SYNTAX
%   axopatch200b_preprocessor(this, data, ai, strct, varargin)
%    this - AXOPATCH_200B
%    data - The gain telegraph data.
%    ai - The analoginput object, on which the gain telegraph is recieved.
%    strct - A SamplesAcquiredFcn struct.
%
%  USAGE
%    Monitors the Axopatch's gain telegraph. This function recieves calls from an AIMUX object.
%
%  CHANGES
%   TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% Created 2/10/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function data = axopatch200b_preprocessor(this, data)

cc = get(this, 'current_clamp');

if cc
    %See Axopatch 200B Patch Clamp Theory And Operation manual page 80
    %I = alpha * beta mV/pA
    data = 1000 * data / get(this, 'gain') / get(this, 'beta');
else
    %See Axopatch 200B Patch Clamp Theory And Operation manual page 80
    %V = alpha mV/mV
    data = 1000 * data / get(this, 'gain');
end

return;
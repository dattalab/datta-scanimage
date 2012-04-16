% AXOPATCH_200B/axopatch200b_gainSamplesAcquiredFcn - Listens for gain telegraphs.
%
%  SYNTAX
%   axopatch200b_gainSamplesAcquiredFcn(this, data, ai, strct, varargin)
%    this - AXOPATCH_200B
%    data - The gain telegraph data.
%    ai - The analoginput object, on which the gain telegraph is recieved.
%    strct - A SamplesAcquiredFcn struct.
%
%  USAGE
%    Monitors the Axopatch's gain telegraph. This function recieves calls from an AIMUX object.
%
%  CHANGES
%   TO110607A - Listen for telegraph changes via nimex. -- Tim O'Connor 11/6/07
%
% Created 2/10/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function axopatch200b_gainSamplesAcquiredFcn(this, data, varargin)

gain = indexTelegraph(this, 'gain', data(end));
oldGain = get(this, 'gain');

set(this, 'gain', gain);

if gain ~= oldGain
    try
        notifyStateListeners(this);
    catch
        warning('Failed to notify AXOPATCH 200B state listeners for ''%s'': %s', get(this, 'name'), lasterr);
    end
end

return;
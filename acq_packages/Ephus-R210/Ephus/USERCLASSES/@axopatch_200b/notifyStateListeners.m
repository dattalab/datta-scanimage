% AXOPATCH_200B/notifyStateListeners - Signal all listeners that the state of this amplifier has changed.
%
% CHANGES
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%
%  SEEALSO @AMPLIFIER/notifyStateListeners
%
% Created 2/18/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function notifyStateListeners(this)

notifyStateListeners(this.AMPLIFIER);%TO122205A

return;
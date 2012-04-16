% AXOPATCH_200B/bindStateListener - Bind a listener for state changes in this object.
%
%  SYNTAX
%   bindStateListener(this, listenerFcn)
%
%  CHANGES
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%   TO041406A - Add the listenerFcnID argument. -- Tim O'Connor 4/14/06
%
%  SEEALSO @AMPLIFIER/bindStateListener
%
% Created 2/17/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function bindStateListener(this, listenerFcn, listenerFcnID)

bindStateListener(this.AMPLIFIER, listenerFcn, listenerFcnID);%TO122205A %TO041406A

return;
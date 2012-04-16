% AXOPATCH_200B/setOutputChannelNames - Set the list of input channels monitored by this amplifier.
%
% USAGE
%
% NOTES
%  Calls through to the superclass.
%
% CHANGES
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%
% SEE ALSO
%  amplifier/setOutputChannelNames
%
% Created 5/6/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function setOutputChannelNames(this, outputChannels)
global amplifierObjects;

setOutputChannelNames(this.AMPLIFIER, outputChannels);%TO122205A

return;
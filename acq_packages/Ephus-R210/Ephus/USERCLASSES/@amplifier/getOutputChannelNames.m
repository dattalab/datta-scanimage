% AMPLIFIER/getInputChannelNames - Retrieve a list of input channels monitored by this amplifier.
%
% SYNTAX
%  inputChannels = getOutputChannelNames(AMPLIFIER)
%   AMPLIFIER - An @AMPLIFIER instance.
%   outputChannels - A cell array of strings representing channel names.
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%
% USAGE
%
% NOTES
%
% CHANGES
%   TO081696H - Switched case convention. See TO122205A. -- Tim O'Connor 8/16/06
%
% Created 2/21/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function outputChannels = getOutputChannelNames(this)
global amplifierObjects;

if ~strcmpi(class(this), 'amplifier')
    obj = struct(this);
    this = obj.amplifier;%TO122505A %TO081606H
end

outputChannels = amplifierObjects(this.ptr).outputChannels;

return;
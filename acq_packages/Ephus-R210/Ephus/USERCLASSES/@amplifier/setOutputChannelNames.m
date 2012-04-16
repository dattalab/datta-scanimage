% AMPLIFIER/setOutputChannelNames - Set the list of input channels monitored by this amplifier.
%
% SYNTAX
%  setOutputChannelNames(AMPLIFIER, outputChannels)
%   AMPLIFIER - An @AMPLIFIER subclass' instance.
%   outputChannels - A cell array of strings representing channel names.
%
% USAGE
%
% NOTES
%  This method is only intended for use by subclasses. Calling from anywhere else will generate an error.
%
% CHANGES
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%   TO022706D - Optimization(s). Allow heavy debugging to be disabled with the `debug` field. -- Tim O'Connor 2/27/06
%   TO081696H - Switched case convention. See TO122205A. -- Tim O'Connor 8/16/06
%
% Created 2/21/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function setOutputChannelNames(this, outputChannels)
global amplifierObjects;

%TO022706D - Only do this when in debugging mode.
if get(this, 'debug')
    %Make sure the call came from a subclass' method.
    stackTraceStruct = dbstack;
    fname = '';
    if length(stackTraceStruct) > 1
        [path fname ext] = fileparts(stackTraceStruct(2).name);
    end

    if ~ismethod(this, fname)
        error('@AMPLIFIER/setOutputChannelNames - This method is only allowed to be called by subclasses: %s', class(this));
    end
end

if ~strcmpi(class(this), 'amplifier')
    obj = struct(this);
    this = obj.amplifier;%TO122205A %TO081606H
end

amplifierObjects(this.ptr).outputChannels = outputChannels;

return;
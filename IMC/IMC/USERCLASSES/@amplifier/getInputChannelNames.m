% AMPLIFIER/getInputChannelNames - Retrieve a list of input channels monitored by this amplifier.
%
% SYNTAX
%  inputChannels = getInputChannelNames(AMPLIFIER)
%   AMPLIFIER - An @AMPLIFIER instance.
%   inputChannels - A cell array of strings representing channel names.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO0330B: Take the scaledOutput channel into account. - Tim O'Connor 3/30/05
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%   TO081696H - Switched case convention. See TO122205A. -- Tim O'Connor 8/16/06
%
% Created 2/21/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function inputChannels = getInputChannelNames(this)
global amplifierObjects;

if ~strcmpi(class(this), 'amplifier')
    obj = struct(this);
    this = obj.amplifier;%TO122205A TO081696H
end

inputChannels = amplifierObjects(this.ptr).inputChannels;

%TO0330B
if ~isempty(amplifierObjects(this.ptr).scaledOutputChannel)
    if iscell(inputChannels)
        if ~ismember(lower(amplifierObjects(this.ptr).scaledOutputChannel), lower(inputChannels))
            inputChannels{length(inputChannels) + 1} = amplifierObjects(this.ptr).scaledOutputChannel;
        end
    else
        inputChannels = {inputChannels, amplifierObjects(this.ptr).scaledOutputChannel};
    end
end

return;
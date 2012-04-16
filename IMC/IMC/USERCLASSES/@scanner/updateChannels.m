% scanner/updateChannels - Update the DAQ channels.
%
% SYNTAX
%  updateChannels(INSTANCE)
%
% USAGE
%  Called to create/modify the channels in the @daqmanager to reflect the settings of this object.
%
% NOTES
%
% CHANGES
%
% Created 3/16/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function updateChannels(this)
global scannerObjectsGlobal;

hChannelName = [scannerObjectsGlobal(this.ptr).name '-horizontal'];
if hasChannel(scannerObjectsGlobal(this.ptr).dm, hChannelName)
    if getBoardID(scannerObjectsGlobal(this.ptr).dm, hChannelName) ~= scannerObjectsGlobal(this.ptr).horizontalBoardID | ...
            getChannelID(scannerObjectsGlobal(this.ptr).dm, hChannelName) ~= scannerObjectsGlobal(this.ptr).horizontalChannelID
        denameOutputChannel(scannerObjectsGlobal(this.ptr).dm, hChannelName);
    end
end

if ~hasChannel(scannerObjectsGlobal(this.ptr).dm, hChannelName)
    nameOutputChannel(scannerObjectsGlobal(this.ptr).dm, scannerObjectsGlobal(this.ptr).horizontalBoardID, ...
        scannerObjectsGlobal(this.ptr).horizontalChannelID, hChannelName);
    enableChannel(scannerObjectsGlobal(this.ptr).dm, hChannelName);
end


vChannelName = [scannerObjectsGlobal(this.ptr).name '-vertical'];
if hasChannel(scannerObjectsGlobal(this.ptr).dm, vChannelName)
    if getBoardID(scannerObjectsGlobal(this.ptr).dm, vChannelName) ~= scannerObjectsGlobal(this.ptr).verticalBoardID | ...
            getChannelID(scannerObjectsGlobal(this.ptr).dm, vChannelName) ~= scannerObjectsGlobal(this.ptr).verticalChannelID
        denameOutputChannel(scannerObjectsGlobal(this.ptr).dm, vChannelName);
    end
end

if ~hasChannel(scannerObjectsGlobal(this.ptr).dm, vChannelName)
    nameOutputChannel(scannerObjectsGlobal(this.ptr).dm, scannerObjectsGlobal(this.ptr).verticalBoardID, ...
        scannerObjectsGlobal(this.ptr).verticalChannelID, vChannelName);
    enableChannel(scannerObjectsGlobal(this.ptr).dm, vChannelName);
end

return;
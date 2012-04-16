%daqjob/getPhysicalChannelIDs: Extracts
%% SYNTAX
% [boardID, portOrChanID, lineID] = getPhysicalChannelIDs(this,physChanName)
%   this: A @daqjob instance (see note)
%   physChanName: A fully-qualified  DAQmx physical channel name (e.g. '/dev3/ai0' or '/dev2/port1/line0:3' or '/dev2/port1/)
%   boardID: The board ID extracted from the the physical channel name (e.g. 3 for '/dev3/ai0')
%   portOrChanID: The channelID for analog channels, or the port ID for digital channels (e.g. 0 for '/dev3/ai0' or '/dev3/port0' or 'dev3/port0/line2')
%   lineID: The lineID, if applicable for digital channels. (e.g. 2 for 'dev3/port0/line2'). An empty string when not needed.
%
%% NOTES
%   This would be a static method, were this class defined using new MCOS features, i.e. there is no reason for this class utility function to be tied to a particular @daqjob instance 
%
%   This function was created to support stim_addChannels() and acq_addChannels() conveniences functions 
%
%% CREDITS
%   Created 8/20/08 by Vijay Iyer
%% **********************************
function [boardID, portOrChanID, lineID] = getPhysicalChannelIDs(this,physChanName)

s = regexpi(physChanName, '/?dev(?<boardID>\d*)/[a-z]*(?<portOrChanID>\d*)(?:/line)?(?<lineID>\d*)', 'names');
boardID = str2double(s.boardID);
portOrChanID = str2double(s.portOrChanID);
lineID = str2double(s.lineID);

return;


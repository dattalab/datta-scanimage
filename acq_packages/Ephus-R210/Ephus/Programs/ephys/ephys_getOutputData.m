% ephys_getOutputData - Get the data for a given channel.
%
% SYNTAX
%  data = ephys_getOutputData(hObject, channelName)
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/14/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function data = ephys_getOutputData(hObject, channelName)

data = getData(pulseMap('acquisition'), channelName, getLocal(progmanager, hObject, 'traceLength'));

return;
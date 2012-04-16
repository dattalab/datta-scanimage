% ephysAcc_getOutputData - Get the data for a given channel.
%
% SYNTAX
%  data = ephysAcc_getOutputData(hObject, channelName)
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/14/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function data = ephysAcc_getOutputData(hObject, channelName)

data = getData(pulseMap('scope'), channelName, getLocal(progmanager, hObject, 'traceLength'));

return;
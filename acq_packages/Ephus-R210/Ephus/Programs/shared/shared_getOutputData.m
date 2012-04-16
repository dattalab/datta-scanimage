% shared_getOutputData - Get the data for a given channel.
%
% SYNTAX
%  data = shared_getOutputData(hObject, channelName)
%
% USAGE
%
% NOTES
%  Adapted from ephys_getOutputData.m
%
% CHANGES
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%
% Created 8/14/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function data = shared_getOutputData(hObject, channelName)

data = getData(pulseMap('acquisition'), channelName, getLocal(progmanager, hObject, 'traceLength'));

return;
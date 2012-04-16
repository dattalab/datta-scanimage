% @daqjob/getStartedChannels - Get a list of channels that are started.
%
% SYNTAX
%  startedChannels = getStartedChannels(job)
%   job - A @daqjob instance.
%   startedChannels - A cell array of strings, where each string is the name of a started channel.
%
% NOTES
%
% CHANGES
%
% Created
%  Timothy O'Connor 5/5/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function startedChannels = getStartedChannels(this)
global daqjobGlobalStructure;

if isempty(daqjobGlobalStructure(this.ptr).startedChannels)
    startedChannels = {};
elseif ~iscell(daqjobGlobalStructure(this.ptr).startedChannels)
    startedChannels = {daqjobGlobalStructure(this.ptr).startedChannels};
else
    startedChannels = daqjobGlobalStructure(this.ptr).startedChannels;
end

return;
% SCOPEOBJECT/bindToDaqjob - Set up a daqjob channel to be displayed on this scope object.
%
% SYNTAX
%  bindToDaqjob(this, job, channelName)
%
% USAGE
%  This is a convenience method, for setting up the callbacks between an nimex task object (via a daqjob object) and a scope object.
%
% NOTES
%   At this time, only single channel data can be bound to a particular scope object (no multi-channel scopes)
%
% CHANGES
%
% Created 8/5/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function bindToDaqjob(this, job, channelName)

addChannel(this, channelName);
bindDataListener(job, channelName, {@addData, this, channelName}, ['@scopeObject_' get(this, 'name')]);

return;
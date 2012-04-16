% SCOPEOBJECT/bindAimuxChannel - Set up a aimux channel to be displayed on this scope object.
%
% SYNTAX
%  bindAimuxChannel(this, channelName, aim)
%
% USAGE
%  This is a convenience method, for setting up the callbacks between an aimux object and a scope object.
%
% NOTES
%
% CHANGES
%   Tim O'Connor 2/3/05 TO020305a: Implemented 'addChannel' method for @AIMUX.
%   Tim O'Connor 2/4/05 TO020405a: Only execute 'addChannel' if it does not already exist.
%   Tim O'Connor 2/11/05 TO021105a: Added listenerFunctionID, making it easier to identify listenerFunctions for removal later.
%   Tim O'Connor 3/14/05 TO031405a: Issue a warning if the channel is already bound.
%
% Created 1/25/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function bindAimuxChannel(this, channelName, aim)
global scopeObjects;

%Check if it's already bound.
if isbound(aim, channelName, this)
    warning('Channel ''%s'' is already bound.', channelName);%TO031405a
    return;
end

bind(aim, channelName, {@addData, this, channelName}, this);

if ~ismember(channelName, scopeObjects(this.ptr).channels) %TO020405a
    addChannel(this, channelName);%TO020305a - Implemented 'addChannel' method for @AIMUX.
end

return;
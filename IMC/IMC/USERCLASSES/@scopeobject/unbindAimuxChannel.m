% SCOPEOBJECT/unbindAimuxChannel - Remove an aimux channel from being displayed on this scope object.
%
% SYNTAX
%  unbindAveragedAimuxChannel(this, channelName, aim)
%
% USAGE
%  This is a convenience method, for removing the callbacks between an aimux object and a scope object.
%
% NOTES
%
% CHANGES
%
% Created 3/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function unbindAimuxChannel(this, channelName, aim)
global scopeObjects;

id = [scopeObjects(this.ptr).name '_Average'];

%Check if it's already bound.
if ~isbound(aim, channelName, this)
    warning('Channel ''%s'' is not bound.', channelName);
    return;
end

unbind(aim, channelName, this);

removeChannel(this, channelName);

return;
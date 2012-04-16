% @SCOPEOBJECT/removeChannel - Remove a channel from being displayed on this scope.
%
% SYNTAX
%  removeChannel(this, channelName)
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 3/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function removeChannel(this, channelName)
global scopeObjects;

if ~ismember(lower(channelName), lower(scopeObjects(this.ptr).channels))
    error('Channel ''%s'' does not exist.', channelName);
end

index = findBindingRowIndex(this, channelName);
indices = 1 : size(1, scopeObjects(this.ptr).bindings);
indices = indices(find(indices ~= index));

channel = scopeObjects(this.ptr).bindings{index, 2};
delete(channel);

scopeObjects(this.ptr).bindings = scopeObjects(this.ptr).bindings{indices, 2};
scopeObjects(this.ptr).min = scopeObjects(this.ptr).min(indices);
scopeObjects(this.ptr).max = scopeObjects(this.ptr).max(indices);

return;
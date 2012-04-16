%Find the row index in the bindings field for the named channel.
function index = findBindingRowIndex(this, channelName)
global scopeObjects;

index = -1;

if isempty(scopeObjects(this.ptr).bindings)
    return;
end

index = find(strcmpi({scopeObjects(this.ptr).bindings{:, 1}}, channelName));

if isempty(index)
    index = -1;
end

return;
% SCOPEOBJECT/getChannelProperty - Get fields tied to specific data channels.
%
% SYNTAX
%  propertyValue = getChannelProperty(SCOPEOBJECT, channelName, propertyName)
%   channelName - The name of the channel to be queried.
%   propertyName - The name of the property to be retrieved.
%   propertyValue - The value of the property that was retrieved.
%
% CHANGES
%   Made the 'YData' accessible, but only for reading. TO021805d - Tim O'Connor 2/18/05
%
% Created 2/9/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function propertyValue = getChannelProperty(this, channelName, propertyName)
global scopeObjects;

if ~ismember(channelName, scopeObjects(this.ptr).channels)
    error('Channel ''%s'' does not exist on this scopeObject.', channelName);
end

index = findBindingRowIndex(this, channelName);
if ~isempty(index) & index > 0
    channel = scopeObjects(this.ptr).bindings{index, 2};
else
    error('Could not find channel ''%s''.', channelName);
end

%TO021805d - Allow access to the YData.
%Maybe other (all) fields of the object should be accessible...?
if strcmpi(propertyName, 'YData')
    propertyValue = get(channel, 'YData');
    return;
end

udata = get(channel, 'UserData');

fnames = fieldnames(udata);
caseSensitiveNameIndex = find(strcmpi(fnames, propertyName));
if isempty(caseSensitiveNameIndex)
    error('Unrecognized channel property: ''%s''', propertyName);
end

propertyValue = udata.(fnames{caseSensitiveNameIndex});

return;
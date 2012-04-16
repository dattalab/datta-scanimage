% SCOPEOBJECT/setChannelProperty - Set fields tied to specific data channels.
%
% SYNTAX
%  setChannelProperty(SCOPEOBJECT, channelName, propertyName, propertyValue, ...)
%   channelName - The name of the channel to be modified.
%   propertyName - The name of the property to be changed.
%   propertyValue - The value to set the property to.
%    Multiple propertyName/propertyValue pairs may be specified, as typical for 'set' methods.
%
% CHANGES
%
% Created 2/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function setChannelProperty(this, channelName, varargin)
global scopeObjects;

if isempty(varargin)
    return;
end

if mod(length(varargin), 2) ~= 0
    error('An equal number of names and values must be supplied.');
end

if ~ismember(channelName, scopeObjects(this.ptr).channels)
    error('Channel ''%s'' does not exist on this scopeObject.', channelName);
end

index = findBindingRowIndex(this, channelName);
if ~isempty(index) & index > 0
    channel = scopeObjects(this.ptr).bindings{index, 2};
else
    error('Could not find channel ''%s''.', channelName);
end
udata = get(channel, 'UserData');

fnames = fieldnames(udata);
fnamesLow = lower(fnames);
unrecognized = {};

%It's slower, but doing it in two passes allows better error handling/reporting.
for i = 1 : 2 : length(varargin)
    if ~ismember(lower(varargin{i}), fnamesLow)
        unrecognized{length(unrecognized) + 1} = varargin{i};
    end
end

if ~isempty(unrecognized)
    s = 'Unrecognized field(s) - ';
    for i = 1 : length(unrecognized) - 1
        s = sprintf('%s''%s'', ', s, unrecognized{i});
    end
    s = sprintf('%s''%s''.', s, unrecognized{end});
    
    error(s);
end

for i = 1 : 2 : length(varargin)
    udata.(varargin{i}) = varargin{i +1};
end
set(channel, 'UserData', udata);

updateDisplayOptions(this);

% for i = 1 : length(scopeObjects(this.ptr).setChannelPropertyListeners)
%     try
%         switch lower(class(scopeObjects(this.ptr).setChannelPropertyListeners{i}))
%             case 'cell'
%                 callback = scopeObjects(this.ptr).setChannelPropertyListeners{i};
%                 feval(callback{:}, varargin{1 : 2 : length(varargin)});
%                 
%             case 'char'
%                 eval(scopeObjects(this.ptr).setChannelPropertyListeners{i})
%                 
%             case 'function_handle'
%                 feval(scopeObjects(this.ptr).setChannelPropertyListeners{i}, varargin{1 : 2 : length(varargin)});
%                 
%             otherwise
%                 warning('Failed to notify this scopeObject''s setListener: Invalid callback class: %s', class(scopeObjects(this.ptr).setChannelPropertyListeners{i}));
%         end
%     catch
%         warning('Failed to notify this scopeObject''s setListener: %s', lasterr);
%     end
% end

return;
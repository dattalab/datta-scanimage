% ttlObject/ttlObject - A ttl representation (including hardware configuration and polarity).
%
% SYNTAX
%  ttlObject
%  ttlObject(name)
%   name - A string, identifying a previously instantiated/loaded object, for which to acquire a pointer.
%
% USAGE
%
% STRUCTURE
%  name - A pseudonym, should be descriptive.
%  boardID - The board ID of the input from this photodiode.
%  channelID - The channel ID of the input from this photodiode.
%  onValue - The value representing this TTL being 'on'. Default: 1
%  offValue - The value representing this TTL being 'off'. Default: 0
%  type - 0 for digital, 1 for analog. Default: 0
%  lastSaveTime - Timestamp of the last save event.
%  lastLoadTime - Timestamp of the last save event.
%  readOnlyFields - A list of fields which can not be set from outside the object.
%    Default: readOnlyFields, lastLoadTime, lastSaveTime
%
% NOTES
%
% CHANGES
%
% Created 8/4/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = ttlObject(varargin)
global ttlObjects;

if isempty(varargin)
    this.ptr = length(ttlObjects) + 1;
    this.serialized = [];
    
    ttlObjects(this.ptr).name = ['ttlObject' num2str(this.ptr)];
    ttlObjects(this.ptr).boardID = -1;
    ttlObjects(this.ptr).channelID = -1;
    ttlObjects(this.ptr).onValue = 1;
    ttlObjects(this.ptr).offValue = 0;
    ttlObjects(this.ptr).type = 0;
    ttlObjects(this.ptr).lastSaveTime = [];
    ttlObjects(this.ptr).lastLoadTime = [];
    ttlObjects(this.ptr).readOnlyFields = {'readOnlyFields', 'lastLoadTime', 'lastSaveTime'};
else
    if length(varargin) ~= 1
        error('Too many arguments.');
    elseif ~strcmpi(class(varargin{1}), 'char')
        error('Argument must be a string.');
    end
    
    this = [];
    for i = 1 : length(ttlObjects)
        if strcmp(varargin{1}, ttlObjects(i).name)
            this.ptr = i;
            this.serialized = [];
            break;
        end
    end
    
    if isempty(this)
        error('No ttlObject found with name ''%s''', varargin{1});
    end  
end

this = class(this, 'ttlObject');

return;
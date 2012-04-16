% @daqjob/bindEventListener(this, eventName, listener, listenerID) - Register a callback to recieve daqjob events.
% 
% SYNTAX
%  bindEventListener(dj, eventName, listener, listenerID)
%  bindEventListener(dj, eventName, listener, listenerID, priority)
%   dj - @daqjob instance.
%   eventName - The event for which to recieve notifications.
%   listener - A @callbackManager style callback.
%   listenerID - A unique ID for this listener.
%   priority - Any number between 1 and 10, such that the lower the number, the more likely this callbackSpec is to be executed first (no gaurantees).
%              Default: 5
%  
% NOTES
%
% CHANGES
%  
% Created
%  Timothy O'Connor 7/30/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function bindEventListener(this, eventName, listener, listenerID, varargin)
global daqjobGlobalStructure;

addCallback(daqjobGlobalStructure(this.ptr).callbackManager, eventName, listener, listenerID, varargin{:});

return;
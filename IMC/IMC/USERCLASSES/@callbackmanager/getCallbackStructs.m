% @callbackManager/getCallbackStructs - Retrieve callbacks structures bound to an event.
%
%  SYNTAX
%   callbackStructs = getEvents(callbackmanager, event)
%    callbackmanager - @callbackmanager object instance.
%    event - A string (case insensitive), naming the event from which to retrieve callbacks.
%    callbackID - A unique identifier (a number, a string, or an object implementing the `eq` method). 
%    callbackStructs - A structure array containing information about the callbacks bound to the named event.
%
%  NOTES
%   A callbackStruct is an (@callbackManager) internal type used to store callbacks. The layout is:
%    .id - The unique identifier associated with this callback.
%    .callbackSpec - The actual callback itself.
%    .priority - The assigned priority of this callback.
%    .callbackArgs - Vectorial cell array of arguments to pass to the callback
%
% CHANGES
%   VI060908A - Added ability to get individual callback structure from among those associated with particular event -- Vijay Iyer 6/9/08
%   TO073108A - Removed VI060908A, as usual, this is in the wrong place (and it's based on 'cut & paste' code, instead of calling the other functions, which is a no-no). -- Tim O'Connor 7/31/08
%
% CREDITS
% Created 12/6/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function callbackStructs = getCallbackStructs(this, event)
global callbackmanagers;

index = [];
if ~isempty(callbackmanagers(this.ptr).callbacks)
    index = find(strcmpi({callbackmanagers(this.ptr).callbacks{:, 1}}, event));
end

if isempty(index)
    callbackStructs = [];
else
    callbackStructs = callbackmanagers(this.ptr).callbacks{index, 2};
end

return;
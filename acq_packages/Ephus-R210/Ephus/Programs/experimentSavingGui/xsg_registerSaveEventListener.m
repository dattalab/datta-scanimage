% xsg_registerSaveEventListener - Recieve save event notifications and a file naming structure.
%
%  SYNTAX
%   xsg_registerSaveEventListener(hObject, callbackSpec, ID)
%    callbackmanager - @callbackmanager object instance.
%    event - A string (case insensitive), naming the event to which to tie callbacks.
%
%  CHANGES
%
% Created 5/18/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function xsg_registerSaveEventListener(hObject, callbackSpec, ID)

cbm = getLocal(progmanager, hObject, 'cbManager');
addCallback(cbm, 'save', callbackSpec, ID);

return;
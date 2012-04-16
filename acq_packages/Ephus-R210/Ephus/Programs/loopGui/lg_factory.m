% lg_factory - This function instantiates a loopGui instance (a singleton GUI) and returns
%              the handle to the gui. It can also return the underlying loopManager object.
%
% SYNTAX
%   lgHandle = lg_factory
%   [lgHandle loopManagerInstance] = lg_factory
%     loopManagerInstance - A @loopManager object.
%     lgHandle - The handle to the loopGui instance.
%
% Created 6/21/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function varargout = lg_factory

hObject = program('loopGui', 'loopGui', 'loopGui');

if ~isstarted(progmanager, hObject)
    openprogram(progmanager, hObject);
end

varargout{1} = hObject;
if nargout == 2
    varargout{2} = getLocal(progmanager, hObject, 'loopManager');
end

return;
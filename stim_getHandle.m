% stim_getHandle - Get the saving gui's handle, start the program, if necessary.
%
%  SYNTAX
%   hObject = stim_getHandle
function hObject = stim_getHandle()

p = program('stimulator', 'stimulator', 'stimulator');
if ~isstarted(progmanager, p)
    openprogram(progmanager, p);
end

hObject = getLocal(progmanager, p, 'hObject');

return;
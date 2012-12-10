% acq_getHandle - Get the saving gui's handle, start the program, if necessary.
%
%  SYNTAX
%   hObject = acq_getHandle
function hObject = ephys_getHandle()

p = program('ephys', 'ephys', 'ephys'); % no idea why there are 3 here..
if ~isstarted(progmanager, p)
    openprogram(progmanager, p);
end

hObject = getLocal(progmanager, p, 'hObject');

return;
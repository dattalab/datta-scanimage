% acq_getHandle - Get the saving gui's handle, start the program, if necessary.
%
%  SYNTAX
%   hObject = acq_getHandle
function hObject = acq_getHandle()

p = program('acquirer', 'acquirer', 'acquirer');
if ~isstarted(progmanager, p)
    openprogram(progmanager, p);
end

hObject = getLocal(progmanager, p, 'hObject');

return;
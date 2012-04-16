% rowNames = st_getRowNames(hObject)
%
% Get the row names of a running summaryTable program, represented by the hObject handle.
%
% Created: Tim O'Connor 12/16/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function rowNames = st_getRowNames(hObject)

rowNames = getLocal(progmanager, hObject, 'rowNames');

return;
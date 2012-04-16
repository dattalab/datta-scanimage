% st_refreshRowNames(hObject)
%
% Update the row names of a running summaryTable program, represented by the hObject handle.
%
% Created: Tim O'Connor 12/14/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_refreshRowNames(hObject)

rowOffset = getLocal(progmanager, hObject, 'rowOffset');
rowNames = getLocal(progmanager, hObject, 'rowNames');

for i = 1 : 20
    handle = getLocalGh(progmanager, hObject, ['row' num2str(i)]);
    
    if i + rowOffset <= length(rowNames)
        set(handle, 'String', rowNames{i + rowOffset});
    else
        set(handle, 'String', num2str(i + rowOffset));
    end
end

return;
% st_refreshColumnNames(hObject)
%
% Update the column names of a running summaryTable program, represented by the hObject handle.
%
% Created: Tim O'Connor 12/14/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function st_refreshColumnNames(hObject)

columnOffset = getLocal(progmanager, hObject, 'columnOffset');
columnNames = getLocal(progmanager, hObject, 'columnNames');

for i = 1 : 8
    handle = getLocalGh(progmanager, hObject, ['column' num2str(i)]);
    
    if i + columnOffset <= length(columnNames)
        set(handle, 'String', columnNames{i + columnOffset});
    else
        set(handle, 'String', num2letter(i + columnOffset));
    end
end

return;

%------------------------------------------------------------
function letter = num2letter(num)

if num > 26
    len = 1 + fix(num ./ 26);
else
    len = 1;
end

for i = 1 : len
    letter(i) = char('A' + num - (len - i) * 26 - i);
end

return;
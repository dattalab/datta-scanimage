% SETTINGSOBJECT/delete
%
% SYNTAX
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO020806B: Must also reduce the pointer values, as well as shuffling the arrays. -- Tim O'Connor 2/8/06
%
% Created 7/15/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function delete(this)
global settingsObjects;

% fprintf(1, '\nvvvvvvvvvvvvvvvvvvvvv\n%s', getStackTraceString);
% settingsObjects(1).table
% this.ptr

index = find([settingsObjects(1).table(:, 1)] == this.ptr);
% fprintf(1, '@settingsobject/delete: %s:%s - %s\n%s\n', num2str(this.ptr), num2str(indexOf(this)), num2str(index), getStackTraceString);
if isempty(index)
    error('Invalid pointer: %s', num2str(this.ptr));
elseif length(index) > 1
    error('Indeterminate pointer value: %s', num2str(this.ptr));
end
pointer = settingsObjects(1).table(index, 2);

indices = find((1:size(settingsObjects(1).table, 1)) ~= index);
pointers = find((1:length(settingsObjects)) ~= pointer);

settingsObjects = [settingsObjects(pointers)];

settingsObjects(1).table = settingsObjects(1).table(indices, :);
reduceIndices = find(settingsObjects(1).table(:, 2) > pointer);%TO020806B
settingsObjects(1).table(reduceIndices, 2) = settingsObjects(1).table(reduceIndices, 2) - 1;%TO020806B

% settingsObjects(1).table
% fprintf(1, '\n^^^^^^^^^^^^^^^^^^^^^\n');

return;
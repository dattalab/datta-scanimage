% SETTINGSOBJECT/private/indexOf
%
% SYNTAX
%  pointer = indexOf(this.ptr)
%
% USAGE
%  Performs a table lookup on the pointer value, to dereference it.
%
% NOTES
%
% CHANGES
%
% Created 7/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function pointer = indexOf(this)
global settingsObjects;

index = find([settingsObjects(1).table(:, 1)] == this.ptr);
if isempty(index)
    error('Invalid pointer: %s', num2str(this.ptr));
elseif length(index) > 1
    error('Indeterminate pointer value: %s', num2str(this.ptr));
end

pointer = settingsObjects(1).table(index, 2);

return;
% SIGNAL/delete - Remove this instance of the object.
%
% Clean up this object's instance, any further method calls to this object will
% have undefined results.
%
% CHANGES:
%   Tim O'Connor 2/3/05 TO020305c: Fixed logical errors in deleting children.
%
% Created 10/25/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function delete(this)
global signalobjects;

% fprintf(1, '@signalobject delete\n%s\n', getStackTraceString);
if length(this) > 1
    for i = 1 : length(this)
        delete(this(i));
    end
    
    return;
end
% fprintf(1, '@signalobject/delete: this.ptr = %s\n%s\n', num2str(this.ptr), getStackTraceString);
if isempty(signalobjects(1).signal)
    warning('Attempt to delete @signal object, when none exist. Seems like a leftover pointer floating around.');
    return;
end

pointer = indexOf(this);

if signalobjects(pointer).debugMode
    warning('@signal/delete - ptr: %s & index: %s', num2str(this.ptr), num2str(pointer));
end

if length(signalobjects) < 1
    if signalobjects(pointer).debugMode
        fprintf(1, '@signal/delete - delete aborted, no objects available in the global array.\n');
    end
    return;
end

for i = 1 : length(this)
    if signalobjects(pointer).deleteChildrenAutomatically
        %TO020305c - Do this before adjusting the global array.
        deleteChildren(this(i));
    end
    if this(i).ptr == length(signalobjects)
        signalobjects = signalobjects(1 : end - 1);
    else
        signalobjects = signalobjects(find((1 : length(signalobjects)) ~= pointer));
    end
    
    %Fix up the map.
    signalobjects(1).signal = signalobjects(1).signal(find(signalobjects(1).signal(:, 1) ~= this(i).ptr), :);
    signalobjects(1).signal = signalobjects(1).signal(find(signalobjects(1).signal(:, 2) ~= pointer), :);
    signalobjects(1).signal(find(signalobjects(1).signal(:, 2) > pointer), 2) = signalobjects(1).signal(find(signalobjects(1).signal(:, 2) > pointer), 2) - 1;
end

return;
% USAGE
%  startsWithIgnoreCase(parentString, childString)
%
% Returns true if, and only if, `lower(childString)` is both a substring of `lower(parentString)`
% and the `lower(childString)` matches a contiguous sequence at the beginning of `lower(parentString)`.
%
% CHANGES
%  TO123005N: Also operate on cell arrays of strings. -- Tim O'Connor 12/30/05
%
%
%Created Timothy O'Connor 8/26/04
%Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function boolean = startsWithIgnoreCase(string, beginning)

if strcmpi(class(string), 'cell')
    for i = 1 : length(string)
        boolean(i) = startsWithIgnoreCase(string{i}, ending);
    end
    
    return;
end

boolean = 0;

if length(string) < length(beginning)
    return;
end

boolean = strcmpi(string(1 : length(beginning)), beginning);

return;
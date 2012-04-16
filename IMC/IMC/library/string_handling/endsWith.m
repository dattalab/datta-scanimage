% USAGE
%  endsWith(parentString, childString)
%
% Returns true if, and only if, childString is both a substring of parentString
% and the childString matches a contiguous sequence at the end of parentString.
%
% CHANGES
%  TO123005N: Also operate on cell arrays of strings. -- Tim O'Connor 12/30/05
%
%Created Timothy O'Connor 8/26/04
%Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function boolean = endsWith(string, ending)

if strcmpi(class(string), 'cell')
    for i = 1 : length(string)
        boolean(i) = endsWith(string{i}, ending);
    end
    
    return;
end

boolean = 0;

if length(string) < length(ending)
    return;
end

boolean = strcmp(string(length(string) - length(ending) + 1: end), ending);

return;
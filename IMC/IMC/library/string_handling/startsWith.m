% USAGE
%  startsWith(parentString, childString)
%
% Returns true if, and only if, childString is both a substring of parentString
% and the childString matches a contiguous sequence at the beginning of parentString.
%
%Created Timothy O'Connor 8/26/04
%Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function boolean = startsWith(string, beginning)

boolean = 0;

if length(string) < length(beginning)
    return;
end

boolean = strcmp(string(1 : length(beginning)), beginning);

return;
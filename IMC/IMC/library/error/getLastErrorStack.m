% getLastErrorStack - Retrieve the a formatted string containing the last error message and stack trace leading to the error, suitable for printing.
%
%  SYNTAX
%   str = getLastErrorStack
%
%  NOTES
%   Relies on getStackTraceString and The Mathworks's (new as of version 7) lasterror function.
%
%  CHANGES
%
% Created 11/30/07 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function str = getLastErrorStack

err = lasterror;
str = sprintf('LastError - ''%s'': \n\t%s\n\tRoot cause:\n\t%s\n', ...
    err.identifier, ...
    strrep(err.message, char(10), char([10 9 32 32])), ...
    strrep(getStackTraceString(err.stack), char(10), char([10 9])));

return;
% getLastErrorStack - Retrieve the a formatted string containing the last error message and stack trace leading to the error, suitable for printing.
%
%%  SYNTAX
%   str = getLastErrorStack
%   str = getLastErrorStack(errorLogFile)
%       errorLogFile: name of a file to which to append error stack information
%
%%  NOTES
%   Relies on getStackTraceString and The Mathworks's (new as of version 7) lasterror function.
%
%%  CHANGES
%   VI081508A: Added option to append error to an error log file -- Vijay Iyer 8/15/08
%
%% CREDITS
% Created 11/30/07 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function str = getLastErrorStack(varargin)

err = lasterror;
str = sprintf('LastError - ''%s'': \n\t%s\n\tRoot cause:\n\t%s\n', ...
    err.identifier, ...
    strrep(err.message, char(10), char([10 9 32 32])), ...
    strrep(getStackTraceString(err.stack), char(10), char([10 9])));

if ~isempty(varargin)
    try
        fid = fopen(varargin{1},'a');
        if fid           
            fprintf(fid,'\n************%s*******************\n%s',datestr(clock),str);
        end
        fclose(fid);
    end
end

return;
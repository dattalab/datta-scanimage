% cellHandle = st_getCellHandle(hObject, cellRowNumber, cellColumnNumber)
%
% Get the handle to the pushbutton representing cellRowNumber and cellColumnNumber.
%
% NOTE: This does not take into account any rowOffset or columnOffset relative to the data.
%       It is strictly to access each button directly, regardless of the data it is attached to.
%
% Created: Tim O'Connor 12/14/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function cellHandle = st_getCellHandle(hObject, rowNumber, columnNumber)

if rowNumber > 20
    error('Row number out of range (1-20): %s', num2str(rowNumber));
elseif rowNumber < 1
    error('Row number out of range (1-20): %s', num2str(rowNumber));
end

if columnNumber > 8
    error('Column number out of range (1-8): %s', num2str(columnNumber));
elseif columnNumber < 1
    error('Column number out of range (1-8): %s', num2str(columnNumber));
end

switch columnNumber
    case 1
        column = 'A';
    case 2
        column = 'B';
    case 3
        column = 'C';
    case 4
        column = 'D';
    case 5
        column = 'E';
    case 6
        column = 'F';
    case 7
        column = 'G';
    case 8
        column = 'H';
    otherwise
        error('Unrecognized column number: %s', num2str(columnNumber));
end

cellHandle = getLocalGh(progmanager, hObject, ['text' column num2str(rowNumber)]);

return;
% @daqjob/setInputOverflowMode - Set input overflow mode
% 
% SYNTAX
%  setInputOverflowMode(dj, mode)
%   dj - @daqjob instance.
%   mode - A string, one of 'error' or 'drop'
%  
% NOTES
%   In a rush, this conforms to existing @daqjob style wherein setters/getters are all named methods, rather than tied to a common get/set method. Ugh. -- Vijay Iyer ??/??/08
%
% CHANGES
%  TO080108G - This function flat out didn't work (clearly never tested). Plus, there was crazy gobbledygook about parsing the input arguments (which aren't flexible). It works now. -- Tim O'Connor 8/1/08
%  TO081008A - As usual, VI080808A involved no testing, thus breaking this function. -- Tim O'Connor 8/10/08
%
% Created
%  Vijay Iyer - ??/??/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute/Janelia Farm Research Center 2008
function setInputOverflowMode(this, mode)
global daqjobGlobalStructure;

if ~ismember(mode, {'error', 'drop'})
    error('InputOverflowMode must be either ''error'' or ''drop''.\n');
end

daqjobGlobalStructure(this.ptr).readErrorMode = mode;%TO081008A since VI080808A didn't actually do anything useful without this.

% errorCond = false;
% if ~ischar(mode)
%     errorCond = true;
% elseif ~strcmpi(mode,'error') && ~strcmpi(mode,'drop')
%     errorCond = true;
% else
%     daqjobGlobalStructure(this.ptr).input = mode;
% end
% 
% if errorCond
%     error('Argument must be a string, one of ''error'' or ''drop''');    
% end

return;
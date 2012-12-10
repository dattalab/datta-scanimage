% ephys_setTraceLength - Set the epoch number.
%
% SYNTAX
%  acq_setTraceLength(traceLength)
%  xsg_setEpochNumber(hObject, traceLength)
%   traceLength - Any integer from 0 to 9999. the length of the trace in
%   seconds
%
% USAGE
%
% NOTES
%
% CHANGES
function ephys_setTraceLength(varargin)

if length(varargin) == 1
    hObject = ephys_getHandle;
    traceLength = varargin{1};
else
    hObject = varargin{1};
    traceLength = varargin{2};
end

setLocal(progmanager, hObject, 'traceLength', traceLength);
ephys('traceLength_Callback',hObject,[],guihandles(getParent(hObject, 'figure')))

return;
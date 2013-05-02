% acq_setTraceLength - Set the acquirer trace length.
%
% SYNTAX
%  acq_setTraceLength(traceLength)
%   traceLength - Any integer from 0 to 9999. the length of the trace in
%   seconds
%
% USAGE
%
% NOTES
%
% CHANGES
function acq_setTraceLength(traceLength)
setGlobal(progmanager, 'traceLength', 'acquirer', 'acquirer', traceLength);
return;
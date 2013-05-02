% ephys_setTraceLength - Set the ephys trace length.
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
function ephys_setTraceLength(traceLength)
setGlobal(progmanager, 'traceLength', 'ephys', 'ephys', traceLength);
return;
% stim_setTraceLength - Set the stimulator trace length.
%
% SYNTAX
%  stim_setTraceLength(traceLength)
%   traceLength - Any integer from 0 to 9999. the length of the trace in
%   seconds
%
% USAGE
%
% NOTES
%
% CHANGES
function stim_setTraceLength(traceLength)
setGlobal(progmanager, 'traceLength', 'stimulator', 'stimulator', traceLength);
return;
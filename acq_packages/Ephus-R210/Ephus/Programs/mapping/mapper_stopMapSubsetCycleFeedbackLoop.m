% mapper_stopMapSubsetCycleFeedbackLoop -  Stops the feedback cycle.
%
% SYNTAX
%  mapper_stopMapSubsetCycleFeedbackLoop
%
% NOTES
%  See mapper_startMapSubsetCycleFeedbackLoop.
%
% Created: Timothy O'Connor 3/14/09
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2009
function mapper_stopMapSubsetCycleFeedbackLoop
global MapSubsetCycleFeedbackLoop;

MapSubsetCycleFeedbackLoop.abort = 1;
stop(MapSubsetCycleFeedbackLoop.timer);

cbm = getUserFcnCBM;
removeCallback(cbm, 'ephys:TraceAcquired', 'userFcns_mapper_MapSubsetCycleFeedbackLoop_userFcn');

return;
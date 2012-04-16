% startResponseTracker - Starts the responseTracker program (under @progmanager control).
%
% SYNTAX
%  responseTracker
%  rt = responseTracker
%    rt - The program handle, assigned during start-up.
%
% Created - Timothy O'Connor 3/13/09
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2009
function rt = startResponseTracker

rt = openprogram(progmanager, 'responseTracker');

return;
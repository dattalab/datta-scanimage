% loopManager/display - Print the object to the screen.
%
% SYNTAX
%  display(lm)
%   lm - A @loopManager instance.
%
% NOTES
%
% CHANGES
%
% Created 10/16/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function display(this)
global loopManagers;

fprintf(1, '@loopManager v0.2\nObjectPointer: %s\n', num2str(this.ptr));

fprintf(1, '\tstarted: %s\n', num2str(loopManagers(this.ptr).started));
fprintf(1, '\trunning: %s\n', num2str(loopManagers(this.ptr).running));
fprintf(1, '\tinterval: %s\n', num2str(loopManagers(this.ptr).interval));
fprintf(1, '\titerationNumber: %s\n', num2str(loopManagers(this.ptr).iterationNumber));
fprintf(1, '\titerationCounter: %s\n', num2str(loopManagers(this.ptr).iterationCounter));
fprintf(1, '\ttotalIterationCounter: %s\n', num2str(loopManagers(this.ptr).totalIterationCounter));
fprintf(1, '\tlastStartTime: %s\n', datestr(loopManagers(this.ptr).lastStartTime));
fprintf(1, '\tlastStartStackTrace:\n\t\t%s\n', strrep(loopManagers(this.ptr).lastStartStackTrace(1:end-1), sprintf('\n'), sprintf('\n\t\t')));
fprintf(1, '\tlastIterationTime: %s\n', datestr(loopManagers(this.ptr).lastIterationTime));
fprintf(1, '\tpreciseTimeMode: %s\n', num2str(loopManagers(this.ptr).preciseTimeMode));
fprintf(1, '\tbusyMode: %s\n', loopManagers(this.ptr).busyMode);

fprintf(1, '\ttimer:\n');
disp(loopManagers(this.ptr).timer);
fprintf(1, '\n\tcallbackManager:\n');
disp(loopManagers(this.ptr).callbackManager);
fprintf(1, '\n');

return;
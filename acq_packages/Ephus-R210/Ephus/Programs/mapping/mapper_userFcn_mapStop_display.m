% mapper_userFcn_mapStop_display - Used to terminate online display of map data.
%
% SYNTAX
%  mapper_userFcn_mapStop_display
%
% USAGE
%  Bind this function to the mapper:MapStop event.
%
% NOTES
%
% CHANGES
%
% Created 3/30/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_userFcn_mapStop_display(varargin)
global mapper_userFcn_display;
% fprintf(1, 'mapper_userFcn_mapStop_display\n');
mapper_userFcn_display.started = 0;

return;
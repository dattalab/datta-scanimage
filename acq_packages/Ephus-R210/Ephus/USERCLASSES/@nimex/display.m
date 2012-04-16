% @nimex/display - Displays the current state of the object.
% 
% SYNTAX
%  display(nimextask)
%   nimextask - An instance of the nimex class.
%  
% NOTES
%  Relies on NIMEX_display.mex32.
%
% CHANGES
%  TO040207A - For consistent syntax, created nimex_display.m. -- Tim O'Connor 4/2/07
%  
% Created
%  Timothy O'Connor 1/29/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function display(this)

nimex_display(this);

% fprintf(1, 'display: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
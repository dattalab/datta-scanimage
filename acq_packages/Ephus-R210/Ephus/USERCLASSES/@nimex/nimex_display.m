% @nimex/nimex_display - Displays the current state of the object.
% 
% SYNTAX
%  nimex_display(nimextask)
%   nimextask - An instance of the nimex class.
%  
% NOTES
%  Relies on NIMEX_display.mex32.
%  
% Created
%  Timothy O'Connor 4/2/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_display(this)

if length(this) > 1
    fprintf(1, '%s matrix of @nimex task objects.\n', mat2str(size(this)));
else
    NIMEX_display(this.NIMEX_TaskDefinition);
end

% fprintf(1, 'nimex_display: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;
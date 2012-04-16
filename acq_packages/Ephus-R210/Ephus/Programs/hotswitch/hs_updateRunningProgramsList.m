% hs_updateRunningProgramsList - Check the @programmanager for an updated program list.
%
% SYNTAX
%  hs_updateRunningProgramsList(hObject)
%    hObject - The program handle.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO032210D - Filter out Hotswitch, since it's now bigger and less likely to need to be configured by itself. -- Tim O'Connor 3/22/10
%
% Created 9/7/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function hs_updateRunningProgramsList(hObject)

names = getProgramNames(progmanager);
names = setdiff(names, 'hotswitch');
setLocalGh(progmanager, hObject, 'runningPrograms', 'String', names);

return;
% xsg_getFilename - Get the fully qualified filename, sans extension.
%
%  SYNTAX
%   filename = xsg_getFileName
%
%  CHANGES
%   TO042106C - Allow options for augmenting the path with the experiment # and set ID. -- Tim O'Connor 4/21/06
%
% Created 5/19/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function filename = xsg_getFilename

hObject = xsg_getHandle;

%TO042106C
directory = getLocal(progmanager, hObject, 'directory');
directory = xsg_getPath;
initials = getLocal(progmanager, hObject, 'initials');
experimentNumber = getLocal(progmanager, hObject, 'experimentNumber');
setID = getLocal(progmanager, hObject, 'setID');
acquisitionNumber = getLocal(progmanager, hObject, 'acquisitionNumber');

filename = fullfile(directory, [initials experimentNumber setID acquisitionNumber]);

return;
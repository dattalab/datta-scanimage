% @progmanager/saveGuiMetaData - Get a list of all running guis (this includes sub-guis within a program).
%
% SYNTAX
%  saveGuiMetaData(progmanager, targetFile, programName)
%    progmanager - The programmanager object instance.
%    targetFile - The file in which to store the metadata.
%    programName - The program for which to store metadata.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 3/16/10 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2010
function saveGuiMetaData(this, targetFile, programName)
global progmanagerglobal;

if exist(targetFile, 'file') == 2
    load(targetFile, '-mat');
end

guiNames = fieldnames(progmanagerglobal.programs.(programName).guinames);
for j = 1 : length(guiNames)
    progmanagerGuisConfig.(programName).guis.(guiNames{j}).position = get(progmanagerglobal.programs.(programName).guinames.(guiNames{j}).fighandle, 'Position');
    progmanagerGuisConfig.(programName).guis.(guiNames{j}).visible = get(progmanagerglobal.programs.(programName).guinames.(guiNames{j}).fighandle, 'Visible');
end

saveCompatible(targetFile, 'progmanagerGuisConfig', '-mat');%TO071906D

return;
% SETTINGSOBJECT/saveobj
%
% SYNTAX
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO113005C - Make sure the metadata is saved/loaded. -- Tim O'Connor 11/30/05
%  TO113005D - Clean up the serialized form. -- Tim O'Connor 11/30/05
%
% Created 7/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = loadobj(this)
global settingsObjects;

if ~isfield(settingsObjects, 'table')
    settingsObjects(1).table = [];
    this.ptr = 1;
else
    if isempty(settingsObjects(1).table)
        this.ptr = 1;
    else
        this.ptr = max([settingsObjects(1).table(:, 1)]) + 1;
    end
end
settingsObjects(1).table(size(settingsObjects(1).table, 1) + 1, 1) = this.ptr;
settingsObjects(1).table(size(settingsObjects(1).table, 1), 2) = length(settingsObjects) + 1;
pointer = settingsObjects(1).table(size(settingsObjects(1).table, 1), 2);

settingsObjects(pointer).settings = this.serialized.settings;
settingsObjects(pointer).lastLoadTime = clock;
settingsObjects(pointer).programName = this.serialized.programName;
settingsObjects(pointer).guiName = this.serialized.guiName;
settingsObjects(pointer).programVersion = this.serialized.programVersion;
settingsObjects(pointer).lastSaveTime = this.serialized.lastSaveTime;
settingsObjects(pointer).metadata = this.serialized.metadata;%TO113005C

this.serialized = [];%TO113005D

return;
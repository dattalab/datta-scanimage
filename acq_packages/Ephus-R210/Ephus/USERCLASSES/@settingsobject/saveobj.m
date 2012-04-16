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
%
% Created 7/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = saveobj(this)
global settingsObjects;

pointer = indexOf(this);
settingsObjects(pointer).lastSaveTime = clock;
this.serialized.settings = settingsObjects(pointer).settings;
this.serialized.programName = settingsObjects(pointer).programName;
this.serialized.guiName = settingsObjects(pointer).guiName;
this.serialized.programVersion = settingsObjects(pointer).programVersion;
this.serialized.lastSaveTime = settingsObjects(pointer).lastSaveTime;
this.serialized.lastLoadTime = settingsObjects(pointer).lastLoadTime;
this.serialized.metadata = settingsObjects(pointer).metadata;%TO113005C

% a = settingsObjects(pointer).settings.signalCollection
% class(a)
% save('test.signals', 'a', '-mat');

return;
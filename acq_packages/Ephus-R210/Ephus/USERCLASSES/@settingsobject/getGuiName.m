% SETTINGSOBJECT/getGuiName
%
% SYNTAX
%  guiName = getGuiName(SETTINGS)
%   SETTINGS - A @settingsobject instance.
%   guiName - The gui name associated with this object.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 7/16/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function guiName = getGuiName(this)
global settingsObjects;

guiName = settingsObjects(indexOf(this)).guiName;

return;
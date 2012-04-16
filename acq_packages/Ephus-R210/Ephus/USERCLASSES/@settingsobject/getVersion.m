% SETTINGSOBJECT/getVersion
%
% SYNTAX
%  version = getVersion(SETTINGS)
%   SETTINGS - A @settingsobject instance.
%   version - The program version associated with this object.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 7/16/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function version = getVersion(this)
global settingsObjects;

version = settingsObjects(indexOf(this)).programVersion;

return;
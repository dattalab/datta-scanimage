% SETTINGSOBJECT/getProgramName
%
% SYNTAX
%  programName = getProgramName(SETTINGS)
%   SETTINGS - A @settingsobject instance.
%   programName - The program name associated with this object.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 7/16/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function programName = getProgramName(this)
global settingsObjects;

programName = settingsObjects(indexOf(this)).programName;

return;
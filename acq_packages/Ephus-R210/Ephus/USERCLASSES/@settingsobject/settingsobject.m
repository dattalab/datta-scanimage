% SETTINGSOBJECT/settingsobject
%
% SYNTAX
%  config = settings
%  config = settings(ProgramName, guiName, programVersion)
%   programName - The name of the program associated with these settings.
%   guiName - The name of the GUI associated with these settings.
%   programVersion - The version number of the program associated with these settings.
%   config - The new settingsObject instance.
%
% USAGE
%  This object represents the settings of a program, for use in saving/loading.
%
% NOTES
%
% CHANGES
%  TO112305C - Added metadata, primarily for dealing with popupmenu and listbox GUI items. -- Tim O'Connor 11/23/05
%
% Created 7/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = settingsobject(varargin)
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
this.serialized = [];

settingsObjects(1).table(size(settingsObjects(1).table, 1) + 1, 1) = this.ptr;
settingsObjects(1).table(size(settingsObjects(1).table, 1), 2) = length(settingsObjects) + 1;
pointer = settingsObjects(1).table(size(settingsObjects(1).table, 1), 2);

settingsObjects(pointer).programName = '';
settingsObjects(pointer).guiName = '';
settingsObjects(pointer).programVersion = NaN;
settingsObjects(pointer).settings = [];
settingsObjects(pointer).metadata = [];
settingsObjects(pointer).lastSaveTime = [];
settingsObjects(pointer).lastLoadTime = [];

if length(varargin) == 3
    if ~ischar(varargin{1}) || ~ischar(varargin{2}) || ~isnumeric(varargin{3})
        error('Invalid programName guiName, or programVersion argument(s).');
    end
    settingsObjects(pointer).programName = varargin{1};
    settingsObjects(pointer).guiName = varargin{2};
% fprintf(1, '@settingsobject/settingsobject: ''%s'':''%s'' - %s:%s\n', varargin{1}, varargin{2}, num2str(this.ptr), num2str(pointer));
    settingsObjects(pointer).programVersion = varargin{3};
end

this = class(this, 'settingsobject');

% fprintf(1, '\n---------------------\n%s', getStackTraceString);
% settingsObjects(1).table
% display(this)

return;
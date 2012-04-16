% SETTINGSOBJECT/get
%
% SYNTAX
%  [variableValue, ...] = get(INSTANCE, variableName, ...)
%  structure = get(INSTANCE)
%   INSTANCE - A settingsObject.
%   variableName - A variable name to be stored.
%   variableValue - A variable value, associated with the given name.
%   structure - A structure representing all the variables and their values (one field for each variable).
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 7/15/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = get(this, varargin)
global settingsObjects;

pointer = indexOf(this);

if isempty(varargin)
    varargout{1} = settingsObjects(pointer).settings;
else
    for i = 1 : length(varargin)
        varargout{i} = settingsObjects(pointer).settings.(varargin{i});
    end
end

return;
% SETTINGSOBJECT/set
%
% SYNTAX
%  set(INSTANCE, variableName, variableValue, ...)
%  set(INSTANCE, structure)
%   INSTANCE - A settingsObject.
%   variableName - A variable name to be stored.
%   variableValue - A variable value, associated with the previous name.
%   structure - A structure representing all the variables and their values (one field for each variable).
%
% USAGE
%  Multiple variableName/variableValue pairs are allowed.
%
% NOTES
%  Using the `set(INSTANCE, structure)` form of this method will overwrite any existing variables,
%  while removing any variables that are not in the new structure. This is the faster (and therefore 
%  preferred) form of this method.
%
% CHANGES
%
% Created 7/15/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function set(this, varargin)
global settingsObjects;

pointer = indexOf(this);

if length(varargin) == 1
    if ~strcmpi(class(varargin{1}), 'struct')
        error('The single argument form of settingsObject/set requires a structure: %s', class(varargin{1}));
    end
    
    settingsObjects(pointer).settings = varargin{1};
else
    if mod(length(varargin), 2) ~= 0
        error('An equal number of names and values must be supplied.');
    end
    
    for i = 1 : 2 : length(varargin)
        settingsObjects(pointer).settings.(varargin{i}) = varargin{i + 1};
    end
end

return;
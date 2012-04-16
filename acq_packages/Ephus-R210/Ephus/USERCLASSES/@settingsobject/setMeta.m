% SETTINGSOBJECT/setMeta
%
% SYNTAX
%  setMeta(INSTANCE, variableName, variableValue, ...)
%   INSTANCE - A settingsObject.
%   variableName - A variable name to be stored.
%   variableValue - A variable value, associated with the previous name.
%
% USAGE
%  Multiple variableName/variableValue pairs are allowed.
%
% NOTES
%  Using the `setMeta(INSTANCE, structure)` form of this method will overwrite any existing metadata,
%  while removing any metadata that is not in the new structure. This is the faster (and therefore 
%  preferred) form of this method.
%
% CHANGES
%
% Created 11/23/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function setMeta(this, varargin)
global settingsObjects;

pointer = indexOf(this);

if length(varargin) == 1
    if ~strcmpi(class(varargin{1}), 'struct')
        error('The single argument form of settingsObject/set requires a structure: %s', class(varargin{1}));
    end
    
    settingsObjects(pointer).metadata = varargin{1};
else
    if mod(length(varargin), 2) ~= 0
        error('An equal number of names and values must be supplied.');
    end

    for i = 1 : 3 : length(varargin)
        settingsObjects(pointer).metadata.(varargin{i}) = varargin{i + 1};
    end
end

return;
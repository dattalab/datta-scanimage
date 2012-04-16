% SETTINGSOBJECT/getMeta
%
% SYNTAX
%  [variableMetadata, ...] = getMeta(INSTANCE, variableName, ...)
%  structure = get(INSTANCE)
%   INSTANCE - A settingsObject.
%   variableName - A variable name to be stored.
%   variableMetadata - A variable's metadata, associated with the given name.
%   structure - A structure representing all the variables and their metadata (one field for each variable).
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO062306D: Return empty if the requested metadata does not exist. -- Tim O'Connor 6/23/06
%
% Created 7/15/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = getMeta(this, varargin)
global settingsObjects;

pointer = indexOf(this);

if isempty(varargin)
    varargout{1} = settingsObjects(pointer).metadata;
else
    for i = 1 : length(varargin)
        %TO062306D
        if isfield(settingsObjects(pointer).metadata, varargin{i})
            varargout{i} = settingsObjects(pointer).metadata.(varargin{i});
        else
            varargout{i} = [];
        end
    end
end

return;
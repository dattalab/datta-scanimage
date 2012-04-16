% SCOPEOBJECT/clearData - Clear all displayed data on a scope (or for just specific channels on a scope).
%
% SYNTAX
%  clearData(SCOPEOBJECT)
%  clearData(SCOPEOBJECT, channelName, ...)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO092605E: Enhanced, so that it can handle batched jobs across multiple objects. -- Tim O'Connor 9/26/05
%  TO121405A: Make the scaling based on running averages. Clear any scaling statistics as well. -- Tim O'Connor 12/14/05
%  Jinyang Liu  & Tim O'Connor 8/2/07 JL080207A: Added holdOn as a field, implemented functionality in addData.m.
%
% Created 6/27/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function clearData(this, varargin)
global scopeObjects;

%TO092605E

if length(this) > 1
    for i = 1 : length(this)
        clearData(this(i));
    end
    return;
end

%aa= scopeObjects(this.ptr).gridOn

if scopeObjects(this.ptr).deleted
    warning('A deleted scope object has recieved a clear command.');
end

if ~ishandle(scopeObjects(this.ptr).figure)
    warning('Figure handle for this @scopeobject (''%s'') is missing/corrupted.', scopeObjects(this.ptr).name);
    return;
end

if ~isempty(varargin)
    if strcmpi(class(varargin{1}), 'cell')
        varargin = varargin{1};
    end
end

if isempty(varargin)
    for i = 1 : size(scopeObjects(this.ptr).bindings, 1)
        set(scopeObjects(this.ptr).bindings{i, 2}, 'YData', [], 'XData', []);
    end
else
    index = findBindingRowIndex(this, channelName);
    yData = set(scopeObjects(this.ptr).bindings{index, 2}, 'YData', [], 'XData', []);
end

if ~isempty(scopeObjects(this.ptr).heldLines)
    delete(scopeObjects(this.ptr).heldLines);
    scopeObjects(this.ptr).heldLines = [];
end

scopeObjects(this.ptr).min(:, :) = 0;%TO021805f, TO121405A
scopeObjects(this.ptr).max(:, :) = 0;%TO021805f, TO121405A
scopeObjects(this.ptr).mean(:, :) = 0;%TO021805f, TO121405A

return;
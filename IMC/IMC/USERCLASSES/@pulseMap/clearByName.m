%  - 
%
% SYNTAX
%
% NOTES
%
% CHANGES
%  TO121307F - Clear the pulse from the shadowMap as well. -- Tim O'Connor 12/13/07
%  TO050408B - Assorted small (non-fatal, often ignored) bug fixes. -- Tim O'Connor 5/4/08
%
% Created
%  Timothy O'Connor 8/13/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function clearByName(this, varargin)
global pulseMapGlobalStructure;

if length(varargin) == 1
    if iscell(varargin{1})
        v = varargin{1};
        for i = 1 : length(v)
            clearByName(this, v{i});
        end
        return;
    end
else
    for i = 1 : length(varargin)
        clearByName(this, varargin{i});
    end
    return;
end

index = indexOf(this, varargin{1});
if isempty(index)
    return;
end
pulseMapGlobalStructure(this.ptr).map{index, 2} = [];
pulseMapGlobalStructure(this.ptr).shadowMap{index, 2} = [];

return;
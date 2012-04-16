%  - 
%
% SYNTAX
%
% NOTES
%
% CHANGES
%  TO101907B - Created a shadow map, to protect the real map when it's swapped out externally. -- Tim O'Connor 10/18/07
%  TO102307D - Allow locking of pulses. -- Tim O'Connor 10/23/07
%
% Created
%  Timothy O'Connor 8/13/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function this = pulseMap(name)
global pulseMapGlobalStructure;

if isempty(pulseMapGlobalStructure)
    index = [];
else
    %Look for an existing job with that name.
    index = find(strcmpi({pulseMapGlobalStructure(:).name}, name));
end

if ~isempty(index)
    if length(index) > 1
        warning('pulseMap - Found multiple object instances that match ''%s''.', name);
    end
    this.ptr = index(1);
else
    this.ptr = length(pulseMapGlobalStructure) + 1;
    %Initialize.
    pulseMapGlobalStructure(this.ptr).name = name;
    pulseMapGlobalStructure(this.ptr).map = {};
    pulseMapGlobalStructure(this.ptr).shadowMap = {};%TO101907B
    pulseMapGlobalStructure(this.ptr).lockedChannels = {};%TO102307D
end

this = class(this, 'pulseMap');

return;
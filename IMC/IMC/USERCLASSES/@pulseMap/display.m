% @pulseMap/display - 
%
% SYNTAX
%  display(pm)
%   pm - A @pulseMap instance.
%
% NOTES
%
% CHANGES
%
% Created
%  Timothy O'Connor 12/13/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function display(this)
global pulseMapGlobalStructure;

fprintf(1, '@pulseMap v0.1\nObjectPointer: %s\nName: %s\n', num2str(this.ptr), pulseMapGlobalStructure(this.ptr).name);
fprintf(1, '\tmap:\n');
printMap(pulseMapGlobalStructure(this.ptr).map);
fprintf(1, '\tshadowMap:\n');
printMap(pulseMapGlobalStructure(this.ptr).shadowMap);
if isempty(pulseMapGlobalStructure(this.ptr).lockedChannels)
    fprintf(1, '\tlockedChannels: NONE\n');
else
    fprintf(1, '\tlockedChannels: {');
    for i = length(pulseMapGlobalStructure(this.ptr).lockedChannels) - 1
        fprintf(1, '''%s'', \n', pulseMapGlobalStructure(this.ptr).lockedChannels{i});
    end
    fprintf(1, '''%s''}\n', pulseMapGlobalStructure(this.ptr).lockedChannels{end});
end
fprintf(1, '\n');

return;

%--------------------------------------------------------------------------------
function printMap(map)
for i = 1 : size(map, 1)
    fprintf(1, '\t\t''%s'': ', map{i, 1});
    if ischar(map{i, 2})
        fprintf(1, '''%s''\n', map{i, 2});
    elseif iscell(map{i, 2})
        fprintf(1, '{@%s, ...}\n', func2str(map{i, 2}{1}));
    elseif strcmpi(class(map{i, 2}), 'function_handle')
        fprintf(1, '@%s\n', func2str(map{i, 2}));
    elseif strcmpi(class(map{i, 2}), 'signalobject')
        fprintf(1, '@signalObject (''%s'')\n', get(map{i, 2}, 'name'));
    else
        fprintf(1, 'INVALID_DATASOURCE (''%s'')\n', class(map{i, 2}));
    end 
end

return;
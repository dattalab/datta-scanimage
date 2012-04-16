% mapper_loadMapPattern - Load the currently selected map pattern from disk.
%
% SYNTAX
%  mapper_loadMapPattern(hObject)
%    hObject - The handle to the mapper program.
%
% NOTES
%  This was refactored from mapper.m/loadMapPattern.
%
% CHANGES
%
% Created 10/23/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function pattern = mapper_loadMapPattern(hObject)

[mapPatternDirectory, mapPattern] = getLocalBatch(progmanager, hObject, 'mapPatternDirectory', 'mapPattern');

pattern = [];

%TO020306B - Only do this if a map pattern is selected.
if ~isempty(mapPattern) && exist(mapPatternDirectory, 'dir') == 7
    realPath = path;
    addpath(mapPatternDirectory);
    try
        pattern = eval(['map' mapPattern '(0, 0);']);
    catch
        pattern = eval(['map' mapPattern ';']);
    end
    path(realPath);
end

return;
% mapper_getMapPattern - Return the current map pattern array, based on all the Mapper settings.
%
% SYNTAX
%  mapPatternArray = mapper_getMapPattern(hObject);
%    hObject - The handle to the mapper program.
%    mapPatternArray - The rotated and flipped map pattern.
%
% NOTES
%  This was refactored from mapper_getMirrorVoltages.
%
% TODO
%
% CHANGES
%
% Created 6/3/08 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function mapPatternArray = mapper_getMapPattern(hObject)

[mapPattern, spatialRotation, patternFlip, patternRotation] = getLocalBatch(progmanager, hObject, ...
    'mapPattern', 'spatialRotation', 'patternFlip', 'patternRotation');

%TO031006C
mapPatternArray = mapper_loadMapPattern(hObject);

if isempty(mapPatternArray)
    return;
end

%TO032906B - Implement pattern flipping and order rotation. -- Tim O'Connor 3/29/06
if patternFlip
    mapPatternArray = flipdim(mapPatternArray, 2);
end

switch patternRotation
    case '0'
        %Do nothing.
    case '90'
        mapPatternArray = rot90(mapPatternArray, 1);
    case '180'
        mapPatternArray = rot90(mapPatternArray, 2);
    case '270'
        mapPatternArray = rot90(mapPatternArray, 3);
    otherwise
        errordlg(sprintf('Invalid pattern rotation value: %s', patternRotation));
        return;
end
% fprintf(1, '\n\n----------\n''loaded'' pattern: \n'); disp(pattern);
%Apply these "hidden" transformations after having saved the pattern to the header. Rows count going down, columns count going right.
% mapPatternArray = flipdim(mapPatternArray, 1);

return;
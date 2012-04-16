% mapper_newCell_userFcn - Implement externally initiated new cell functionality.
%
% SYNTAX
%  mapper_newCell_userFcn
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 10/4/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function mapper_newCell_userFcn(varargin)

if ~isempty(varargin)
    hObject = varargin{1};
else
    hObject = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
end

setLocalBatch(progmanager, hObject, 'mapNumber', 1, 'flashNumber', 1, 'imageCounter', 1, ...
    'soma1Coordinates', [], 'soma2Coordinates', [], 'soma1x', [], 'soma1y', [], 'soma2x', [], 'soma2y', []);

pos = get(hObject, 'Position');
mapper('updateDisplay', hObject);
set(hObject, 'Position', pos);

return;
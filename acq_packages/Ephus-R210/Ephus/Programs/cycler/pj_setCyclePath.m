% pj_setCyclePath - Set the path to the cycle files, update the GUI accordingly.
%
% SYNTAX
%  pj_setCyclePath(hObject)
%  pj_setCyclePath(hObject, cyclePath)
%    hObject - The program handle.
%    cyclePath - The new cycle path.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO090506J - Iterate over found files to populate the available cycle list. -- Tim O'Connor 9/5/06
%
% Created 8/29/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_setCyclePath(hObject, varargin)

if isempty(varargin)
    p = getLocal(progmanager, hObject, 'cyclePath');
else
    p = varargin{1};
    setLocal(progmanager, hObject, 'cyclePath', p);
end

pulseJackerFiles = dir(fullfile(p, '*.pj'));
if ~isempty(pulseJackerFiles)
    %TO090506J
    cycleNames = {''};
    for i = 1 : length(pulseJackerFiles)
        if ~strcmpi(pulseJackerFiles(i).name, '.') & ~strcmpi(pulseJackerFiles(i).name, '..')
            cycleNames{length(cycleNames) + 1} = pulseJackerFiles(i).name(1 : end - 3);
        end
    end
else
    cycleNames = {''};
end
setLocalGh(progmanager, hObject, 'cycleName', 'String', cycleNames);
setDefaultCacheValue(progmanager, 'cyclePath', p);

return;
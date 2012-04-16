% pj_setPulsePath - Set the path to the pulse files, update the GUI accordingly.
%
% SYNTAX
%  pj_setPulsePath(hObject)
%  pj_setPulsePath(hObject, pulsePath)
%    hObject - The program handle.
%    pulsePath - The new cycle path.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO102007A - Default to the cached pulsePath when choosing a pulse directory. -- Tim O'Connor 10/20/07
%
% Created 8/29/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_setPulsePath(hObject, varargin)

if isempty(varargin)
    p = getLocal(progmanager, hObject, 'pulsePath');
    if isempty(p)
        p = getDefaultCacheDirectory(progmanager, 'pulseDir');
    end
    p = uigetdir(p, 'Select pulse directory.');
    if length(p) == 1
        if p == 0
            return;
        end
    end
else
    p = varargin{1};
end

setLocal(progmanager, hObject, 'pulsePath', p);
setDefaultCacheValue(progmanager, 'pulsePath', p);

pulseSetNames = {''};
d = dir(p);
for i = 1 : length(d)
    if strcmpi(d(i).name, '.') || strcmpi(d(i).name, '..')
        continue;
    end
    if d(i).isdir
        pulseSetNames{length(pulseSetNames) + 1} = d(i).name;
    end
end
setLocalGh(progmanager, hObject, 'pulseSetName', 'String', pulseSetNames);

pj_currentChannel(hObject);

return;
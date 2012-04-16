% pj_loadCycle - Load a pre-existing cycle definition.
%
% SYNTAX
%  pj_loadCycle(hObject)
%  pj_loadCycle(hObject, filename)
%    hObject - The program handle.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO090506K - Make sure a pulse directory has been selected. -- Tim O'Connor 9/5/06
%
% Created 8/28/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_loadCycle(hObject, varargin)

if isempty(varargin)
    [f, p] = uigetfile(fullfile(getDefaultCacheDirectory(progmanager, 'cyclePath'), '*.pj'));
    if length(f) == 1
        if f == 0
            if length(p) == 1
                if p == 0
                    return;
                end
            end
        end
    end
    if ~endsWithIgnoreCase(f, '.pj')
        f = [f '.pj'];
    end
else
    [p, f, ext] = fileparts(varargin{1});
    f = [f ext];
end

%TO090506K - Make sure a pulse directory has been selected. -- Tim O'Connor 9/5/06
pulsePath = getLocal(progmanager, hObject, 'pulsePath');
if exist(pulsePath) ~= 7
    pj_setPulsePath(hObject);
end

pj_setCyclePath(hObject, p);

savedInformation = load(fullfile(p, f), '-mat');
positions = savedInformation.positions;
setLocalBatch(progmanager, hObject, 'cyclePath', p, 'cycleName', f(1 : end - 3), 'positions', positions, 'currentPosition', 0);
pj_selectCycle(hObject);

return;
% pj_new - Create a new pulseJacker cycle.
%
% SYNTAX
%  successful = pj_new(hObject)
%  successful = pj_new(hObject, cycleName)
%    hObject - The program handle.
%    cycleName - The name of the cycle to be created.
%                The user will be prompted if this is not specified.
%                This is just a name, not a fully-qualified path. The new cycle will be placed with existing cycles.
%    successful - 1 if a new cycle is created, 0 otherwise.
%                 This can be used to detect if a cancellation was issued by the user.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO060108F - Added the successful return value. -- Tim O'Connor 6/1/08
%  TO060308B - Allow a new cycle's name to be specified as an argument. -- Tim O'Connor 6/3/08
%
% Created 8/25/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function successful = pj_new(hObject, varargin)

successful = 0;%%TO060108

if isempty(varargin)
    [f, p] = uiputfile(fullfile(getDefaultCacheDirectory(progmanager, 'cyclePath'), '*.pj'));
    if length(f) == 1
        if f == 0
            if length(p) == 1
                if p == 0
                    return;
                end
            end
        end
    end
else
    cycleName = varargin{1};
    if ~endsWithIgnoreCase(cycleName, '.pj')
        cycleName = [cycleName '.pj'];
    end
    p = getDefaultCacheDirectory(progmanager, 'cyclePath');
    if exist(fullfile(p, cycleName), 'file') == 2
        yOrN = questdlg(sprintf('Cycle ''%s'' already exists. Overwrite?', fullfile(p, cycleName)), 'Confirm Overwrite', 'Yes', 'No', 'No');
        if ~strcmpi(yOrN, 'Yes')
            return;
        end
    end
    f = cycleName;
end
if ~endsWithIgnoreCase(f, '.pj')
    if exist(fullfile(p, [f '.pj'])) == 2
        yOrN = questdlg(sprintf('%s already exists. Overwrite?', f), 'Overwrite?', 'Yes', 'No', 'No');
        if strcmpi(yOrN, 'No')
            return;
        end
    end
    f = [f '.pj'];
end

pj_setCyclePath(hObject, p);

cycleNames = get(getLocalGh(progmanager, hObject, 'cycleName'), 'String');
cycleNames{length(cycleNames) + 1} = f(1 : end - 3);

setLocalGh(progmanager, hObject, 'cycleName', 'String', unique(cycleNames));

pj_saveCycle(hObject, fullfile(p, f));

setLocalBatch(progmanager, hObject, 'cycleName', f(1 : end - 3), 'positions', [], 'currentPosition', 0);
pj_selectCycle(hObject);

successful = 1;%TO060108

return;
% pj_saveCycle - Save the current cycle.
%
% SYNTAX
%  pj_saveCycle(hObject)
%  pj_saveCycle(hObject, fileName)
%    hObject - The program handle.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/29/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_saveCycle(hObject, varargin)

[f, p, positions] = getLocalBatch(progmanager, hObject, 'cycleName', 'cyclePath', 'positions');

if isempty(varargin)
    if isempty(f)
        warning('No cycle name defined. Aborting save...');
        return;
    end
    filename = fullfile(p, [f '.pj']);
else
    filename = varargin{1};
    if ~endsWithIgnoreCase(filename, '.pj')
        filename = [filename '.pj'];
    end
end

metaInfo.saveTime = clock;
metaInfo.saveCallStack = getStackTraceString;
saveCompatible(filename, 'positions', 'metaInfo', '-mat');

return;
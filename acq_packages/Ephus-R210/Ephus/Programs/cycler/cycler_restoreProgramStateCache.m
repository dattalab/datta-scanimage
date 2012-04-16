% cycler_restoreProgramStateCache - Returns all cycled programs to their original (precycle) state.
%
% SYNTAX
%  cycler_restoreProgramStateCache(hObject)
%
% USAGE
%
% NOTES
%  See TO062306E.
%
% CHANGES
%  TO062306E: Cache the initial states of programs, to reset them after the cycle is disabled. -- Tim O'Connor 6/23/06
%
% Created 9/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function cycler_restoreProgramStateCache(hObject)

[programInitialStateCache enable] = getLocalBatch(progmanager, hObject, 'programInitialStateCache', 'enable');
if ~enable
    for i = 1 : size(programInitialStateCache, 1)
        try
            setProgramSettings(progmanager, programInitialStateCache{i, 2}, programInitialStateCache{i, 3});
            fields = fieldnames(programInitialStateCache{i, 3});
            for j = 1 : length(fields)
                delete(programInitialStateCache{i, 3}.(fields{j}));
            end
        catch
            warning('Cycler - Failed to restore cache of initial state of program ''%s'': %s', programInitialStateCache{i, 1}, lasterr);
        end
    end
end

setLocal(progmanager, hObject, 'programInitialStateCache', {});

return;
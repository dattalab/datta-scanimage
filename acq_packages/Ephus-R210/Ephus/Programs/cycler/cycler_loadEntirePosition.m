% cycler_loadEntirePosition - Loads all configurations in the current cycle position.
%
% SYNTAX
%  cycler_loadEntirePosition(hObject)
%  cycler_loadEntirePosition(hObject, eventdata)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO120205F: Changed file extension to be compatible with @progmanager's saved program settings. -- Tim O'Connor 12/2/05
%  TO062306E: Cache the initial states of programs, to reset them after the cycle is disabled. -- Tim O'Connor 6/23/06
%  TO062806D: Delete settings once they've been loaded. -- Tim O'Connor 6/28/06
%  TO062806R: Accept eventdata, only because it's in the documentation, and that form may be called somewhere. -- Tim O'Connor 6/28/06
%  TO080406A: Print information about what is being loaded. -- Tim O'Connor 8/04/06
%
% Created 9/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function cycler_loadEntirePosition(hObject, varargin)
% fprintf(1, 'cycler_loadEntirePosition\n');

%TO062806R
if ~isempty(varargin)
    warning('DEPRECATED: cycler_loadEntirePosition(hObject, eventdata) has been removed in favor of cycler_loadEntirePosition(hObject).');
end

selectedConfigurations = getLocalGh(progmanager, hObject, 'selectedConfigurations', 'String');
[programInitialStateCache,  enable, verboseLoading, currentPosition] = getLocalBatch(progmanager, hObject, ...
    'programInitialStateCache', 'enable', 'verboseLoading', 'currentPosition');%TO080406A
cacheNeeded = 0;

if verboseLoading
    loadTimeStart = clock;
    fprintf(1, '%s - cycler: Loading position %s...\n', datestr(now), num2str(currentPosition));%TO080406A
end

for j = 1 : length(selectedConfigurations)
    if verboseLoading
        fprintf(1, '                               Mounting configuration ''%s''...\n', selectedConfigurations{j});%TO080406A
    end
    
    loaded = load(fullfile(getLocal(progmanager, hObject, 'pathname'), [getLocal(progmanager, hObject, 'cycleName') '_configurations'], ...
        [selectedConfigurations{j} '.settings']), '-mat');%TO120205F
    config = loaded.config;
    
    if ~ismember(lower(config.programName), lower(fieldnames(config.settings)))
        warning('Cycler configuration ''%s'' may have become corrupted.', getLocal(progmanager, hObject, 'cycleName'));
    end
    
    programs = getLocal(progmanager, hObject, 'programs');
    index = find(strcmpi({programs{:, 1}}, config.programName));
    if isempty(index)
        error('No program found with name ''%s''.', config.programName);
    elseif length(index) > 1
        warning('Multiple programs found with name ''%s''.', config.programName);
    end
    
    for i = 1 : length(index)
        if enable
            try
                if isempty(programInitialStateCache)
                    cacheIndex = 1;
                    cacheNeeded = 1;
                else
                    cacheIndex = find(strcmp({programInitialStateCache{:, 1}}, programs{index(i), 1}));
                    if isempty(cacheIndex)
                        cacheIndex = size(programInitialStateCache, 1) + 1;
                        cacheNeeded = 1;
                    end
                end
                
                if cacheNeeded
% fprintf(1, 'cycler_loadEntirePosition: Caching state of ''%s'' in programInitialStateCache{%s, :}\n', programs{index(i), 1}, num2str(cacheIndex));
                    programInitialStateCache{cacheIndex, 1} = programs{index(i), 1};
                    programInitialStateCache{cacheIndex, 2} = programs{index(i), 2};
                    programInitialStateCache{cacheIndex, 3} = getProgramSettings(progmanager, programs{index(i), 2});
                end
            catch
                warning('Cycler - Failed to cache initial state of program ''%s'': %s', programs{index(i), 1}, lasterr);
            end
        end
        setProgramSettings(progmanager, programs{index(i), 2}, config.settings);
        %TO062806D
        fields = fieldnames(config.settings);
        for k = 1 : length(fields)
            delete(config.settings.(fields{k}));%TO062806D
        end
    end
end

if verboseLoading
    fprintf(1, '%s - cycler: Loaded position %s in %s seconds.\n\n', datestr(now), num2str(currentPosition), num2str(etime(clock, loadTimeStart)));%TO080406A
end

if cacheNeeded
    setLocal(progmanager, hObject, 'programInitialStateCache', programInitialStateCache);
end

return;
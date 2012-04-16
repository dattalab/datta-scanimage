% cycler_precacheEntireCycle - Load all cycle positions, in anticipation of a board-timed loop.
%
% SYNTAX
%   cycler_precacheEntireCycle(hObject)
%     hObject - Cycler program handle.
%
% NOTES
%  See TO062806C.
%
% CHANGES
%  TO062806D: Delete settings once they've been loaded. -- Tim O'Connor 6/28/06
%  TO070306B: The counter calculation needed to be corrected (in two places), rollover depends on `counter` not the loop index. -- Tim O'Connor 7/3/06
%  TO080306F: Update the screen once the operation is completed. -- Tim O'Connor 8/3/06
%
% Created 6/28/06 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function cycler_precacheEntireCycle(hObject)

wb = waitbar(0, 'Cycler: Precaching Entire Cycle...');
try
    fig = getParent(getLocal(progmanager, hObject, 'hObject'), 'figure');
    set(wb, 'Units', get(fig, 'Units'));
    cyclerPos = get(fig, 'Position');
    wbPos = get(wb, 'Position');
    wbPos(1:2) = cyclerPos(1:2) + 0.5 * [0 cyclerPos(4)];
    set(wb, 'Position', wbPos);
catch
    fprintf(1, 'cycler_precacheEntireCycle - Failed to set waitbar position: %s\n', lasterr);
end

[programInitialStateCache, enable, positions, currentPosition, positionIterationsArray] = ...
    getLocalBatch(progmanager, hObject, 'programInitialStateCache', 'enable', 'positions', 'currentPosition', 'positionIterationsArray');
programUpdateList = {};

cacheNeeded = 0;

lm = loopManager;
loopIterations = get(lm, 'iterations');
completedConfigurations = 0;
totalConfigurations = 0;
rollover = 0;
counter = 1;
for i = currentPosition : loopIterations + currentPosition - 1
    counter = i - length(positions) * rollover;%TO070306B
    if counter >= length(positions)
        rollover = rollover + 1;
    end

    totalConfigurations = totalConfigurations + length(positions{counter}) * positionIterationsArray(counter);
    if totalConfigurations >= loopIterations
        totalConfigurations = loopIterations;
    end
end

%Iterate over positions.
rollover = 0;
for k = currentPosition : loopIterations + currentPosition - 1
    counter = k - length(positions) * rollover;%TO070306B
    if counter >= length(positions)
        rollover = rollover + 1;
    end
    setLocal(progmanager, hObject, 'currentPosition', counter);
    cycler_currentPosition_Callback(hObject, [], [], 0);%See TO062806H in cycler_currentPosition_Callback.m.
    selectedConfigurations = getLocalGh(progmanager, hObject, 'selectedConfigurations', 'String');

    %Iterate over configurations (per position).
    for j = 1 : length(selectedConfigurations)
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
            
            %Don't forget to take into account the iterations of any given position.
            for iterations = 1 : positionIterationsArray(counter)
                progName = getProgramName(progmanager, programs{index(i), 2});
                if isempty(programUpdateList)
                    programUpdateList{1} = progName;
                    programUpdateList{2} = programs{index(i), 2};
                    cacheProgramSettingsOperationBegin(progmanager, programs{index(i), 2});%TO062806M
                else
                    nameIndex = find(strcmp({programUpdateList{:, 1}}, progName));
                    if isempty(nameIndex)
                        programUpdateList{size(programUpdateList, 1) + 1, 1} = progName;
                        programUpdateList{size(programUpdateList, 1), 2} = programs{index(i), 2};
                        cacheProgramSettingsOperationBegin(progmanager, programs{index(i), 2});%TO062806M
                    end
                end
                cacheProgramSettings(progmanager, programs{index(i), 2}, config.settings);
                completedConfigurations = completedConfigurations + 1;
                waitbar(completedConfigurations / totalConfigurations, wb);
            end
            
            %TO062806D
            fields = fieldnames(config.settings);
            for m = 1 : length(fields)
                delete(config.settings.(fields{m}));%TO062806D
            end
        end
    end
end

%Make sure the position is ready for the start of the next cycle.
counter = currentPosition + loopIterations - length(positions) * rollover;
if counter > length(positions)
    counter = 1;
end
setLocalBatch(progmanager, hObject, 'currentPosition', counter, 'refreshPosition', 1);
cycler_currentPosition_Callback(hObject, [], [], 0);%See TO062806H in cycler_currentPosition_Callback.m.

if cacheNeeded
    setLocal(progmanager, hObject, 'programInitialStateCache', programInitialStateCache);
end

for i = 1 : size(programUpdateList, 1)
    cacheProgramSettingsOperationComplete(progmanager, programUpdateList{i, 2});
end

%TO080306F
drawnow;

close(wb);

return;
% xsg_getPath - Get the save path, which may include augmentations to the directory.
%
%  SYNTAX
%   directory = xsg_getDirectory
%
%  CHANGES
%   TO042806A: Allow option to concatenate initials and experiment #. -- Tim O'Connor 4/28/06
%
%  NOTES
%   See TO042106C, all calls to xsg_getDirectory should now call this function instead.
%   This function assures that subdirectories exist, but will not work if the base directory does not exist.
%
% Created 4/21/06 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function directory = xsg_getPath

hObject = xsg_getHandle;

[directory, experimentNumber, setID, addExperimentNumberToPath, addSetIDToPath, addInitialsToPath, initials, concatenateInitialsAndExpNum] = ...
    getLocalBatch(progmanager, xsg_getHandle, ...
    'directory', 'experimentNumber', 'setID', 'addExperimentNumberToPath', 'addSetIDToPath', 'addInitialsToPath', 'initials', 'concatenateInitialsAndExpNum');

%TO042806A
if concatenateInitialsAndExpNum
    if addInitialsToPath
        subdir = initials;
    else
        subdir = '';
    end
    if addExperimentNumberToPath
        subdir = [subdir experimentNumber];
    end
    if ~isempty(subdir)
        if exist(directory, 'dir') == 7
            d = fullfile(directory, subdir);
            if exist(d, 'dir') ~= 7
                [success, message, messageID] = mkdir(directory, subdir);
                if ~success
                    warning('xsg_getPath failed to create initials & experimentNumber subdirectory: %s - %s', messageID, message);
                end
            end
            
            directory = d;
        end
    end
else
    if addInitialsToPath
        d = fullfile(directory, initials);
        if exist(d) ~= 7
            [success, message, messageID] = mkdir(directory, initials);
            if ~success
                warning('xsg_getPath failed to create initials subdirectory: %s - %s', messageID, message);
            end
        end
        
        directory = d;
    end
    
    if addExperimentNumberToPath
        d = fullfile(directory, experimentNumber);
        if exist(d) ~= 7
            [success, message, messageID] = mkdir(directory, experimentNumber);
            if ~success
                warning('xsg_getPath failed to create experimentNumber subdirectory: %s - %s', messageID, message);
            end
        end
        
        directory = d;
    end
end

if addSetIDToPath
    d = fullfile(directory, setID);
    if exist(d) ~= 7
        [success, message, messageID] = mkdir(directory, setID);
        if ~success
            warning('xsg_getPath failed to create setID subdirectory: %s - %s', messageID, message);
        end
    end
    
    directory = d;
end

return;
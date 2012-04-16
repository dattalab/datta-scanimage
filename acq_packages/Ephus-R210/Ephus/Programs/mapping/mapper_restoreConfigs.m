% mapper_restoreConfigs - Restore configurations of all programs, after having modified them.
%
% SYNTAX
%  mapper_restoreConfigs(hObject)
%
% USAGE
%
% NOTES
%  See TO020206B (creation of this function).
%
% CHANGES
%  TO030706B: Added fine-grained error checking for configuration deletions. -- Tim O'Connor 3/7/06
%  TO032406A: Add more information to error messages and be more careful about only deleting valid objects. -- Tim O'Connor 3/24/06
%  TO042106C: Added optional configurability to the XSG. -- Tim O'Connor 4/21/06
%  TO053108B - Allow the mapper to work without the usual 'Big 3' programs. -- Tim O'Connor 5/31/08
%  VI061208A - Restore cached loopmanager settings here -- Vijay Iyer 6/12/08
%
% Created 2/2/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_restoreConfigs(hObject)
% fprintf(1, 'mapper_restoreConfigs\n');
[ephysConfig xsgConfig stimConfig acqConfig, xsgConfigurationEnabled, loopConfig] = getLocalBatch(progmanager, hObject, ...
    'ephysConfig', 'xsgConfig', 'stimConfig', 'acqConfig', 'xsgConfigurationEnabled','loopConfig'); 

% stopAllChannels(getDaqmanager);%FIX_ME!!!!!!!!!!!!!!!!!!!!

%TO053108B
xsgObj = xsg_getHandle;
ephysObj = [];
stimObj = [];
acqObj = [];
if isprogram(progmanager, 'ephys')
    ephysObj = getGlobal(progmanager, 'hObject', 'ephys', 'ephys');
end
if isprogram(progmanager, 'stimulator')
    stimObj = getGlobal(progmanager, 'hObject', 'stimulator', 'stimulator');
end
if isprogram(progmanager, 'acquirer')
    acqObj = getGlobal(progmanager, 'hObject', 'acquirer', 'acquirer');
end

if ~isempty(xsgConfig)
    if isfield(xsgConfig, 'xsg')
        if strcmpi(class(xsgConfig.xsg), 'settingsobject')
            try
                setLocal(progmanager, xsg_getHandle, 'configurationEnabled', 1);%TO042106C
                setProgramSettings(progmanager, xsgObj, xsgConfig);
                setLocal(progmanager, xsg_getHandle, 'configurationEnabled', xsgConfigurationEnabled);%TO042106C
            catch
                warning('Failed to reset configuration for xsg: %s', lasterr);%TO032406A
            end
            
            %TO030706B
            try
                delete(xsgConfig.xsg);
            catch
                warning('Failed to delete temporary configuration for xsg: %s', lasterr);
            end
        end
    end
end

if ~isempty(ephysConfig)
    if isfield(ephysConfig, 'ephys')
        if strcmpi(class(ephysConfig.ephys), 'settingsobject')
            try
                setProgramSettings(progmanager, ephysObj, ephysConfig);
            catch
                warning('Failed to reset configuration for ephys: %s', lasterr);%TO032406A
            end
            %TO030706B
            try
                delete(ephysConfig.ephys);
            catch
                warning('Failed to delete temporary configuration for ephys: %s', lasterr);
            end
        end
    end
end

if ~isempty(stimConfig)
    if isfield(stimConfig, 'stimulator')
        if strcmpi(class(stimConfig.stimulator), 'settingsobject')
            try
                setProgramSettings(progmanager, stimObj, stimConfig);
            catch
                warning('Failed to reset configuration for stimulator: %s', lasterr);%TO032406A
            end
            %TO030706B
            try
                delete(stimConfig.stimulator);
            catch
                warning('Failed to delete temporary configuration for stimulator: %s', lasterr);
            end
        end
    end
end

if ~isempty(acqConfig)
    if isfield(acqConfig, 'acquirer')
        if strcmpi(class(acqConfig.acquirer), 'settingsobject')
            try
                setProgramSettings(progmanager, acqObj, acqConfig);
            catch
                warning('Failed to reset configuration for acquirer: %s', lasterr);%TO032406A
            end
            %TO030706B
            try
                delete(acqConfig.acquirer);
            catch
                warning('Failed to delete temporary configuration for acquirer: %s', lasterr);
            end
        end
    end
end

%Restore cached loopmanager settings (VI061208A)
lm = loopManager;
set(lm,'preciseTimeMode',loopConfig.preciseTimeMode);
set(lm,'busyMode',loopConfig.busyMode);
set(lm,'iterations',loopConfig.iterations);
set(lm,'interval',loopConfig.interval);
%%%%%


%Clear any previous ones, in case they're memory leak prone.
setLocalBatch(progmanager, hObject, 'ephysConfig', [], 'xsgConfig', [], 'stimConfig', [], 'acqConfig', []);

return;
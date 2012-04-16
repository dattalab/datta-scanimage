% mapper_captureConfigs - Marshall configurations of all programs, before modifying them.
%
% SYNTAX
%  mapper_captureConfigs(hObject)
%
% USAGE
%
% NOTES
%  See TO020206B (creation of this function).
%
% CHANGES
%  TO030706B: Added fine-grained error checking for configuration deletions. Fixed typo (changed `xsgConfig` to `acqConfig`). -- Tim O'Connor 3/7/06
%  TO032406A: Be more careful about only deleting valid objects. -- Tim O'Connor 3/24/06
%  TO042106C: Added optional configurability to the XSG. -- Tim O'Connor 4/21/06
%  TO053108B - Allow the mapper to work without the usual 'Big 3' programs. -- Tim O'Connor 5/31/08
%  VI061208A - Cache loopmanager settings here -- Vijay Iyer 6/12/08
%
% Created 2/2/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_captureConfigs(hObject)
% fprintf(1, 'mapper_captureConfigs\n');
%Clear any previous ones, in case they're memory leak prone.
[ephysConfig xsgConfig stimConfig acqConfig loopConfig] = getLocalBatch(progmanager, hObject, ...
    'ephysConfig', 'xsgConfig', 'stimConfig', 'acqConfig', 'loopConfig');

%TO030706B
if ~isempty(ephysConfig)
    if isfield(ephysConfig, 'ephys')
        if strcmpi(class(ephysConfig.ephys), 'settingsobject')
            try
                delete(ephysConfig.ephys);
            catch
                warning('Error deleting ephys configuration: %s', lasterr);
            end
        end
    end
end
if ~isempty(xsgConfig)
    if isfield(xsgConfig, 'xsg')
        if strcmpi(class(xsgConfig.xsg), 'settingsobject')
            try
                delete(xsgConfig.xsg);
            catch
                warning('Error deleting xsg configuration: %s', lasterr);
            end
        end
    end
end
if ~isempty(stimConfig)
    if isfield(stimConfig, 'stimulator')
        if strcmpi(class(stimConfig.stimulator), 'settingsobject')
            try
                delete(stimConfig.stimulator);
            catch
                warning('Error deleting stimulator configuration: %s', lasterr);
            end
        end
    end
end
if ~isempty(acqConfig) %TO030706B
    if isfield(acqConfig, 'acquirer')
        if strcmpi(class(acqConfig.acquirer), 'settingsobject')
            try
                delete(acqConfig.acquirer);
            catch
                warning('Error deleting acquirer configuration: %s', lasterr);
            end
        end
    end
end

%TO053108B
xsgObj = xsg_getHandle;
xsgConfig = getProgramSettings(progmanager, xsgObj);
xsgConfigurationEnabled = getLocal(progmanager, xsg_getHandle, 'configurationEnabled');%TO042106C

if isprogram(progmanager, 'ephys')
    ephysObj = getGlobal(progmanager, 'hObject', 'ephys', 'ephys');
    ephysConfig = getProgramSettings(progmanager, ephysObj);
else
    ephysConfig = [];
end
if isprogram(progmanager, 'stimulator')
    stimObj = getGlobal(progmanager, 'hObject', 'stimulator', 'stimulator');
    stimConfig = getProgramSettings(progmanager, stimObj);
else
    stimConfig = [];
end
if isprogram(progmanager, 'acquirer')
    acqObj = getGlobal(progmanager, 'hObject', 'acquirer', 'acquirer');
    acqConfig = getProgramSettings(progmanager, acqObj);
else
    acqConfig = [];
end

%Cache loopmanager settings (VI061208A)
lm = loopManager;
loopConfig.preciseTimeMode = get(lm,'preciseTimeMode');
loopConfig.busyMode = get(lm,'busyMode');
loopConfig.iterations = get(lm,'iterations');
loopConfig.interval = get(lm,'interval');

setLocalBatch(progmanager, hObject, 'ephysConfig', ephysConfig, 'xsgConfig', xsgConfig, ...
    'stimConfig', stimConfig, 'acqConfig', acqConfig, 'xsgConfigurationEnabled', xsgConfigurationEnabled,'loopConfig',loopConfig);

return;
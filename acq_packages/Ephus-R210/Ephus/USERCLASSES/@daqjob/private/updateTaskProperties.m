% @daqjob/private/updateTaskProperties - . Ensures that task properties match their counterparts in the @daqjob instance.
%
% SYNTAX
%  updateTaskProperties(job, deviceName, subsystemName, task)
%  updateTaskProperties(job, deviceName, subsystemName, task, property)
%   job - @daqjob instance.
%   subsystemName - The NIDAQmx subsystem for which a nimex task is required.
%                   Example: '/dev1/ai0'
%   task - The task whose properties need to be updated. Must correspond to subsystemName.
%   property - The NIMEX task property to be updated. May be a cell array of property names. 
%              Allowable values: 'triggerSource', 'clockSource', 'clockExportTerminal'
%              Default: 'triggerSource', 'clockSource', 'clockExportTerminal'
%
% NOTES
%  When this took an index as an argument, index was 'The index of the task in this @daqjob's taskMap.' and
%  was only used to look-up the deviceName. The deviceName is actually unnecessary, the subsystemName is sufficient. -- Tim O'Connor 7/30/08
%
% CHANGES
%  TO033008D - Created the clockDestination field. -- Tim O'Connor 3/30/08
%  TO033008E - Refactored `updateTaskProperties` out of `getOrCreateTask`. -- Tim O'Connor 3/30/08
%  TO050508C - Reworked the clock synchronization to allow for a sampleClock and a timebaseClock (20MHz). -- Tim O'Connor 5/5/08
%  TO050508E - Handle device names with more than two slashes when setting a relative clock source. -- Tim O'Connor 5/5/08
%  TO050508G - Digital input/output tasks can't be directly triggered. Instead, trigger their clock source. -- Tim O'Connor 5/5/08
%  TO073008C - Changed arguments from (this, index, subsystemName, task) to (this, subsystemName, task, property). -- Tim O'Connor 7/30/08
%
% Created
%  Timothy O'Connor 7/30/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function updateTaskProperties(this, subsystemName, task, varargin)
global daqjobGlobalStructure;

triggerSource = '';
clockSource = '';
clockExportTerminal = '';

%TO101507C %TO050508E
%TO050508G - Don't apply a trigger condition to digital lines. -- Tim O'Connor 5/5/08
if isempty(strfind(lower(subsystemName), 'line'))
    if ~isempty(daqjobGlobalStructure(this.ptr).triggerDestination)
        %deviceName = daqjobGlobalStructure(this.ptr).taskMap{index, 1};
        idx = find(subsystemName(2:end) == '/') + 1;%Add 1 because we're skipping the first character, which might be a superfluous '/'.
        if isempty(idx)
            error('@daqjob/private/updateTaskProperties: Failed to parse ''%s'' to determine root (device name) for setting of relative sampleClockDestination specifier.', subsystemName);
        end
        idx = idx(1) + 1;
%         idx = length(subsystemName);
%         for i = idx : - 1 : 1
%             if subsystemName(i) == '/'
%                 break;
%             else
%                 idx = i;
%             end
%         end
        triggerSource = [subsystemName(1 : idx-1) daqjobGlobalStructure(this.ptr).triggerDestination];
    end
end

%TO033008D %TO050508C %TO050508E
if ~isempty(daqjobGlobalStructure(this.ptr).sampleClockDestination)
    %deviceName = daqjobGlobalStructure(this.ptr).taskMap{index, 1};
    idx = find(subsystemName(2:end) == '/') + 1;%Add 1 because we're skipping the first character, which might be a superfluous '/'.
    if isempty(idx)
        error('@daqjob/private/updateTaskProperties: Failed to parse ''%s'' to determine root (device name) for setting of relative sampleClockDestination specifier.', subsystemName);
    end
    idx = idx(1) + 1;
%     idx = length(subsystemName);
%     for i = idx : - 1 : 1
%         if subsystemName(i) == '/'
%             break;
%         else
%             idx = i;
%         end
%     end
    clockSource = [subsystemName(1 : idx-1) daqjobGlobalStructure(this.ptr).sampleClockDestination];
end

%TO050508C
% if ~isempty(daqjobGlobalStructure(this.ptr).clockOrigin)
%     idx = find(subsystemName ==  '/');
%     if idx(1) ~= 1
%         idx = idx(1);
%     elseif length(idx) > 1
%         idx = idx(2);
%     end
%     subSystemDevice = subsystemName(1:idx);
%     
%     idx = find(daqjobGlobalStructure(this.ptr).clockOrigin ==  '/');
%     if idx(1) ~= 1
%         idx = idx(1);
%     elseif length(idx) > 1
%         idx = idx(2);
%     end
%     clockOriginDevice = daqjobGlobalStructure(this.ptr).clockOrigin(1:idx);
% 
%     if strcmpi(clockOriginDevice, subSystemDevice)
%         clockExportTerminal = daqjobGlobalStructure(this.ptr).clockOrigin;
%     end
% end

%TO033008D - Update properties en-masse.
if isempty(varargin)
    nimex_setTaskProperty(task, 'triggerSource', triggerSource, 'clockSource', clockSource, 'clockExportTerminal', clockExportTerminal);
else
    properties = varargin{1};
    for i = 1 : length(properties)
        switch lower(properties{i})
            case 'triggersource'
                nimex_setTaskProperty(task, 'triggerSource', triggerSource);
            case 'clocksource'
                nimex_setTaskProperty(task, 'clockSource', clockSource);
            case 'clockexportterminal'
                nimex_setTaskProperty(task, 'clockExportTerminal', clockExportTerminal);
            otherwise
                error('Unrecognized @daqjob task property ''%s''.', properties{i});
        end
    end
end

return;